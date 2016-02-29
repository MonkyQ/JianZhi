//
//  MKMapViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/27.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKMapViewController.h"
//用哪个头文件 就导入哪个
#import "BaiduMapAPI_Map.framework/Headers/BMKMapView.h"

//定位的
#import "BaiduMapAPI_Location.framework/Headers/BMKLocationService.h"

// 地理位置编码SDK
#import "BaiduMapAPI_Search.framework/Headers/BMKGeocodeSearch.h"
#import "MKTextField.h"

#import "UIControl+ActionBlocks.h"

#import "UIApplication+Permissions.h"
@interface MKMapViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,CLLocationManagerDelegate, BMKGeoCodeSearchDelegate>
{
    CLLocationManager *_manager;
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_searcher;
}
//地图定位一般在项目中会用到以下功能
/**
 *  1.定位:可以得到一个坐标
 *  2.编码地理位置:给一个具体的地址 编码成一个坐标 然后可以在地图上添加标注
 *  3.反编码:给一个坐标 可以反编码出具体地址 也可以直接添加标注
 *  4.搜索.路径规划
 */
@property (nonatomic,strong)BMKMapView *mapView;


@end

@implementation MKMapViewController

- (void)loadView
{
    [super loadView];
    [self loadSubView];
}
- (void)loadSubView
{
    MKTextField *searchText = [[MKTextField alloc]init];
    searchText.placeholder = @"输入地址";
    
    [self.view addSubview:searchText];
    [searchText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(WTopHeight +16);
        make.left.equalTo(16);
        make.centerX.equalTo(0);
        make.height.equalTo(48);
       
    }];
    
    [searchText handleControlEvents:UIControlEventEditingDidEnd withBlock:^(id weakSender) {
        _searcher.delegate = self;
        BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
        geoCodeSearchOption.city= @"北京市";
        geoCodeSearchOption.address = [weakSender text];
        BOOL flag = [_searcher geoCode:geoCodeSearchOption];
        if(flag)
        {
            NSLog(@"geo检索发送成功");
        }
        else
        {
            NSLog(@"geo检索发送失败");
        }
    }];

    
    //创建地图控件
    self.mapView = [[BMKMapView alloc]init];
  
    [self.view addSubview:_mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-16);
        make.left.equalTo(16);
        make.centerX.equalTo(0);
        make.top.equalTo(searchText.mas_bottom).offset(16);
    }];
    //定位的模式
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;


    //是否显示用户本机位置
    self.mapView.showsUserLocation = YES;
    
    // 添加定位按钮
    UIButton *locateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [locateBtn setTitle:@"定位" forState:UIControlStateNormal];
    [locateBtn setTitleColor:[UIColor colorWithRed:0.000 green:0.502 blue:0.502 alpha:1.000] forState:UIControlStateNormal];
    locateBtn.frame = CGRectMake(10, 500, 96, 48);
    [self.view addSubview:locateBtn];
    [locateBtn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        /**
         *  设定地图中心坐标点
         *
         *  @param CLLocationCoordinate2D 要设定的地图中心点坐标 用经纬度表示
         */
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(31, 121) animated:YES];
    }];
//    [locateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(16);
//        make.top.equalTo(_mapView.mas_bottom).offset(0);
//        make.width.equalTo(96);
//        make.height.equalTo(48);
//        
//    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self requestUserLocation];
    //定位我的位置
    [self locateMyLocation];

}
- (void)locateMyLocation
{
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];
}
//申请用户地理位置权限
- (void)requestUserLocation
{
    _manager = [[CLLocationManager alloc]init];
    if ([CLLocationManager authorizationStatus]<=3) {
        [_manager requestWhenInUseAuthorization];
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_mapView viewWillAppear];
    self.mapView.delegate = self;// 此处记得不用的时候需要置nil，否则影响内存的释放
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    self.mapView.delegate = nil;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
}
/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //将坐标移动到定位的地方
    [_mapView updateLocationData:userLocation];

}

/**
 *定位失败后，会调用此函数
 *@param error 错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error
{
    WLog(@"定位失败");
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations{
    WLog(@"%@", locations);
}
/**
 *返回地址信息搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKGeoCodeSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
}

/**
 *返回反地理编码搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    
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
