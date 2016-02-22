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
#import "FrameAccessor.h"
#import "UIView+Extension.h"
#import "MJRefresh.h"
#import "YYModel.h"
#import "MKHomeCell.h"
#import "MKHomeCellModel.h"

@interface MKHomePageViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    int _currentPage;
}

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *cellModels;

/**
 *  用户进行筛选操作时选择的数据
 */
@property (strong, nonatomic) NSString *selectedChannel;
@property (strong, nonatomic) NSString *selectedCity;
@property (strong, nonatomic) NSString *selectedTime;

/**
 *  用户选择的查询条件字典
 */
@property (strong, nonatomic) NSMutableDictionary *selectDic;
//首页列表、MVC、Cell内跳转、循环广告条、打开应用更新内容
//二维码 生成与识别、检测更新、网络状态检测
//推送、点开推送跳转、应用内收到推送
//聊天、聊天服务器与账号关联\ UITableView 细节调整和处理
//地图半天 3DTouch\ 动画展开 cell、
//第三方分享和登录、官方和OpenShare
//短信、照相机、摇一摇、打电话
@end

@implementation MKHomePageViewController

//给对象初始化时NS_DESIGNATED_INITIALIZER 里一定会执行
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.cellModels =[[NSMutableArray alloc]init];
        [self configSiftCondition];
    }
    return self;
    
}
- (void)configSiftCondition{
    self.channelType = @"0";
    self.city = @"";
    self.filtrateTime = @"";
    self.selectedChannel = @"类型";
    self.selectedCity = @"区域";
    self.selectedTime = @"时间";
    self.selectDic = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                       @"channelType": @"0",
                                                                       @"city": @"",
                                                                       @"filtrateTime": @"",
                                                                       @"selectedChannel": @"类型",
                                                                       @"selectedCity": @"区域",
                                                                       @"selectedTime": @"时间"
                                                                       }];
}



//纯代码推荐
//加载视图
- (void)loadView
{
    [super loadView];
    [self addLoginBtn];
    [self configureTableView];
}
//xib等用这个
//视图加载完毕
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self getCellData];
}

- (void)configureTableView
{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    //防止上下挡住
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //内容边界区域
    self.tableView.contentInset = UIEdgeInsetsMake(WTopHeight, 0, WTabBarHeight, 0);
    //滚动条区域不会被挡住
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(WTopHeight, 0, WTabBarHeight, 0);
    //防止下方会有格子
    self.tableView.tableFooterView = [[UIView alloc]init];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getCellData];
    }];
    
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[MKHomeCell class] forCellReuseIdentifier:@"MKHomeCell"];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    /**
     *  去掉 Cell 分隔线左边的空白
     */
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    // 修改 cell 的分割线颜色
    self.tableView.separatorColor = WArcColor;
}

- (void)addLoginBtn
{
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    [loginBtn setTitleColor:WColorFontTitle forState:UIControlStateNormal];
    //[loginBtn setBackgroundColor:WColorMain];因为系统中没有为不同状态设置颜色的方法搜一用到分类
//    [loginBtn setBackgroundImage:[UIImage imageWithColor:WColorAssist] forState:UIControlStateNormal];
//    [loginBtn setBackgroundImage:[UIImage imageWithColor:WColorMain] forState:UIControlStateHighlighted];
//    [loginBtn setBackgroundImage:[UIImage imageWithColor:WColorFontTitle] forState:UIControlStateDisabled];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:loginBtn];
    loginBtn.frame = CGRectMake(0, 0, 50, 44);
  //  loginBtn.size = loginBtn.currentImage.size;
    [loginBtn addTarget:self action:@selector(userLogin) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:loginBtn];
    
    //loginBtn用Masonry布局
    //必须指定所有的约束来确定一个view的指定位置和大小
//    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.equalTo(100);//使用宏之后可以直接使用数字
//        make.center.equalTo(self.view);
//    }];
}

- (void)userLogin
{
    MKLoginView *loginView = [MKLoginView MKLoginView];
    [[MKbackView shareBackView]popView:loginView];
}
// 1 2 3 4 5 6 一秒执行一次

// 1 3 2 4 // （异步）分线程
// 1 2 3 4 同步队列

- (void)getCellData {
    //	dispatch_sync(<#dispatch_queue_t queue#>, <#^(void)block#>)
    //	dispatch_async(<#dispatch_queue_t queue#>, <#^(void)block#>)
    
    NSString *currentPageStr = [NSString stringWithFormat:@"%d", _currentPage];
    NSDictionary *parameters = @{
                                 @"token": TOKEN,
                                 @"refer": @"sy",
                                 @"tag": @"xs1",
                                 @"page": currentPageStr,
                                 @"channel_type": [self.selectDic objectForKey:@"channelType"],
                                 @"city": [self.selectDic objectForKey:@"city"],
                                 @"filtrate_time": [self.selectDic objectForKey:@"filtrateTime"],
                                 @"tag_time": @""
                                 };
    
    [MKNetHelp getDataWithParam:parameters andPath:@"app_api.php" andComplete:^(BOOL success, id result) {
        if (success) {
            NSDictionary *modelInfos = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:nil];
            
            [self.cellModels removeAllObjects];
            [self.cellModels addObjectsFromArray:[NSArray yy_modelArrayWithClass:[MKHomeCell class] json:modelInfos[@"json_data"]]];
            [self.tableView.mj_header endRefreshing];
            [self.tableView reloadData];
        }else {
            
        }
        
        //		[self.tableView reloadData];
    }];
}

#pragma mark ----delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MKCommentCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:@"MKHomeCell" forIndexPath:indexPath];
    
    MKHomeCellModel *model = [self.cellModels objectAtIndex:indexPath.row];
    
    
    [cell configWithModel:model];
    return cell;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellModels.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController *newVC = [[UIViewController alloc] init];
    newVC.view.backgroundColor = [UIColor whiteColor];
    newVC.hidesBottomBarWhenPushed = YES;
    MKHomeCellModel *model = [self.cellModels objectAtIndex:indexPath.row];
    newVC.navigationItem.title = model.title;
    [self.navigationController pushViewController:newVC animated:YES];
}
// 去掉 cell 左边的线
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
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
