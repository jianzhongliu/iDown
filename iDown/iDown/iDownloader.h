//
//  iDownloader.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    iDownStateDownloading,
    iDownStatePaused,
    iDownStateFailed,
    iDownStateSucceed,
    iDownStateUnknown,
    
} iDownStates;

@protocol iDownloaderEvent <NSObject>

- (void) didFinishDownloadData : (NSData *) data withKey : (NSString *) key;
- (void) didFinishDownloadDataSize : (double) sizeKB;
- (void) didChangeDownloadProgress : (float) progress withKey : (NSString *) key;
- (void) didChangeDownloadSpeedTo : (float) speed withKey : (NSString *) key;
- (void) didGetDownloadExpectSize : (float) sizeKB;

@end

@interface iDownloader : NSObject

@property (nonatomic, strong) id<iDownloaderEvent> delegate;
@property (nonatomic, unsafe_unretained, readonly) iDownStates state;
@property (nonatomic, strong) NSString *key;

- (id) initWithUrl : (NSURL *) url andKey : (NSString *) key;
- (void) startDownload;
- (void) pauseDownload;
- (void) endDownload;

@end
