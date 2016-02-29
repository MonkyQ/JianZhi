//
//  AppDelegate.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "AppDelegate.h"
#import "MKViewController.h"

#import "JPUSHService.h"

#import "MKViewController.h"
#import "MKScanViewController.h"

#import "BaiduMapAPI_Base.framework/Headers/BMKMapManager.h"
#import "BaiduMapAPI_Map.framework/Headers/BMKMapView.h"

#import "WXApi.h"

#import "OpenShare.h"
#import "OpenShareHeader.h"

@interface AppDelegate ()<WXApiDelegate>
{
      BMKMapManager* _mapManager;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    
    //1.创建Window
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //2.添加代码
    MKViewController *MKVC = [[MKViewController alloc]init];
    self.window.rootViewController = MKVC;
    //3.将window显示出来
    [self.window makeKeyAndVisible];

    //版本查询
//    [self cheackNewVersion];
//    [self cheackNewVersionFromAppStore];
    
    // 配置极光推送环境和申请推送权限。
    [self setUpJpush:launchOptions];
    
    // 注册一些通知，比如监控是否登录
    [self rigistNotification];
    
    // 每次打开应用，先判断上次别名设置是否成功，如果没有设置成功，继续设置。
    [self setAlias];
    
    
    
    //配置百度地图
    [self setupBaiduMap];
    
    
    //配置快捷菜单有静态和动态之分
    //静态配置通过修改Plist.info文件 设置快捷菜单
    //还可以通过代码设置
    //type是标识快捷菜单项的唯一字符串
    UIApplicationShortcutItem *firstItem = [[UIApplicationShortcutItem alloc]initWithType:@"First" localizedTitle:@"第一个菜单" localizedSubtitle:@"这是子标题" icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypePlay] userInfo:nil];
    UIApplicationShortcutItem *secondItem = [[UIApplicationShortcutItem alloc]initWithType:@"Second" localizedTitle:@"第二个菜单" localizedSubtitle:nil icon:[UIApplicationShortcutIcon iconWithType:UIApplicationShortcutIconTypeLove] userInfo:nil];
    [[UIApplication sharedApplication]setShortcutItems:@[firstItem,secondItem]];
    
    // 配置微信的 appkey, 也就是在工程配置里面添加的 scheme
    [self setUpWeChat];
    
    
    //配置OpenShare
    [self setupOpenShare];

    return YES;
}

- (void)setupOpenShare
{
    [OpenShare connectWeixinWithAppId:@"wxd930ea5d5a258f4f"];
    
    [OpenShare connectQQWithAppId:@"100424468"];
}
// 配置微信的 appkey, 也就是在工程配置里面添加的 scheme
- (void)setUpWeChat {
    [WXApi registerApp:@"wxd930ea5d5a258f4f" withDescription:@"我是谁"];
}


