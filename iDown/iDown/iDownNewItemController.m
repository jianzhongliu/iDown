//
//  iDownNewItemController.m
//  iDown
//
//  Created by David Tang on 13-4-10.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownNewItemController.h"
#import "UIColor+iDown.h"

#import <QuartzCore/QuartzCore.h>

@interface iDownNewItemController () <UITextViewDelegate>

@end

@implementation iDownNewItemController
{
    UITextField *title;
    UITextView *url;
}

@synthesize delegate = _delegate;

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
    self.navigationItem.title = @"新下载项目";

    [self.view setBackgroundColor:[UIColor iDownDarkGray]];
    
    CGFloat y = 20;
    
    UILabel *keyLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 20)];
    [keyLabel setBackgroundColor:[UIColor clearColor]];
    [keyLabel setText:@"请输入下载项目的标题"];
    [keyLabel setTextAlignment:NSTextAlignmentLeft];
    [keyLabel setTextColor:[UIColor whiteColor]];
    [keyLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:keyLabel];
    
    y += 30;
    
    title = [[UITextField alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 20)];
    [title setBackgroundColor:[UIColor lightGrayColor]];
    [title setTextAlignment:NSTextAlignmentLeft];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont systemFontOfSize:15.0f]];
    title.layer.masksToBounds = YES;
    title.layer.cornerRadius = 6;
    [self.view addSubview:title];
    
    y += 30;
    
    UILabel *urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 20)];
    [urlLabel setBackgroundColor:[UIColor clearColor]];
    [urlLabel setText:@"请输入url"];
    [urlLabel setTextAlignment:NSTextAlignmentLeft];
    [urlLabel setTextColor:[UIColor whiteColor]];
    [urlLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [self.view addSubview:urlLabel];
    
    y += 30;
    
    url = [[UITextView alloc] initWithFrame:CGRectMake(20, y, self.view.frame.size.width - 40, 100)];
    [url setBackgroundColor:[UIColor lightGrayColor]];
    [url setTextAlignment:NSTextAlignmentLeft];
    [url setTextColor:[UIColor whiteColor]];
    [url setFont:[UIFont systemFontOfSize:15.0f]];
    url.keyboardType = UIKeyboardTypeURL;
    url.delegate = self;
    url.layer.masksToBounds = YES;
    url.layer.cornerRadius = 6;
    [self.view addSubview:url];
    
    y += 110;
    
    UIButton *submit = [[UIButton alloc] initWithFrame:CGRectMake(0, y, 120, 30)];
    [submit setCenter:CGPointMake(self.view.frame.size.width / 2, y + 15)];
    [submit setBackgroundColor:[UIColor iDownLightGray]];
    [submit setTitle:@"确定" forState:UIControlStateNormal];
    [submit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [submit addTarget:self action:@selector(didTapSubmit) forControlEvents:UIControlEventTouchUpInside];
    submit.layer.masksToBounds = YES;
    submit.layer.cornerRadius = 4;
    [self.view addSubview:submit];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma textview

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [title resignFirstResponder];
        [url resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma button

- (void) didTapSubmit
{
    if (_delegate)
    {
        [_delegate shouldAddNewItemWithUrl:url.text andKey:title.text];
    }
}

@end
