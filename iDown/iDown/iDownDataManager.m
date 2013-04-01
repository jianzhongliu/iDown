//
//  iDownDataManager.m
//  iDown
//
//  Created by David Tang on 13-3-29.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownDataManager.h"
#import "iDownManager.h"

@implementation iDownDataManager
{
    NSMutableArray *keys;
    NSMutableDictionary *dic;
}

+ (iDownDataManager *) shared
{
    static iDownDataManager *instance;
    
    @synchronized(self)
    {
        if (instance == NULL)
        {
            instance = [[iDownDataManager alloc] init];
        }
    }
    
    return instance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        keys = [[NSMutableArray alloc] init];
        dic = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (NSUInteger) indexOfKey:(NSString *)key
{
    return [keys indexOfObject:keys];
}

- (iDownData *) dataAtIndex:(int)index
{
    if ([keys count] <= index)
        return NULL;
    
    return [dic objectForKey:[keys objectAtIndex:index]];
}

- (iDownData *) dataWithKey:(NSString *)key
{
    return [dic objectForKey:key];
}

- (void) appendData:(iDownData *)data
{
    [keys addObject:data.key];
    [dic setObject:data forKey:data.key];
}

- (void) removeDataWithKey:(NSString *)key
{
    [keys removeObject:key];
    [dic removeObjectForKey:key];
}

- (NSUInteger) count
{
    return [keys count];
}

- (void) allStartDownload
{
    iDownData *data;
    for (NSObject *key in keys)
    {
        data = [dic objectForKey:key];
        [data handleEvent:iDownEventUserTappedAllStartButton];
    }
}

@end