- (void)setupBaiduMap
{
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [_mapManager start:@"S3xF9q2InjWnv5rxWhRxGuD4"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
}


- (void)setUpJpush:(NSDictionary *)launchOptions
{
    [JPUSHService setupWithOption:launchOptions appKey:@"7a7480d43b98d2a36626c517" channel:@"appStore" apsForProduction:NO];
    
    //	if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {

    //	}
    //	UIUserNotificationTypeBadge   = 1 << 0, // the application may badge its icon upon a notification being received
    //	UIUserNotificationTypeSound   = 1 << 1, // the application may play a sound upon a notification being received
    //	UIUserNotificationTypeAlert   = 1 << 2
    // 申请远程推送权限
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
}
- (void)rigistNotification {
    // 监控登录成功的通知
    // 当用户登录的时候，需要给极光推送设置别名为用户名。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MKloginSuccess:) name:@"MKLoginSuccess" object:nil];
    
    // 当用户推出登录的时候，要将别名设置为空。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MKlogoffSuccess:) name:@"MKLogOffSuccess" object:nil];
}
//登陆成功
- (void)MKloginSuccess:(NSNotification *)noti {
    
    // 取出登录成功的用户手机号
    NSString *userID = noti.object;
    
    [self setAlias:userID];
    // 将此手机号设置为极光推送的别名
}
//设置别名
- (void)setAlias:(NSString *)alias {
    //	[JPUSHService setAlias:userID callbackSelector:@selector() object:<#(id)#>]
    [JPUSHService setTags:nil alias:alias fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        // iResCode 为0 表示设置成功，6002 表示超时
        // 当设置别名失败的时候，重新调用此方法，继续设置，直到设置成功。
        if (iResCode != 0) {
            NSDictionary *aliasInfo = @{
                                        @"success": @"NO",
                                        @"alias": alias,
                                        };
            
            [[NSUserDefaults standardUserDefaults] setObject:aliasInfo forKey:@"alias"];
            
            [self setAlias:alias];
        }else {
            
            NSDictionary *aliasInfo = @{
                                        @"success": @"YES",
                                        @"alias": alias,
                                        };
            
            [[NSUserDefaults standardUserDefaults] setObject:aliasInfo forKey:@"alias"];
        }
        WLog(@"%d, %@, %@", iResCode, iTags, iAlias);
    }];
}
//每次进入应用是判断别名是否设置成功
- (void)setAlias {
    // 取出存放的别名设置
    NSDictionary *aliasInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"alias"];
    
    NSString *res = [aliasInfo objectForKey:@"success"];
    // 判断上次是否设置成功，如果不成功，就继续设置别名。
    if ([res isEqualToString:@"NO"]) {
        [self setAlias:[aliasInfo objectForKey:@"alias"]];
    }
}
//退出登陆
- (void)MKlogoffSuccess:(NSNotification *)noti  {
    // 设置 alias 为空字符串 @"" 时，代表取消这个手机以前设置的别名
    [JPUSHService setTags:nil alias:@"" fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        // iResCode 为0 表示设置成功，6002 表示超时
        WLog(@"%d, %@, %@", iResCode, iTags, iAlias);
    }];
}


#define LAST_RUN_VERSION_KEY        @"last_run_version_of_application"
// 本地应用监测是否安装了更新的版本。
// 判断打开应用时候，是否播放欢迎动画。
- (void)cheackNewVersion {
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LAST_RUN_VERSION_KEY];
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        //		return YES;
        // App is being run for first time
    }else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        //		return YES;
        // App has been updated since last run
    }
    //	return NO;
}

// 监测 appStore 是否有更新的版本需要更新。
// 从服务器接口获取最新的数据
- (void)cheackNewVersionFromAppStore {
    NSDictionary *versionInfo = @{
                                  @"version" : @"3.0",
                                  @"isUpdateForce" : @"1",
                                  @"newVersionContent" : @"修复了一些bug",
                                  };
    // 取出本地版本号。
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleShortVersionString"];
    
    if (![currentVersion isEqualToString:versionInfo[@"version"]]) {
        WLog(@"有新版本");
        if ([versionInfo[@"isUpdateForce"] isEqualToString:@"1"]) {
            // 打开 appstore,让用户更新最新的版本。
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:WAppStoreLink]];
        }
        
    }
    
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//先申请权限才会有
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 把 deviceToken 上传到极光，通过这个可以给指定的手机发送推送消息
    [JPUSHService registerDeviceToken:deviceToken];

}

// 申请远程推送权限失败调用。
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    WLog(@"error:%@", error);
}

// 写处理推送消息的方法
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //iOS6 之前用这个方法吃力远程推送
    WLog(@"%@", userInfo);
    
    [JPUSHService handleRemoteNotification:userInfo];
}


// 假如现在有需求
// 给所有在上海的手机推送消息
// 现在 18513017173 这个账号购买了一个东西，已经送到，需要推送一条消息，告诉用户。

// 极光推送的几种推送方式
// 1> 群推，手动给所有安装了软件的用户推送（推广告）
// 2> 通过 tag （标签）推送，上海就是一个标签,要这样推送，首先要给所有在上海的手机用户打上标签
// 一个手机可以有多个标签，既可以打上上海的标签，也可以用 男女作为标签，
// 3> 通过 alias (别名) 推送，18513017173(手机号)可以作为一个用户的别名。
// 一个手机只有一个别名，设置新的别名，会把原来设置过的覆盖。

