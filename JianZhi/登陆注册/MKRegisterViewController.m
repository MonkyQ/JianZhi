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


@interface MKRegisterViewController ()

@property (nonatomic,weak)UITextField *numberText;
@property (nonatomic,weak)UITextField *cheakText;
@property (nonatomic,weak)UITextField *passwordText;
@property (nonatomic,weak)UITextField *inviteText;

@end

@implementation MKRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0.963 alpha:1.000];
    self.navigationItem.title = @"新用户注册";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setBackgroundImage:[UIImage imageNamed:@"navi_back_new"] forState:UIControlStateNormal];
    btn.size = btn.currentBackgroundImage.size;
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    //   btn.size = btn.currentBackgroundImage.size;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self setupView];
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
    numberText.font = [UIFont systemFontOfSize:13];
    numberText.layer.borderColor = WColorLightGray.CGColor;
    numberText.layer.borderWidth = 1.0f;
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
    cheakText.layer.borderColor = WColorLightGray.CGColor;
    cheakText.layer.borderWidth = 1.0f;
    cheakText.font = [UIFont systemFontOfSize:13];
        cheakText.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cheakText];
    [cheakText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(numberText.mas_bottom).offset(0);
        make.height.mas_equalTo(numberText);
        make.left.mas_equalTo(0);
        // make.width.mas_equalTo(width);
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
    passwordText.layer.borderColor = WColorLightGray.CGColor;
    passwordText.layer.borderWidth = 1.0f;
        passwordText.backgroundColor = [UIColor whiteColor];
    passwordText.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:passwordText];
    [passwordText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cheakText.mas_bottom).offset(0);
        make.height.mas_equalTo(numberText);
        make.left.mas_equalTo(0);
        // make.width.mas_equalTo(width);
        make.right.mas_equalTo(0);
    }];
    
    //邀请码
    MKTextField *inviteText = [[MKTextField alloc]init];
    inviteText.placeholder = @"邀请码(可不填)";
    inviteText.layer.borderColor = WColorLightGray.CGColor;
    inviteText.layer.borderWidth = 1.0f;
        inviteText.backgroundColor = [UIColor whiteColor];
    inviteText.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:inviteText];
    [inviteText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordText.mas_bottom).offset(0);
        make.height.mas_equalTo(numberText);
        make.left.mas_equalTo(0);
        // make.width.mas_equalTo(width);
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
    
    //信号流
    RAC(registerBtn,enabled) = [RACSignal combineLatest:@[numberText.rac_textSignal,passwordText.rac_textSignal,cheakText.rac_textSignal] reduce:^id(NSString *number,NSString *pwd,NSString *cheak){
        NSLog(@"%@,%@,%@",number,pwd,cheak);
        return @(number.length ==11&&pwd.length>=6&&cheak.length>0);
    }];
    
    self.numberText =numberText;
    self.passwordText =passwordText;
    self.inviteText = inviteText;
    self.cheakText = cheakText;
    
}
- (void)registerUser
{///app_api.php?token=565e9507862572d85920de12a783e09f&refer=zx&tag=yhzc& phone=&password=&smscode=&offercode=
    
    NSDictionary *param = @{
                            @"phone":self.numberText.text,
                            @"password":self.passwordText.text,
                            @"smscode":self.cheakText.text,
                            @"offercode":self.inviteText.text
                            };
    [MKNetHelp postWithParam:param andPath:@"/app_api.php?token=565e9507862572d85920de12a783e09f&refer=zx&tag=yhzc" andComplete:^(BOOL success, id result) {
        if (success) {
            WLog(@"登录成功, %@", result);
            [MKbackView hideView];
        }else{
              WLog(@"登录失败, %@", result);
        }
    }];
}
@end
