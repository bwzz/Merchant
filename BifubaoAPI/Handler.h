//
//  Handler.h
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Result.h"

typedef void(^SucceedHandler) (Result * result);
typedef void(^FailedHandler) (Result * result);
typedef void(^NetworkErrorHandler) (MKNetworkOperation *errorOp, NSError* error);

@interface Handler : NSObject
@property (copy) SucceedHandler succedHandler;
@property (copy) FailedHandler failedHandler;
@property (copy) NetworkErrorHandler networkErrorHandler;

-(void)handleResult:(Result*)result;
@end
