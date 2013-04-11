//
//  iDownState.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownStateMachine.h"

@implementation iDownStateMachine

@synthesize state = _state;

- (id) initWithState:(iDownState)state
{
    self = [super init];
    if (self)
    {
        _state = state;
    }
    
    return self;
}

- (NSString *) description
{
    switch (_state) {
        case iDownStateFailed:
            return @"iDownStateFailed";
        case iDownStateDownloading:
            return @"iDownStateDownloading";
        case iDownStatePaused:
            return @"iDownStatePaused";
        case iDownStateSucceed:
            return @"iDownStateSucceed";
        case iDownStateUnknown:
            return @"iDownStateUnknown";
        default:
            break;
    }
}

- (iDownState) nextStateWithEvent:(iDownEvent)event
{
    switch (event) {
        case iDownEventUserTappedItem:
            if (_state == iDownStateDownloading)
            {
                _state = iDownStatePaused;
            }
            else if (_state == iDownStatePaused || _state == iDownStateFailed || _state == iDownStateUnknown)
            {
                _state = iDownStateDownloading;
            }
            break;
            
        case iDownEventUserTappedAllStartButton:
            if (_state == iDownStatePaused || _state == iDownStateUnknown || _state == iDownStateFailed)
            {
                _state = iDownStateDownloading;
            }
            break;
            
        case iDownEventFailedDownload:
            if (_state == iDownStateDownloading)
            {
                _state = iDownStateFailed;
            }
            break;
            
        case iDownEventFinishedDownload:
            if (_state == iDownStateDownloading)
            {
                _state = iDownStateSucceed;
            }
            break;
            
        case iDownEventRestart:
            _state = iDownStateUnknown;
            break;
            
        case iDownEventAppDidEnterBackground:
            if (_state == iDownStateDownloading)
            {
                _state = iDownStatePaused;
            }
            break;
        
        case iDownEventAppDidResumeActive:
            break;
            
        case iDownEventFileCheckInvalid:
            _state = iDownStateFailed;
            break;
            
        case iDownEventUserTappedDeleteButton:
            _state = iDownStateUnknown;
            break;
            
        default:
            break;
    }
    
    return _state;
}

@end
