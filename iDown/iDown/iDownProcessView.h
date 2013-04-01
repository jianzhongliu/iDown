//
//  iDownProcessView.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iDownloader.h"

@interface iDownProcessView : UIView

@property (nonatomic, unsafe_unretained) float progress;

- (id) init;
- (void) setOrigin : (CGPoint) p;
- (void) switchToState : (iDownState) state;


@end
