//
//  DetailViewController.h
//  视频
//
//  Created by 魏永贺 on 16/4/4.
//  Copyright © 2016年 魏永贺. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayVideoView.h"
#import "VideoModel.h"
@interface DetailViewController : UIViewController


@property (nonatomic,strong) PlayVideoView *playVideoView;
@property (strong, nonatomic)VideoModel *model;
@property (strong, nonatomic)UIView *videoView;

- (void)reloadData;

@end
