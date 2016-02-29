//
//  MKWebViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/22.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKWebViewController.h"

#import "UMSocial.h"

#import "OpenShare.h"
#import "OpenShareHeader.h"
@interface MKWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate>
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation MKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self configWebView];
    
    // 在导航条上面加入一个按钮，用于分享网页
    [self setUpNaviItem];
}
- (void)setUpNaviItem {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareWebSite)];
}
- (void)shareWebSite {
    // 用友盟自带的分享面板分享
    //	[UMSocialSnsService presentSnsIconSheetView:self
    //										 appKey:@"507fcab25270157b37000010"
    //									  shareText:@"你要分享的文字"
    //									 shareImage:[UIImage imageNamed:@"icon.png"]
    //								shareToSnsNames:[NSArray arrayWithObjects:UMShareToSina,UMShareToWechatSession,UMShareToQQ,nil]
    //									   delegate:nil];
    // 用 UIActionSheet 弹出框，显示需要的分享面板。
    // 用 titleArr 存储可以用的第三方平台
    //	NSMutableArray *titleArr = [[NSMutableArray alloc] init];
    //
    //	if ([OpenShare isWeixinInstalled]) {
    //		[titleArr addObjectsFromArray:@[@"微信登录", @"分享给微信朋友", @"分享到朋友圈"]];
    //
    //	}
    //
    //	if ([OpenShare isQQInstalled]) {
    //		[titleArr addObjectsFromArray:@[@"QQ登录", @"分享到QQ好友"]];
    //	}
    //
    //	[titleArr addObject:nil];
    
    // 一般不用 ActionSheet 首先，不能显示图标，再者，无法方便的定义显示的按钮
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"分享" delegate:self cancelButtonTitle:@"取消分享" destructiveButtonTitle:nil otherButtonTitles:@"微信登录", @"分享给微信朋友", @"分享到朋友圈", @"QQ登录", @"分享到QQ好友", nil];
    
    [actionSheet showInView:self.view];
    
}

- (void)configWebView {
    self.webView = [[UIWebView alloc] init];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(0);
    }];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlPath]];
    [self.webView loadRequest:request];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // OpenShare 登录微信，用 block 处理结果
        [OpenShare WeixinAuth:@"snsapi_userinfo" Success:^(NSDictionary *message) {
            WLog(@"message = %@", message);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString: [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=wxd930ea5d5a258f4f&secret=0c806938e2413ce73eef92cc3&code=%@&grant_type=authorization_code", message[@"code"]]]];
                WLog(@"%@", dic);
                
            });
            
        } Fail:^(NSDictionary *message, NSError *error) {
            
            WLog(@"error = %@", error);
        }];
    }else if (buttonIndex == 1) {
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
