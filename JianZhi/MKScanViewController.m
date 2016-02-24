//
//  MKScanViewController.m
//  JianZhi
//
//  Created by Monky on 16/2/23.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MKMyQRCodeViewController.h"
#import "UIControl+ActionBlocks.h"
static NSInteger WScanWidth = 160;
//static NSInteger WBottomPedding = 170;

//AVCaptureMetadataOutputObjectsDelegate这个代理只有一个方法需要实现 用于处理输出
@interface MKScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    int _num;
    BOOL _upOrdown;
    NSTimer *_timer;
    CGFloat _oriBrightess;
}
//硬件捕捉
@property (nonatomic,strong)AVCaptureDevice *device;
//从硬件摄像头输入数据
@property (nonatomic,strong)AVCaptureDeviceInput *input;
//识别二维码后输出的数据
@property (nonatomic,strong)AVCaptureMetadataOutput *output;
//闪光灯
@property (nonatomic,strong)AVCaptureSession *session;
//预览扫描视频的Layer
@property (nonatomic,strong)AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic,strong)UILabel *resultLabel;
@property (retain, nonatomic) UIImageView *line;
@end

@implementation MKScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //扫描设置
    [self configCapture];
    //界面设置
    [self configSubViews];
    self.view.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.750];

}

//因为打开摄像头需要的时间很长,写到视图已经出现的方法里,防止阻碍push视图出现
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //打开
    [self setUpCamera];

}



//添加下方按钮配置界面
- (void)configSubViews {
    // 用于存放解析到的二维码结果字符串
    self.resultLabel = [[UILabel alloc] init];
    [self.view addSubview:self.resultLabel];
    self.resultLabel.backgroundColor = [UIColor colorWithRed:0.522 green:0.953 blue:0.460 alpha:0.408];
    [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(WPedding);
        make.height.equalTo(48);
        make.centerX.equalTo(0);
    }];
    
    // 返回
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"返回" forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-48);
        make.left.equalTo(0);
        make.height.equalTo(48);
    }];
    //分类中的方法
    [cancelBtn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        // 这个页面有循环引用，需要在页面消失时候，销毁成员变量，防止内存泄露。
        [self dismissViewControllerAnimated:YES completion:^{
            // 停止扫描，销毁对象
            [_session stopRunning];
            _session = nil;
            _device = nil;
            _input = nil;
            _output = nil;
        }];
    }];
    
    UIButton *shanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shanBtn setTitle:@"打开闪光灯" forState:UIControlStateNormal];
    [self.view addSubview:shanBtn];
    [shanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-48);
        make.centerX.equalTo(0);
        make.height.equalTo(cancelBtn);
        make.width.equalTo(cancelBtn);
    }];
    [shanBtn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        //闪光灯
        AVCaptureTorchMode torch = self.input.device.torchMode;
        switch (_input.device.torchMode) {
            case AVCaptureTorchModeAuto:
                break;
            case AVCaptureTorchModeOff:
                torch = AVCaptureTorchModeOn;
                break;
            case AVCaptureTorchModeOn:
                torch = AVCaptureTorchModeOff;
                break;
            default:
                break;
        }
        //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
        [_input.device lockForConfiguration:nil];
        //设置闪光灯状态
        _input.device.torchMode = torch;
        [_input.device unlockForConfiguration];
    }];
    
    UIButton *myQRCodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [myQRCodeBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
    [self.view addSubview:myQRCodeBtn];
    [myQRCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(-48);
        make.right.equalTo(-16);
        make.height.equalTo(cancelBtn);
        make.width.equalTo(cancelBtn);
    }];
    
    [myQRCodeBtn handleControlEvents:UIControlEventTouchUpInside withBlock:^(id weakSender) {
        MKMyQRCodeViewController *myQRCodeVC = [[MKMyQRCodeViewController alloc]init];
        [self.navigationController pushViewController:myQRCodeVC animated:YES];
    }];
    UIImageView *borderImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanBorder"]];
    [self.view addSubview:borderImage];
    [borderImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(0);
        make.bottom.equalTo(myQRCodeBtn.mas_top).offset(-100);
        make.size.equalTo(CGSizeMake(WScanWidth, WScanWidth));
    }];
    
    _line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ScanLine"]];
    [borderImage addSubview:_line];
    [_line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(0);
        make.top.equalTo(0);
        make.width.equalTo(borderImage);
    }];
    
    _upOrdown = NO;
    _num = 0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}
//动画 移动扫描条
- (void)animation {
    if (_upOrdown == NO) {
        _num ++;
        CGPoint center = _line.center;
        center.y += 2;
        _line.center = center;
        if (2 * _num == WScanWidth - 10) {
            _upOrdown = YES;
        }
    }
    else {
        _num --;
        CGPoint center = _line.center;
        center.y -= 2;
        _line.center = center;
        if (_num == 0) {
            _upOrdown = NO;
        }
    }
}
- (void)configCapture
{
    NSError *error = nil;
    // Device
    //创建一个捕捉视频流的设备
    //AVMediaTypeVideo视频
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    //输入流 捕捉到的视频
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    
    if (!_input) {
        WLog(@"%@", [error localizedFailureReason]);
        return;
    }
    //如果还没有获取过摄像头权限 申请获取权限 如果用户拒绝了 就直接退出
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        WLog(@"没有打开照相机的权限");
        return;
    }
    // Output
    //视频输出流,输出流把内容发送给metadataObject进行识别
    _output = [[AVCaptureMetadataOutput alloc] init];
    //输出流在主线程刷新
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // Session
    //输入输出流中间处理的桥梁
    _session = [[AVCaptureSession alloc] init];
    //AVCaptureSessionPresetHigh捕捉到的信息的分辨率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    //分别桥接输入输出流
    if ([_session canAddInput:self.input]){
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output]){
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    //AVMetadataObjectTypeQRCode二维码(条形码)
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    // Preview
    //视频预览Layer
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:1].CGColor;
    _previewLayer.frame = CGRectMake(0, 0, WScreenWidth, WScreenHeight);
    //将_previewLayer插入到self.view.layer 上面
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    // rectOfInterest 代表我们识别二维码的区域。
    // 圆角的二维码和被挡住一部分的二维码特别难以识别，缩小识别范围可以提升识别速度。
    // _output 的 rectOfInterest，是以图片形式识别二维码的，图片是横着的，手机屏幕是竖着的。
    // x 和 y 是反着的， 宽和高也是反着的。x\y\width\height 的值，都是在 0 - 1 之间。
    // 以比例的方式设置。
    _output.rectOfInterest = CGRectMake(0.25, 0.25, 0.5, 0.5);

}
//开启摄像头
- (void)setUpCamera
{
    // 开始捕捉视频
    [_session startRunning];
}
- (void)createBackLayerWithFrame:(CGRect)frame{
    CALayer *backLayer = [CALayer layer];
    backLayer.frame = frame;
    backLayer.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.550].CGColor;
    [self.view.layer addSublayer:backLayer];
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    NSString *stringValue;
    if (metadataObjects != nil && [metadataObjects count] >0){
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        self.resultLabel.text = stringValue;
    }else {
        
    }
}

- (void)dealloc {
    //必须在这里停掉扫描
    [_session stopRunning];
    [_timer setFireDate:[NSDate distantFuture]];
    [_timer invalidate];
    //销毁对象
    _timer = nil;
    _session = nil;
    _device = nil;
    _input = nil;
    _output = nil;
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
	[_session stopRunning];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
