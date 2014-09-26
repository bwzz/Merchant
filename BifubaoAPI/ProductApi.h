//
//  ProductApi.h
//  Merchant
//
//  Created by wanghb on 14-9-22.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "BaseEngine.h"

@interface ProductApi : BaseEngine
-(MKNetworkOperation*)listWithPageNo:(int)page andPageSize:(int)pageSize handler:(Handler*) handler;
-(MKNetworkOperation*)productDetail:(NSString*)productId handler:(Handler*) handler;
-(MKNetworkOperation*)orderList:(NSString*)productId page:(int) page pageSize:(int) pageSize handler:(Handler*) handler;
@end
