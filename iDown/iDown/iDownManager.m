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
    [_items setObject:_downloader forKey:key];
    NSLog(@"%s-added [%@] to download list", __FUNCTION__, key);
    return _downloader;
}

- (void) allStart
{
    for (NSObject *key in [_items keyEnumerator])
    {
        [self startDownloadWithKey: (NSString *) key];
    }
}

- (void) startDownloadWithKey:(NSString *)key
{
    iDownloader *_downloader = [_items objectForKey:key];
    [_downloader startDownload];;
}

@end
