//
//  YMEncryptionManager.h
//  SecureTest
//
//  Created by mac on 2019/4/2.
//  Copyright © 2019 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;

NS_ASSUME_NONNULL_BEGIN

@interface YMEncryptionManager : NSObject

#pragma mark - public

+ (YMEncryptionManager*)shareManager;

+ (void)generateDataBase;

///设置自己的id（非重新登录的话，只需要设置自己的userID即可）
- (void)setUserID:(NSString *)userID;

- (NSString *)getMyIdentityKey;

///是否上传了公钥信息
- (BOOL)hadUploadPublicKey;

///登录时调用，上传自己的身份公钥和预共享公钥、一次性密钥(需要先设置自己的userID)
- (void)uploadKeyAfterLogin;

///打开应用时补充自己的一次性公钥
- (void)supplementOneTimeKey;

/**
 加密数据
 
 @param data 要加密的数据
 @param userID 聊天对象的ID
 @param need 是否要返回base64String
 @param block 回调
 */
- (void)encryptData:(NSData*)data withUserID:(NSString*)userID needBase64:(BOOL)need complete:(void(^)(id serialize, NSInteger cryptType))block;

/**
 解密数据

 @param cryptData 要解密的数据
 @param cryptoType 加密的类型 0 Prekey， 1 Whisper
 @param userID 发来数据的userID
 @return 解密后的数据
 */
- (NSString*)decryptData:(NSString*)cryptData cryptoType:(NSInteger)cryptoType withUserID:(NSString*)userID;

- (id)decryptData:(id)cryptData cryptoType:(NSInteger)cryptoType withUserID:(NSString*)userID needBase64:(BOOL)need;



/**
 附件加密，使用AES256加密（内部实现：随机生成一串字符串，取前一半为key，后一半为iv）

 @param data 文件数据
 @param block serialize为加密后的base64字符串，key为加密所用的key和iv，用“,”隔开
 */
- (void)encryptAttachment:(NSData*)data withKey:(nullable NSString*)keyString complete:(void(^)(NSData *serialize, NSString *key))block;


/**
 附件解密，使用AES256解密

 @param data 服务端下载到的文件数据
 @param key 消息附带的key，逗号前一半为key，后一半为iv
 @return 解密完的文件数据
 */
- (nullable NSData*)decryptAttachment:(NSData*)data withKey:(NSString*)key;

#pragma mark - single

///获取好友列表时，将好友公钥和userID对应存储起来(暂时没用)
- (BOOL)saveRemoteIdentity:(NSData *)identityKey userID:(NSString *)userID;

/**
 开始一个密聊会话
 
 @param userID 对方的userID
 */
- (void)startSecretSeesionWithUserID:(NSString*)userID;


/**
 更新好友的密钥信息（聊天消息返回好友身份密钥变更时调用）
 
 @param data 服务端返回的数据，内部解析
 @param userID 好友id
 */
- (void)updateUserCryptInfo:(NSDictionary*)data withUserId:(NSString*)userID;


/**
 存储好友的私密聊天roomId
 
 @param roomId 该好友的房间号
 @param userID 该好友的id
 @param sender 是否是自己发起的，由于有系统提示，方向需要知道
 @param timeStamp 第一条消息的时间，用于保证系统提示都在最上面
 */
- (void)storeCryptRoomId:(NSString*)roomId userId:(NSString*)userID isSender:(BOOL)sender timeStamp:(NSTimeInterval)timeStamp;

///获取好友的身份密钥
- (NSString*)remoteIdentityKeyWithUserID:(NSString*)userID;

///获取用户的密聊房间ID
- (void)getCryptRoomIDWithUserID:(NSString*)userID complete:(void(^)(NSString *cryptRoomID))block;

/**
 显示安全码的VC
 
 @param userID 对方的userID
 @param userName 对方的名字
 @param navigation 可以push的UINavigationController
 */
- (void)showSecureCodeVC:(NSString*)userID userName:(NSString*)userName withNavigationController:(UINavigationController*)navigation;


#pragma mark - group
//获取群组成员的公钥
- (void)getGroupUserKeys:(NSArray*)userIds;

#pragma mark - debug
- (void)addActionLog:(NSString*)crytpString content:(NSString*)content data:(NSData*)data crypt:(NSString*)type;
///保存加密日志
- (void)logCryptMessage:(MessageModel*)model;
@end

NS_ASSUME_NONNULL_END
