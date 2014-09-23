//
//  OrderApi.m
//  Merchant
//
//  Created by wanghb on 14-9-23.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "OrderApi.h"

@implementation OrderApi

-(MKNetworkOperation*)createInternal:(NSString*) productHashId handler:(Handler*) handler{
    NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
    [param setValue:productHashId forKey:@"product_hash_id"];
    [param setValue:@"1" forKey:@"quantity"];
    return [self createOperation:createPath(@"order/createinternal/") params:param handler:handler];
}

@end
