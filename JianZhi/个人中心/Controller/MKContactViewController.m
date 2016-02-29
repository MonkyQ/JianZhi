//
//  MKContactViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/27.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKContactViewController.h"
#import "UIControl+ActionBlocks.h"
#import <MessageUI/MessageUI.h>

@interface MKContactViewController ()<MFMessageComposeViewControllerDelegate>

@end

@implementation MKContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}
- (void)loadView
{
    [super loadView];
    
    [self loadSubViews];
}
//加载子视图
- (void)loadSubViews
{
    UIButton *phoneBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneBtn1 setTitle:@"直接打电话" forState:UIControlStateNormal];
    [phoneBtn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:phoneBtn1];
    [phoneBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(16);
        make.width.equalTo(self.view.mas_width).dividedBy(4);
        make.top.equalTo(WTopHeight + 16);
        make.height.equalTo(self.view.mas_width).dividedBy(8);
    }];
    
    UIButton *phoneBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [phoneBtn2 setTitle:@"提示打电话" forState:UIControlStateNormal];
    [phoneBtn2 setTitleColor:[UIColor colorWithRed:0.400 green:1.000 blue:0.400 alpha:1.000] forState:UIControlStateNormal];
    [self.view addSubview:phoneBtn2];
    [phoneBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(-16);
        make.width.equalTo(phoneBtn2);
        make.top.equalTo(WTopHeight + 16);
        make.height.equalTo(phoneBtn2);
    }];
    [phoneBtn1 handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        //用openURL方式打电话----直接跳转到电话界面(app) 直接拨打
        //用这种方式打电话上架会被拒
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tel://10086"]];
    }];
    [phoneBtn2 handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        //用UIWebView打电话
        //系统会弹出警示框  是否呼叫
        UIWebView *webView = [[UIWebView alloc]init];
        NSURL *url = [NSURL URLWithString:@"tel://10086"];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
        
        [self.view addSubview:webView];
    }];
    
    UIButton *smsBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [smsBtn1 setTitle:@"直接发短信" forState:UIControlStateNormal];
    [smsBtn1 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:smsBtn1];
    [smsBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(16);
        make.width.equalTo(self.view.mas_width).dividedBy(4);
        make.bottom.equalTo(-WTopHeight + 16);
        make.height.equalTo(self.view.mas_width).dividedBy(8);
    }];
    UIButton *smsBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [smsBtn2 setTitle:@"指定内容" forState:UIControlStateNormal];
    [smsBtn2 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:smsBtn2];
    [smsBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.equalTo(-16);
        make.width.equalTo(self.view.mas_width).dividedBy(3);
        make.bottom.equalTo(-WTopHeight + 16);
        make.height.equalTo(self.view.mas_width).dividedBy(8);
    }];
    
    [smsBtn1 handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        //用openUrl方式 指定短信发送人 发送短信---直接跳转到短信应用
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"sms://10086"]];
    }];
    [smsBtn2 handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *mfMessageVC = [[MFMessageComposeViewController alloc]init];
            //可以定义多个接受者(群发短信)
            //很重要 接受者最多不要超过50个 如果超过就会卡在短信界面
            mfMessageVC.recipients = @[@"10086",@"10010"];
            //设置短信内容
            mfMessageVC.body =@"66";
            //可以设置代理
            mfMessageVC.messageComposeDelegate = self;
            
            //这里不能用Push 应该用present-----继承自NavVC
            [self.navigationController presentViewController:mfMessageVC animated:YES completion:nil];
                        
        }else
        {
            WLog(@"你的设备不支持发送短信");

        }
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    /*
     enum MessageComposeResult {
     MessageComposeResultCancelled,
     MessageComposeResultSent,
     MessageComposeResultFailed
     };

     */
    //虽然说返回的是MessageComposeResult 但不能断定短信发送成功
    if (result ==MessageComposeResultCancelled) {
        WLog(@"取消发送");
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
    
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
