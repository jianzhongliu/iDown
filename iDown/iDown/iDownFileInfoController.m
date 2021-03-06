//
//  iDownFileInfoController.m
//  iDown
//
//  Created by David Tang on 13-4-10.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownFileInfoController.h"
#import "UIColor+iDown.h"
#import <QuartzCore/QuartzCore.h>

@interface iDownFileInfoController ()

@end

@implementation iDownFileInfoController
{
    UILabel *fileTitle;
    UITextView *filePath;
    UITextView *fileURL;
    UILabel *fileSize;
    UILabel *downloadTime;
    UILabel *downloadSpeed;
    UIScrollView *back;
    
    iDownData *_data;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.title = @"文件信息";
    [self.view setBackgroundColor:[UIColor iDownDarkGray]];
    
    back = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)];
    [back setBackgroundColor:[UIColor clearColor]];
    [back setPagingEnabled:YES];
    [back setScrollEnabled:YES];
    back.showsVerticalScrollIndicator = YES;
    [self.view addSubview:back];
    
    CGFloat y = 10;
    
    [back addSubview:[self labelWithY:y andText:@"下载项目"]];
    
    y += 30;
    
    fileTitle = [self labelWithY:y andText:@""];
    [fileTitle setBackgroundColor:[UIColor iDownLightGray]];
    [back addSubview:fileTitle];
    
    y += 30;
    
    [back addSubview:[self labelWithY:y andText:@"文件路径"]];
    
    y += 30;
    
    filePath = [[UITextView alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 60)];
    [filePath setBackgroundColor:[UIColor iDownLightGray]];
    [filePath setTextAlignment:NSTextAlignmentLeft];
    [filePath setTextColor:[UIColor whiteColor]];
    [filePath setFont:[UIFont systemFontOfSize:15.0f]];
    [filePath setEditable:NO];
    filePath.layer.masksToBounds = YES;
    filePath.layer.cornerRadius = 6;
    [back addSubview:filePath];
    
    y += 70;
    
    fileURL = [[UITextView alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 60)];
    [fileURL setBackgroundColor:[UIColor iDownLightGray]];
    [fileURL setTextAlignment:NSTextAlignmentLeft];
    [fileURL setTextColor:[UIColor whiteColor]];
    [fileURL setFont:[UIFont systemFontOfSize:15.0f]];
    [fileURL setEditable:NO];
    fileURL.layer.masksToBounds = YES;
    fileURL.layer.cornerRadius = 6;
    [back addSubview:fileURL];
    
    y += 70;
    
    [back addSubview:[self labelWithY:y andText:@"文件大小"]];
    
    y += 30;
    
    fileSize = [self labelWithY:y andText:@""];
    [fileSize setBackgroundColor:[UIColor iDownLightGray]];
    [back addSubview:fileSize];
    
    y += 30;
    
    [back addSubview:[self labelWithY:y andText:@"下载时间"]];
    
    y += 30;
    
    downloadTime = [self labelWithY:y andText:@""];
    [downloadTime setBackgroundColor:[UIColor iDownLightGray]];
    [back addSubview:downloadTime];
    
    y += 30;
    
    [back addSubview:[self labelWithY:y andText:@"平均速度"]];
    
    y += 30;
    
    downloadSpeed = [self labelWithY:y andText:@""];
    [downloadSpeed setBackgroundColor:[UIColor iDownLightGray]];
    [back addSubview:downloadSpeed];
    
    y += 30;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    [button setCenter:CGPointMake(self.view.frame.size.width / 2, y + 15)];
    [button setBackgroundColor:[UIColor iDownLightGray]];
    [button setTitle:@"删除文件" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didTapDelete) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 4;
    [back addSubview:button];
    
    y += 40;
    
    [back setContentSize:CGSizeMake(back.frame.size.width, y)];
    
    [self updateInfo];
}

- (UILabel *) labelWithY : (CGFloat) y andText : (NSString *) text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 20)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:[UIColor whiteColor]];
    [label setFont:[UIFont systemFontOfSize:15.0f]];
    [label setText:text];
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = 6;
    
    return label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma getter/setter

- (void) setData:(iDownData *)data
{
    _data = data;
    [self updateInfo];
}

- (void) updateInfo
{
    if (_data)
    {
        double size = [_data.downloader getDownloadSizeKB];
        double time = [_data.downloader getDownloadTime];
        fileSize.text = [NSString stringWithFormat:@"%.2fk", size];
        downloadTime.text = [NSString stringWithFormat:@"%.2fs", time];
        downloadSpeed.text = [NSString stringWithFormat:@"%.2fk/s", size / time];
        filePath.text = _data.filePath;
        fileTitle.text = _data.key;
        fileURL.text = _data.url;
    }
}

#pragma mark - button

- (void) didTapDelete
{
    [_data handleEvent:iDownEventUserTappedDeleteButton];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
