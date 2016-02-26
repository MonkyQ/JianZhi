//
//  MKRegisterViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKRegisterViewController.h"
#import "UIImage+Color.h"
#import "UIView+Extension.h"
#import "MKNetHelp.h"
#import "MKbackView.h"
#import "ReactiveCocoa.h"
#import "MKTextField.h"
#import "UIControl+ActionBlocks.h"


@interface MKRegisterViewController ()

@property (nonatomic,strong)MKTextField *numberText;
@property (nonatomic,strong)MKTextField *cheakText;
@property (nonatomic,strong)MKTextField *passwordText;
@property (nonatomic,strong)MKTextField *inviteText;
@property (nonatomic,assign)NSNumber *waitNumber;
@property (nonatomic,strong)UIButton *btn;
@property (nonatomic,strong)NSTimer *waitTimer;

@end

@implementation MKRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始值设置为-1 表示现在可以获取验证码
    self.waitNumber = @-1;
    self.waitTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeRealse) userInfo:nil repeats:YES];
    // 先让定时器不可用
    [self.waitTimer setFireDate:[NSDate distantFuture]];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.963 alpha:1.000];
    self.navigationItem.title = @"新用户注册";
    //设置左返回
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"navi_back_new"] forState:UIControlStateNormal];
    btn.size = btn.currentBackgroundImage.size;
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self setupView];
}
- (void)timeRealse
{
    if (self.waitNumber.intValue ==-1) {
        [self.waitTimer setFireDate:[NSDate distantFuture]];
    }
    self.waitNumber = [NSNumber numberWithInt:self.waitNumber.intValue - 1];
}
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupView
{
    //手机号
    MKTextField *numberText = [[MKTextField alloc]init];
    numberText.backgroundColor = [UIColor whiteColor];
    numberText.placeholder = @"输入手机号";
    //进入是成为第一响应者
    [numberText becomeFirstResponder];
    [self.view addSubview:numberText];
    //布局
    [numberText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64);
        make.height.mas_equalTo(48);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];

    
    //验证码
    MKTextField *cheakText = [[MKTextField alloc]init];
    cheakText.placeholder = @"验证码";
    cheakText.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cheakText];
    [cheakText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(numberText.mas_bottom).offset(0);
        make.height.mas_equalTo(numberText);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    //发送按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [btn setTitleColor:WColorDarkGray forState:UIControlStateDisabled];
    [btn setTitleColor:WColorAssist forState:UIControlStateNormal];
    [btn setTitleColor:WColorFontContent forState:UIControlStateHighlighted];
    btn.titleLabel.font = [UIFont systemFontOfSize:13];
    cheakText.rightView = btn;
    btn.enabled = NO;
    cheakText.rightViewMode = UITextFieldViewModeAlways;
    
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(150, 50));
    }];
    //密码
    MKTextField *passwordText = [[MKTextField alloc]init];
    passwordText.placeholder = @"密码";
    passwordText.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:passwordText];
    [passwordText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cheakText.mas_bottom).offset(0);
        make.height.mas_equalTo(numberText);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    //邀请码
    MKTextField *inviteText = [[MKTextField alloc]init];
    inviteText.placeholder = @"邀请码(可不填)";
    inviteText.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:inviteText];
    [inviteText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordText.mas_bottom).offset(0);
        make.height.mas_equalTo(numberText);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    //注册按钮
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[UIImage imageWithColor:WColorDarkGray] forState:UIControlStateDisabled];
    [registerBtn setBackgroundImage:[UIImage imageWithColor:WColorMain] forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[UIImage imageWithColor:WColorLightGray] forState:UIControlStateHighlighted];
    registerBtn.enabled = NO;
    registerBtn.layer.cornerRadius = 5;
    registerBtn.clipsToBounds = YES;
    [self.view addSubview:registerBtn];
    [registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordText.mas_bottom).offset(78);
        make.height.mas_equalTo(48);
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
    }];
    [registerBtn addTarget:self action:@selector(registerUser) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.numberText handleControlEvents:UIControlEventEditingChanged withBlock:^(MKTextField *weakSender) {
        //当手机号输入符合规则 自动跳到下一个
        if (weakSender.text.length>=11&&[[weakSender text]hasPrefix:@"1"]) {
            [self.cheakText becomeFirstResponder];
            //在这里判断手机号是否被注册过
            [self judgePhoneRegister];
        }
    }];
    
    [self.cheakText handleControlEvents:UIControlEventEditingChanged withBlock:^(MKTextField *weakSender) {
        //当手机号输入符合规则 自动跳到下一个
        if ([weakSender text].length>=4) {
            [self.passwordText becomeFirstResponder];
        }
    }];
    

    [btn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        [self getCode];
    }];
    //获取验证码的按钮状态
    RAC(btn,enabled) = [RACSignal combineLatest:@[numberText.rac_textSignal,RACObserve(self, waitNumber)] reduce:^id(NSString *number,NSNumber *waitNumber){
        return @((number.length ==11)&&(waitNumber.intValue ==-1));
    }];

    //信号流
    RAC(registerBtn,enabled) = [RACSignal combineLatest:@[numberText.rac_textSignal,passwordText.rac_textSignal,cheakText.rac_textSignal] reduce:^id(NSString *number,NSString *pwd,NSString *cheak){
        NSLog(@"%@,%@,%@",number,pwd,cheak);
        return @(number.length ==11&&pwd.length>=6&&cheak.length==4);
    }];

    [RACObserve(self, waitNumber)subscribeNext:^(NSNumber *number) {
        if (number.intValue > 0) {
            [self.btn setTitle:[NSString stringWithFormat:@"%@秒后重试",number] forState:UIControlStateNormal];
        }else if (number.intValue ==0){
            [self.btn setTitle:@"获取验证码" forState:UIControlStateNormal];        }
    }];
    self.numberText =numberText;
    self.passwordText =passwordText;
    self.inviteText = inviteText;
    self.cheakText = cheakText;
    self.btn = btn;
}
- (void)registerUser
{///app_api.php?token=565e9507862572d85920de12a783e09f&refer=zx&tag=yhzc& phone=&password=&smscode=&offercode=
    
    NSDictionary *param = @{
                            @"phone": self.numberText.text,
                            @"password": self.passwordText.text,
                            @"smscode": self.cheakText.text,
                            @"offercode": self.inviteText.text,
                            };
    [MKNetHelp postWithParam:param andPath:@"http://wap2.yojianzhi.com/app_api.php?token=565e9507862572d85920de12a783e09f&refer=zx&tag=yhzc" andComplete:^(BOOL success, id result) {
        if (success) {
            NSString *res = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
            if ([res isEqualToString:@"0"]) {
                WLog(@"请求失败,请重试");
            }else if([res isEqualToString:@"-1"])
            {
                WLog(@"验证码已过期");
            }else
            {
                WLog(@"userid = %@", res);
            }
            WLog(@"登录成功, %@", result);
            [MKbackView hideView];
        }
    }];
}
//判断是否注册过
- (void)judgePhoneRegister
{
    NSDictionary *param = @{
                            @"phone":self.numberText.text,
                        
                            };
    [MKNetHelp postWithParam:param andPath:@"app_api.php?token=565e9507862572d85920de12a783e09f&refer=zx&tag=sjsfzc" andComplete:^(BOOL success, id result) {
        if (success) {
            
            NSString *res = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
            if ([res isEqualToString:@"0"]) {
                WLog(@"请求失败,请稍后再试");
            }else if ([res isEqualToString:@"1"]){
                WLog(@"此手机号已经注册过,请登陆");
                //设置获取验证码按钮不可用
                self.waitNumber = @0;
            }
        }
    }];
}

- (void)getCode
{
    NSDictionary *param = @{
                            @"phone":self.numberText.text,
                            
                            };
    [MKNetHelp postWithParam:param andPath:@"app_api.php?token=565e9507862572d85920de12a783e09f&refer=dx&tag=fsyzm" andComplete:^(BOOL success, id result) {
        if (success) {
            
            NSString *res = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
            if ([res isEqualToString:@"0"]) {
                WLog(@"请求失败,请稍后再试");
            }else if ([res isEqualToString:@"1"]){
                WLog(@"验证码获取成功");
                //设置获取验证码按钮倒计时
                self.waitNumber = @60;
                //让定时器开始计时
                [self.waitTimer setFireDate:[NSDate date]];
            }
        }
    }];    
}




@end
