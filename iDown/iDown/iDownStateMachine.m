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

- (id) initWithState:(iDownStates)state
{
    self = [super init];
    if (self)
    {
        _state = state;
    }
    
    return self;
}

- (iDownStates) nextStateWithEvent:(iDownEvent)event
{
    switch (event) {
        case iDownEventUserTappedItem:
            if (_state == iDownStateDownloading)
            {
                _state = iDownStatePaused;
            }
            else if (_state == iDownStatePaused || _state == iDownStateFailed)
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
            
        default:
            break;
    }
    
    return _state;
}

@end
