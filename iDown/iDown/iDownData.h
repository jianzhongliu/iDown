//
//  iDownData.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownState.h"
#import "iDownloader.h"

@protocol iDownStateController <NSObject>

- (void) didChangeToState : (iDownStates) state withKey : (NSString *) key;

@end

@interface iDownData : NSObject

@property (nonatomic, unsafe_unretained) iDownStates state;
@property (nonatomic, strong) id<iDownStateController> delegate;
@property (nonatomic, readonly) iDownloader *downloader;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, unsafe_unretained) float size;

- (id) initWithUrl : (NSString *) urlString;
- (void) setDownloadEventHandler : (id<iDownloaderEvent>) delegate;

@end
