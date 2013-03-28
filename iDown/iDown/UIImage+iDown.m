//
//  UIImage+iDown.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "UIImage+iDown.h"

@implementation UIImage (iDown)

+ (UIImage *) iDownIconDownloading
{
    return [UIImage imageNamed:@"downloading.png"];
}

+ (UIImage *) iDownIconFailed
{
    return [UIImage imageNamed:@"failed.png"];
}

+ (UIImage *) iDownIconPaused
{
    return [UIImage imageNamed:@"paused.png"];
}

@end
