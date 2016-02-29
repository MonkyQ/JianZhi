//
//  MKShakeViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/27.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKShakeViewController.h"
#import "UIView+Shake.h"

#import "UIView+Screenshot.h"

#import "WXApi.h"
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
    //当摇一摇时候屏幕截图
    [_imageView setImage:[self.view screenshot]];
    //弹出分享框
    [self showShareView];
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    WLog(@"取消摇一摇");
    
}
- (void)showShareView {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消分享" destructiveButtonTitle:nil otherButtonTitles:@"微信朋友分享", @"微信朋友圈", @"微信登录", nil];
    
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    // 分享消息的步骤
    // 1. 构造一条要分享的消息，设置消息类型
    // 2. 构造分享的内容，图片、文字、视频、网站......
    // 3. 构造一个分享请求，设置分享的场景和消息。
    // 4. 请求微信分享
    //判断点击的是哪一个
    if (buttonIndex ==0) {
        /*
         //构造一条要分享的信息
         WXMediaMessage *message = [WXMediaMessage message];
         
         //设置要分享的图片
         WXImageObject *imageObject = [WXImageObject object];
         //分享时候可以使用本地的图片 也可以使用网络上的图片
         // 用 UIImagePNGRepresentation 将图片无损压缩，转换成 NSData 对象。
         imageObject.imageData = UIImagePNGRepresentation(_imageView.image);
         //UIImageJPEGRepresentation 将图片有损压缩成 jpeg 格式，第二个参数为压缩的质量。
         imageObject.imageData = UIImageJPEGRepresentation(_imageView.image, 0.5);
         //设置成缩略图
         [message setThumbImage:_imageView.image];
         //设置要分享的图片
         [message setMediaObject:imageObject];
         */
        //构造分享请求,把上面的消息传递给微信
        SendMessageToWXReq *sendReq = [[SendMessageToWXReq alloc]init];
        //设置分享内容为媒体类型
        sendReq.bText = YES;
        // 设置分享的文字
        sendReq.text = @"你必须全力以赴，才能看起来毫不费力";
        //设置分享的消息
       // sendReq.message = message;
        //设置分享的场景
        sendReq.scene = WXSceneSession;
        //给微信发送分享请求
        BOOL res = [WXApi sendReq:sendReq];
        WLog(@"%d", res);
        
        // 判断微信是否安装
        WLog(@"%d", [WXApi isWXAppInstalled]);
        
        // 利用下面的方法，判断手机上是否安装了某个软件
        //		[[UIApplication sharedApplication] canOpenURL:<#(nonnull NSURL *)#>]
        
        // 判断当前微信的版本是否支持OpenApi
        WLog(@"%d", [WXApi isWXAppSupportApi]);
        
        // 什么都不做，直接打开微信应用
        //		WLog(@"%d", [WXApi openWXApp]);
        
    }else if (buttonIndex ==2){
        //1.设置登陆的quthReq
        //2.设置authReq 的scope、state、openid
        SendAuthReq *authReq = [[SendAuthReq alloc]init];
        authReq.scope = @"snsapi_userinfo";
        authReq.state = @"123";
        // openID 是申请应用第三方登录权限时候给的。
        authReq.openID = @"0c806938e2413ce73eef92cc3";
        // 申请微信登录
        [WXApi sendAuthReq:authReq viewController:self delegate:self];
    }
}



@end
