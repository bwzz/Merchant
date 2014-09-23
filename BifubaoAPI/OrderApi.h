//
//  OrderApi.h
//  Merchant
//
//  Created by wanghb on 14-9-23.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "BaseEngine.h"

@interface OrderApi : BaseEngine
-(MKNetworkOperation*)createInternal:(NSString*) productHashId handler:(Handler*) handler;
@end
