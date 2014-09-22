//
//  Result.h
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Result : NSObject
@property (nonatomic, strong) NSString* message;
@property (nonatomic,strong) NSNumber* code;
@property (nonatomic, strong) id result;

-(BOOL)isSucceed;
-(BOOL)isEqualCode:(int) code;
@end
