//
//  MKNetHelp.m
//  JianZhi
//
//  Created by Monky on 16/2/20.
//  Copyright © 2016年 Monky. All rights reserved.
//

#import "MKNetHelp.h"

static MKNetHelp *_shareManager = nil;


@implementation MKNetHelp

+ (id)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareManager = [[super allocWithZone:NULL]initWithBaseURL:[NSURL URLWithString:@"http://wap2.yojianzhi.com"]];
        //设置返回数据的类型为原始的数据不然是二进制
        _shareManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _shareManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];

    });
    return  _shareManager;

}

//封装 Get请求 成功与失败分开
+ (void)getDataWithParam:(NSDictionary *)params andPath:(NSString *)path andSuccess:(void(^)(id responseObject))sucess failure:(void(^)(id result))failure
{
    [[self shareManager]GET:path parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
    }];
    
}
//封装 Post请求 成功与失败分开
+ (void)postDataWithParam:(NSDictionary *)params andPath:(NSString *)path andSuccess:(void(^)(id responseObject))sucess failure:(void(^)(id result))failure
{
    [[self shareManager]POST:path parameters:path success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([result isEqualToString:@"0"]) {
            result =@"登录失败";
        }else
        {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        }
        NSLog(@"%@",result);
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        id result = error.localizedDescription;
        NSLog( @"%@",result);
    }];
}


// 封装 Get 请求，成功和失败分开处理
+ (void)getDataWithParam:(NSDictionary *)params andPath:(NSString *)path andComplete:(void (^)(BOOL success, id result))complete {
    [[self shareManager] GET:path parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        
        
    }];
}

// 封装 Get 请求，成功和失败在一个 block 里面处理
+ (void)postWithParam:(NSDictionary *)params andPath:(NSString *)path andComplete:(void (^)(BOOL success, id result))complete {
    [[self shareManager] POST:path parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        BOOL success = YES;
        id result;
        
        NSString *resultStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([resultStr isEqualToString:@"0"]) {
            success = NO;
            result = @"登录失败，请重试";
        }else {
            result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        }
        complete(success, result);
        
    } failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
        BOOL success = NO;
        id result = error.localizedDescription;
        complete(success, result);
        
    }];
}


@end
