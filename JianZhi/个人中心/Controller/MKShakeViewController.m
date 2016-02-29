//
//  MKShakeViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/27.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKShakeViewController.h"
#import "UIView+Shake.h"

@interface MKShakeViewController ()
{
    UIImageView *_imageView;
}
@end

@implementation MKShakeViewController

- (void)loadView
{
    [super loadView];
    
    [self loadSubViews];
}

- (void)loadSubViews
{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"4.jpg"]];
    [self.view addSubview:imageView];
    _imageView = imageView;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
        make.height.equalTo(imageView.mas_width);
        make.left.equalTo(16);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //加入摇一摇
    [[UIApplication sharedApplication]setApplicationSupportsShakeToEdit:YES];
    //以当前的控制器设置为第一响应者 以响应摇一摇手势
    [self becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//上滑菜单 在上层使用3的 Touch peek时候 可以弹出此方法返回的数组
- (NSArray<id<UIPreviewActionItem>> *)previewActionItems
{
    UIPreviewAction *item1 = [UIPreviewAction actionWithTitle:@"收藏" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //上滑后的操作
        WLog(@"赞");
    }];
    UIPreviewAction *item2 = [UIPreviewAction actionWithTitle:@"扔掉" style:UIPreviewActionStyleDefault handler:^(UIPreviewAction * _Nonnull action, UIViewController * _Nonnull previewViewController) {
        //上滑后的操作
        WLog(@"扔掉");
    }];
    return @[item1,item2];
}


//这三个方法是识别摇一摇手势的三种状态的回调方法
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    WLog(@"开始摇一摇");
}
//摇一摇完成
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    WLog(@"结束");
    [_imageView shake];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    WLog(@"取消摇一摇");
    
}


@end
