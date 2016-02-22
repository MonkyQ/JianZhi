//
//  MKTextField.h
//  JianZhi
//
//  Created by Monky on 16/2/22.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKTextField : UITextField
// 左边空余宽度
@property (assign, nonatomic) NSInteger leftPedding;
// 右边空余宽度
@property (assign, nonatomic) NSInteger rightPedding;
@end
