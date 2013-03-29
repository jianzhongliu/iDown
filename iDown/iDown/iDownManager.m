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

- (void) addDownloadTaskWithUrlString : (NSString *) url
{
    NSURL *_url = [[NSURL alloc] initWithString:url];
    NSString *_key = [_url relativeString];
    
    iDownloader *_downloader = [[iDownloader alloc] initWithUrl:_url andKey:_key];
    [_downloader startDownload];
    [_items setObject:_downloader forKey:_key];
}

@end
