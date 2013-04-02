//
//  iDownloadPack.m
//  iDown
//
//  Created by David Tang on 13-4-1.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownloadPack.h"

@implementation iDownloadPack
{
    NSTimeInterval backupTime;
}

@synthesize request = _request;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize startTime = _startTime;
@synthesize currentTime = _currentTime;
@synthesize totalLength = _totalLength;
@synthesize currentLength = _currentLength;

- (id) init
{
    self = [super init];
    if (self)
    {
        backupTime = 0;
    }
    return self;
}

- (double) downloadTime
{
    return (double) (_currentTime - _startTime + backupTime);
}

- (double) downloadSpeed
{
    return (double) _currentLength / self.downloadTime;
}

- (double) progress
{
    return (double) _currentLength / (double) _totalLength;
}

- (double) currentSizeKBWithBackup:(iDownloadPack *)backupPack
{
    if (backupPack && backupPack.totalLength > 0)
        return (double) (_currentLength + backupPack.currentLength) / 1024.0f;
    
    return (double) _currentLength / 1024.0f;
}

- (double) totalSizeKBWithBackup:(iDownloadPack *)backupPack
{
    if (backupPack && backupPack.totalLength > 0)
        return (double) backupPack.totalLength / 1024.0f;
    
    return self.totalLength / 1024.0f;
}

- (double) timeWithBackup:(iDownloadPack *)backupPack
{
    if (backupPack)
        return self.downloadTime + backupPack.downloadTime;
    
    return self.downloadTime;
}

- (double) speedKBPSWithBackup:(iDownloadPack *)backupPack
{
    return [self currentSizeKBWithBackup:backupPack] / [self timeWithBackup:backupPack];
}

- (double) progressWithBackup:(iDownloadPack *)backupPack
{
    return [self currentSizeKBWithBackup:backupPack] / [self totalSizeKBWithBackup:backupPack];
}

- (bool) appendProgressWithPack:(iDownloadPack *)newPack
{
    if (newPack.totalLength + self.currentLength == self.totalLength)
    {
        self.currentLength += newPack.currentLength;
        backupTime = self.downloadTime;
        _currentTime = newPack.currentTime;
        _startTime = newPack.startTime;
        [_data appendData:newPack.data];
        return YES;
    }
    
    return NO;
}

@end
