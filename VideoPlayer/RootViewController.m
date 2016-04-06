//
//  RootViewController.m
//  视频
//
//  Created by 魏永贺 on 16/4/4.
//  Copyright © 2016年 魏永贺. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "MeViewController.h"
@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:homeVC];
    nav1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"视频.png"] tag:101];
    
    
    MeViewController *meVC = [[MeViewController alloc] init];
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:meVC];
    nav2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[UIImage imageNamed:@"我的.png"] tag:102];
    
    self.viewControllers = @[nav1,nav2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
