//
//  MKbackView.h
//  JianZhi
//
//  Created by Monky on 16/2/19.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKbackView : UIView

+ (id)shareBackView;

- (void)popView:(UIView *)view;

+ (void)hideView;
@end
