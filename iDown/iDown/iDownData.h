//
//  iDownData.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iDownState.h"

@protocol iDownStateController <NSObject>

- (void) didChangeToState : (iDownStates) state;

@end

@interface iDownData : NSObject

@property (nonatomic, unsafe_unretained) iDownStates state;
@property (nonatomic, strong) id<iDownStateController> delegate;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, unsafe_unretained) float size;

@end
