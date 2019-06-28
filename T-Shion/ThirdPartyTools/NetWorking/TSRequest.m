//
//  TSRequest.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//


#import "TSRequest.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "GSKeyChainDataManager.h"

@implementation TSRequest
static AFHTTPSessionManager *operationManager ;
static dispatch_queue_t completionQueue;
+ (instancetype)request {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(TSRequest * request, id response))success
    failure:(void (^)(TSRequest * request, NSError *error))failure {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    //wsp 注释，2019.4.10
//    operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
//    operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //end
    
    NSString *accessToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if ([self isValidateString:accessToken]==YES) {
        [self.operationManager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
    }
    
    [self setHttpHead];
    
    [self.operationManager GET:URLString
                    parameters:parameters
                      progress:^(NSProgress * _Nonnull downloadProgress) {
                          
                      }
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           if ([responseObject isKindOfClass:[NSDictionary class]]) {
                               NSLog(@"%@",responseObject);
                               success(self,responseObject);
                           }else {
                               id object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                               NSLog(@"%@",object);
                               success(self,object);
                           }
                           
                           dispatch_semaphore_signal(semaphore);
                       }
                       failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                           failure(self,error);
                           id object;
                           NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                           if ([errorData isKindOfClass:[NSData class]]) {
                               object = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
                           }
                           
                           if (object) {
                               NSInteger errorCode = [[object objectForKey:@"status"] integerValue];
                               if (errorCode == -10000 || errorCode == -10005 || errorCode == 401) {
                                   [self requestException:errorCode urlString:URLString];
                               }
                           }
                           
                           failure(self,error);
                           dispatch_semaphore_signal(semaphore);
                       }
     ];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
}

