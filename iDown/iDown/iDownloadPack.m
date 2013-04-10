//
//  iDownloadPack.m
//  iDown
//
//  Created by David Tang on 13-4-1.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownloadPack.h"

@implementation iDownloadPack

@synthesize request = _request;
@synthesize connection = _connection;
@synthesize data = _data;
@synthesize startTime = _startTime;
@synthesize currentTime = _currentTime;
@synthesize totalLength = _totalLength;
@synthesize currentLength = _currentLength;
@synthesize minSizeKBForStore = _minSizeKBForStore;
@synthesize backupTime = _backupTime;

- (id) init
{
    self = [super init];
    if (self)
    {
        _minSizeKBForStore = 500;
    }
    return self;
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"request = %@\nconnection = %@\ndata = [%d]\nstartTime = %.2f\ncurrentTime = %.2f\ncurrentLength = %.2f\ntotalLength = %.2f",
            [_request description],
            [_connection description],
            [_data length],
            _startTime,
            _currentTime,
            [self currentSizeKBWithBackup:nil],
            [self totalSizeKBWithBackup:nil]];
}

- (double) downloadTime
{
    return (double) (_currentTime - _startTime + _backupTime);
}

- (double) downloadSpeed
{
    return (double) _currentLength / self.downloadTime;
}

- (double) progress
{
    if (_totalLength == 0)
        return 0.0f;
    
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
    if ([self timeWithBackup:backupPack] == 0)
        return 0;
    
    return [self currentSizeKBWithBackup:backupPack] / [self timeWithBackup:backupPack];
}

- (double) progressWithBackup:(iDownloadPack *)backupPack
{
    double totalSizeKB = [self totalSizeKBWithBackup:backupPack];
    if (totalSizeKB == 0)
        return 0.0f;
    
    return [self currentSizeKBWithBackup:backupPack] / totalSizeKB;
}

- (bool) appendProgressWithPack:(iDownloadPack *)newPack
{
    if (newPack.totalLength + self.currentLength == self.totalLength)
    {
        self.currentLength += newPack.currentLength;
        _backupTime = self.downloadTime;
        _currentTime = newPack.currentTime;
        _startTime = newPack.startTime;
        if (!_data)
        {
            _data = [[NSMutableData alloc] init];
        }
        [_data appendData:newPack.data];
        return YES;
    }
    
    return NO;
}

- (NSData *) buffToWriteWithBackup:(iDownloadPack *)backupPack isComplete:(bool)complete
{
    long long tempLength = [_data length];
    if (backupPack && backupPack.data)
    {
        tempLength += [backupPack.data length];
    }
    
    double sizeKB = (double) tempLength / 1024.0f;
    
//    NSLog(@"%s-buff length = [%.2fk]", __FUNCTION__, sizeKB);
    if (sizeKB > _minSizeKBForStore || complete)
    {
        NSMutableData *ret = [[NSMutableData alloc] init];
        if (backupPack && backupPack.data)
        {
            [ret appendData:backupPack.data];
            backupPack.data = [[NSMutableData alloc] init];
        }
        
        [ret appendData:_data];
        _data = [[NSMutableData alloc] init];
        return ret;
    }

    return nil;
}

- (bool) checkValidWithBackup : (iDownloadPack *) backupPack
{
    if (backupPack)
        return (backupPack.totalLength == _totalLength + backupPack.currentLength);
    else
        return YES;
}

@end
