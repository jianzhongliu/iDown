//
//  NSDictionary+Helper.m
//  iDown
//
//  Created by David Tang on 13-4-7.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "NSDictionary+Helper.h"

#define ARCHIVER_KEY    @"IDOWN_ARCHIVER"

@implementation NSDictionary (Helper)

+ (NSDictionary *) dictionaryWithContentsOfData:(NSData *)data
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *myDictionary = [unarchiver decodeObjectForKey:ARCHIVER_KEY];
    [unarchiver finishDecoding];
    
    return myDictionary;
}

- (NSData *) toData
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:ARCHIVER_KEY];
    [archiver finishEncoding];
    
    return data;
}

@end
