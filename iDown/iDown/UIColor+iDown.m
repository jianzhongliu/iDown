//
//  UIColor+iDown.m
//  iDown
//
//  Created by David Tang on 13-3-27.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "UIColor+iDown.h"

@implementation UIColor (iDown)

+ (UIColor *) colorFromIntR : (int) r intG : (int)g intB : (int)b intA : (int) a
{
    return [UIColor colorWithRed:(GLfloat)r / 255.0
                           green:(GLfloat)g / 255.0
                            blue:(GLfloat)b / 255.0
                           alpha:(GLfloat)a / 255.0];
}

+ (UIColor *) iDownDarkGray
{
    return [UIColor colorFromIntR:128 intG:128 intB:128 intA:255];
}

+ (UIColor *) iDownLightGray
{
    return [UIColor colorFromIntR:200 intG:200 intB:200 intA:255];
}

+ (UIColor *) iDownDownloadingColor
{
    return [UIColor colorFromIntR:99 intG:184 intB:82 intA:255];
}

+ (UIColor *) iDownPausedColor
{
    return [UIColor colorFromIntR:87 intG:134 intB:178 intA:255];
}

+ (UIColor *) iDownFailedColor
{
    return [UIColor colorFromIntR:247 intG:37 intB:0 intA:255];
}

+ (UIColor *) iDownProgressBackColor
{
    return [UIColor colorFromIntR:166 intG:166 intB:166 intA:255];
}

@end
