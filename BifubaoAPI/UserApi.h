//
//  UserApi.h
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "BaseEngine.h"

@interface UserApi : BaseEngine
-(MKNetworkOperation*)loginWithName:(NSString*) phone_or_email password:(NSString*) password handler:(Handler*)handler;
-(MKNetworkOperation*)loginByApp:(Handler*)handler;
-(MKNetworkOperation*)userInfo:(Handler*)handler;
-(MKNetworkOperation*)createAppForRefreshToken:(Handler*)handler;
@end
