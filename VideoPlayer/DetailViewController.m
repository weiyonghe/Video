//
//  DetailViewController.m
//  视频
//
//  Created by 魏永贺 on 16/4/4.
//  Copyright © 2016年 魏永贺. All rights reserved.
//

#import "DetailViewController.h"
#import "UIViewExt.h"

@interface DetailViewController ()

@end

@implementation DetailViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, 140)];
    _videoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_videoView];
}

- (void)addObserver
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:)
                                                 name:kHTPlayerFinishedPlayNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:)
                                                 name:kHTPlayerFullScreenBtnNotificationKey object:nil];
}

- (void)reloadData
{
    [self addObserver];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (_playVideoView) {
        [self toDetial];
    }else{
        [self startPlayVideo:nil];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)videoDidFinished:(NSNotification *)notice{
    
    if (_playVideoView.screenType == UIHTPlayerSizeFullScreenType){
        
        [self toCell];//先变回cell
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _playVideoView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_playVideoView removeFromSuperview];
        [self releaseWMPlayer];
    }];
    
}

-(void)fullScreenBtnClick:(NSNotification *)notice{
    
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [self toCell];
    }
}

-(void)toCell{
    
    [_playVideoView toDetailScreen:_videoView];
}

-(void)toDetial{
    
    [_playVideoView toDetailScreen:_videoView];
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [_playVideoView toFullScreenWithInterfaceOrientation:interfaceOrientation];
}

//开始播放
-(void)startPlayVideo:(UIButton *)sender{
    
    if (_playVideoView) {
        [_playVideoView removeFromSuperview];
        [_playVideoView setVideoURLStr:_model.mp4_url];
        
    }else{
        _playVideoView = [[PlayVideoView alloc]initWithFrame:self.videoView.bounds videoURLStr:_model.mp4_url];
    }
    
    _playVideoView.screenType = UIHTPlayerSizeDetailScreenType;
    
    [_playVideoView setPlayTitle:_model.title];
    
    [self.videoView addSubview:_playVideoView];
    [self.videoView bringSubviewToFront:_playVideoView];
    
    if (_playVideoView.screenType == UIHTPlayerSizeSmallScreenType) {
        [_playVideoView reductionWithInterfaceOrientation:self.videoView];
    }
}

-(void)releaseWMPlayer{
    
    [_playVideoView releaseWMPlayer];
    _playVideoView = nil;
}

-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    //    [self releaseWMPlayer];
}

@end
