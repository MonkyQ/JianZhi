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
        _shareManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/text",@"text/xml",@"text/json",@"application/json", nil];

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
        
        if ([result isEqual:@"0"]) {
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
@end
