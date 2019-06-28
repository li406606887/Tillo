//
//  YMEncryptionManager.m
//  SecureTest
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 mac. All rights reserved.
//

#import "YMEncryptionManager.h"
#import "YMEncryptionUserModel.h"
#import "YMIdentityManager.h"
#import "PreKeyRecord.h"
#import "SignedPrekeyRecord.h"
#import "FMDBManager+SessionStore.h"
#import "FMDBManager+SignedPreKeyStore.h"
#import "FMDBManager+PreKeyStore.h"
#import <Curve25519Kit/Ed25519.h>
#import <Curve25519Kit/Curve25519.h>
#import "NSData+keyVersionByte.h"
#import "SessionBuilder.h"
#import "SessionCipher.h"
#import "SPKMockProtocolStore.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIImage.h>
#import "FMDBManager+EncryptStore.h"
#import "TSRequest.h"
#import "NSData+OWS.h"
#import "YMSecureCodeViewController.h"
#import <iconv.h>
#import <CommonCrypto/CommonCryptor.h>

@interface YMEncryptionManager ()

@property (nonatomic, copy) NSString *userID;
@property (nonatomic, strong) ECKeyPair *identityKey;
@property (nonatomic, strong) NSLock *cryptLock;
@property (nonatomic, strong) NSLock *decryptLock;

@end

@implementation YMEncryptionManager

#pragma mark - public

+ (YMEncryptionManager*)shareManager {
    static YMEncryptionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[YMEncryptionManager alloc] init];
    });
    return manager;
}

+ (void)generateDataBase {
    //创建加密相关的表，内部有判断是否创建过了
    [[FMDBManager shared] createEncryptTable];
}

//设置自己的id
- (void)setUserID:(NSString *)userID {
    _userID = userID;
    [[FMDBManager shared] createEncryptTable];
    self.identityKey = [[YMIdentityManager sharedManager] identityWithUserId:userID];
    NSLog(@"identity.pubkey:%@,prikey:%@", self.identityKey.publicKey, self.identityKey.privateKey);
    NSArray *array = [[FMDBManager shared] loadSignedPreKeys];
    NSLog(@"预共享密钥：%@", array);
//    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
//        BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Crypt_Log (room_id TEXT, sender TEXT, receiver TEXT, content TEXT, cryptContent TEXT, message_id TEXT, backId TEXT, timestamp TEXT, remoteKey TEXT, cryptoType TEXT)"];
//        if (!success) {
//            NSLog(@"创建加密日志表失败");
//        }
//        
//        success = [db executeUpdate:@"ALTER TABLE Crypt_Log ADD COLUMN remoteKey TEXT"];
//        if (!success) {
//            NSLog(@"加密日志表添加字段remoteKey失败");
//        }
//        
//        success = [db executeUpdate:@"ALTER TABLE Crypt_Log ADD COLUMN cryptoType TEXT"];
//        if (!success) {
//            NSLog(@"加密日志表添加字段cryptoType失败");
//        }
//        
//        success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS CryptAction (cryptContent TEXT, content TEXT, type TEXT, data BLOB)"];
//        if (!success) {
//            NSLog(@"创建加解密操作表失败");
//        }
//        
//        success = [db executeUpdate:@"ALTER TABLE CryptAction ADD COLUMN data BLOB"];
//        if (!success) {
//            NSLog(@"CryptAction表添加字段data失败");
//        }
//    }];
    [self showLog];
}

- (NSString *)getMyIdentityKey {
    return [self.identityKey.publicKey.prependKeyType base64EncodedString];
}

///是否上传了公钥信息
- (BOOL)hadUploadPublicKey {
    return [[YMIdentityManager sharedManager] isUploadedPublicKey];
}