// 当应用在前台时候，收到远程推送，会调用这个方法。

// 当应用点击通知栏推送消息时，会先进入这个方法。

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //iOS6以后的处理
    // 都需要先把推送消息用 极光推送处理。
    [JPUSHService handleRemoteNotification:userInfo];
    // 清空通知栏通知，清除应用 icon 上面的角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 可以通过自定义 sound 参数，播放不同的声音
    // 声音文件必须是 caf 格式的。
    
    
    WLog(@"%@", userInfo);
    // 取出推送消息
    NSDictionary *apsInfo = userInfo[@"aps"];
    
    // 取出通知类型
    NSString *notiType = userInfo[@"noti_type"];
    // 取出推送的内容
    NSString *message = apsInfo[@"alert"];
    
    if ([notiType isEqualToString:@"alert"]) {
        //      这个枚举类型代表当前应用所处的状态，是在激活状态（前台），还是后台。
        //		UIApplicationStateActive,
        //		UIApplicationStateInactive,
        //		UIApplicationStateBackground
        // 当应用在前台接到推送消息时，弹出警示框
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            
        }
        // 当应用点击通知栏进入的时候，跳转到相应的 viewController;
        // 根据应用不同的状态和通知的不同类型，做不同的处理。
        else {
            MKViewController *tabVC = (MKViewController *)[self window].rootViewController;
            UINavigationController *currentNaviVC = [tabVC selectedViewController];
            
            MKScanViewController *scanVC = [[MKScanViewController alloc] init];
            
            [currentNaviVC pushViewController:scanVC animated:YES];
            
        }
    }
    
    completionHandler(UIBackgroundFetchResultNewData);
}

//点击快捷菜单会调用这个方法
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    NSString *type = [shortcutItem type];
    if ([type isEqualToString:@"First"]) {
        
        
        UINavigationController *naviVC = [(MKViewController *)self.window.rootViewController selectedViewController];
        
        [naviVC pushViewController:[[MKScanViewController alloc] init] animated:YES];

    }else{
    
    }
    
}


// 1. 从别的应用打开本应用，并且带回的 url 需要咱们自己处理,不知道是具体从哪个应用调回的。
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    // 返回一个 bool 类型，表示能否处理这个 url
    	//return [WXApi handleOpenURL:url delegate:self];
    
    //return [UMSocialSnsService handleOpenURL:url];
    
    
    // 让 OpenShare 去处理第三方应用传回的 url，处理成功或者失败
    return [OpenShare handleOpenURL:url];
}

// 2. 从别的应用打开本应用，并且带回的 url 需要咱们自己处理,但是知道具体是从哪个应用回调回来的。
// 比如分享完成，登录成功。
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    	//return [WXApi handleOpenURL:url delegate:self];
   // return [UMSocialSnsService handleOpenURL:url];
    if ([OpenShare handleOpenURL:url]) {
        return YES;
    }else {
        return [WXApi handleOpenURL:url delegate:self];
    }
    
    return [OpenShare handleOpenURL:url];

}


/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
-(void) onReq:(BaseReq*)req {
    
}


/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */

-(void) onResp:(BaseResp*)resp {
    
    SendAuthResp *authResp = resp;
    
    NSString *code = authResp.code;
    
    // 当第三方（微信）登录成功之后，会返回一个 code ,我们可以通过 code 去获取操作微信的 access_token，只有这个 token 才能获取用户信息等等操作。
    // 但是其他的一些第三方平台，可能直接把 access_token 和 openuserId 返回给我们，直接可以操作。
    //	https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    // 异步和同步方法，前面加 a 就是异步
    //	dispatch_sync(<#dispatch_queue_t queue#>, <#^(void)block#>)
    // 异步于主线程获取微信的 access_token
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=wxd930ea5d5a258f4f&secret=0c806938e2413ce73eef92cc3&code=%@&grant_type=authorization_code", code]]];
        WLog(@"%@", dic);
        
    });
    
}

@end
