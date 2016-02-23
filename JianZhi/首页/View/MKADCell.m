//
//  MKADCell.m
//  JianZhi
//
//  Created by Monky on 16/2/22.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKADCell.h"
#import "MKADCellModel.h"
#import "MKWebViewController.h"
#import "UIView+ViewController.h"

static NSInteger const QFADImageBaseTag = 10;

@interface MKADCell ()<UIScrollViewDelegate>
@property (nonatomic,strong) NSArray *adModels;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSTimer *timer;

@end


@implementation MKADCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self= [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configScrollView];
        [self configTimer];
    }
    return self;
}

- (void)configScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc]init];
    //关闭竖直上的弹性效果
    scrollView.bounces = NO;
    //关闭滚动条
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    
    //sutoLayout布局scrollView时候一定要先加一个contentView撑起来
    UIView *contentView = [[UIView alloc]init];
    [scrollView addSubview:contentView];
    
    [self.contentView addSubview:scrollView];
    
    //循环创建时 自动布局
    UIView *lastView = nil;
    for (int i = 0; i<3; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        
        // 将 imageView 加入到 scollView 的 contentView 上。
        [contentView addSubview:imageView];
        
        imageView.tag = QFADImageBaseTag + i;
        imageView.userInteractionEnabled = YES;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            // 如果是第一个 imageView (lastView 不存在)，则设置约束最左边为0，否则设置约束最左边为上个 imageView 的最右边，挨个排列。
            make.left.equalTo(lastView?lastView.mas_right:@0);
            make.top.bottom.equalTo(@0);
            // 设置每个 imageView 的宽度等于cell 的宽度。
            make.width.equalTo(self.contentView);
        }];
        lastView = imageView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushToWebVC)];
        [imageView addGestureRecognizer:tap];
    }
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(0);
        // 设置 contentView 的底部约束，防止图片被截取
        make.bottom.equalTo(self.contentView);
        // 设置 contentView 的右边约束，等于最后一个 imageView 的最右边。
        make.right.equalTo(lastView.mas_right);
        
    }];
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
        make.right.equalTo(contentView.mas_right);
    }];
    
    UIPageControl *pageControl = [[UIPageControl alloc]init];
    pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    pageControl.currentPageIndicatorTintColor = WColorMain;
    self.pageControl = pageControl;
    [self.contentView addSubview:pageControl];
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(0);
        make.width.greaterThanOrEqualTo(48);
        
    }];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl = pageControl;
    pageControl.currentPage = 0;
    
    scrollView.delegate = self;
    // 默认 scrollView 显示的是第二个 imageView 上面的内容
    scrollView.contentSize = CGSizeMake(WScreenWidth * 3, 120);
    scrollView.contentOffset = CGPointMake(WScreenWidth, 0);
    self.scrollView = scrollView;
    self.currentPage = 0;

    
    
}
- (void)changePage:(UIPageControl *)pageControl
{
    self.currentPage = pageControl.currentPage;
    [self configImageView];
    
}
- (void)configWithModel:(NSArray *)model
{
    self.adModels = model;
    self.pageControl.numberOfPages = self.adModels.count;
    [self configImageView];
}
- (void)configImageView {
    
    NSInteger page = (self.currentPage - 1 + self.adModels.count) % self.adModels.count;
    
    for (int i = 0; i < 3; ++i) {
        // viewWithTag 方法，是递归查找子 view 里是否有对应 tag 的控件。
        int pageIndex = (int)(i + page) % self.adModels.count;
        MKADCellModel *model = [self.adModels objectAtIndex:pageIndex];
        
        UIImageView *imageView = [self.contentView viewWithTag:QFADImageBaseTag + i];
        imageView.image = [UIImage imageNamed:model.imageUrl];
    }
    self.pageControl.currentPage = self.currentPage;
    self.scrollView.contentOffset = CGPointMake(WScreenWidth, 0);
    // 调用 scrollRectToVisible: 手动设置 scrollView 滑动到相应的位置
    //	[self.scrollView scrollRectToVisible:CGRectMake(0, WScreenWidth, 0, 0) animated:YES];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger pageIndex = floor((scrollView.contentOffset.x - WScreenWidth) / WScreenWidth);
    
    // 当前页加一或者减一，并且不会小于0，不会超过广告的条数。
    self.currentPage = (pageIndex + self.currentPage) % self.adModels.count;
    
    [self configImageView];
}
- (void)configTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(autoChagePage) userInfo:nil repeats:YES];
}

- (void)autoChagePage {
    self.currentPage = (self.currentPage + 1) % self.adModels.count;
    [self configImageView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self pushToWebVC];
    }
}

- (void)pushToWebVC {
    MKWebViewController *webVC = [[MKWebViewController alloc] init];
    webVC.hidesBottomBarWhenPushed = YES;
    
    MKADCellModel *model = [self.adModels objectAtIndex:self.currentPage];
    webVC.urlPath = model.action;
    
    // 由 view 直接找到 viewController
    [self.viewController.navigationController pushViewController:webVC animated:YES];
}


@end
