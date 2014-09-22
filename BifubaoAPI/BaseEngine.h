//
//  BaseEngine.h
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "MKNetworkEngine.h"
#import "NSMutableDictionary+ParamBuilder.h"
#import "Handler.h"

#define createPath(path) [NSString stringWithFormat:@"v00002/%@", path]
#define HOST_NAME @"testapi.bifubao.com"

@interface BaseEngine : MKNetworkEngine
-(id)initWithDefaultHostName;
-(MKNetworkOperation*)createOperation:(NSString*) path params:(NSMutableDictionary*) param handler:(Handler*)handler;
@end
