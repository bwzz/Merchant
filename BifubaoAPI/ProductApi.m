//
//  ProductApi.m
//  Merchant
//
//  Created by wanghb on 14-9-22.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "ProductApi.h"

@implementation ProductApi

-(MKNetworkOperation*)listWithPageNo:(int)page andPageSize:(int)pageSize handler:(Handler*) handler{
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setValue:@(page).stringValue forKey:@"page_no"];
    [param setValue:@(pageSize).stringValue forKey:@"page_size"];
    return [self createOperation:createPath(@"product/list/") params:param handler:handler];
}

-(MKNetworkOperation*)productDetail:(NSString*)productId handler:(Handler*) handler{
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setValue:productId forKey:@"product_id"];
    return [self createOperation:createPath(@"product/detail/") params:param handler:handler];
}

-(MKNetworkOperation*)orderList:(NSString*)productId page:(int) page pageSize:(int) pageSize handler:(Handler*) handler {
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setValue:productId forKey:@"product_id"];
    [param setValue:@(page).stringValue forKey:@"page_no"];
    [param setValue:@(pageSize).stringValue forKey:@"page_size"];
    return [self createOperation:createPath(@"product/orderlist/") params:param handler:handler];
}
@end
