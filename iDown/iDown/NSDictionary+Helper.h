//
//  NSDictionary+Helper.h
//  iDown
//
//  Created by David Tang on 13-4-7.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Helper)

+ (NSDictionary *) dictionaryWithContentsOfData : (NSData *) data;

- (NSData *) toData;

@end
