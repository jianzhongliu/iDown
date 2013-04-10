//
//  iDownItem.m
//  iDown
//
//  Created by David Tang on 13-3-28.
//  Copyright (c) 2013年 David Tang. All rights reserved.
//

#import "iDownItem.h"
#import "iDownProcessView.h"
#import "UIImage+iDown.h"
#import "iDownloader.h"
#import "iDownDataManager.h"

@interface iDownItem () <iDownloaderEvent, iDownStateController>

@end

@implementation iDownItem
{
    UIImageView *stateIcon;
    UILabel *stateLabel;
    UILabel *nameLabel;
    UILabel *sizeLabel;
    UILabel *speedLabel;
    iDownProcessView *process;
    
    iDownData *_data;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        stateIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [stateIcon setCenter:CGPointMake(20, self.bounds.size.height / 2)];
        [self.contentView addSubview:stateIcon];
        
        process = [[iDownProcessView alloc] init];
        [process setOrigin:CGPointMake(40, 25)];
        [self.contentView addSubview:process];
        
        stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 35, 50, 10)];
        [stateLabel setBackgroundColor:[UIColor clearColor]];
        [stateLabel setTextAlignment:NSTextAlignmentLeft];
        [stateLabel setTextColor:[UIColor whiteColor]];
        [stateLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [self.contentView addSubview:stateLabel];
        
        speedLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 35, 50, 10)];
        [speedLabel setBackgroundColor:[UIColor clearColor]];
        [speedLabel setTextAlignment:NSTextAlignmentLeft];
        [speedLabel setTextColor:[UIColor whiteColor]];
        [speedLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [self.contentView addSubview:speedLabel];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 160, 15)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [self.contentView addSubview:nameLabel];
        
        sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 20 - 80, 23, 80, 10)];
        [sizeLabel setBackgroundColor:[UIColor clearColor]];
        [sizeLabel setTextAlignment:NSTextAlignmentLeft];
        [sizeLabel setTextColor:[UIColor whiteColor]];
        [sizeLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [self.contentView addSubview:sizeLabel];
    }
    return self;
}

- (void) initWithNormalMode
{
    self.textLabel.text = nil;
    [stateIcon setHidden:NO];
    [process setHidden:NO];
    [stateLabel setHidden:NO];
    [speedLabel setHidden:NO];
    [nameLabel setHidden:NO];
    [sizeLabel setHidden:NO];
}

- (void) initWithClickToAddNewMode
{
    [stateIcon setHidden:YES];
    [process setHidden:YES];
    [stateLabel setHidden:YES];
    [speedLabel setHidden:YES];
    [nameLabel setHidden:YES];
    [sizeLabel setHidden:YES];
    
    self.textLabel.text = kClickToAddDownload;
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    self.textLabel.textColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) switchToState : (iDownState) state
{
    [process switchToState:state];

    switch (state) {
        case iDownStateDownloading:
            stateIcon.image = [UIImage iDownIconDownloading];
            stateLabel.text = @"下载中...";
//            NSLog(@"%s-[%@] switch to state [downloading]", __FUNCTION__, _data.key);
            break;
            
        case iDownStateFailed:
            stateIcon.image = [UIImage iDownIconFailed];
            stateLabel.text = @"下载失败";
//            NSLog(@"%s-[%@] switch to state [failed]", __FUNCTION__, _data.key);
            break;
            
        case iDownStatePaused:
            stateIcon.image = [UIImage iDownIconPaused];
            stateLabel.text = @"已暂停";
//            NSLog(@"%s-[%@] switch to state [paused]", __FUNCTION__, _data.key);
            break;
            
        case iDownStateSucceed:
            stateIcon.image = [UIImage iDownIconDownloading];
            stateLabel.text = @"下载完成";
//            NSLog(@"%s-[%@] switch to state [complete]", __FUNCTION__, _data.key);
            break;
            
        default:
            stateLabel.text = @"未开始";
//            NSLog(@"%s-[%@] switch to state [unknown]", __FUNCTION__, _data.key);
            break;
    }
}

- (iDownData *) data
{
    return _data;
}

- (void) setData:(iDownData *)data
{
    if ([data.key isEqualToString:kClickToAddDownload])
    {
        [self initWithClickToAddNewMode];
        return;
    }
    
    [self initWithNormalMode];
    _data = data;
    _data.delegate = self;
    [_data setDownloadEventHandler:self];
    [nameLabel setText:_data.key];
    
    [data idle];
}

#pragma mark - iDownData

- (void) stateChanged
{
    [self switchToState:_data.state.state];
}

#pragma mark - iDownEvent

- (void) didFailedDownloadFile
{
    [self switchToState:iDownStateFailed];
    [_data handleEvent:iDownEventFailedDownload];
}

- (void) didChangeDownloadProgress:(float)progress withKey:(NSString *)key
{
    process.progress = progress;
}

- (void) didChangeDownloadSpeedTo:(float)speed withKey:(NSString *)key
{
    [speedLabel setText:[NSString stringWithFormat:@"%@/s", [self stringFromSize:speed]]];
}

- (void) didFinishDownload
{
    [self switchToState:iDownStateSucceed];
}

- (void) didFinishDownloadDataSize : (double) sizeKB
{
    [sizeLabel setText:[NSString stringWithFormat:@"%@/%@", [self stringFromSize:sizeKB], [self stringFromSize:_data.size]]];
}

- (void) didGetDownloadExpectSize:(float)sizeKB
{
    _data.size = sizeKB;
    [sizeLabel setText:[NSString stringWithFormat:@"0/%@", [self stringFromSize:_data.size]]];
}

- (void) didPausedDownload
{
    [self switchToState:iDownStatePaused];
}

- (NSString *) stringFromSize : (float) sizeKB
{
    if (sizeKB > 1048576.0f)
    {
        return [NSString stringWithFormat:@"%.1fG", sizeKB / 1048576.0f];
    }
    else if (sizeKB > 1024.0f)
    {
        return [NSString stringWithFormat:@"%.1fM", sizeKB / 1024.0f];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fK", sizeKB];
    }
}

@end