//登录后上传公钥
- (void)uploadKeyAfterLogin {
    if (!self.userID) {
        NSLog(@"请先设置自己的userID");
        return;
    }
    [[YMIdentityManager sharedManager] setUploadPublicKey:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        //获取自己的身份密钥
        NSString *identityKey = [self.identityKey.publicKey.prependKeyType base64EncodedString];
        //生成预共享密钥
        SignedPreKeyRecord *signedPrekeyRecord = [[FMDBManager shared] generateRandomSignedRecord];
        NSString *signedKey = [signedPrekeyRecord.keyPair.publicKey.prependKeyType base64EncodedString];
        int signedKeyId = signedPrekeyRecord.Id;
        NSString *sigendKeySign = [signedPrekeyRecord.signature base64EncodedString];
        [[FMDBManager shared] storeSignedPreKey:signedKeyId signedPreKeyRecord:signedPrekeyRecord];
        //生成100对一次性临时密钥
        NSArray *prekeys = [[FMDBManager shared] generatePreKeyRecordsWithCount:100];
        NSMutableArray *prekeyPublics = [NSMutableArray arrayWithCapacity:100];
        for (PreKeyRecord *prekey in prekeys) {
            int Id = prekey.Id;
            NSString *key = [prekey.keyPair.publicKey.prependKeyType base64EncodedString];
            NSDictionary *dic = @{@"keyId":@(Id), @"publicKey":key};
            [prekeyPublics addObject:dic];
        }
        NSDictionary *param = @{@"oneTimeKey":prekeyPublics, @"identityKey":identityKey, @"signedKeyId":@(signedKeyId), @"signedKey":signedKey, @"signedKeySignature":sigendKeySign};
        NSError *error = nil;

        [TSRequest postRequetWithApi:api_save_my_three_key withParam:param error:&error];
        if (error) {
            NSLog(@"保存身份密钥失败");
        }
        else {
            NSLog(@"保存密钥成功");
            [[YMIdentityManager sharedManager] setUploadPublicKey:YES];
        }
    });
    ///每次重新登录时，最好都重新拉一遍好友的密钥
//    [self regetRemoteIdentity];
}

///已经上传了公钥的要补充一次性密钥
- (void)supplementOneTimeKey {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSError *error = nil;
        RequestModel *model = [TSRequest getRequetWithApi:api_query_onetimekey_count withParam:nil error:&error];
        if (!error) {
            if ([model.data objectForKey:@"oneTimeKeyCount"]) {
                NSInteger count = [[model.data objectForKey:@"oneTimeKeyCount"] integerValue];
                if (count < 50) {
                    //生成100对一次性临时密钥
                    NSArray *prekeys = [[FMDBManager shared] generatePreKeyRecordsWithCount:100];
                    NSMutableArray *prekeyPublics = [NSMutableArray arrayWithCapacity:100];
                    for (PreKeyRecord *prekey in prekeys) {
                        int Id = prekey.Id;
                        NSString *key = [prekey.keyPair.publicKey.prependKeyType base64EncodedString];
                        NSDictionary *dic = @{@"keyId":@(Id), @"publicKey":key};
                        [prekeyPublics addObject:dic];
                    }
                    NSDictionary *param = @{@"oneTimeKey":prekeyPublics};
                    [TSRequest postRequetWithApi:api_increment_onetimekey withParam:param error:&error];
                    if (error) {
                        NSLog(@"补充一次性公钥失败");
                    }
                }
            }
        }
    });
}

//每次登录都要更新的
- (void)refreshSignedPreKey {
    SignedPreKeyRecord *signedPrekeyRecord = [[FMDBManager shared] generateRandomSignedRecord];
    //上传到服务器
    [[FMDBManager shared] storeSignedPreKey:signedPrekeyRecord.Id signedPreKeyRecord:signedPrekeyRecord];
}

//将数据加密，返回加密后数据的base64序列化
- (void)encryptData:(NSData*)data withUserID:(NSString*)userID needBase64:(BOOL)need complete:(void(^)(id serialize, NSInteger cryptType))block {
    [self.cryptLock tryLock];
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:userID deviceId:1];
    @try {
        id<CipherMessage> outgoingMessage = [aliceSessionCipher throws_encryptMessage:data protocolContext:nil];
        NSData *cryptData = [outgoingMessage serialized];
        NSInteger type = 3;
        if ([outgoingMessage isKindOfClass:[PreKeyWhisperMessage class]]) {
            type = 3;
        }
        else if ([outgoingMessage isKindOfClass:[WhisperMessage class]]){
            type = 2;
        }
        if (need) {
            NSString *serialize = [cryptData base64EncodedString];
            block(serialize, type);
            //            [self addActionLog:serialize content:[NSString stringWithUTF8String:data.bytes] data:data crypt:@"1"];
        }
        else {
            block(cryptData, type);
        }
    } @catch (NSException *exception) {
        [self.cryptLock unlock];
        //        if (need)
        //            [self addActionLog:exception.reason content:[NSString stringWithUTF8String:data.bytes] data:nil crypt:@"2"];
        @weakify(self)
        [self getCryptRoomIDWithUserID:userID complete:^(NSString * _Nonnull cryptRoomID) {
            if (cryptRoomID) {
                @strongify(self)
                [self encryptData:data withUserID:userID needBase64:need complete:block];
            }
        }];
    } @finally {
        [self.cryptLock unlock];
    }
}

