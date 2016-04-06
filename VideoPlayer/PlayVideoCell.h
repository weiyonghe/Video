//
//  PlayVideoCell.h
//  视频
//
//  Created by 魏永贺 on 16/4/4.
//  Copyright © 2016年 魏永贺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoModel.h"

@interface PlayVideoCell : UITableViewCell
@property (strong, nonatomic)VideoModel *model;

@property (strong, nonatomic)UIImageView *imgView;
@property (strong, nonatomic)UILabel *titleLabel;
@property (strong, nonatomic)UIButton *playBtn;

@property (strong, nonatomic)UIView *backView;

@end
