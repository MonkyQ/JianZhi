//
//  MKMyQRCodeViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/23.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKMyQRCodeViewController.h"
#import "QREncoder.h"


@interface MKMyQRCodeViewController ()
{
    CGFloat _brightess;
}
@end

@implementation MKMyQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // CIFilter *filter = [CIFilter filterWithName:<#(nonnull NSString *)#>];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc]init];
    [self.view addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(0);
        make.width.height.equalTo(150);
    }];
    // 把上面生成的数据，转化为一个二维码图片
    int qrcodeImageDimension = 250;
   	DataMatrix *matrix = [QREncoder encodeWithECLevel:QR_ECLEVEL_H version:QR_VERSION_AUTO string:@"www.baidu.com"];
    UIImage *image = [QREncoder renderDataMatrix:matrix imageDimension:qrcodeImageDimension];
    imageView.image = image;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // iOS 5.0 才加入的 api,调整系统亮度
    _brightess = [UIScreen mainScreen].brightness;
    
    [[UIScreen mainScreen] setBrightness:1.0];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[UIScreen mainScreen] setBrightness:_brightess];
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
