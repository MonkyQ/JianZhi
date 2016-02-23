//
//  MKbackView.h
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"

@interface MKbackView : FXBlurView
// 单例蒙版对象。
+ (id)shareBackView;

//- (void)popView:(UIView *)view;
// 弹出蒙版上的控件，isTouchHide 表示点击蒙版是否隐藏
+ (void)exchangeTopViewWith:(UIView *)newView isTouchHide:(BOOL)isTouchHidden;
// 隐藏蒙版和上面的弹出框
+ (void)hideView;
@end
