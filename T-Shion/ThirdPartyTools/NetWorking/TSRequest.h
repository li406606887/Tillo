//
//  TSRequest.h
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

typedef void(^TSRequestSuccessBlock)(id responseData);
typedef void(^TSRequestFailureBlock)(NSError *error);

@class TSRequest;
@protocol TSRequestDelegate <NSObject>

- (void)TSRequest:(TSRequest *)request finished:(id )response;
- (void)TSRequest:(TSRequest *)request Error:(NSString *)error;

@end



@interface TSRequest : NSObject {
    NSURLSessionDownloadTask *_download;
}
@property (assign) id <TSRequestDelegate> delegate;

/**
 *当前的请求operation队列
 */
@property (nonatomic, strong) NSOperationQueue* operationQueue;

/**
 *功能: 创建CMRequest的对象方法
 */
+ (instancetype)request;

/**
 *功能：DELETE请求
 *参数：(1)请求的url: urlString
 *     (2)POST请求体参数:parameters
 *     (3)请求成功调用的Block: success
 *     (4)请求失败调用的Block: failure
 */
- (void)DELETE:(NSString *)URLString
    parameters:(NSDictionary*)parameters
       success:(void (^)(TSRequest *request, id response))success
       failure:(void (^)(TSRequest *request, NSError *error))failure;

/**
 *功能：GET请求
 *参数：(1)请求的url: urlString
 *     (2)请求成功调用的Block: success
 *     (3)请求失败调用的Block: failure
 */
- (void)GET:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(TSRequest *request, id response))success
    failure:(void (^)(TSRequest *request, NSError *error))failure;

/**
 *功能：POST请求
 *参数：(1)请求的url: urlString
 *     (2)POST请求体参数:parameters
 *     (3)请求成功调用的Block: success
 *     (4)请求失败调用的Block: failure
 */
- (void)POST:(NSString *)URLString
  parameters:(id )parameters
     success:(void (^)(TSRequest *request, id response))success
     failure:(void (^)(TSRequest *request, NSError *error))failure;
/**
 *功能：PUT请求
 *参数：(1)请求的url: urlString
 *     (2)PUT请求体参数:parameters
 *     (3)请求成功调用的Block: success
 *     (4)请求失败调用的Block: failure
 */
- (void)PUT:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(TSRequest *request, id response))success
    failure:(void (^)(TSRequest *request, NSError *error))failure;


/**
 *功能：下载文件请求
 *参数：(1)请求的url: urlString
 *     (2)PUT请求体参数:parameters
 *     (3)请求成功调用的Block: success
 *     (4)请求失败调用的Block: failure
 */
- (void)downImageWithURL:(NSString *)URLString
                filePath:(NSString *)path
                 success:(void (^)(TSRequest *, id))success
                    fail:(void (^)(TSRequest *, NSError *))fail
                progress:(void (^)(int64_t count, int64_t total))progress;

/**
 *  get请求
 *  @param URLString  请求网址
 */
- (void)downAudioWithURL:(NSString *)URLString
                filePath:(NSString *)path
                 success:(void (^)(TSRequest *, id))success
                    fail:(void (^)(TSRequest *, NSError *))fail;
/**
 *  post请求
 *
 *  @param URLString  请求网址
 *  @param parameters 请求参数
 */
- (void)postWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters;


/**
 *  get 请求
 *
 *  @param URLString 请求网址
 */
- (void)getWithURL:(NSString *)URLString;

/**
 *取消当前请求队列的所有请求
 */
- (void)cancelAllOperations;

#pragma mark - 新云存储相关
/**
 新上传图片接口(TCloud)
 
 @param parameters 上传参数
 @param data 图片内容
 @param fileName 图片文件名
 @param success 成功回调
 @param failure 失败回调
 */
- (void)PostImageWithParameters:(NSDictionary *)parameters
                           data:(NSData *)data
                       fileName:(NSString *)fileName
                        success:(TSRequestSuccessBlock)success
                        failure:(TSRequestFailureBlock)failure;


/**
 新单文件上传接口

 @param parameters s上传参数
 @param data 文件
 @param fileName 文件名
 @param mimeType 文件类型
 @param success 成功回调
 @param failure 失败回调
 */
- (void)PostSingleFileWithParameters:(NSDictionary*)parameters
                                data:(NSData *)data
                            fileName:(NSString *)fileName
                            mimeType:(NSString *)mimeType
                             success:(TSRequestSuccessBlock)success
                             failure:(TSRequestFailureBlock)failure;

- (void)downImageWithURL:(NSString *)URLString
                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                filePath:(NSString *)filePath
                 success:(TSRequestSuccessBlock)success
                 failure:(TSRequestFailureBlock)failure;


@end

