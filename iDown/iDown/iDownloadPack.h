//
//  iDownloadPack.h
//  iDown
//
//  Created by David Tang on 13-4-1.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iDownloadPack : NSObject

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, unsafe_unretained) NSTimeInterval startTime;
@property (nonatomic, unsafe_unretained) NSTimeInterval currentTime;
@property (nonatomic, unsafe_unretained) long long totalLength;
@property (nonatomic, unsafe_unretained) long long currentLength;
@property (nonatomic, unsafe_unretained) double minSizeKBForStore;

@property (nonatomic, unsafe_unretained, readonly) double downloadSpeed;
@property (nonatomic, unsafe_unretained, readonly) double downloadTime;
@property (nonatomic, unsafe_unretained, readonly) double progress;

- (double) speedKBPSWithBackup : (iDownloadPack *) backupPack;
- (double) currentSizeKBWithBackup : (iDownloadPack *) backupPack;
- (double) totalSizeKBWithBackup : (iDownloadPack *) backupPack;
- (double) timeWithBackup : (iDownloadPack *) backupPack;
- (double) progressWithBackup : (iDownloadPack *) backupPack;

- (NSData *) buffToWriteWithBackup : (iDownloadPack *) backupPack isComplete : (bool) complete;

- (bool) appendProgressWithPack : (iDownloadPack *) newPack;
- (bool) checkValidWithBackup : (iDownloadPack *) backupPack;

@end
