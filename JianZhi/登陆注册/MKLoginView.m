//
//  MKLoginView.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//
#import "MKLoginView.h"
#import "ReactiveCocoa.h"
#import "UIImage+Color.h"
#import "AFHTTPSessionManager.h"
#import "MKViewController.h"
#import "MKRegisterViewController.h"
#import "MKbackView.h"
#import "MKLostViewController.h"



@implementation MKLoginView

+(MKLoginView *)MKLoginView
{
    MKLoginView *login = [[[NSBundle mainBundle] loadNibNamed:@"MKLoginView" owner:nil options:nil]lastObject];
    
    NSLog(@"-.-");
    return login;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self= [super initWithCoder:aDecoder])
    {
        NSLog(@"0.0");
    }
    return self;
}
//如果要获得控件 在这个方法中实现
- (void)awakeFromNib
{
    NSLog(@"+.+");
    //登陆按钮
    [_commitBtn setBackgroundImage:[UIImage imageWithColor:WColorMain] forState:UIControlStateNormal];
    [_commitBtn setBackgroundImage:[UIImage imageWithColor:WColorLightGray] forState:UIControlStateHighlighted];
    [_commitBtn setBackgroundImage:[UIImage imageWithColor:WColorFontDetail] forState:UIControlStateDisabled];
    _commitBtn.layer.cornerRadius = 5;
    _commitBtn.clipsToBounds = YES;
    
    //文本框属性设置
    _nameText.layer.borderWidth = 1.0f;
    _nameText.layer.borderColor = WColorMain.CGColor;
    _nameText.layer.cornerRadius = 5;
    _passwordText.layer.borderColor = WColorMain.CGColor;
    _passwordText.layer.borderWidth = 1.0f;
    _passwordText.layer.cornerRadius = 5;
    //leftView  rightView
    _passwordText.secureTextEntry = YES;
    //图片
    UIButton *seePassword = [UIButton buttonWithType:UIButtonTypeCustom];
    [seePassword setImage:[UIImage imageNamed:@"Password_show"] forState:UIControlStateNormal];
    [seePassword setImage:[UIImage imageNamed:@"Password_hide"] forState:UIControlStateSelected];
    _passwordText.rightView =seePassword;
    _passwordText.rightViewMode = UITextFieldViewModeAlways;
    [seePassword mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(50, 50));
    }];
    [seePassword addTarget:self action:@selector(seePassword:) forControlEvents:UIControlEventTouchUpInside];
    
    //下划线处理
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"免费注册"];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [_registerBtn setTintColor:WColorAssist];
    [_registerBtn setAttributedTitle:str forState:UIControlStateNormal];
    //RACObserve(_nameText, text)---KVO失去焦点时变化
    //reactiveCocoa合并信号流
    RAC(self.commitBtn,enabled) = [RACSignal combineLatest:@[_nameText.rac_textSignal,_passwordText.rac_textSignal] reduce:^id(NSString *name, NSString *password){
        NSLog(@"%@, %@", name, password);
        return @(name.length ==11&&password.length>=6);
    }];
    
    [_registerBtn addTarget:self action:@selector(gotoRegisterVC) forControlEvents:UIControlEventTouchUpInside];
    [_forgetBtn addTarget:self action:@selector(gotoLostVC) forControlEvents:UIControlEventTouchUpInside];
    
    
}
- (void)gotoRegisterVC
{
    [MKbackView hideView];
    MKViewController *MKVC = (MKViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    UINavigationController *currentNav = [MKVC selectedViewController];
    MKRegisterViewController *registerVC = [[MKRegisterViewController alloc]init];
    [currentNav pushViewController:registerVC animated:YES];
}
- (void)gotoLostVC
{
    [MKbackView hideView];
    MKViewController *MKVC = (MKViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
    UINavigationController *currentNav = [MKVC selectedViewController];
    MKLostViewController *registerVC = [[MKLostViewController alloc]init];
    [currentNav pushViewController:registerVC animated:YES];
}

- (void)seePassword:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.passwordText.secureTextEntry = !btn.isSelected;
    
}
//用户登录
- (IBAction)userLogin:(id)sender {

    //参数必须--/app_api.php?token= 565e9507862572d85920de12a783e09f&refer=zx&tag=yhdl& phone=&password=
    NSDictionary *param = @{
                            @"phone":self.nameText.text,
                            @"password":self.passwordText.text
                            };
    [MKNetHelp postWithParam:param andPath:@"/app_api.php?token=565e9507862572d85920de12a783e09f&refer=zx&tag=yhdl" andComplete:^(BOOL success, id result) {
        if (success) {
            WLog(@"登录成功, %@", result);
            [MKbackView hideView];
            
            //在登录成功的时候发送一个通知,告诉所有的观察者登陆成功 并且附上用户名
            [[NSNotificationCenter defaultCenter]postNotificationName:@"MKLoginSuccess" object:self.nameText.text];
        }else
        {
            WLog(@"登录失败, %@", result);
        }
    }];
    
     }


@end
