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

- (NSString *) description
{
    return [NSString stringWithFormat:@"url = %@\nisPaused = %d\ncurrentSpeed = %.2f\npacket = {\n%@\n}\nbackup = {\n%@\n}",
            _url,
            isPaused,
            currentDownloadSpeed,
            packet,
            backupPacket];
}

- (void) startDownload
{
    if (isPaused)
    {
        packet = [[iDownloadPack alloc] init];
        packet.data = [[NSMutableData alloc] init];
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
        packet.data = [[NSMutableData alloc] init];
        packet.request = [[NSMutableURLRequest alloc] initWithURL:_url];
//        [packet.request setValue:[NSString stringWithFormat:@"bytes=%lld-", backupPacket.currentLength]
//              forHTTPHeaderField:@"RANGE"];
//        [packet.request setValue:@"" forHTTPHeaderField:@"IF-RANGE"];
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
    isPaused = YES;
    [packet.connection cancel];
    
    if (backupPacket)
        [backupPacket appendProgressWithPack:packet];
    else
        backupPacket = packet;

    if (_delegate)
    {
        [_delegate didPausedDownload];
    }
    
    if (_storageDelegate)
    {
        [_storageDelegate reportData:[backupPacket buffToWriteWithBackup:nil isComplete:YES]];
        [_storageDelegate reportComplete];
    }
    
    packet = nil;
    NSLog(@"%s-[%@] is canceled, current progress [%.2fk/%.2fk] with [%.2fs], speed [%.2fk/s]", __FUNCTION__,
          _key, [backupPacket currentSizeKBWithBackup:NULL], [backupPacket totalSizeKBWithBackup:NULL], backupPacket.downloadTime, [backupPacket speedKBPSWithBackup:NULL]);
}

- (void) endDownload
{
    isPaused = NO;
    [packet.connection cancel];
    backupPacket = nil;
    packet = [[iDownloadPack alloc] init];
}

- (void) succeedDownload
{
    isPaused = NO;
    [packet.connection cancel];
    if (backupPacket)
        [backupPacket appendProgressWithPack:packet];
    else
        backupPacket = packet;
    packet = nil;
}

- (void) idle
{
    if (_delegate)
    {
        if (packet)
        {
            [_delegate didGetDownloadExpectSize:[packet totalSizeKBWithBackup:backupPacket]];
            [_delegate didFinishDownloadDataSize:[packet currentSizeKBWithBackup:backupPacket]];
            [_delegate didChangeDownloadSpeedTo:[packet speedKBPSWithBackup:backupPacket] withKey:_key];
            [_delegate didChangeDownloadProgress:[packet progressWithBackup:backupPacket] withKey:_key];
        }
        else
        {
            [_delegate didGetDownloadExpectSize:[backupPacket totalSizeKBWithBackup:nil]];
            [_delegate didFinishDownloadDataSize:[backupPacket currentSizeKBWithBackup:nil]];
            [_delegate didChangeDownloadSpeedTo:[backupPacket speedKBPSWithBackup:nil] withKey:_key];
            [_delegate didChangeDownloadProgress:[backupPacket progressWithBackup:nil] withKey:_key];

        }
        
    }
}

- (double) getDownloadTime
{
    if (packet)
    {
        return [packet timeWithBackup:backupPacket];
    }
    
    return backupPacket.downloadTime;
}

- (double) getDownloadSizeKB
{
    if (packet)
    {
        return [packet totalSizeKBWithBackup:backupPacket];
    }
    
    return [backupPacket totalSizeKBWithBackup:nil];
}

- (NSDictionary *) exportToDictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:_url forKey:@"url"];
    [dic setValue:_key forKey:@"key"];
    [dic setValue:[NSNumber numberWithDouble:currentDownloadSpeed] forKey:@"speed"];
    [dic setValue:[NSNumber numberWithBool:isPaused] forKey:@"isPaused"];
    
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
    [downloader setIsPuased: [(NSNumber *)[dic objectForKey:@"isPaused"] boolValue]];
    
    iDownloadPack *tempPack = [[iDownloadPack alloc] init];
    NSDictionary *packDic = [dic objectForKey:@"packet"];
    tempPack.currentLength = [(NSNumber *)[packDic valueForKey:@"currentLength"] longLongValue];
    tempPack.totalLength = [(NSNumber *)[packDic valueForKey:@"totalLength"] longLongValue];
    tempPack.currentTime = [(NSNumber *)[packDic valueForKey:@"currentTime"] doubleValue];
    tempPack.startTime = [(NSNumber *)[packDic valueForKey:@"startTime"] doubleValue];
    tempPack.backupTime = [(NSNumber *)[packDic valueForKey:@"backupTime"] doubleValue];

    [downloader setBackupPacket:tempPack];
    return downloader;
}

#pragma mark - privates for import from file

- (void) setIsPuased : (bool) paused
{
    isPaused = paused;
}

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
//        NSLog(@"%s-[%@] received data [%.2fk], current speed [%.2fk/s], current size [%.2fk/%.2fk]",
//              __FUNCTION__, _key, (double) [data length] / 1024.0f, _speed,
//              [packet currentSizeKBWithBackup:backupPacket], [packet totalSizeKBWithBackup:backupPacket]);
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
    packet.currentTime = packet.startTime;
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
        [_delegate didFinishDownload];
        if ((int)[packet timeWithBackup:backupPacket] == 0) {
            
        }
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
