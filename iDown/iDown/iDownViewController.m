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
#import "iDownDataManager.h"
#import "iDownManager.h"

#import <QuartzCore/QuartzCore.h>

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
    
    [self buildTestData];
}

- (void) buildTestData
{
    iDownData *d1 = [[iDownData alloc] initWithUrl:@"http://www.dongting.com/files/ttpod-setup.exe"];
    d1.key = @"天天动听";
    [[iDownDataManager shared] appendItem:d1];
    
    iDownData *d2 = [[iDownData alloc] initWithUrl:@"http://ttplayer.qianqian.com/download/ttpsetup-95024068.exe"];
    d2.key = @"千千静听";
    [[iDownDataManager shared] appendItem:d2];
    
    iDownData *d3 = [[iDownData alloc] initWithUrl:@"http://ww4.sinaimg.cn/bmiddle/6b13f227jw1e36rdsvb15j.jpg"];
    d3.key = @"名字";
    [[iDownDataManager shared] appendItem:d3];
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
    item.data = [[iDownDataManager shared] dataAtIndex:indexPath.row];
    [item switchToState:iDownStateUnknown];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[iDownDataManager shared] count];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (iDownItem *) cellForKey : (NSString *) key
{
    NSUInteger index = [[iDownDataManager shared] indexOfKey:key];
    if (index == NSNotFound)
        return NULL;
    
    return (iDownItem *)[downloadTable cellForRowAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0]];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    iDownData *data = [[iDownDataManager shared] dataAtIndex:indexPath.row];
    if (data)
    {
        [data handleEvent:iDownEventUserTappedItem];
    }
}

#pragma mark - button

- (void) didTapAllStart
{
    NSLog(@"%s-did tap all start", __FUNCTION__);
    [[iDownDataManager shared] allStartDownload];
}

- (void) didTapEdit
{
    NSLog(@"%s-did tap edit", __FUNCTION__);
}

@end