- (NSString*)decryptData:(id)cryptData cryptoType:(NSInteger)cryptoType withUserID:(NSString*)userID{
    return [self decryptData:cryptData cryptoType:cryptoType withUserID:userID needBase64:YES];
}

- (id)decryptData:(id)cryptData cryptoType:(NSInteger)cryptoType withUserID:(NSString*)userID needBase64:(BOOL)need {
    [self.decryptLock tryLock];
    NSData *data = cryptData;
    if ([cryptData isKindOfClass:[NSString class]])
        data = [NSData dataFromBase64String:cryptData];
    id incomingMessage;
    NSData *decryptMessage = nil;
    @try {
        if (cryptoType == 3 || cryptoType == 0) {
            PreKeyWhisperMessage *message = [[PreKeyWhisperMessage alloc] init_throws_withData:data];
            incomingMessage = message;
        }
        else if (cryptoType == 2 || cryptoType == 1){
            WhisperMessage *message = [[WhisperMessage alloc] init_throws_withData:data];
            incomingMessage = message;
        }
        SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:userID deviceId:1];
        decryptMessage = [bobSessionCipher throws_decrypt:incomingMessage protocolContext:nil];
    } @catch (NSException *exception) {
        NSLog(@"解密异常");
        decryptMessage = data;
#ifdef AilloTest
        if (need) {
            //            [self addActionLog:cryptData content:exception.reason data:decryptMessage crypt:@"3"];
            return exception.reason;
        }
#else
        if (need) {
            //            [self addActionLog:cryptData content:exception.reason data:decryptMessage crypt:@"3"];
            return @"[未知消息]";
        }
#endif
    } @finally {
        [self.decryptLock unlock];
    }
    
    if (!need)
        return decryptMessage;
    if (decryptMessage.length == 0) {
        //        [self addActionLog:cryptData content:@"" data:decryptMessage crypt:@"4"];
        return @"";
    }
    
    NSString *decryptString = [[NSString alloc] initWithData:decryptMessage encoding:NSUTF8StringEncoding];
    if (!decryptString || decryptString.length == 0) {
        decryptString = [[NSString alloc] initWithData:[self cleanUTF8:decryptMessage] encoding:NSUTF8StringEncoding];
        //        [self addActionLog:cryptData content:decryptString data:decryptMessage crypt:@"5"];
        NSLog(@"数据异常了5");
    }
    //    if (!decryptString || decryptString.length == 0) {
    //        [self addActionLog:cryptData content:decryptString data:decryptMessage crypt:@"7"];
    //        NSLog(@"数据异常了7");
    //    }
    //    else
    //        [self addActionLog:cryptData content:decryptString data:decryptMessage crypt:@"6"];
    NSLog(@"decryptString:%@", decryptString);
    return decryptString;
}

/**
 附件加密，使用AES256加密
 
 @param data 文件数据
 @param keyString 用逗号隔开的字符串，如果为空，随机生成一串字符串，取前一半为key，后一半为iv
 @param block serialize为加密后的数据，key为加密所用的key和iv，用“,”隔开
 */
