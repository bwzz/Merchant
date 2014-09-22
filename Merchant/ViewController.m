//
//  ViewController.m
//  Merchant
//
//  Created by wanghb on 14-9-18.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "ViewController.h"
#import <CommonCrypto/CommonDigest.h>

#import <openssl/x509.h>
#import <openssl/pem.h>

#import "NSMutableDictionary+ParamBuilder.h"
#import "UserApi.h"
#import "ProductApi.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UserApi* api = [[UserApi alloc] initWithDefaultHostName];
    
    Handler* uihandler = [[Handler alloc] init];
    uihandler.succedHandler = ^(Result * result){
        L(result.result);
    };
    
    Handler* handler = [[Handler alloc] init];
    
    handler.succedHandler = ^(Result* result) {
//        L(result.result);
//        [api userInfo:uihandler];
        [self loadProducts];
    };
    [api loginWithName:@"wwwroi@163.com" password:@"5bian5jii" handler:handler];
}

-(void)loadProducts{
    Handler* handler = [[Handler alloc] init];
    handler.succedHandler = ^(Result * r) {
        L(r.result
          );
    };
    ProductApi* api = [[ProductApi alloc] initWithDefaultHostName];
    [api listWithPageNo:1 andPageSize:100 handler:handler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
