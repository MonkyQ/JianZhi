//
//  MKTextField.m
//  JianZhi
//
//  Created by Monky on 16/2/22.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKTextField.h"
#import "FrameAccessor.h"

@implementation MKTextField


// 手动创建的默认设置
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _leftPedding = WPedding;
        self.returnKeyType = UIReturnKeyDone;
    }
    return self;
}

// xib 时候的默认设置
- (void)awakeFromNib {
    [super awakeFromNib];
    self.leftPedding = _leftPedding;
    self.returnKeyType = UIReturnKeyDone;
}

// 设置左边空白边距
- (void)setLeftPedding:(NSInteger)leftPedding {
    _leftPedding = leftPedding;
    // 刷新界面
    [self layoutIfNeeded];
}

// 设置右边空白边距
- (void)setRightPedding:(NSInteger)rightPedding {
    _rightPedding = rightPedding;
    // 刷新界面
    [self layoutIfNeeded];
}

// 正常文字范围
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(_leftPedding + self.leftView.width, 0, bounds.size.width - _leftPedding - self.leftView.width - _rightPedding - self.rightView.width, bounds.size.height);
}
// 提示文字范围
- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectMake(_leftPedding + self.leftView.width, 0, bounds.size.width - _leftPedding - self.leftView.width - _rightPedding - self.rightView.width, bounds.size.height);
}
// 边距区域
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectMake(_leftPedding + self.leftView.width, 0, bounds.size.width - _leftPedding - self.leftView.width - _rightPedding - self.rightView.width, bounds.size.height);
}
// rightView 范围
- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.size.width - _rightPedding - self.rightView.width, floor((bounds.size.height - self.rightView.height) / 2), self.rightView.width, self.rightView.height);
}
// leftView 范围
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    return CGRectMake(_leftPedding, floor((bounds.size.height - self.leftView.height) / 2), self.leftView.width, self.leftView.height);
}

@end
