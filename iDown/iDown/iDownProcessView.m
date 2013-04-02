//
//  iDownProcessView.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownProcessView.h"
#import "UIColor+iDown.h"

#define LENGTH  160
#define WIDTH   6

@implementation iDownProcessView
{
    UIView *backLine;
    UIView *frontLine;
    float _progress;
}

- (id)init
{
    return [self initWithFrame:CGRectMake(0, 0, LENGTH, 6)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backLine = [[UIView alloc] initWithFrame:self.frame];
        [backLine setBackgroundColor:[UIColor iDownProgressBackColor]];
        [self addSubview:backLine];
        
        frontLine = [[UIView alloc] initWithFrame:self.frame];
        [self addSubview:frontLine];
        
        _progress = 0;
    }
    return self;
}

- (void) setOrigin:(CGPoint)p
{
    [self setFrame:CGRectMake(p.x, p.y, self.frame.size.width, self.frame.size.height)];
    [backLine setBounds:self.bounds];
    [frontLine setBounds:self.bounds];
}

- (void) switchToState:(iDownState)state
{
    switch (state) {
        case iDownStateDownloading:
            [self setHidden:NO];
            [frontLine setBackgroundColor:[UIColor iDownDownloadingColor]];
            break;
            
        case iDownStateFailed:
            [self setHidden:NO];
            [frontLine setBackgroundColor:[UIColor iDownFailedColor]];
            break;
            
        case iDownStatePaused:
            [self setHidden:NO];
            [frontLine setBackgroundColor:[UIColor iDownPausedColor]];
            break;
        
        case iDownStateSucceed:
//            [self setHidden:YES];
            break;
            
        case iDownStateUnknown:
            self.progress = 0;
            break;
            
        default:
            break;
    }
}

- (float) progress
{
    return _progress;
}

- (void) setProgress:(float)progress
{
    if (progress < 0 || progress > 1)
    {
        return;
    }
    
    _progress = progress;
    [frontLine setFrame:CGRectMake(frontLine.frame.origin.x, frontLine.frame.origin.y, progress * LENGTH, WIDTH)];
}

@end
