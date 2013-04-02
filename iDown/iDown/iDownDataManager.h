//
//  iDownDataManager.h
//  iDown
//
//  Created by David Tang on 13-3-29.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownData.h"

@interface iDownDataManager : NSObject

+ (iDownDataManager *) shared;

- (iDownData *) dataAtIndex : (int) index;
- (iDownData *) dataWithKey : (NSString *) key;
- (NSUInteger) indexOfKey : (NSString *) key;

- (void) appendItem : (iDownData *) data;
- (void) removeDataWithKey : (NSString *) key;
- (NSUInteger) count;
- (void) allStartDownload;
- (void) allRestartDownload;

@end
