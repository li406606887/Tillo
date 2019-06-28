//
//  NetworkModel.h
//  T-Shion
//
//  Created by together on 2019/1/8.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkModel : NSObject

//发送消息
+ (void)sendMessageWithMessage:(MessageModel *)model;
//撤回消息
+ (void)withdrawMessageWithModel:(MessageModel *)model;

//add by chw 2019.04.25 for Encryption Session Screen Shot
+ (void)sendScreenShotMessageWithModel:(MessageModel*)model;
+ (void)sendCryptGroupMessage:(MessageModel*)message;

#pragma mark - 新云存储相关
/**
 新云存储，上传图片接口

 @param data 图片内容
 @param params 请求参数
 @param fileName 文件名
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)uploadImageWithData:(NSData *)data
                     params:(NSDictionary *)params
                   fileName:(NSString *)fileName
                    success:(void(^)(id ))success
                       fail:(void(^)(void))fail;


/**
 新云存储,单文件上传

 @param data 文件内容
 @param params 参数
 @param fileName 文件名
 @param mimeType 文件类型
 @param success 成功回调
 @param fail 失败回调
 */
+ (void)uploadSingleFileWithData:(NSData *)data
                          params:(NSDictionary *)params
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         success:(void(^)(id ))success
                            fail:(void(^)(void))fail;

@end

NS_ASSUME_NONNULL_END
