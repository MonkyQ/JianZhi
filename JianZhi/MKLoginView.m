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
#import <AFHTTPSessionManager.h>

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
}
//用户登录
- (IBAction)userLogin:(id)sender {

    //参数必须--/app_api.php?token= 565e9507862572d85920de12a783e09f&refer=zx&tag=yhdl& phone=&password=
    NSDictionary *param = @{
                            @"phone":self.nameText.text,
                            @"password":self.passwordText.text
                            };
    [MKNetHelp postDataWithParam:param andPath:@"/app_api.php?token= 565e9507862572d85920de12a783e09f&refer=zx&tag=yhdl" andSuccess:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(id result) {
        NSLog(@"%@",result);
    }];
}


@end
