//
//  iDownViewController.m
//  iDown
//
//  Created by David Tang on 13-3-27.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownViewController.h"
#import "UIColor+iDown.h"
#import "iDownData.h"
#import "iDownItem.h"

#import <QuartzCore/QuartzCore.h>

@interface iDownViewController () <UITableViewDataSource, UITableViewDelegate, iDownStateController>

@end

@implementation iDownViewController
{
    UIView *back;
    UIButton *allStartBtn;
    UIButton *editBtn;
    UITableView *downloadTable;
    NSMutableArray *downloadItems;
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
    back.userInteractionEnabled = YES;
    [self setView:back];
    
    CGFloat y = 10;
	
    allStartBtn = [[UIButton alloc] initWithFrame:CGRectMake(30, y, 120, 30)];
    [allStartBtn setBackgroundColor:[UIColor iDownLightGray]];
    [allStartBtn setTitle:@"全部开始" forState:UIControlStateNormal];
    [allStartBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [allStartBtn addTarget:self action:@selector(didTapAllStart) forControlEvents:UIControlEventTouchUpInside];
    allStartBtn.layer.masksToBounds = YES;
    allStartBtn.layer.cornerRadius = 4;
    [back addSubview:allStartBtn];
    
    editBtn = [[UIButton alloc] initWithFrame:CGRectMake(back.frame.size.width - 30 - 120, y, 120, 30)];
    [editBtn setBackgroundColor:[UIColor iDownLightGray]];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(didTapEdit) forControlEvents:UIControlEventTouchUpInside];
    editBtn.layer.masksToBounds = YES;
    editBtn.layer.cornerRadius = 4;
    [back addSubview:editBtn];
    
    y += 40;
    
    downloadTable = [[UITableView alloc] initWithFrame:CGRectMake(0, y, back.frame.size.width, back.frame.size.height - y)
                                                 style:UITableViewStylePlain];
    [downloadTable setBackgroundColor:[UIColor iDownDarkGray]];
    downloadTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    downloadTable.separatorColor = [UIColor iDownLightGray];
    downloadTable.dataSource = self;
    downloadTable.delegate = self;
    [back addSubview:downloadTable];
    
    downloadItems = [[NSMutableArray alloc] init];
    [self buildTestData];
}

- (void) buildTestData
{
    iDownData *d1 = [[iDownData alloc] init];
    d1.delegate = self;
    d1.name = @"天天动听";
    d1.size = 100.1;
    [downloadItems addObject:d1];
    
    iDownData *d2 = [[iDownData alloc] init];
    d2.delegate = self;
    d2.name = @"天天星愿";
    d2.size = 50;
    [downloadItems addObject:d2];
    
    iDownData *d3 = [[iDownData alloc] init];
    d3.delegate = self;
    d3.name = @"天天向上";
    d3.size = 50;
    [downloadItems addObject:d3];
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
        cell = [[iDownItem alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    iDownItem *item = (iDownItem *)cell;
    item.data = [downloadItems objectAtIndex:indexPath.row];
    [item switchToState:iDownStateDownloading];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [downloadItems count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

#pragma mark - iDownData

- (void) didChangeToState:(iDownStates)state
{
    
}

#pragma mark - button

- (void) didTapAllStart
{
    NSLog(@"did tap all start");
}

- (void) didTapEdit
{
    NSLog(@"did tap edit");
}

@end
