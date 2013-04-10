//
//  iDownDataManager.m
//  iDown
//
//  Created by David Tang on 13-3-29.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownDataManager.h"
#import "iDownManager.h"
#import "NSDictionary+Helper.h"

@implementation iDownDataManager
{
    NSMutableArray *keys;
    NSMutableDictionary *dic;
    NSString *statusFile;
    
    NSString *newKey;
    iDownData *newData;
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
        [self reset];
        statusFile = @"status";
        
        newKey = kClickToAddDownload;
        newData = [[iDownData alloc] initWithUrl:@"http://ww4.sinaimg.cn/bmiddle/6b13f227jw1e36rdsvb15j.jpg"];
        newData.key = newKey;
    }
    
    return self;
}

- (void) reset
{
    keys = [[NSMutableArray alloc] init];
    dic = [[NSMutableDictionary alloc] init];
}

- (NSUInteger) indexOfKey:(NSString *)key
{
    return [keys indexOfObject:keys];
}

- (iDownData *) dataAtIndex:(int)index
{
    if (index > [keys count])
        return nil;
    
    if (index == [keys count])
        return newData;
    
    return [dic objectForKey:[keys objectAtIndex:index]];
}

- (iDownData *) dataWithKey:(NSString *)key
{
    return [dic objectForKey:key];
}

- (void) appendItem:(iDownData *)data
{
    [keys addObject:data.key];
    [dic setObject:data forKey:data.key];
}

- (void) removeDataWithKey:(NSString *)key
{
    [keys removeObject:key];
    [dic removeObjectForKey:key];
}

- (void) removeDataWithIndex : (NSUInteger) index
{
    if (index >= [keys count])
        return;
    
    if (index == NSNotFound)
        return;
    
    NSString *tempKey = [keys objectAtIndex:index];
    [self removeDataWithKey:tempKey];
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

- (void) allRestartDownload
{
    iDownData *data;
    for (NSObject *key in keys)
    {
        data = [dic objectForKey:key];
        [data handleEvent:iDownEventRestart];
    }
}

- (void) idle
{
    iDownData *data;
    for (NSObject *key in keys)
    {
        data = [dic objectForKey:key];
        [data idle];
    }
}

- (void) saveStatus
{
    NSMutableDictionary *totalData = [[NSMutableDictionary alloc] init];
    for (NSObject *key in keys)
    {
        iDownData *data = [dic objectForKey:key];
        [data handleEvent:iDownEventAppDidEnterBackground];
        [totalData setValue:[data exportToDictionary] forKey:data.key];
    }
    
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:statusFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        [fileManager removeItemAtPath:filePath error:nil];
        NSLog(@"%s-File [%@] exists, delete it", __FUNCTION__, filePath);
    }
    [fileManager createFileAtPath:filePath contents:nil attributes:totalData];
    NSLog(@"%s-File [%@] created", __FUNCTION__, filePath);
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [fileHandle writeData:[totalData toData]];
    [fileHandle closeFile];
}

- (void) loadStatus
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [directoryPaths objectAtIndex:0];
    NSString *filePath = [documentDirectory stringByAppendingPathComponent:statusFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath])
    {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        NSData *dataFromFile = [fileHandle readDataToEndOfFile];
        NSDictionary *status = [NSDictionary dictionaryWithContentsOfData:dataFromFile];
        [fileHandle closeFile];
        
        [self reset];
        for (NSObject *key in [status keyEnumerator])
        {
            NSString *keyString = (NSString *) key;
            iDownData *downData = [iDownData importFromDictionary:[status objectForKey:keyString]];
            [keys addObject:keyString];
            [dic setObject:downData forKey:keyString];
        }
        NSLog(@"%s-status loaded", __FUNCTION__);
    }
    else//for test
    {
        NSLog(@"%s-First time, build test data", __FUNCTION__);
        [self buildTestData];
    }
}

- (void) clearStatus
{
    
}

- (void) buildTestData
{
    iDownData *d1 = [[iDownData alloc] initWithUrl:@"http://www.dongting.com/files/ttpod-setup.exe"];
    [[iDownDataManager shared] appendItem:d1];
    
    iDownData *d2 = [[iDownData alloc] initWithUrl:@"http://ttplayer.qianqian.com/download/ttpsetup-95024068.exe"];
    [[iDownDataManager shared] appendItem:d2];
    
    iDownData *d3 = [[iDownData alloc] initWithUrl:@"http://ww4.sinaimg.cn/bmiddle/6b13f227jw1e36rdsvb15j.jpg"];
    d3.key = @"名字";
    [[iDownDataManager shared] appendItem:d3];
}

@end
