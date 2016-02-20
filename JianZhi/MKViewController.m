//
//  MKViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKViewController.h"
#import "MKHomePageViewController.h"
#import "MKGroupViewController.h"
#import "MKMyJobViewController.h"
#import "MKMineViewController.h"

@interface MKViewController ()

@end

@implementation MKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
}

- (void)setupViewController
{
    MKHomePageViewController *home = [[MKHomePageViewController alloc]init];
    [self addChildVC:home title:@"主页" image:@"TabBar_Client_1_n" selectedImage:@"TabBar_Client_1_p"];
    
    MKGroupViewController *group = [[MKGroupViewController alloc]init];
    [self addChildVC:group title:@"群" image:@"TabBar_Client_2_n" selectedImage:@"TabBar_Client_2_p"];
    
    MKMyJobViewController *job = [[MKMyJobViewController alloc]init];
    [self addChildVC:job title:@"我的报名" image:@"TabBar_Client_3_n" selectedImage:@"TabBar_Client_3_p"];
    
    MKMineViewController *mine = [[MKMineViewController alloc]init];
    [self addChildVC:mine title:@"个人中心" image:@"TabBar_Client_4_n" selectedImage:@"TabBar_Client_4_p"];

}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    //设置子控制器标题
    childVC.title = title;
    //设置子控制器图片
    childVC.tabBarItem.image = [UIImage imageNamed:image];
    childVC.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage]imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //设置文字样式
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = WColorDarkGray;
    NSMutableDictionary *selectTextAttrs = [NSMutableDictionary dictionary];
    selectTextAttrs[NSForegroundColorAttributeName] = WColorMain;
    [childVC.tabBarItem setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:selectTextAttrs forState:UIControlStateSelected];
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:childVC];
    [self addChildViewController:nav];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
