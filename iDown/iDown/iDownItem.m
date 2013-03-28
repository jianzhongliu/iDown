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

@implementation iDownItem
{
    UIImageView *stateIcon;
    UILabel *stateLabel;
    UILabel *nameLabel;
    UILabel *sizeLabel;
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
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 5, 160, 15)];
        [nameLabel setBackgroundColor:[UIColor clearColor]];
        [nameLabel setTextAlignment:NSTextAlignmentLeft];
        [nameLabel setTextColor:[UIColor whiteColor]];
        [nameLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [self.contentView addSubview:nameLabel];
        
        sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 23, 80, 10)];
        [sizeLabel setBackgroundColor:[UIColor clearColor]];
        [sizeLabel setTextAlignment:NSTextAlignmentLeft];
        [sizeLabel setTextColor:[UIColor whiteColor]];
        [sizeLabel setFont:[UIFont systemFontOfSize:10.0f]];
        [self.contentView addSubview:sizeLabel];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) switchToState : (iDownStates) state
{
    [process switchToState:state];

    switch (state) {
        case iDownStateDownloading:
            stateIcon.image = [UIImage iDownIconDownloading];
            stateLabel.text = @"下载中...";
            break;
            
        case iDownStateFailed:
            stateIcon.image = [UIImage iDownIconFailed];
            stateLabel.text = @"下载失败";
            break;
            
        case iDownStatePaused:
            stateIcon.image = [UIImage iDownIconPaused];
            stateLabel.text = @"已暂停";
            break;
            
        case iDownStateSucceed:
            stateIcon.image = [UIImage iDownIconDownloading];
            stateLabel.text = @"下载完成";
            
        default:
            break;
    }
}

- (iDownData *) data
{
    return _data;
}

- (void) setData:(iDownData *)data
{
    _data = data;
    [nameLabel setText:_data.name];
    [sizeLabel setText:[NSString stringWithFormat:@"0/%.1fM", _data.size]];
}

@end
