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
    [params setValue:password forKey:@"password"];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [self login:createPath(@"user/login") params:params signatureKey:[userDefaults valueForKey:@"rsa_private_key"] handler:handler];
}

-(MKNetworkOperation*)loginByApp:(Handler*)handler {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [params setValue:[userDefaults valueForKey:@"app_hash_id"] forKey:@"_app_hash_id_"];
    return [self login:createPath(@"user/loginbyapp") params:params signatureKey:[userDefaults valueForKey:@"app_private_key"] handler:handler];
}

-(MKNetworkOperation*)login:(NSString*) path params:(NSMutableDictionary*) params signatureKey:(NSString*) signatureKey handler:(Handler*) handler {
    [params setValue:@"1" forKey:@"is_need_rsa"];
    [params setWithoutToken:YES];
    Handler* wrapHandler = [[Handler alloc] initWithHandler:handler];
    wrapHandler.succedHandler = ^(Result* result){
        NSString *pk =result.result[@"session"][@"rsa_private_key"];
        NSString *token =result.result[@"session"][@"token"];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setValue:pk forKey:@"rsa_private_key"];
        [userDefaults setValue:token forKey:@"token"];
        [userDefaults synchronize];
        [handler handleResult:result];
    };
    return [self createOperation:path params:params signatureKey:signatureKey handler:wrapHandler];
}

-(MKNetworkOperation*)userInfo:(Handler*)handler {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    return [self createOperation:createPath(@"user/info/") params:param handler:handler];
}

-(MKNetworkOperation*)createAppForRefreshToken:(Handler*)handler {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"100" forKey:@"app_type"];
    Handler* wrapHandler = [[Handler alloc] initWithHandler:handler];
    wrapHandler.succedHandler = ^(Result* result) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *pk =result.result[@"private_key"];
        NSString *hash =result.result[@"app"][@"app_hash_id"];
        [userDefaults setValue:pk forKey:@"app_private_key"];
        [userDefaults setValue:hash forKey:@"app_hash_id"];
        [userDefaults synchronize];
        [handler handleResult:result];
    };
    return [self createOperation:createPath(@"app/create") params:param handler:wrapHandler];
}
@end
