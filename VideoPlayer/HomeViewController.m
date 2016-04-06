//
//  HomeViewController.m
//  视频
//
//  Created by 魏永贺 on 16/4/4.
//  Copyright © 2016年 魏永贺. All rights reserved.
//

#import "HomeViewController.h"
#import "PlayVideoCell.h"
#import "DataManager.h"
#import "PlayVideoView.h"
#import "MJRefresh.h"
#import "DetailViewController.h"
#import "UIViewExt.h"
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableArray * DataSourceArray;
@property (nonatomic,strong) PlayVideoView *playVideoView;
@property (strong, nonatomic)NSIndexPath *currentIndexPath;
@property (strong, nonatomic)PlayVideoCell *currentCell;//当前播放的cell
@property (strong, nonatomic)PlayVideoView *PlayerVideo;
@property (assign, nonatomic)BOOL isSmallScreen;
@property (strong, nonatomic)UITableView *ListTableView;

@property (nonatomic,strong) DetailViewController *detail;

@end
static NSString *cellID = @"cell";

@implementation HomeViewController

-(NSMutableArray *)DataSourceArray
{
    if (!_DataSourceArray) {
        _DataSourceArray = [NSMutableArray array];
    }
    return _DataSourceArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"首页";
    [self.view addSubview:self.ListTableView];
    
    [self.ListTableView registerClass:[PlayVideoCell class] forCellReuseIdentifier:@"VideoCell"];
    
    [self addMJRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popDetail:)
                                                 name:kHTPlayerPopDetailNotificationKey
                                               object:nil];
    [self addObserver];
    
}

- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinished:)
                                                 name:kHTPlayerFinishedPlayNotificationKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:)
                                                 name:kHTPlayerFullScreenBtnNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTheVideo:)
                                                 name:kHTPlayerCloseVideoNotificationKey
                                               object:nil];
    
}

//播放完成后
-(void)videoDidFinished:(NSNotification *)notice{
    
    if (_PlayerVideo.screenType == UIHTPlayerSizeFullScreenType){
        
        [self toCell];//先变回cell
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        _PlayerVideo.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_PlayerVideo removeFromSuperview];
        [self releaseWMPlayer];
    }];
    
}
//关闭播放
-(void)closeTheVideo:(NSNotification *)obj{
    
    [UIView animateWithDuration:0.3 animations:^{
        _PlayerVideo.alpha = 0.0;
    } completion:^(BOOL finished) {
        [_PlayerVideo removeFromSuperview];
        [self releaseWMPlayer];
    }];
}

//全屏显示
-(void)fullScreenBtnClick:(NSNotification *)notice{
    
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        if (_isSmallScreen) {
            //放widow上,小屏显示
            [self toSmallScreen];
        }else{
            [self toCell];
        }
    }
}

-(void)releaseWMPlayer{
    [_PlayerVideo releaseWMPlayer];
    _PlayerVideo = nil;
    _currentIndexPath = nil;
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self loadData];
}
-(void)loadData{
    if (self.DataSourceArray.count == 0) {
        [self refreshData];
    }
}
- (void)refreshData
{
    __weak typeof(self) weakself = self;
    [[DataManager shareManager] getSIDArrayWithURLString:@"http://c.m.163.com/nc/video/home/0-10.html" success:^(NSArray *sidArray, NSArray *videoArray) {
        _DataSourceArray =[NSMutableArray arrayWithArray:videoArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself.ListTableView reloadData];
        });
        
    } failed:^(NSError *error) {
        
    }];
    
}

-(void)addMJRefresh{
    __unsafe_unretained UITableView *tableView = self.ListTableView;
    __weak HomeViewController *selfView = self;
    // 下拉刷新
    tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [selfView refreshData];
    }];
    // 设置自动切换透明度(在导航栏下面自动隐藏)
    tableView.mj_header.automaticallyChangeAlpha = YES;
    // 上拉刷新
    tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSString *URLString = [NSString stringWithFormat:@"http://c.m.163.com/nc/video/home/%ld-10.html",_DataSourceArray.count - _DataSourceArray.count%10];
        
        __weak typeof(self) weakself = self;
        [[DataManager shareManager] getSIDArrayWithURLString:URLString success:^(NSArray *sidArray, NSArray *videoArray) {
            _DataSourceArray =[NSMutableArray arrayWithArray:videoArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.ListTableView reloadData];
            });
            
        } failed:^(NSError *error) {
            
        }];
        
        // 结束刷新
        [tableView.mj_footer endRefreshing];
    }];
}

