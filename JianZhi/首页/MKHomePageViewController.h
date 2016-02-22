//
//  MKHomePageViewController.h
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKHomePageViewController : UIViewController

/**
 *  兼职活动类型
 */
@property (strong, nonatomic) NSString *channelType;

/**
 *  地区
 */
@property (strong, nonatomic) NSString *city;

/**
 *  筛选时间
 */
@property (strong, nonatomic) NSString *filtrateTime;
@end
