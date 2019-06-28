//
//  TSRequest+Api.h
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSRequest.h"
@class MessageModel;

@class RequestModel;

@interface TSRequest (Api)
//post 提交数据
+ (RequestModel *)postRequetWithApi:(NSString *)api withParam:(id)data_dic error:(NSError* __autoreleasing*)error;
//get 获取数据
+ (RequestModel *)getRequetWithApi:(NSString *)api withParam:(NSDictionary*)data_dic error:(NSError* __autoreleasing*)error;
//delete 方式
+ (RequestModel *)deleteRequetWithApi:(NSString *)api withParam:(NSDictionary *)data_dic error:(NSError *__autoreleasing *)error;
//PUT
+ (RequestModel *)putRequetWithApi:(NSString *)api withParam:(NSDictionary *)data_dic error:(NSError *__autoreleasing *)error;
//下载音频
+ (BOOL)downloadAudioWithMessageModel:(MessageModel *)model error:(NSError* __autoreleasing*)error;
//下载文件
+ (BOOL)downloadFileWithMessageModel:(MessageModel *)model error:(NSError *__autoreleasing *)error;

//根据model下载音频
+ (void)downLoadAudioWithTitle:(MessageModel *)model ;

//下载加密后的图片
+ (BOOL)downloadImageWithMessageModel:(MessageModel *)model imageURL:(NSString*)url error:(NSError *__autoreleasing *)error;
+ (BOOL)downloadVideoThumbIMGWithMessageModel:(MessageModel *)model imageURL:(NSString*)url error:(NSError *__autoreleasing *)error;


#pragma mark - 下载图片相关
//+ (BOOL)downloadImageWithMessageModel:(MessageModel *)model
//                             imageURL:(NSString *)imageURL
//                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
//                                error:(NSError *__autoreleasing *)error;

+ (void)downloadImageWithMessageModel:(MessageModel *)model
                             imageURL:(NSString *)imageURL
                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                              success:(TSRequestSuccessBlock)success
                              failure:(TSRequestFailureBlock)failure;

@end