- (void)encryptAttachment:(NSData*)data withKey:(NSString*)keyString complete:(void(^)(NSData *serialize, NSString *key))block {
    NSString *aesKey = nil;
    NSString *aesIV = nil;
    if (keyString != nil) {
        NSArray *array = [keyString componentsSeparatedByString:@","];
        if (array.count == 2) {
            aesKey = [array firstObject];
            aesIV = [array lastObject];
        }
    }
    else {
        NSString *key = @"";
        while (key.length < 32) {
            key = [key stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)arc4random()]];
        }
        if (key.length > 32)
            key = [key substringWithRange:NSMakeRange(0, 32)];
        aesKey = [key substringWithRange:NSMakeRange(0, key.length/2)];
        aesIV = [key substringFromIndex:key.length/2];
    }
    
    NSUInteger dataLength = data.length;
    // 为结束符'\\0' +1
    char keyPtr[kCCBlockSizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [aesKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    // 密文长度 <= 明文长度 + BlockSize
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [aesIV dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,  // 系统默认使用 CBC，然后指明使用 PKCS7Padding
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          initVector.bytes,
                                          data.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        NSData *serialize = [NSData dataWithBytes:encryptedBytes length:actualOutSize];
        NSString *k = [NSString stringWithFormat:@"%@,%@", aesKey, aesIV];
        if (block)
            block(serialize, k);
    }
    else if (block)
        block(nil,nil);
    free(encryptedBytes);
}


/**
 附件解密，使用AES256解密
 
 @param data 服务端下载到的数据
 @param key 消息附带的key，逗号前一半为key，后一半为iv
 @return 解密完的文件数据
 */
- (nullable NSData*)decryptAttachment:(NSData*)data withKey:(NSString*)key {
    if (![data isKindOfClass:[NSData class]] || data.length < 1) {
        NSLog(@"错误的密文");
        return nil;
    }
    NSArray *array = [key componentsSeparatedByString:@","];
    if (array.count != 2) {
        NSLog(@"错误的key");
        return nil;
    }
    NSString *aesKey = [array firstObject];
    NSString *aesIV = [array lastObject];
    NSData *cryptData = data;

    NSUInteger dataLength = cryptData.length;
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [aesKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    NSData *initVector = [aesIV dataUsingEncoding:NSUTF8StringEncoding];
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding,
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          initVector.bytes,
                                          cryptData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytes:decryptedBytes length:actualOutSize];
    }
    free(decryptedBytes);
    return nil;
}

#pragma mark - single

- (NSString*)remoteIdentityKeyWithUserID:(NSString*)userID {
    NSData *identityKey = [[YMIdentityManager sharedManager] identityKeyForRecipientId:userID];
    return [identityKey.prependKeyType base64EncodedString];
}

- (BOOL)saveRemoteIdentity:(NSData *)identityKey userID:(NSString *)userID {
    return [[YMIdentityManager sharedManager] saveRemoteIdentity:identityKey recipientId:userID protocolContext:nil];
}

- (void)getCryptRoomIDWithUserID:(NSString*)userID complete:(void(^)(NSString *cryptRoomID))block{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        NSDictionary *param = @{@"oppositeId":userID};
        RequestModel *model = [TSRequest getRequetWithApi:api_get_crypt_room_id withParam:param error:&error];
        if (!error) {
            NSDictionary *data = model.data;
            NSString *cryptRoomId = [data objectForKey:@"enctryptRoomId"];
            if (cryptRoomId && ![cryptRoomId isEqual:[NSNull null]]) {
                cryptRoomId = [[data objectForKey:@"enctryptRoomId"] stringValue];
            }
            else {
                if (block)
                    block(nil);
            }
            //先将各种公钥保存起来
            NSData *identity = [NSData dataFromBase64String:[data objectForKey:@"identityKey"]];
            YMRecipientIdentity *recipientIdentity = [[YMIdentityManager sharedManager] recipientIdentityForRecipientId:userID];
            //如果群聊已获取过一次密钥，单聊再获取一次可能会出错，除非服务端告诉错误，否则不重新获取
            if (recipientIdentity && [recipientIdentity.identityKey isEqualToData:identity]) {
                NSLog(@"已存在一样的key，不需要再保存一次");
                return ;
            }
            NSData *signedKey = [NSData dataFromBase64String:[data objectForKey:@"signedKey"]];
            NSData *signedKeySign = [NSData dataFromBase64String:[data objectForKey:@"signedKeySign"]];
            int signedKeyId = [[data objectForKey:@"signedKeyId"] intValue];
            NSDictionary *one = [data objectForKey:@"oneTimeKey"];
            NSData *oneTimeKey = nil;
            int oneTimeKeyId = 0;
            if (![one isKindOfClass:[NSNull class]]) {
                oneTimeKey = [NSData dataFromBase64String:[one objectForKey:@"publicKey"]];
                oneTimeKeyId = [[one objectForKey:@"keyId"] intValue];
            }
            [[YMIdentityManager sharedManager] saveRemoteIdentity:identity recipientId:userID protocolContext:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:userID deviceId:1];
                PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:1 deviceId:1 preKeyId:oneTimeKeyId preKeyPublic:oneTimeKey signedPreKeyPublic:signedKey signedPreKeyId:signedKeyId signedPreKeySignature:signedKeySign identityKey:identity];
                [aliceSessionBuilder throws_processPrekeyBundle:bobPreKey protocolContext:nil];
                NSString *cryptRoomId = [[data objectForKey:@"enctryptRoomId"] stringValue];
                NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
                [[FMDBManager shared] storeCryptRoomId:cryptRoomId userId:userID isSender:YES timeStamp:timeStamp];
                if (block)
                    block(cryptRoomId);
            });
        }
        else{
            block(nil);
        }
        
    });
}

