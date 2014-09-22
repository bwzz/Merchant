//
//  NSMutableDictionary+ParamBuilder.m
//  Merchant
//
//  Created by wanghb on 14-9-19.
//  Copyright (c) 2014年 bifubao. All rights reserved.
//

#import "NSMutableDictionary+ParamBuilder.h"
#import <openssl/x509.h>
#import <openssl/pem.h>
#import <objc/runtime.h>

static char withoutTokenKey;

@implementation NSMutableDictionary (ParamBuilder)

@dynamic withoutToken;

-(void)setWithoutToken:(BOOL)withoutToken {
    objc_setAssociatedObject(self, &withoutTokenKey, @(withoutToken), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)withoutToken{
    return (BOOL)objc_getAssociatedObject(self, &withoutTokenKey);
}

-(NSDictionary*)buildPostParams {
    [self setValue:[NSNumber numberWithInt:[[NSDate date] timeIntervalSince1970]] forKeyPath:@"_time_"];
    [self removeObjectForKey:@"_signature_"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (!self.withoutToken) {
        [self setValue:[userDefaults stringForKey:@"token"] forKey:@"_token_"];
    }
    // signature
    NSString* key = [userDefaults stringForKey:@"rsa_private_key"];
    if (key != nil) {
        NSString *signature = [self signMessage:[self makeSignPlainTextWithParam] withKey:key];
        [self setValue:signature forKey:@"_signature_"];
    }
    return self;
}

- (NSString *)signMessage:(NSString *)messageString withKey:(NSString *)keyString {
    // 1. RSA private key from string
    RSA *privKey = NULL;
    NSData *data = [keyString dataUsingEncoding:NSUTF8StringEncoding];
    BIO *b = BIO_new(BIO_s_mem());
    BIO_write(b, [data bytes], [data length]);
    privKey = PEM_read_bio_RSAPrivateKey(b, &privKey, NULL, NULL);
    
    // 2. caculate message
    NSData *message_data = [messageString dataUsingEncoding:NSUTF8StringEncoding];
    const unsigned char *message = (const unsigned char *)[message_data bytes];
    unsigned int message_length = [message_data length];
    unsigned char *sig = NULL;
    unsigned int sig_len = 0;
    sig = malloc(RSA_size(privKey));
    
    // 3. sha message, then sign
    // sha512
    unsigned char message_digest[SHA512_DIGEST_LENGTH];
    SHA512(message, message_length, message_digest);
    int success = RSA_sign(NID_sha512, message_digest, SHA512_DIGEST_LENGTH, sig, &sig_len, privKey);
    
    // 4. return
    if(success == 1){
        NSData *signed_data = [NSData dataWithBytes:sig length:sig_len];
        return [signed_data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }
    
    return nil;
}

- (NSString *)makeSignPlainTextWithParam {
    NSMutableString *plainText = [NSMutableString string];
    // 排序
    NSArray *keys = [self allKeys];
    NSArray *sortedKeys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    // 组装
    for (NSString *key in sortedKeys) {
        [plainText appendFormat:@"%@%@", key, [self objectForKey:key]];
    }
    
    return plainText;
}
@end
