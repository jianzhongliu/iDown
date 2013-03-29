//
//  iDownManager.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownManager.h"
#import "iDownloader.h"

@implementation iDownManager
{
    NSMutableDictionary *_items;
}

+ (iDownManager *) shared
{
    static iDownManager *instance;
    
    @synchronized(self)
    {
        if (instance == NULL)
        {
            instance = [[iDownManager alloc] init];
        }
    }
    
    return instance;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _items = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (iDownloader *) addDownloadTaskWithUrlString : (NSString *) url andKey:(NSString *)key
{
    NSURL *_url = [[NSURL alloc] initWithString:url];
    
    iDownloader *_downloader = [[iDownloader alloc] initWithUrl:_url andKey:key];
    [_downloader startDownload];
    [_items setObject:_downloader forKey:key];
    
    return _downloader;
}

- (void) allStart
{
    iDownloader *_downloader;
    for (NSObject *key in [_items keyEnumerator])
    {
        _downloader = [_items objectForKey:key];
        [_downloader startDownload];
    }
}

@end