- (void)POST:(NSString *)URLString
  parameters:(id)parameters
     success:(void (^)(TSRequest *request, id response))success
     failure:(void (^)(TSRequest *request, NSError *error))failure{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    //wsp 修改 ,2019.4.10
//    self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    //end
    self.operationManager.requestSerializer.timeoutInterval = 30.f;
    
    [self setHttpHead];
    
    [self.operationManager POST:URLString
                     parameters:parameters
                       progress:^(NSProgress * _Nonnull uploadProgress) {
                           
                       }
                        success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                            id object;
                            if ([responseObject isKindOfClass:[NSData class]]) {
                                object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                            }else{
                                object =responseObject;
                            }
                            NSLog(@"%@",object);
                            success(self,object);
                            
                            dispatch_semaphore_signal(semaphore);
                        }
                        failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                            id object;
                            NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                            if ([errorData isKindOfClass:[NSData class]]) {
                                object = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
                            }
                            NSLog(@"%@",object);
                            
                            if (object) {
                                NSInteger errorCode = [[object objectForKey:@"status"] integerValue];
                                if (errorCode == -10000 || errorCode == -10005 || errorCode == 401) {
                                    [self requestException:errorCode urlString:URLString];
                                }
                            }
                            
                            failure(self,error);
                            dispatch_semaphore_signal(semaphore);
                        }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)PUT:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(TSRequest *request, id response))success
    failure:(void (^)(TSRequest *request, NSError *error))failure{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    //wsp修改，2019.4.10
//    self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    [self setHttpHead];
    [self.operationManager PUT:URLString
                    parameters:parameters
                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           id object;
                           if ([responseObject isKindOfClass:[NSData class]]) {
                               object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                           }else{
                               object =responseObject;
                           }
                           NSLog(@"%@",object);
                           success(self,object);
                           dispatch_semaphore_signal(semaphore);
                       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           id object;
                           NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
                           if ([errorData isKindOfClass:[NSData class]]) {
                               object = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
                           }
                           
                           if (object) {
                               
                               NSInteger errorCode = [[object objectForKey:@"status"] integerValue];
                               if (errorCode == -10000 || errorCode == -10005 || errorCode == 401) {
                                   [self requestException:errorCode urlString:URLString];
                               }
                               
                           }
                           
                           NSLog(@"%@",object);
                           failure(self,error);
                           dispatch_semaphore_signal(semaphore);
                       }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)DELETE:(NSString *)URLString
    parameters:(NSDictionary*)parameters
       success:(void (^)(TSRequest *request, id response))success
       failure:(void (^)(TSRequest *request, NSError *error))failure {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    //wsp修改,2019.4.10
//    self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    //end
    
    [self setHttpHead];
    [self.operationManager DELETE:URLString
                       parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                           id object;
                           if ([responseObject isKindOfClass:[NSData class]]) {
                               object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
                           }else {
                               object =responseObject;
                           }
                           success(self,object);
                           dispatch_semaphore_signal(semaphore);
                           
                       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                           failure(self,error);
                           dispatch_semaphore_signal(semaphore);
                       }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)downImageWithURL:(NSString *)URLString filePath:(NSString *)path success:(void (^)(TSRequest *, id))success fail:(void (^)(TSRequest *, NSError *))fail progress:(void (^)(int64_t count, int64_t total))progress{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    //请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [self setHttpHead];
    NSURLSessionDownloadTask *downloadTask = [self.operationManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {//进度
        NSLog(@"%lld",downloadProgress.completedUnitCount);
        progress(downloadProgress.completedUnitCount,downloadProgress.totalUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        if (error) {
            fail(self,error);
        }
        if(filePath){
            success(self,filePath);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    //3.启动任务
    [downloadTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)downAudioWithURL:(NSString *)URLString filePath:(NSString *)path success:(void (^)(TSRequest *, id))success fail:(void (^)(TSRequest *, NSError *))fail {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    //请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [self setHttpHead];
    NSURLSessionDownloadTask *downloadTask = [self.operationManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {//进度
        NSLog(@"%lld",downloadProgress.completedUnitCount);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nonnull filePath, NSError * _Nonnull error) {
        if (error) {
            fail(self,error);
        }
        if(filePath){
            success(self,filePath);
        }
        dispatch_semaphore_signal(semaphore);
    }];
    //3.启动任务
    [downloadTask resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)isValidateString:(NSString*)str {
    if (str == nil) {
        return NO;
    }
    
    if ([str isKindOfClass:[NSNull class]]) {
        return NO;
    }
    
    if ([str isEqualToString:@""]) {
        return NO;
    }
    
    if ([str length] == 0) {
        return NO;
    }
    
    return YES;
}

- (void)postWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters {
    [self POST:URLString
    parameters:parameters
       success:^(TSRequest *request, id  response) {
           if ([self.delegate respondsToSelector:@selector(TSRequest:finished:)]) {
               [self.delegate TSRequest:request finished:response];
           }
       }
       failure:^(TSRequest *request, NSError *error) {
           if ([self.delegate respondsToSelector:@selector(TSRequest:Error:)]) {
               [self.delegate TSRequest:request Error:error.description];
           }
       }];
}

- (void)getWithURL:(NSString *)URLString {
    [self GET:URLString parameters:nil success:^(TSRequest *request, id response) {
        if ([self.delegate respondsToSelector:@selector(TSRequest:finished:)]) {
            [self.delegate TSRequest:request finished:response];
        }
    } failure:^(TSRequest *request, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(TSRequest:Error:)]) {
            [self.delegate TSRequest:request Error:error.description];
        }
    }];
}

- (void)cancelAllOperations{
    [self.operationQueue cancelAllOperations];
}


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
                        failure:(TSRequestFailureBlock)failure {
    
    [self setupPostFile];
    NSString *URLString = [NSString stringWithFormat:@"%@/uploadImageFile",NewCloudHostUrl];
    
    [self.operationManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"进度---------------%lld-/-%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id object;
        if ([responseObject isKindOfClass:[NSData class]]) {
            object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        }else{
            object =responseObject;
        }
        success(object);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        id object;
        NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if ([errorData isKindOfClass:[NSData class]]) {
            object = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
        }
        failure(error);
    }];
}

- (void)PostSingleFileWithParameters:(NSDictionary*)parameters
                                data:(NSData *)data
                            fileName:(NSString *)fileName
                            mimeType:(NSString *)mimeType
                             success:(TSRequestSuccessBlock)success
                             failure:(TSRequestFailureBlock)failure {
    [self setupPostFile];
    
    NSString *URLString = [NSString stringWithFormat:@"%@/uploadSingleFile",NewCloudHostUrl];
    mimeType = mimeType.length > 0 ? mimeType : @"image/jpeg";
    
    [self.operationManager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"进度---------------%lld-/-%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        id object;
        if ([responseObject isKindOfClass:[NSData class]]) {
            object = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
        } else {
            object =responseObject;
        }
        success(object);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        id object;
        NSData *errorData = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        if ([errorData isKindOfClass:[NSData class]]) {
            object = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];
        }
        failure(error);
    }];
    
}

- (void)downImageWithURL:(NSString *)URLString
                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                filePath:(NSString *)filePath
                 success:(TSRequestSuccessBlock)success
                 failure:(TSRequestFailureBlock)failure {
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    //请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    [self setHttpHead];
    
    NSURLSessionDownloadTask *downloadTask = [self.operationManager downloadTaskWithRequest:request progress:downloadProgressBlock destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            failure(error);
        }
        if (filePath) {
            success(response);
        }
//        dispatch_semaphore_signal(semaphore);
    }];
    
    //3.启动任务
    [downloadTask resume];
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}



