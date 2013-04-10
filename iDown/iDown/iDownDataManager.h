//
//  iDownDataManager.h
//  iDown
//
//  Created by David Tang on 13-3-29.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownData.h"

#define kClickToAddDownload @"点击添加下载"

@interface iDownDataManager : NSObject

+ (iDownDataManager *) shared;

- (iDownData *) dataAtIndex : (int) index;
- (iDownData *) dataWithKey : (NSString *) key;
- (NSUInteger) indexOfKey : (NSString *) key;

- (void) appendItem : (iDownData *) data;
- (void) removeDataWithKey : (NSString *) key;
- (void) removeDataWithIndex : (NSUInteger) index;
- (NSUInteger) count;
- (void) allStartDownload;
- (void) allRestartDownload;

- (void) saveStatus;
- (void) loadStatus;
- (void) idle;

@end
