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
#import "iDownNewItemController.h"

#import <QuartzCore/QuartzCore.h>

@interface iDownViewController () <UITableViewDataSource, UITableViewDelegate, iDownNewItemDelegate>

@end

@implementation iDownViewController
{
    UIView *back;
    UIButton *allStartBtn;
    UIButton *editBtn;
    UITableView *downloadTable;
    bool editMode;
    iDownNewItemController *newItemController;
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
    
    editMode = NO;
}

- (void) saveStatus
{
    [[iDownDataManager shared] saveStatus];
}

- (void) loadStatus
{
    [[iDownDataManager shared] loadStatus];
    [downloadTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView display

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
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[iDownDataManager shared] count] + 1;
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
    if (indexPath.row == [[iDownDataManager shared] count])
    {
        NSLog(@"insert");
        [self didTapNewItem];
        return;
    }
    
    iDownData *data = [[iDownDataManager shared] dataAtIndex:indexPath.row];
    if (data)
    {
        [data handleEvent:iDownEventUserTappedItem];
    }
}

#pragma mark - tableview edit

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [[iDownDataManager shared] count])
        return UITableViewCellEditingStyleNone;
    
    if (editMode)
    {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

- (void) tableView: (UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [[iDownDataManager shared] removeDataWithIndex:row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
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
    editMode = !editMode;
    [downloadTable setEditing:editMode animated:YES];
    [downloadTable reloadData];
}


#pragma mark - newItem

- (void) didTapNewItem
{
    NSLog(@"new item");
    
    newItemController = [[iDownNewItemController alloc] init];
    newItemController.delegate = self;
    [self.navigationController pushViewController:newItemController animated:YES];
}

- (void) shouldAddNewItemWithUrl:(NSString *)url andKey:(NSString *)key
{
    iDownData *iData = [[iDownData alloc] initWithUrl:url];
    iData.key = key;
    
    [[iDownDataManager shared] appendItem:iData];
    [self.navigationController popViewControllerAnimated:YES];
    [downloadTable reloadData];
}

@end
