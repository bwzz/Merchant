//
//  ProductApi.m
//  Merchant
//
//  Created by wanghb on 14-9-22.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "ProductApi.h"

@implementation ProductApi

-(MKNetworkOperation*)listWithPageNo:(int)pageNo andPageSize:(int)pageSize handler:(Handler*) handler{
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    return [self createOperation:createPath(@"product/list/") params:param handler:handler];
}
@end
