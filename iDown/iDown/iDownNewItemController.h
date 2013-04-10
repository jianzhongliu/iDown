//
//  iDownNewItemController.h
//  iDown
//
//  Created by David Tang on 13-4-10.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol iDownNewItemDelegate <NSObject>

- (void) shouldAddNewItemWithUrl : (NSString *) url andKey : (NSString *) key;

@end

@interface iDownNewItemController : UIViewController

@property (nonatomic, strong) id<iDownNewItemDelegate> delegate;

@end
