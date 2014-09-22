//
//  UserApi.m
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "UserApi.h"

@implementation UserApi
-(MKNetworkOperation*)loginWithName:(NSString*) phone_or_email password:(NSString*) password handler:(Handler*)handler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:phone_or_email forKey:@"phone_or_email"];
    [params setValue:@"1" forKey:@"is_need_rsa"];
    [params setValue:password forKey:@"password"];
    [params setValue:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKeyPath:@"_time_"];
    Handler* wrapHandler = [[Handler alloc] init];
    wrapHandler.succedHandler = ^(Result* result){
        NSString *pk =result.result[@"session"][@"rsa_private_key"];
        NSString *token =result.result[@"session"][@"token"];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:pk forKey:@"rsa_private_key"];
        [userDefaults setValue:token forKey:@"token"];
        if (handler != nil) {
            [handler handleResult:result];
        }
    };
    return [self createOperation:createPath(@"user/login/") params:params handler:wrapHandler];
}

-(MKNetworkOperation*)userInfo:(Handler*)handler {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    return [self createOperation:createPath(@"user/info/") params:param handler:handler];
}

@end
