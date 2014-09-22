//
//  BaseEngine.m
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "BaseEngine.h"

#import <openssl/x509.h>
#import <openssl/pem.h>

@implementation BaseEngine
-(id)initWithDefaultHostName {
    return [self initWithHostName:HOST_NAME];
}
-(MKNetworkOperation*)createOperation:(NSString*) path params:(NSMutableDictionary*) param handler:(Handler*)handler {
    [param buildPostParams:YES];
    MKNetworkOperation *op = [self operationWithPath:path
                                              params:param
                                          httpMethod:@"POST"
                                                 ssl:YES];
    [op addCompletionHandler:^(MKNetworkOperation *completedOperation)
     {
         id jsonObject = [completedOperation responseJSON];
         Result* result = [[Result alloc] init];
         result.code = jsonObject[@"error_no"];
         result.message = jsonObject[@"error_no"];
         result.result = jsonObject[@"result"];
         if (handler != nil) {
             [handler handleResult:result];
         }
     }errorHandler:^(MKNetworkOperation *errorOp, NSError* error){
         if (handler!=nil&&handler.networkErrorHandler!=nil) {
             handler.networkErrorHandler(errorOp,error);
         }
     }];
    [self enqueueOperation:op];
    return op;
}
@end
