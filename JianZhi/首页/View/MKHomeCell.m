//
//  MKHomeCell.m
//  JianZhi
//
//  Created by Monky on 16/2/22.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKHomeCell.h"
#import "MKHomeCellModel.h"

@interface MKHomeCell ()
@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *MKTitleLabel;
@property (nonatomic, strong) UILabel *MKSubTitleLabel;
@property (nonatomic, strong) UILabel *MKSalaryLabel;

@end


@implementation MKHomeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self configSubViews];
        //		self.sep
        
    }
    return self;
}

- (void)configSubViews {
    self.leftLabel = [[UILabel alloc] init];
    // 自定义的控件要加到 self.contentView 上面
    [self.contentView addSubview:self.leftLabel];
    
    [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.and.height.equalTo(50);
        make.left.equalTo(WPedding);
        make.centerY.equalTo(0);
    }];
    
    self.leftLabel.layer.cornerRadius = 25;
    self.leftLabel.layer.borderColor = WArcColor.CGColor;
    self.leftLabel.layer.borderWidth = 1.0f;
    self.leftLabel.textAlignment = NSTextAlignmentCenter;
    self.leftLabel.font = [UIFont systemFontOfSize:15];
    self.leftLabel.textColor = WArcColor;
    
    self.MKSalaryLabel = [[UILabel alloc] init];
    // 自定义的控件要加到 self.contentView 上面
    [self.contentView addSubview:self.MKSalaryLabel];
    
    [self.MKSalaryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-8);
        make.top.equalTo(WPedding);
    }];
    [self.MKSalaryLabel sizeToFit];
    self.MKSalaryLabel.textAlignment = NSTextAlignmentCenter;
    self.MKSalaryLabel.font = [UIFont systemFontOfSize:14];
    self.MKSalaryLabel.textColor = WColorFontContent;
    
    self.MKTitleLabel = [[UILabel alloc] init];
    // 自定义的控件要加到 self.contentView 上面
    [self.contentView addSubview:self.MKTitleLabel];
    
    [self.MKTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftLabel.mas_right).offset(8);
        make.top.equalTo(8);
        make.right.lessThanOrEqualTo(self.MKTitleLabel.mas_left).offset(-6);
    }];
    [self.MKTitleLabel sizeToFit];
    self.MKTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.MKTitleLabel.font = [UIFont systemFontOfSize:15];
    self.MKTitleLabel.textColor = WColorFontTitle;
    
    
    self.MKSubTitleLabel = [[UILabel alloc] init];
    // 自定义的控件要加到 self.contentView 上面
    [self.contentView addSubview:self.MKSubTitleLabel];
    
    [self.MKSubTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftLabel.mas_right).offset(8);
        make.top.equalTo(self.MKSubTitleLabel.mas_bottom).offset(6);
    }];
    [self.MKSubTitleLabel sizeToFit];
    self.MKSubTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.MKSubTitleLabel.font = [UIFont systemFontOfSize:13];
    self.MKSubTitleLabel.textColor = WColorFontDetail;
}

- (void)configWithModel:(MKHomeCellModel *)model {
    self.MKTitleLabel.text = [NSString stringWithFormat:@"%@%@%@", model.title, model.title, model.title];
    self.MKSubTitleLabel.text = model.district;
    self.leftLabel.text = @"展会";
    self.MKSalaryLabel.text = model.showprice;
}



@end
