//
//  Result.m
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "Result.h"

@implementation Result
-(BOOL)isSucceed {
    return [self.code isEqualToValue:[NSNumber numberWithInt:0]];
}
@end