/** 设置上传文件相关参数 */
- (void)setupPostFile {
    [self.operationManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    [self.operationManager.requestSerializer setValue:kTCloudAppId forHTTPHeaderField:@"User-Id"];
    self.operationQueue = self.operationManager.operationQueue;
}

#pragma mark - 请求设置相关
- (AFHTTPSessionManager *)operationManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operationManager = [AFHTTPSessionManager manager];
        operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        completionQueue = dispatch_queue_create("AilloConcurrent.cc", DISPATCH_QUEUE_CONCURRENT);
        operationManager.completionQueue = completionQueue;
        operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/plain", @"text/json", @"text/javascript",@"text/html", nil];
        operationManager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    });
    return operationManager;
}

- (void)setHttpHead {
    NSString *appLanguage;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]) {
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        if ([language hasPrefix:@"zh-Hans"]) {//开头匹配
            [[NSUserDefaults standardUserDefaults] setObject:@"zh-Hans" forKey:@"appLanguage"];
            appLanguage = @"zh_simple";
        }else{
            [[NSUserDefaults standardUserDefaults] setObject:@"en" forKey:@"appLanguage"];
            appLanguage = @"en";
        }
    } else {
        if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"] isEqualToString:@"en"]) {
            appLanguage = @"zh_simple";
        } else {
            appLanguage = @"en";
        }
    }
    
    //change by wsp for deviceUUID Change 2019.3.8
    NSString *deviceUUID = [GSKeyChainDataManager readUUID];
    
    [self.operationManager.requestSerializer setValue:deviceUUID forHTTPHeaderField:@"deviceId"];
    [self.operationManager.requestSerializer setValue:appLanguage forHTTPHeaderField:@"language"];
    [self.operationManager.requestSerializer setValue:@"2" forHTTPHeaderField:@"platform"];
    NSString *accessToken =  [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    if ([self isValidateString:accessToken]==YES) {
        [self.operationManager.requestSerializer setValue:accessToken forHTTPHeaderField:@"Authorization"];
        SDWebImageDownloader *sdmanager = [SDWebImageDownloader sharedDownloader];
        [sdmanager setValue:accessToken forHTTPHeaderField:@"Authorization"];
        [sdmanager setValue:deviceUUID forHTTPHeaderField:@"deviceId"];
        [sdmanager setValue:@"2" forHTTPHeaderField:@"platform"];
    }
}

#pragma mark - 请求异常处理
- (void)requestException:(NSInteger)code urlString:(NSString *)urlString{
    [self cancelAllOperations];
    if (code == -10000) {
        NSMutableDictionary *kickData = [NSMutableDictionary dictionary];
        
        NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        
        if (token.length > 0 && userId.length > 0) {
            [kickData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
            [kickData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] forKey:@"user_id"];
            NSString *name = [SocketViewModel shared].userModel.name.length > 0 ? [SocketViewModel shared].userModel.name : @"";
            [kickData setObject:name forKey:@"userName"];
            [kickData setObject:[GSKeyChainDataManager readUUID] forKey:@"deviceId"];
            [kickData setObject:urlString forKey:@"requestURL"];
            [kickData setObject:[NSDate getNowTimestamp] forKey:@"timeStr"];
            [FMDBManager updateKickLog:kickData];
            [SocketViewModel kickUserRequest:NO];
        }
        
    } else if (code == 401) {
        [SocketViewModel kickUserRequest:YES];
    } else if (code == -10005) {
        [SocketViewModel forbidUser];
    }
}

@end
