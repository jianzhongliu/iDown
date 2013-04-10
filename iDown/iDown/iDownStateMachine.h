//
//  iDownState.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    iDownEventUserTappedItem,
    iDownEventUserTappedAllStartButton,
    iDownEventUserTappedDeleteButton,
    iDownEventAppDidEnterBackground,
    iDownEventAppDidResumeActive,
    iDownEventFileCheckInvalid,
    iDownEventFinishedDownload,
    iDownEventFailedDownload,
    iDownEventRestart,
} iDownEvent;

typedef enum
{
    iDownStateDownloading,
    iDownStatePaused,
    iDownStateFailed,
    iDownStateSucceed,
    iDownStateUnknown,
    
} iDownState;

@interface iDownStateMachine : NSObject

@property (nonatomic, unsafe_unretained, readonly) iDownState state;

- (id) initWithState : (iDownState) state;
- (iDownState) nextStateWithEvent : (iDownEvent) event;

@end
