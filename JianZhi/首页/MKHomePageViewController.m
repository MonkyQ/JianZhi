//
//  MKHomePageViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKHomePageViewController.h"
#import "UIImage+Color.h"
#import "MKbackView.h"
#import "MKLoginView.h"

@interface MKHomePageViewController ()

@end

@implementation MKHomePageViewController
//纯代码推荐
//加载视图
- (void)loadView
{
    [super loadView];
    [self addLoginBtn];    
}
- (void)addLoginBtn
{
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [loginBtn setTitleColor:WColorFontTitle forState:UIControlStateNormal];
    //[loginBtn setBackgroundColor:WColorMain];因为系统中没有为不同状态设置颜色的方法搜一用到分类
    [loginBtn setBackgroundImage:[UIImage imageWithColor:WColorAssist] forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage imageWithColor:WColorMain] forState:UIControlStateHighlighted];
    [loginBtn setBackgroundImage:[UIImage imageWithColor:WColorFontTitle] forState:UIControlStateDisabled];
    
    
    [loginBtn addTarget:self action:@selector(userLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    //loginBtn用Masonry布局
    //必须指定所有的约束来确定一个view的指定位置和大小
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(100);//使用宏之后可以直接使用数字
//        make.height.equalTo(@100);
        make.center.equalTo(self.view);
    }];
    
}
- (void)userLogin
{
    MKLoginView *loginView = [MKLoginView MKLoginView];
    [[MKbackView shareBackView]popView:loginView];
    
}

//xib等用这个
//视图加载完毕
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
