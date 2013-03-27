//
//  iDownViewController.m
//  iDown
//
//  Created by David Tang on 13-3-27.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownViewController.h"
#import "UIColor+iDown.h"

@interface iDownViewController ()

@end

@implementation iDownViewController
{
    UIView *back;
    UIButton *allStartBtn;
    UIButton *editBtn;
    UITableView *downloadTable;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        back = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
        [back setBackgroundColor:[UIColor bgColor]];
        [self setView:back];
        
        self.navigationItem.title = @"我的下载";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
