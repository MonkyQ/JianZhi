//
//  MKNetHelp.h
//  JianZhi
//
//  Created by Monky on 16/2/20.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface MKNetHelp : AFHTTPSessionManager

//封装 Get请求 成功与失败分开
//+ (void)getDataWithParam:(NSDictionary *)params andPath:(NSString *)path andSuccess:(void(^)(id responseObject))sucess failure:(void(^)(id result))failure;
//封装 Post请求 成功与失败分开
//+ (void)postDataWithParam:(NSDictionary *)params andPath:(NSString *)path andSuccess:(void(^)(id responseObject))sucess failure:(void(^)(id result))failure;

//+ (NSURLSessionDataTask *)getDataWithParam:(NSDictionary *)params orpostDataWithParam:(NSDictionary *)Postparams andPath:(NSString *)path andSuccess:(void(^)(id responseObject))sucess failure:(void(^)(id result))failure;
//
//+ (NSURLSessionDataTask *)postDataWithParam:(NSDictionary *)params andPath:(NSString *)path andCompleete:(void(^)(BOOL success,id result))complete;

// 封装 Get 请求，成功和失败分开处理
+ (void)getDataWithParam:(NSDictionary *)params andPath:(NSString *)path andComplete:(void (^)(BOOL success, id result))complete;

// 封装 Get 请求，成功和失败在一个 block 里面处理
+ (void)postWithParam:(NSDictionary *)params andPath:(NSString *)path andComplete:(void (^)(BOOL success, id result))complete;

@end
