//
//  MKbackView.m
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKbackView.h"
#import "AppDelegate.h"
#import "MKLoginView.h"
static MKbackView *_shareBackView = nil;

@interface MKbackView ()<UIGestureRecognizerDelegate>
// 点击是否隐藏
@property (assign, nonatomic) BOOL isTouchHidden;
// 蒙版上面的弹出框
@property (strong, nonatomic) UIView *topView;
// 是否是正在弹出状态
@property (assign, nonatomic) BOOL isPopping;
// 键盘弹出时上移高度
@property (assign, nonatomic) NSInteger popHeight;
@end


@implementation MKbackView

+ (id)shareBackView
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareBackView = [[super allocWithZone:NULL]initWithFrame:CGRectMake(0, 0, WScreenWidth, WScreenHeight)];
_shareBackView.popHeight = WButtonHeight;
        // 设置背景模糊效果
        [_shareBackView configBlur];
        // 设置背景颜色
        [_shareBackView configUnderView];
        // 设置单击手势
        [_shareBackView addGesture];
    });
    return _shareBackView;
}

- (void)configBlur
{
    // 是否动态更新
    self.dynamic = NO;
    // 是否开启高斯模糊
    self.blurEnabled = YES;
    // 模糊效果
    self.blurRadius = 5.0f;
}
- (void)configUnderView {
    // 以一个 underView 放到高斯模糊背景的下面，控制模糊的颜色效果
    UIView *underView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WScreenWidth, WScreenHeight)];
    underView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.670];
    [self addSubview:underView];
    [underView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)addGesture
{// 为蒙层添加一个单击手势，target 设为类方法，防止引用环
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[self class] action:@selector(tapBackView:)];
    // 设置单击手势的代理
    [tap setDelegate:self];
    [self addGestureRecognizer:tap];
    // 默认设置为可单击隐藏
    _shareBackView.isTouchHidden = YES;

}
// 点击背景时，是否隐藏
+ (void)tapBackView:(UITapGestureRecognizer *)tap {
    if (_shareBackView.isTouchHidden == YES) {
        [self hideView];
    }
    [_shareBackView endEditing:YES];
}
// 点击弹出框，隐藏键盘
+ (void)tapTopView:(UITapGestureRecognizer *)tap {
    [_shareBackView endEditing:YES];
}

// 弹出蒙层
+ (void)popView {
    [[self shareBackView] popView];
}

- (void)popView {
    // 将弹出状态设为真
    self.isPopping = YES;
    // 监控键盘弹出通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    // 监控键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // 将蒙版加到 window 上面，覆盖整个界面
    UIWindow *window = [(AppDelegate *)[UIApplication sharedApplication].delegate window];
    [window addSubview:self];
    [self popTopView];
}
- (void)popTopView {
    // 如果现在状态没有弹出
    if (!self.isPopping) {
        [self popView];
    }
    [self endEditing:YES];
    // 设置弹出框的圆角
    self.topView.layer.cornerRadius = WCornerRadius;
    self.topView.layer.masksToBounds = YES;
    _topView.alpha = 1.0f;
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.left.equalTo(@(WPedding));
    }];
    [self layoutIfNeeded];
    
    // 在弹出框上面再加一个单击手势，防止点击弹出框时隐藏整个蒙层
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:[self class] action:@selector(tapTopView:)];
    [tap setDelegate:self];
    [_topView addGestureRecognizer:tap];
    
    // spring 动画弹出 view
    _topView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:WAnimationTime * 1.5 delay:0.0 usingSpringWithDamping:0.75 initialSpringVelocity:1.0 options:UIViewAnimationOptionTransitionNone animations:^{
        _topView.transform = CGAffineTransformIdentity;
    } completion:nil];
}
// 调用此方法弹出
+ (void)exchangeTopViewWith:(UIView *)newView isTouchHide:(BOOL)isTouchHidden {
    [[self shareBackView] setIsTouchHidden:isTouchHidden];
    [self exchangeTopViewWith:newView];
}
// 先移除原有的弹出框，再弹出新的。
- (void)exchangeTopViewWith:(UIView *)newView{
    [self removeTopView:^{
        self.topView = newView;
        newView.center = CGPointMake(WScreenWidth / 2, WScreenHeight / 2);
        [self popTopView];
    }];
}
+ (void)exchangeTopViewWith:(UIView *)newView {
    [[self shareBackView] exchangeTopViewWith:newView];
}
- (void)removeTopView:(void (^)(void))complete{
    if (self.topView) {
        // 消失动画
        //		_topView.transform = CGAffineTransformScale(_topView.transform, 0.5, 0.5);
        //		[UIView animateWithDuration:WAnimationTime animations:^{
        //			_topView.transform = CGAffineTransformMakeScale(0.001, 0.001);
        //			_topView.alpha = 0.5f;
        //		} completion:^(BOOL finished) {
        [self.topView removeFromSuperview];
        if (complete) {
            complete();
        }
        //		}];
    }else {
        if (complete) {
            complete();
        }
    }
}
- (void)removeFromSuperview {
    [self removeTopView:^{
        // 更新状态、删除手势
        self.isPopping = NO;
        [_topView.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [_topView removeGestureRecognizer:obj];
        }];
        self.topView = nil;
        // 去除监听通知
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [super removeFromSuperview];
    }];
}

// 隐藏蒙层
+ (void)hideView {
    [[self shareBackView] removeFromSuperview];
}
// 键盘弹出
- (void)keyboardWasShown:(NSNotification *)keyboardShownNoti {
    NSDictionary *keyboardInfo = keyboardShownNoti.userInfo;
    // 取出键盘高度
    NSInteger keyboardHeight = [[keyboardInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    // 动画更新 view 的中心
    NSUInteger centerY = WScreenHeight - keyboardHeight - self.topView.frame.size.height / 2 + 50- self.popHeight;
    CGPoint center = CGPointMake(WScreenWidth / 2, centerY);
    [UIView animateWithDuration:WAnimationTime animations:^{
        self.topView.center = center;
    }];
}
// 键盘消失
- (void)keyboardWillBeHidden:(NSNotification *)keyboardHiddenNoti {
    // 动画形式将弹出框中心更新为蒙层中心
    CGPoint center = CGPointMake(WScreenWidth / 2, WScreenHeight / 2);
    [UIView animateWithDuration:WAnimationTime animations:^{
        self.topView.center = center;
    }];
}
#pragma mark - UIGestureRecognizerDelegate
// called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // 解决手势冲突
    if ([touch.view isEqual:_topView] || [touch.view.superview isEqual:self]) {
        return YES;
    }
    return NO;
}

@end
