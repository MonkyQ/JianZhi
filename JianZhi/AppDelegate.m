//
//  AppDelegate.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "AppDelegate.h"
#import "MKViewController.h"


@interface AppDelegate ()

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

    
//    [self cheackNewVersion];
//    [self cheackNewVersionFromAppStore];
    return YES;
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

@end
