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
    return [self.code isEqualToNumber:[NSNumber numberWithInt:0]];
}
-(BOOL)isEqualCode:(int) code {
    return [self.code isEqualToNumber:[NSNumber numberWithInt:code]];
}
@end
