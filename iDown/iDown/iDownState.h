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
    iDownStateDownloading,
    iDownStatePaused,
    iDownStateFailed,
    iDownStateSucceed,
    iDownStateUnknown,
    
} iDownStates;

@interface iDownState : NSObject

@end
