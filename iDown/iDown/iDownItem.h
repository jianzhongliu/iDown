//
//  iDownItem.h
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iDownState.h"
#import "iDownData.h"



@interface iDownItem : UITableViewCell

@property (nonatomic, strong) iDownData *data;

- (void) switchToState : (iDownStates) state;

@end