- (void)storeCryptRoomId:(NSString*)roomId userId:(NSString*)userID isSender:(BOOL)sender timeStamp:(NSTimeInterval)timeStamp {
    [[FMDBManager shared] storeCryptRoomId:roomId userId:userID isSender:sender timeStamp:timeStamp];
}

/**
 更新好友的密钥信息（聊天消息返回好友身份密钥变更时调用）
 
 @param data 服务端返回的数据，内部解析
 @param userID 好友id
 */
- (void)updateUserCryptInfo:(NSDictionary*)data withUserId:(NSString*)userID {
    NSData *identity = [NSData dataFromBase64String:[data objectForKey:@"identityKey"]];
    NSData *signedKey = [NSData dataFromBase64String:[data objectForKey:@"signedKey"]];
    NSData *signedKeySign = [NSData dataFromBase64String:[data objectForKey:@"signedKeySign"]];
    int signedKeyId = [[data objectForKey:@"signedKeyId"] intValue];
    NSDictionary *one = [data objectForKey:@"oneTimeKey"];
    NSData *oneTimeKey = nil;
    int oneTimeKeyId = 0;
    if (![one isKindOfClass:[NSNull class]]) {
        oneTimeKey = [NSData dataFromBase64String:[one objectForKey:@"publicKey"]];
        oneTimeKeyId = [[one objectForKey:@"keyId"] intValue];
    }
    [[YMIdentityManager sharedManager] saveRemoteIdentity:identity recipientId:userID protocolContext:nil];
    SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:userID deviceId:1];
    PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:1 deviceId:1 preKeyId:oneTimeKeyId preKeyPublic:oneTimeKey signedPreKeyPublic:signedKey signedPreKeyId:signedKeyId signedPreKeySignature:signedKeySign identityKey:identity];
    [aliceSessionBuilder throws_processPrekeyBundle:bobPreKey protocolContext:nil];
//    NSString *cryptRoomId = [[data objectForKey:@"enctryptRoomId"] stringValue];
}

- (void)showSecureCodeVC:(NSString *)userID userName:(nonnull NSString *)userName withNavigationController:(nonnull UINavigationController *)navigation {
    NSString *myId = self.userID;
    NSData *myIdentity = self.identityKey.publicKey;
    NSString *otherId = userID;
    NSData *otherIdentity = [[YMIdentityManager sharedManager] identityKeyForRecipientId:userID];
    YMSecureCodeViewController *vc = [[YMSecureCodeViewController alloc] initWithMyID:myId myIdentity:myIdentity theirUserID:otherId theirIdentity:otherIdentity theirNickName:userName];
    [navigation pushViewController:vc animated:YES];
}

- (void)regetRemoteIdentity {
    __block NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Friend"];
        while (result.next) {
            FriendsModel *model = [FriendsModel initModelWithResult:result];
            if (model.encryptRoomID.length > 6) {
                [array addObject:model];
            }
        }
        [result close];
    }];
    for (FriendsModel *m in array) {
        if (m.encryptRoomID.length > 0) {
            [self getCryptRoomIDWithUserID:m.userId complete:^(NSString * _Nonnull cryptRoomID) {
                NSLog(@"重新获取好友的身份密钥：%@", m.userId);
            }];
        }
    }
}
#pragma mark - group
//获取群组成员的公钥
- (void)getGroupUserKeys:(NSArray*)userIds {
    if (userIds.count == 0)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *a = [userIds mutableCopy];
        for (NSString *userId in userIds) {
            if ([self remoteIdentityKeyWithUserID:userId]) {
                [a removeObject:userId];
            }
        }
        if (a.count == 0)
            return;
        NSError * error;
        NSDictionary *param = @{@"oppositeId":a};
        RequestModel *model = [TSRequest postRequetWithApi:api_get_group_user_key withParam:param error:&error];
        if (!error) {
            NSArray *array = model.data;
            for (NSDictionary *data in array) {
                //先将各种公钥保存起来
                NSData *identity = [NSData dataFromBase64String:[data objectForKey:@"identityKey"]];
                NSData *signedKey = [NSData dataFromBase64String:[data objectForKey:@"signedKey"]];
                NSData *signedKeySign = [NSData dataFromBase64String:[data objectForKey:@"signedKeySign"]];
                int signedKeyId = [[data objectForKey:@"signedKeyId"] intValue];
                NSDictionary *one = [data objectForKey:@"oneTimeKey"];
                NSData *oneTimeKey = nil;
                int oneTimeKeyId = 0;
                if (![one isKindOfClass:[NSNull class]]) {
                    oneTimeKey = [NSData dataFromBase64String:[one objectForKey:@"publicKey"]];
                    oneTimeKeyId = [[one objectForKey:@"keyId"] intValue];
                }
                NSString *userID = [data objectForKey:@"userId"];
                [[YMIdentityManager sharedManager] saveRemoteIdentity:identity recipientId:userID protocolContext:nil];
                SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:userID deviceId:1];
                PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:1 deviceId:1 preKeyId:oneTimeKeyId preKeyPublic:oneTimeKey signedPreKeyPublic:signedKey signedPreKeyId:signedKeyId signedPreKeySignature:signedKeySign identityKey:identity];
                [aliceSessionBuilder throws_processPrekeyBundle:bobPreKey protocolContext:nil];
            }
        }
    });
}

