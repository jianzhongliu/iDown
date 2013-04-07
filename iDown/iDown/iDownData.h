//
//  iDownData.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownStateMachine.h"
#import "iDownloader.h"
#import "iDownStateMachine.h"

@protocol iDownStateController <NSObject>

- (void) stateChanged;

@end

@interface iDownData : NSObject

@property (nonatomic, strong) iDownStateMachine *state;
@property (nonatomic, strong) id<iDownStateController> delegate;
@property (nonatomic, readonly) iDownloader *downloader;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, unsafe_unretained) float size;

- (id) initWithUrl : (NSString *) urlString;
- (void) setDownloadEventHandler : (id<iDownloaderEvent>) delegate;

- (void) handleEvent : (iDownEvent) event;
- (void) idle;
- (NSDictionary *) exportToDictionary;
+ (iDownData *) importFromDictionary : (NSDictionary *) dic;

@end
