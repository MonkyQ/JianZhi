//
//  MKLostViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/20.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKLostViewController.h"
#import "UIImage+Color.h"
#import "UIView+Extension.h"
#import "MKNetHelp.h"
#import "MKbackView.h"
#import "ReactiveCocoa.h"
#import "MKTextField.h"

@interface MKLostViewController ()


@end

@implementation MKLostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.963 alpha:1.000];
    self.navigationItem.title = @"找回密码";
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
    passwordText.placeholder = @"输入新密码";
    passwordText.layer.borderColor = WColorLightGray.CGColor;
    passwordText.layer.borderWidth = 1.0f;
    passwordText.backgroundColor = [UIColor whiteColor];
    passwordText.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:passwordText];
    [passwordText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cheakText.mas_bottom).offset(0);
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
        make.top.mas_equalTo(numberText.bottom).offset(126);
        make.height.mas_equalTo(48);
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
    }];
    [registerBtn addTarget:self action:@selector(findUser) forControlEvents:UIControlEventTouchUpInside];
}

- (void)findUser
{
    
}
@end