#pragma mark - debug
//以下为测试代码
static ECKeyPair *bobIdentityKeyPair = nil;
- (void)test {
    NSString *BOB_RECIPIENT_ID   = @"+3828923892";
    NSString *ALICE_RECIPIENT_ID = @"1111";
    
    ECKeyPair *aliceIdentityKeyPair = self.identityKey;
    ECKeyPair *aliceBaseKeyPair = [Curve25519 generateKeyPair];
    SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    SPKMockProtocolStore *bobStore      = [SPKMockProtocolStore new];
    bobIdentityKeyPair = [bobStore valueForKey:@"identityKeyPair"];
    ECKeyPair *bobPreKeyPair            = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPreKeyPair      = [Curve25519 generateKeyPair];
    
    NSData *bobSignedPreKeySignature = [Ed25519 throws_sign:bobSignedPreKeyPair.publicKey.prependKeyType withKeyPair:bobIdentityKeyPair];
    
    PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:1234
                                                                 deviceId:1
                                                                 preKeyId:31337
                                                             preKeyPublic:bobPreKeyPair.publicKey.prependKeyType
                                                       signedPreKeyPublic:bobSignedPreKeyPair.publicKey.prependKeyType
                                                           signedPreKeyId:22
                                                    signedPreKeySignature:bobSignedPreKeySignature
                                                              identityKey:bobIdentityKeyPair.publicKey.prependKeyType];
    
    [aliceSessionBuilder throws_processPrekeyBundle:bobPreKey protocolContext:nil];
    NSString *originalMessage = @"Freedom is the right to tell people what they do not want to hear.";
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithSessionStore:[FMDBManager shared] preKeyStore:[FMDBManager shared] signedPreKeyStore:[FMDBManager shared] identityKeyStore:[YMIdentityManager sharedManager] recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    WhisperMessage *outgoingMessage =
    [aliceSessionCipher throws_encryptMessage:[originalMessage dataUsingEncoding:NSUTF8StringEncoding]
                              protocolContext:nil];
    NSLog(@"alice out:%@",outgoingMessage.serialized);
    
    PreKeyWhisperMessage *incomingMessage = (PreKeyWhisperMessage*)outgoingMessage;
    
    [bobStore storePreKey:31337 preKeyRecord:[[PreKeyRecord alloc] initWithId:bobPreKey.preKeyId keyPair:bobPreKeyPair]];
    [bobStore storeSignedPreKey:22 signedPreKeyRecord:[[SignedPreKeyRecord alloc] initWithId:22 keyPair:bobSignedPreKeyPair signature:bobSignedPreKeySignature generatedAt:[NSDate date]]];
    
    SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:ALICE_RECIPIENT_ID deviceId:1];
    NSData *decryptMessage = [bobSessionCipher throws_decrypt:incomingMessage protocolContext:nil];
    
    NSString *decryptString = [NSString stringWithCString:[decryptMessage bytes] encoding:NSUTF8StringEncoding];
    NSLog(@"decryptString:%@", decryptString);
    
    //    originalMessage = @"BobRecive and reply to alice";
    WhisperMessage *outgoingMessage2 = [bobSessionCipher throws_encryptMessage:[originalMessage dataUsingEncoding:NSUTF8StringEncoding] protocolContext:nil];
    NSLog(@"bob out:%@", outgoingMessage2.serialized);
    PreKeyWhisperMessage *incomingMessage2 = (PreKeyWhisperMessage*)outgoingMessage2;
    NSData *decryptMessage2 = [aliceSessionCipher throws_decrypt:incomingMessage2 protocolContext:nil];
    
    NSString *decryptString2 = [NSString stringWithCString:[decryptMessage2 bytes] encoding:NSUTF8StringEncoding];
    NSLog(@"decryptString2:%@", decryptString2);
    
    
    //    originalMessage = @"alice second message";
    WhisperMessage *outgoingMessage3 =
    [aliceSessionCipher throws_encryptMessage:[originalMessage dataUsingEncoding:NSUTF8StringEncoding]
                              protocolContext:nil];
    NSLog(@"alice3 out:%@",outgoingMessage3.serialized);
    NSData *decryptMessage3 = [bobSessionCipher throws_decrypt:outgoingMessage3 protocolContext:nil];
    
    NSString *decryptString3 = [NSString stringWithCString:[decryptMessage3 bytes] encoding:NSUTF8StringEncoding];
    NSLog(@"decryptString3:%@", decryptString3);
}


