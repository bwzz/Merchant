//
//  Handler.m
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "Handler.h"

@implementation Handler
-(void)handleResult:(Result*)result{
    if ([result isSucceed]) {
        if (self.succedHandler!=nil) {
            self.succedHandler(result);
        }
    } else {
        if(self.failedHandler!=nil) {
            self.failedHandler(result);
        }
    }
}
@end
