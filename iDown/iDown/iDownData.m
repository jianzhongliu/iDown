//
//  iDownData.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownData.h"
#import "iDownManager.h"

@implementation iDownData
{
    NSString *_urlString;
}

@synthesize key = _key;
@synthesize size = _size;
@synthesize downloader = _downloader;
@synthesize delegate = _delegate;
@synthesize state = _state;

+ (NSString *) getDefaultKey
{
    static int defaultId = 0;
    return [NSString stringWithFormat:@"item %d", defaultId ++];
}

- (id) initWithUrl:(NSString *)urlString
{
    self = [super init];
    if (self)
    {
        _urlString = urlString;
        _key = NULL;
        
        for (int i = [_urlString length]; i > 0; -- i)
        {
            if ([_urlString characterAtIndex: i - 1] == '/')
            {
                _key = [_urlString substringFromIndex:i + 1];
                break;
            }
        }
        
        if (!_key)
        {
            _key = [iDownData getDefaultKey];
        }
        
        _downloader = [[iDownManager shared] addDownloadTaskWithUrlString:_urlString andKey:_key];
        _state = [[iDownStateMachine alloc] initWithState:iDownStateUnknown];
    }

    return self;
}

#pragma mark - getter/setter

- (void) setDownloadEventHandler:(id<iDownloaderEvent>)delegate
{
    _downloader.delegate = delegate;
}

- (void) setKey:(NSString *)key
{
    _key = key;
    _downloader.key = _key;
}

#pragma mark - interfaces

- (void) handleEvent:(iDownEvent)event
{
    [_state nextStateWithEvent:event];
    [self handleNextState];
}

#pragma mark - privates

- (void) handleNextState
{
    switch (_state.state) {
        case iDownStateDownloading:
            [self startDownload];
            break;
            
        case iDownStatePaused:
            [self pauseDownload];
            break;
            
        case iDownStateSucceed:
            break;
            
        case iDownStateFailed:
            break;
            
        default:
            break;
    }
}

- (void) startDownload
{
    if (_delegate)
    {
        [_delegate stateChanged];
    }
    [_downloader startDownload];
}

- (void) pauseDownload
{
    if (_delegate)
    {
        [_delegate stateChanged];
    }
    [_downloader pauseDownload];
}



@end
