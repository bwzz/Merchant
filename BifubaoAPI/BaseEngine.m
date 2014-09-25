//
//  BaseEngine.m
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "BaseEngine.h"
#import "UserApi.h"
#import <openssl/x509.h>
#import <openssl/pem.h>

@implementation BaseEngine
-(id)initWithDefaultHostName {
    return [self initWithHostName:HOST_NAME];
}

-(MKNetworkOperation*)createOperation:(NSString*) path params:(NSMutableDictionary*) param handler:(Handler*)handler {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [self createOperation:path params:param signatureKey:[userDefaults valueForKey:@"rsa_private_key"] handler:handler];
}

-(MKNetworkOperation*)createOperation:(NSString*) path params:(NSMutableDictionary*) param signatureKey:(NSString*) signatureKey handler:(Handler*)handler {
    [param buildPostParams:signatureKey];
    MKNetworkOperation *op = [self operationWithPath:path
                                              params:param
                                          httpMethod:@"POST"
                                                 ssl:YES];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         Lf(@"request path : %@",path);
         L([completedOperation responseString]);
         id jsonObject = [completedOperation responseJSON];
         Result* result = [[Result alloc] init];
         result.code = jsonObject[@"error_no"];
         result.message = jsonObject[@"error_msg"];
         result.result = jsonObject[@"result"];
         if (!param.withoutToken && [result isEqualCode:90000]) {
             // token not found
             [self refreshToken:path params:param handler:handler];
         } else if (handler != nil) {
             [handler handleResult:result];
         }
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error){
         Lf(@"%@\n%@",path,error);
         if (handler!=nil&&handler.networkErrorHandler!=nil) {
             handler.networkErrorHandler(errorOp,error);
         }
     }];
    [self enqueueOperation:op];
    return op;
}

-(void) refreshToken:(NSString*) path params:(NSMutableDictionary*) param handler:(Handler*)handler {
    L(@"refresh token");
    UserApi* api = [[UserApi alloc] initWithDefaultHostName];
    Handler* rhandler = [[Handler alloc] init];
    rhandler.succedHandler = ^(Result* result) {
        [self createOperation:path params:param handler:handler];
    };
    rhandler.failedHandler = ^(Result* result) {
        // notify session out of date, logout
        UIAlertView *at = [[UIAlertView alloc] initWithTitle:nil message:@"session out of date" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [at show];
    };
    [api loginByApp:rhandler];
}
@end
