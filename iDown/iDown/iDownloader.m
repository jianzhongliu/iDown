//
//  iDownloader.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownloader.h"
#import "iDownloadPack.h"

@interface iDownloader () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@end

@implementation iDownloader
{
    NSURL *_url;
    iDownloadPack *packet;
    iDownloadPack *backupPacket;
    
    bool isPaused;    
    double currentDownloadSpeed;
}

@synthesize eventDelegate = _delegate;
@synthesize storageDelegate = _storageDelegate;
@synthesize key = _key;
@synthesize storageBuffLength = _storageBuffLength;

- (id) initWithUrl:(NSURL *)url andKey:(NSString *)key
{
    self = [super init];
    if (self)
    {
        _key = key;
        _url = url;

        isPaused = NO;
    }
    
    return self;
}

- (void) startDownload
{
    if (isPaused)
    {
        packet = [[iDownloadPack alloc] init];
        packet.request = [[NSMutableURLRequest alloc] initWithURL:_url];
        [packet.request setValue:[NSString stringWithFormat:@"bytes=%lld-", backupPacket.currentLength]
              forHTTPHeaderField:@"Range"];
        packet.connection = [[NSURLConnection alloc] initWithRequest:packet.request
                                                            delegate:self
                                                    startImmediately:NO];
        [packet.connection start];
        NSLog(@"%s-[%@] connection resume from byte [%lld]/[%lld]",
              __FUNCTION__, _key, backupPacket.currentLength, backupPacket.totalLength);
    }
    else
    {
        packet = [[iDownloadPack alloc] init];
        packet.request = [[NSMutableURLRequest alloc] initWithURL:_url];
        packet.connection = [[NSURLConnection alloc] initWithRequest:packet.request
                                                            delegate:self
                                                    startImmediately:NO];
        [packet.connection start];
        if (_delegate)
        {
            [_delegate didChangeDownloadProgress:0 withKey:_key];
        }
        NSLog(@"%s-[%@] connection started", __FUNCTION__, _key);
    }
}

- (void) pauseDownload
{
    if (backupPacket)
        [backupPacket appendProgressWithPack:packet];
    else
        backupPacket = packet;
    
    isPaused = YES;
    
    [packet.connection cancel];
    if (_delegate)
    {
        [_delegate didPausedDownload];
    }
    NSLog(@"%s-[%@] is canceled, current progress [%.2fk/%.2fk] with [%.2fs], speed [%.2fk/s]", __FUNCTION__,
          _key, [backupPacket currentSizeKBWithBackup:NULL], [backupPacket totalSizeKBWithBackup:NULL], backupPacket.downloadTime, [backupPacket speedKBPSWithBackup:NULL]);
}

- (void) endDownload
{
    isPaused = NO;
    [packet.connection cancel];
}

#pragma mark - network

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if (_delegate)
    {
        [_delegate didFailedDownloadFile];
    }
    
    isPaused = NO;
    NSLog(@"%s-Connection to [%@] failed, error : %@", __FUNCTION__, [_url absoluteString], error);
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [packet.data appendData:data];
    packet.currentLength += [data length];
    packet.currentTime = [NSDate timeIntervalSinceReferenceDate];
    
    if (_delegate)
    {
        [_delegate didFinishDownloadDataSize: [packet currentSizeKBWithBackup:backupPacket]];
        [_delegate didChangeDownloadProgress: [packet progressWithBackup:backupPacket] withKey:_key];
        
        double _speed = [packet speedKBPSWithBackup:backupPacket];
        if (abs(_speed - currentDownloadSpeed) > 0.1)
        {
            [_delegate didChangeDownloadSpeedTo:_speed withKey:_key];
            currentDownloadSpeed = _speed;
        }
//        NSLog(@"%s-[%@] received data [%.2fk], current speed [%.2fk/s]", __FUNCTION__, _key, (double) [data length] / 1024.0, _speed);
    }
    
    if (_storageDelegate)
    {
        [_storageDelegate reportData:[packet buffToWriteWithBackup:backupPacket isComplete:NO]];
        packet.data = [[NSMutableData alloc] init];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *_res = (NSHTTPURLResponse *) response;
    if (_res)
    {
        NSLog(@"%s-[%@] received a %d status code", __FUNCTION__,
              _key, _res.statusCode);
    }
    
    packet.totalLength = [response expectedContentLength];
    packet.currentLength = 0;
    packet.startTime = [NSDate timeIntervalSinceReferenceDate];
    packet.data = [[NSMutableData alloc] init];
    
    if (_delegate)
    {
        [_delegate didChangeDownloadProgress: [packet progressWithBackup:backupPacket] withKey:_key];
        [_delegate didChangeDownloadSpeedTo: [packet speedKBPSWithBackup:backupPacket] withKey:_key];
        [_delegate didGetDownloadExpectSize: [packet totalSizeKBWithBackup:backupPacket]];
        NSLog(@"%s-[%@] get expected size [%.2fk], begin download", __FUNCTION__, _key, [packet totalSizeKBWithBackup:backupPacket]);
    }
    
    if (_storageDelegate)
    {
        [_storageDelegate reportFileName: [_res suggestedFilename]];
    }
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    packet.currentTime = [NSDate timeIntervalSinceReferenceDate];
    if (_delegate)
    {
        [_delegate didFinishDownloadDataSize: [packet currentSizeKBWithBackup:backupPacket]];
        [_delegate didChangeDownloadProgress: [packet progressWithBackup:backupPacket] withKey:_key];
        [_delegate didFinishDownloadData: packet.data withKey:_key];//to be detail discussed
        NSLog(@"%s-[%@] finished download, size [%.2fk], cost time [%.2fs], average speed [%.2fk/s]",
              __FUNCTION__, _key, [packet currentSizeKBWithBackup:backupPacket], [packet timeWithBackup:backupPacket], [packet speedKBPSWithBackup:backupPacket]);
    }
    
    if (_storageDelegate)
    {
        [_storageDelegate reportData:[packet buffToWriteWithBackup:backupPacket isComplete:YES]];
        [_storageDelegate reportComplete];
    }
}

@end