-(NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _DataSourceArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 160;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"VideoCell";
    PlayVideoCell *cell = (PlayVideoCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    cell.model = [_DataSourceArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell.playBtn addTarget:self action:@selector(startPlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    cell.playBtn.tag = indexPath.row;
    
    return cell;
}

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView ==self.ListTableView){
        if (_PlayerVideo==nil) return;
        
        if (_PlayerVideo.superview) {
            CGRect rectInTableView = [self.ListTableView rectForRowAtIndexPath:_currentIndexPath];
            CGRect rectInSuperview = [self.ListTableView convertRect:rectInTableView toView:[self.ListTableView superview]];
            
            //            NSLog(@"rectInSuperview = %@",NSStringFromCGRect(rectInSuperview));
            
            if (rectInSuperview.origin.y-kNavbarHeight<-self.currentCell.backView.height||rectInSuperview.origin.y>self.view.height) {//往上拖动
                
                if (![[UIApplication sharedApplication].keyWindow.subviews containsObject:_PlayerVideo]) {
                    //放widow上,小屏显示
                    [self toSmallScreen];
                }
                
            }else{
                if (![self.currentCell.backView.subviews containsObject:_PlayerVideo]) {
                    [self toCell];
                }
            }
        }
        
    }
}

-(void)toCell{
    
    self.currentCell = (PlayVideoCell *)[self.ListTableView cellForRowAtIndexPath:_currentIndexPath];
    [_PlayerVideo reductionWithInterfaceOrientation:self.currentCell.backView];
    _isSmallScreen = NO;
    [self.ListTableView reloadData];
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    
    [_PlayerVideo toFullScreenWithInterfaceOrientation:interfaceOrientation];
}
-(void)toSmallScreen{
    //放widow上
    [_PlayerVideo toSmallScreen];
    _isSmallScreen = YES;
}

//开始播放
-(void)startPlayVideo:(UIButton *)sender{
    _currentIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    self.currentCell = (PlayVideoCell *)[self.ListTableView cellForRowAtIndexPath:_currentIndexPath];
    
    VideoModel *model = [_DataSourceArray objectAtIndex:sender.tag];
    
    
    if (_PlayerVideo) {
        [_PlayerVideo removeFromSuperview];
        [_PlayerVideo setVideoURLStr:model.mp4_url];
        
    }else{
        _PlayerVideo = [[PlayVideoView alloc]initWithFrame:self.currentCell.backView.bounds videoURLStr:model.mp4_url];
    }
    
    [_PlayerVideo setPlayTitle:model.title];
    
    [self.currentCell.backView addSubview:_PlayerVideo];
    [self.currentCell.backView bringSubviewToFront:_PlayerVideo];
    
    if (_PlayerVideo.screenType == UIHTPlayerSizeSmallScreenType) {
        [_PlayerVideo reductionWithInterfaceOrientation:self.currentCell.backView];
    }
    _isSmallScreen = NO;
    
    [self.ListTableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!_detail) {
        _detail = [[DetailViewController alloc] init];
        _detail.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController addChildViewController:_detail];
        [self.navigationController.view addSubview:_detail.view];
        _detail.view.alpha = 0;
    }
    
    //    判断当前播放的视频，是否用户点击的视频。
    if (_currentIndexPath && _currentIndexPath.row != indexPath.row) {
        
        _isSmallScreen = NO;
        if (_PlayerVideo) {
            [self releaseWMPlayer];//关闭视频
        }
        
        _currentIndexPath = indexPath;
        _currentCell = [tableView cellForRowAtIndexPath:indexPath];
    }
    _detail.playVideoView =_PlayerVideo;
    VideoModel *model = [_DataSourceArray objectAtIndex:indexPath.row];
    _detail.model =model;
    
    [_detail reloadData];
    
    [UIView animateWithDuration:0.5 animations:^{
        _detail.view.alpha = 1;
    }];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTPlayerFinishedPlayNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTPlayerFullScreenBtnNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kHTPlayerFinishedPlayNotificationKey object:nil];
}

- (void)popDetail:(NSNotification *)obj
{
   _PlayerVideo = (PlayVideoView *)obj.object;
    
    if (_PlayerVideo) {
        if (_isSmallScreen) {
            //放widow上,小屏显示
            [self toSmallScreen];
        }else{
            [self toCell];
        }
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        _detail.view.alpha = 0.0;
    }];
    
    [[NSNotificationCenter defaultCenter] removeObserver:_detail];
    [self addObserver];
}

- (UITableView *)ListTableView
{
    if (_ListTableView) return _ListTableView;
    _ListTableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _ListTableView.dataSource = self;
    _ListTableView.delegate = self;
    _ListTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return _ListTableView;
}


-(void)dealloc{
    NSLog(@"%@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseWMPlayer];
}

@end
