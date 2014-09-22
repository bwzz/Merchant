//
//  NSMutableDictionary+ParamBuilder.h
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (ParamBuilder)
-(NSDictionary*)buildPostParams:(BOOL)addToken;
@end
