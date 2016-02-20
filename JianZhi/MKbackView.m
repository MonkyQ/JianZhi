//
//  MKbackView.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKbackView.h"
#import "AppDelegate.h"
#import "MKLoginView.h"
static MKbackView *_shareBackView = nil;

@implementation MKbackView

+ (id)shareBackView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareBackView = [[super allocWithZone:NULL]initWithFrame:CGRectMake(0, 0, WScreenWidth, WScreenHeight)];
        _shareBackView.backgroundColor = [UIColor lightGrayColor];
        _shareBackView.frame = CGRectMake(0, 0, WScreenWidth, WScreenHeight);
        
        [_shareBackView addGesture];
    });
    return _shareBackView;
}
- (void)addGesture
{
    UITapGestureRecognizer *g1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapBackView)];
    [self addGestureRecognizer:g1];
}
- (void)tapBackView
{
    [self removeFromSuperview];
}

- (void)popView:(UIView *)view
{
    //当前程序运行的window
    UIWindow *window = [(AppDelegate *)[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.left.equalTo(16);
    }];
    
}
@end
