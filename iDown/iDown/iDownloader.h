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

- (void) didFinishDownloadData : (NSData *) data withKey : (NSString *) key;
- (void) didFinishDownloadDataSize : (double) sizeKB;
- (void) didChangeDownloadProgress : (float) progress withKey : (NSString *) key;
- (void) didChangeDownloadSpeedTo : (float) speed withKey : (NSString *) key;
- (void) didGetDownloadExpectSize : (float) sizeKB;
- (void) didFailedDownloadFile;
- (void) didPausedDownload;

@end

@interface iDownloader : NSObject

@property (nonatomic, strong) id<iDownloaderEvent> delegate;
@property (nonatomic, strong) NSString *key;

- (id) initWithUrl : (NSURL *) url andKey : (NSString *) key;
- (bool) startDownload;
- (bool) pauseDownload;
- (bool) endDownload;

@end
