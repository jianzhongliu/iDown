//
//  iDownloader.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownStateMachine.h"

@protocol iDownloaderEvent <NSObject>

- (void) didFinishDownload;
- (void) didFinishDownloadDataSize : (double) sizeKB;
- (void) didChangeDownloadProgress : (float) progress withKey : (NSString *) key;
- (void) didChangeDownloadSpeedTo : (float) speed withKey : (NSString *) key;
- (void) didGetDownloadExpectSize : (float) sizeKB;
- (void) didFailedDownloadFile;
- (void) didPausedDownload;

@end

@protocol iDownloadStorage <NSObject>

- (void) reportData : (NSData *) data;
- (void) reportFileName : (NSString *) name;
- (void) reportComplete;

@end

@interface iDownloader : NSObject

@property (nonatomic, strong) id<iDownloaderEvent> eventDelegate;
@property (nonatomic, strong) id<iDownloadStorage> storageDelegate;
@property (nonatomic, unsafe_unretained) long long storageBuffLength;
@property (nonatomic, strong) NSString *key;

- (id) initWithUrl : (NSURL *) url andKey : (NSString *) key;
- (void) startDownload;
- (void) pauseDownload;
- (void) endDownload;
- (void) succeedDownload;
- (void) idle;

- (NSDictionary *) exportToDictionary;
+ (iDownloader *) importFromDictionary : (NSDictionary *) dic;

@end
