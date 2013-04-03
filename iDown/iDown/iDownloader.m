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
              forHTTPHeaderField:@"RANGE"];
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
        [packet.request setValue:[NSString stringWithFormat:@"bytes=%lld-", backupPacket.currentLength]
              forHTTPHeaderField:@"RANGE"];
        [packet.request setValue:@"" forHTTPHeaderField:@"IF-RANGE"];
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
    backupPacket = nil;
    packet = nil;
}

- (NSDictionary *) exportToDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_url forKey:@"url"];
    [dic setValue:_key forKey:@"key"];
    [dic setValue:[NSNumber numberWithDouble:currentDownloadSpeed] forKey:@"speed"];
    
    NSMutableDictionary *packetDic = [[NSMutableDictionary alloc] init];
    [packetDic setValue:[NSNumber numberWithLongLong:backupPacket.currentLength] forKey:@"currentLength"];
    [packetDic setValue:[NSNumber numberWithLongLong:backupPacket.totalLength] forKey:@"totalLength"];
    [packetDic setValue:[NSNumber numberWithDouble:backupPacket.currentTime] forKey:@"currentTime"];
    [packetDic setValue:[NSNumber numberWithDouble:backupPacket.startTime] forKey:@"startTime"];
    [packetDic setValue:[NSNumber numberWithDouble:backupPacket.backupTime] forKey:@"backupTime"];

    [dic setValue:packetDic forKey:@"packet"];
    
    return dic;
}

+ (iDownloader *) importFromDictionary:(NSDictionary *)dic
{
    iDownloader *downloader = [[iDownloader alloc] initWithUrl:[dic valueForKey:@"url"]
                                                        andKey:[dic valueForKey:@"key"]];
    [downloader setSpeed: (NSNumber *)[dic objectForKey:@"speed"]];
    
    iDownloadPack *tempPack = [[iDownloadPack alloc] init];
    tempPack.currentLength = [(NSNumber *)[dic valueForKey:@"currentLength"] longLongValue];
    tempPack.totalLength = [(NSNumber *)[dic valueForKey:@"totalLength"] longLongValue];
    tempPack.currentTime = [(NSNumber *)[dic valueForKey:@"currentTime"] doubleValue];
    tempPack.startTime = [(NSNumber *)[dic valueForKey:@"startTime"] doubleValue];
    tempPack.backupTime = [(NSNumber *)[dic valueForKey:@"backupTime"] doubleValue];

    [downloader setBackupPacket:tempPack];
    return downloader;
}

#pragma mark - privates for import from file

- (void) setBackupPacket : (iDownloadPack *) backup
{
    backupPacket = backup;
}

- (void) setSpeed : (NSNumber *) speed
{
    currentDownloadSpeed = [speed doubleValue];
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
        NSLog(@"%s-[%@] received data [%.2fk], current speed [%.2fk/s], current size [%.2fk/%.2fk]",
              __FUNCTION__, _key, (double) [data length] / 1024.0f, _speed,
              [packet currentSizeKBWithBackup:backupPacket], [packet totalSizeKBWithBackup:backupPacket]);
    }
    
    if (_storageDelegate)
    {
        [_storageDelegate reportData:[packet buffToWriteWithBackup:backupPacket isComplete:NO]];
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *_res = (NSHTTPURLResponse *) response;
    if (_res)
    {
        NSLog(@"%s-[%@] received a %d status code", __FUNCTION__,
              _key, _res.statusCode);
        if (_res.statusCode == 206)
        {
            NSLog(@"%s-[%@] received a continuous download response, with content-length = [%@]",
                  __FUNCTION__, _key,
                  [[_res allHeaderFields] valueForKey:@"Content-Range"]);
        }
    }
    
    packet.totalLength = [response expectedContentLength];
    packet.currentLength = 0;
    packet.startTime = [NSDate timeIntervalSinceReferenceDate];
    packet.data = [[NSMutableData alloc] init];
    
    if (![packet checkValidWithBackup:backupPacket])
    {
        NSLog(@"%s-[%@] continuous download resume with a [%lld] length, check backup downloaded length [%lld] + resume total expected length [%lld] != backup total length [%lld], server may not support continuous download. Halt current downloading.",
              __FUNCTION__,
              _key,
              packet.totalLength,
              backupPacket.currentLength,
              packet.totalLength,
              backupPacket.totalLength);
        
        if (_delegate)
        {
            [_delegate didFailedDownloadFile];
        }
        if (_storageDelegate)
        {
            [_storageDelegate reportComplete];
        }
        
        return;
    }
    
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
