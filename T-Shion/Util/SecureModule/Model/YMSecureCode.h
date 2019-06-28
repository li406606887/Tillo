//
//  YMSecureCode.h
//  SecureTest
//
//  Created by mac on 2019/4/9.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface YMSecureCode : NSObject

+ (instancetype)fingerprintWithMyStableId:(NSString *)myStableId
                            myIdentityKey:(NSData *)myIdentityKeyWithoutKeyType
                            theirStableId:(NSString *)theirStableId
                         theirIdentityKey:(NSData *)theirIdentityKeyWithoutKeyType
                                theirName:(NSString *)theirName;

- (instancetype)initWithMyStableId:(NSString *)myStableId
                     myIdentityKey:(NSData *)myIdentityKeyWithoutKeyType
                     theirStableId:(NSString *)theirStableId
                  theirIdentityKey:(NSData *)theirIdentityKeyWithoutKeyType
                         theirName:(NSString *)theirName;

#pragma mark - Properties

@property (nonatomic, readonly) NSData *myStableIdData;
@property (nonatomic, readonly) NSData *myIdentityKey;
@property (nonatomic, readonly) NSString *theirStableId;
@property (nonatomic, readonly) NSData *theirStableIdData;
@property (nonatomic, readonly) NSData *theirIdentityKey;
@property (nonatomic, readonly) NSString *displayableText;//展示的安全码，按照设计分为了三行四列，每个5位数的格式了。
@property (nullable, nonatomic, readonly) UIImage *image;//展示的二维码

#pragma mark - Instance Methods

- (BOOL)matchesLogicalFingerprintsData:(NSData *)data;//扫描二维码验证安全码

@property (nonatomic, assign) CGSize qrCodeSize;

@end

NS_ASSUME_NONNULL_END
