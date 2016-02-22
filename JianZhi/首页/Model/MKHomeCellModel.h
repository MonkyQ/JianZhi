//
//  MKHomeCellModel.h
//  JianZhi
//
//  Created by Monky on 16/2/22.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKHomeCellModel : NSObject

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *channel_type;

@property (nonatomic, copy) NSString *sex;

@property (nonatomic, copy) NSString *clearing_type;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *lat;

@property (nonatomic, assign) BOOL applies_state;

@property (nonatomic, copy) NSString *city;

@property (nonatomic, copy) NSString *showprice;

@property (nonatomic, copy) NSString *district;

@property (nonatomic, copy) NSString *lng;

@property (nonatomic, copy) NSString *top_status;

@end
