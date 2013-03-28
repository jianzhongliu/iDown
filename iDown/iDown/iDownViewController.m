//
//  iDownViewController.m
//  iDown
//
//  Created by David Tang on 13-3-27.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownViewController.h"
#import "UIColor+iDown.h"

@interface iDownViewController () <UITableViewDataSource, UITableViewDelegate>

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

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的下载";
    
    back = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [back setBackgroundColor:[UIColor iDownDarkGray]];
    [self setView:back];
    
    CGFloat y = 10;
	
    allStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(40, y, 100, 30)];
    [allStartBtn setBackgroundColor:[UIColor iDownLightGray]];
    [allStartBtn setTitle:@"全部开始" forState:UIControlStateNormal];
    [allStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back addSubview:allStartBtn];
    
    editBtn = [[UIButton alloc] initWithFrame:CGRectMake(200, y, 100, 30)];
    [editBtn setBackgroundColor:[UIColor iDownLightGray]];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [back addSubview:editBtn];
    
    y += 50;
    
    downloadTable = [[UITableView alloc] initWithFrame:CGRectMake(0, y, back.frame.size.width, back.frame.size.height - y)
                                                 style:UITableViewStylePlain];
    [downloadTable setBackgroundColor:[UIColor iDownDarkGray]];
    downloadTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    downloadTable.separatorColor = [UIColor iDownLightGray];
    downloadTable.dataSource = self;
    downloadTable.delegate = self;
    [back addSubview:downloadTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"iDown";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = @"hello";
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

@end