- (NSLock*)cryptLock {
    if (!_cryptLock)
        _cryptLock = [[NSLock alloc] init];
    return _cryptLock;
}

- (NSLock*)decryptLock {
    if (!_decryptLock)
        _decryptLock = [[NSLock alloc] init];
    return _decryptLock;
}

#pragma mark - Log
- (void)addActionLog:(NSString*)crytpString content:(NSString*)content data:(NSData*)data crypt:(NSString*)type {
    NSLog(@"加密原始数据:%@", content);
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"INSERT INTO CryptAction (cryptContent, content, type, data) VALUES (?, ?, ?, ?)", crytpString, content, type, data];
        if (!success)
            NSLog(@"存储加解密操作日志失败");
    }];
}

- (void)logCryptMessage:(MessageModel*)model {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL success = [db executeUpdate:@"INSERT INTO Crypt_Log (room_id, sender, receiver, content, cryptContent, message_id, backId, timestamp, remoteKey, cryptoType) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", model.roomId, model.sender, model.receiver, model.originalContent, model.content, model.messageId, model.backId, model.timestamp, model.remoteIdentityKey, @(model.cryptoType)];
        if (!success) {
            NSLog(@"保存加密日志失败");
        }
    }];
}
//查看加密日志(可以从UI获取到room_id和sender或者receive来查看日志，与另一台手机获取的对比看cryptContent、content是否一致)
- (void)showLog {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM Crypt_Log WHERE room_id='572868792489607168'"];//572868792489607168(金三)
//         WHERE room_id = ? AND sender = ?", @"123", @"123"572876250134085632
        while (result.next) {
            NSLog(@"加解密消息%@", result.resultDictionary);
        }
        [result close];
//        [db executeUpdate:@"DELETE FROM Crypt_Log"];
    }];
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM CryptAction"];
        while (result.next) {
            NSLog(@"加解密日志%@", result.resultDictionary);
        }
        [result close];
//        [db executeUpdate:@"DELETE FROM CryptAction"];
    }];
}


/**
 剔除非UTF-8字符
 https://blog.csdn.net/xiao562994291/article/details/78100419
 @param data 原来的数据data
 @return 处理后的输入data
 */
- (NSData *)cleanUTF8:(NSData *)data {
    iconv_t cd = iconv_open("UTF-8", "UTF-8"); // 从UTF-8转UTF-8
    int one = 1;
    iconvctl(cd, ICONV_SET_DISCARD_ILSEQ, &one); // 剔除非UTF-8的字符
    
    size_t inbytesleft, outbytesleft;
    inbytesleft = outbytesleft = data.length;
    char *inbuf  = (char *)data.bytes;
    char *outbuf = malloc(sizeof(char) * data.length);
    char *outptr = outbuf;
    if (iconv(cd, &inbuf, &inbytesleft, &outptr, &outbytesleft)
        == (size_t)-1) {
        NSLog(@"this should not happen, seriously");
        return nil;
    }
    NSData *result = [NSData dataWithBytes:outbuf length:data.length - outbytesleft];
    iconv_close(cd);
    free(outbuf);
    return result;
}

@end
