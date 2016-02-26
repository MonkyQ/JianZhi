//
//  MKMineViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKMineViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
//#import "UINavigationController+JZExtension.h"
#import "MJRefresh.h"
#import "MKScanViewController.h"


@interface MKMineViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic,strong)UITableView *tableView;//xib用的是weak 因为默认有这个子控件

@end

@implementation MKMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //隐藏导航栏
    self.fd_prefersNavigationBarHidden = YES;
    //self.navigationBarBackgroundHidden = YES;//导航没有标题还在
    
    
    [self configTableView];
}

- (void)configTableView
{
    // 创建tableView,如果是手动创建，成员变量可以为 strong （强引用）
    self.tableView = [[UITableView alloc] initWithFrame:CGRectNull style:UITableViewStyleGrouped];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    //	self.tableView.indicatorStyle
    //	self.tableView.separatorStyle
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, WTabBarHeight, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, WTabBarHeight, 0);
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    
    
    // 修改 cell 的分割线颜色
    self.tableView.separatorColor = WArcColor;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowNumber = 0;
    switch (section) {
        case 0:
            rowNumber = 2;
            break;
        case 1:
            rowNumber = 3;
            break;
        case 2:
            rowNumber = 1;
            break;
        default:
            break;
    }
    return rowNumber;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"forIndexPath:indexPath];
    if (indexPath.section ==2) {
        
    }else
    {
        cell.textLabel.text = @"扫码上岗";
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //反选 动画
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section ==1 &&indexPath.row ==1) {
        MKScanViewController *scanVC = [[MKScanViewController alloc]init];
        UINavigationController *naviVC = [[UINavigationController alloc] initWithRootViewController:scanVC];
        // prensent 一个视图控制器，不用再隐藏他的导航条
        [self.navigationController presentViewController:naviVC animated:YES completion:nil];
    }else if (indexPath.section ==2){
        //有代理方法
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提醒" message:@"您确定要退出当前账号吗" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"退出", nil];
        	[alertView show];
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        //想要去掉header footer的高度 不能return 0,应该返回一个极小数
        return 0.0000001;
    }else
    {
        return 16;
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"MKLogOffSuccess" object:nil];
}

@end
