//
//  TSRequest+Api.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSRequest+Api.h"
#import "YMEncryptionManager.h"
@implementation TSRequest (Api)

+ (RequestModel *)deleteRequetWithApi:(NSString *)api withParam:(NSDictionary *)data_dic error:(NSError *__autoreleasing *)error {
    __block RequestModel *model = nil;
    __block NSError *blockError = nil;
    [[TSRequest request] DELETE:api
                     parameters:data_dic
                        success:^(TSRequest *request, id response) {
                            model = [RequestModel mj_objectWithKeyValues:response];
                            if ([model.status intValue] != 200) {
                                blockError = (NSError *)@"fail";
                            }
                            NSLog(@"delete request back message:%@",model.message);
                        } failure:^(TSRequest *request, NSError *error) {
                            blockError = error;
                        }];
    if (blockError) {
        *error = blockError;
    }
    return model;
}

+ (RequestModel *)postRequetWithApi:(NSString *)api withParam:(id)data_dic error:(NSError* __autoreleasing*)error {
    
    __block RequestModel *model = nil;
    __block NSError *blockError = nil;
    
    [[TSRequest request] POST:api
                   parameters:data_dic
                      success:^(TSRequest *request, id response) {
                          model = [RequestModel mj_objectWithKeyValues:response];
                          if ([model.status intValue] != 200) {
                              blockError = (NSError *)@"fail";
                          }
                          NSLog(@"post request -- message:%@",model.message);
                      }failure:^(TSRequest *request, NSError *error) {
                          blockError = error;
                      }];
    if (blockError) {
        *error = blockError;
    }
    return model;
}

+ (RequestModel *)getRequetWithApi:(NSString *)api withParam:(NSDictionary*)data_dic error:(NSError* __autoreleasing*)error {
    __block RequestModel *model = nil;
    __block NSError *blockError = nil;
    
    [[TSRequest request] GET:api
                  parameters:data_dic
                     success:^(TSRequest *request, id response) {
                         model = [RequestModel mj_objectWithKeyValues:response];
                         if ([model.status intValue] != 200) {
                             blockError = (NSError *)@"fail";
                         }
                         NSLog(@"get request back message:%@",model.message);
                     } failure:^(TSRequest *request, NSError *error) {                    
                         blockError = error;
                     }];
    
    if (blockError) {
        *error = blockError;
    }
    return model;
}

+ (RequestModel *)putRequetWithApi:(NSString *)api withParam:(NSDictionary *)data_dic error:(NSError *__autoreleasing *)error {
    __block RequestModel *model = nil;
    __block NSError *blockError = nil;
    
    [[TSRequest request] PUT:api
                  parameters:data_dic
                     success:^(TSRequest *request, id response) {
                         model = [RequestModel mj_objectWithKeyValues:response];
                         
                         if ([model.status intValue] != 200) {
                             blockError = (NSError *)@"fail";
                         }
                         NSLog(@"get request back message:%@",model.message);
                     } failure:^(TSRequest *request, NSError *error) {
                         blockError = error;
                     }];
    
    if (blockError) {
        *error = blockError;
    }
    return model;
}


+ (BOOL)downloadAudioWithMessageModel:(MessageModel *)model error:(NSError *__autoreleasing *)error {
    __block BOOL result = NO;
    __block NSError *blockError = nil;
//    __block NSString *fileName = model.fileName;
//    __block NSString *messageId = model.messageId;
//    __block NSString *roomId = model.roomId;
    
    NSString *hostUrl = [NSString ym_fileUrlStringWithSourceId:model.sourceId];
//    NSString *hostUrl = [NSString stringWithFormat:@"%@/file/getFile?id=%@",UploadHostUrl,model.sourceId];
    NSString *fileName = model.fileName;
    if (model.isCryptoMessage)
        fileName = [@"sec" stringByAppendingString:fileName];
    NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:fileName];
    if ([NSFileManager defaultManager])
    [[TSRequest request] downAudioWithURL:hostUrl
                                 filePath:path
                                  success:^(TSRequest *request, id response) {
                                      result = [FMDBManager seletedFileIsSaveWithPath:model];
                                      if (model.isCryptoMessage && !result) {
                                          NSData *data = [NSData dataWithContentsOfFile:path];
                                          if (!data)
                                              return;
                                          if (model.fileKey) {
                                              data = [[YMEncryptionManager shareManager] decryptAttachment:data withKey:model.fileKey];
                                          }
                                          else {
                                              data = [[YMEncryptionManager shareManager] decryptData:data cryptoType:model.cryptoType withUserID:model.sender needBase64:NO];
                                          }
                                          NSString *nPath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
                                          [data writeToFile:nPath atomically:YES];
                                          [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                                      }
                                      [FMDBManager updateFileNameWithMessageModel:model];
                                  } fail:^(TSRequest *request, NSError *error) {
                                      NSLog(@"%@",error);
                                      blockError = error;
                                  }];
    if (blockError) {
        *error = blockError;
    }
    return result;
}

+ (BOOL)downloadFileWithMessageModel:(MessageModel *)model error:(NSError *__autoreleasing *)error {
    __block BOOL result = NO;
    __block NSError *blockError = nil;
    
    NSString *hostUrl = [NSString ym_fileUrlStringWithSourceId:model.sourceId];
    NSString *fileName = model.fileName;
    
//    NSString *hostUrl = [NSString stringWithFormat:@"%@/file/getFile?id=%@",UploadHostUrl,model.sourceId];

    if (model.isCryptoMessage) {
        fileName = [@"sec" stringByAppendingString:fileName];
    }else {
        model.content = [model.messageId stringByAppendingString:model.fileName];
        fileName = model.content;
    }

    NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:fileName];
    [[TSRequest request] downAudioWithURL:hostUrl
                                 filePath:path
                                  success:^(TSRequest *request, id response) {
                                      result = [FMDBManager seletedFileIsSaveWithPath:model];
                                      if (model.isCryptoMessage && !result) {
                                          NSData *data = [NSData dataWithContentsOfFile:path];
                                          if (!data)
                                              return;
                                          if (model.fileKey) {
                                              data = [[YMEncryptionManager shareManager] decryptAttachment:data withKey:model.fileKey];
                                          }
                                          else {
                                              data = [[YMEncryptionManager shareManager] decryptData:data cryptoType:model.cryptoType withUserID:model.sender needBase64:NO];
                                          }
                                          NSString *nPath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
                                          [data writeToFile:nPath atomically:YES];
                                          [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
                                      }
                                      [FMDBManager updateFileNameWithMessageModel:model];
                                  } fail:^(TSRequest *request, NSError *error) {
                                      NSLog(@"%@",error);
                                      blockError = error;
                                  }];
    if (blockError) {
        *error = blockError;
    }
    return result;
}

+ (void)downLoadAudioWithTitle:(MessageModel *)model {
    if (model.fileName.length<1) {
        model.fileName = [NSString stringWithFormat:@"audio_%@.aac",[NSUUID UUID].UUIDString];
    }
    __block NSString *messageId = model.messageId;
    
    @weakify(model);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error;
        @strongify(model)
        BOOL result = [TSRequest downloadAudioWithMessageModel:model error:&error];
        if (error==nil&&result==YES) {
            NSLog(@"音频下载成功");
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadingMessage" object:@{@"messageId":messageId}];
    });
}

+ (BOOL)downloadImageWithMessageModel:(MessageModel *)model imageURL:(NSString*)url error:(NSError *__autoreleasing *)error
{
    __block BOOL result = NO;
    __block NSError *blockError = nil;
    NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    [[TSRequest request] downImageWithURL:url
                                 filePath:path
                                  success:^(TSRequest *request, id response) {
                                      result = [FMDBManager seletedFileIsSaveWithPath:model];
                                      if (model.isCryptoMessage && result) {
                                          NSData *data = [NSData dataWithContentsOfFile:path];
                                          UIImage *image = [UIImage imageWithData:data];
                                          if (image)
                                              return;
                                          if (model.fileKey) {
                                              data = [[YMEncryptionManager shareManager] decryptAttachment:data withKey:model.fileKey];
                                          }
                                          else {
                                              data = [[YMEncryptionManager shareManager] decryptData:data cryptoType:model.cryptoType withUserID:model.sender needBase64:NO];
                                          }
                                          [data writeToFile:path atomically:YES];
                                      }
                                      [FMDBManager updateFileNameWithMessageModel:model];
                                  } fail:^(TSRequest *request, NSError *error) {
                                      NSLog(@"%@",error);
                                      blockError = error;
                                  } progress:^(int64_t count, int64_t total) {
                                      
                                  }];
    if (blockError) {
        *error = blockError;
    }
    return result;
}

+ (BOOL)downloadVideoThumbIMGWithMessageModel:(MessageModel *)model imageURL:(NSString*)url error:(NSError *__autoreleasing *)error
{
    __block BOOL result = NO;
    __block NSError *blockError = nil;
    NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.videoIMGName];
    [[TSRequest request] downImageWithURL:url
                                 filePath:path
                                  success:^(TSRequest *request, id response) {
                                      if (model.isCryptoMessage) {
                                          NSData *data = [NSData dataWithContentsOfFile:path];
                                          UIImage *image = [UIImage imageWithData:data];
                                          if (image)
                                              return;
                                          if (model.fileKey) {
                                              data = [[YMEncryptionManager shareManager] decryptAttachment:data withKey:model.fileKey];
                                          }
                                          else {
                                              data = [[YMEncryptionManager shareManager] decryptData:data cryptoType:model.cryptoType withUserID:model.sender needBase64:NO];
                                          }
                                          [data writeToFile:path atomically:YES];
                                      }
                                  } fail:^(TSRequest *request, NSError *error) {
                                      NSLog(@"%@",error);
                                      blockError = error;
                                  } progress:^(int64_t count, int64_t total) {
                                      
                                  }];
    if (blockError) {
        *error = blockError;
    }
    return result;
}



#pragma mark - 下载图片
+ (void)downloadImageWithMessageModel:(MessageModel *)model
                             imageURL:(NSString *)imageURL
                             progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                              success:(TSRequestSuccessBlock)success
                              failure:(TSRequestFailureBlock)failure {
    __block BOOL result = NO;
    NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    
    [[TSRequest request] downImageWithURL:imageURL progress:downloadProgressBlock filePath:path success:^(id responseData) {
        
        result = [FMDBManager seletedFileIsSaveWithPath:model];
        if (model.isCryptoMessage && result) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage *image = [UIImage imageWithData:data];
            if (success) {
                success(responseData);
            }
            if (image) return;
            if (model.fileKey) {
                data = [[YMEncryptionManager shareManager] decryptAttachment:data withKey:model.fileKey];
            }
            else {
                data = [[YMEncryptionManager shareManager] decryptData:data cryptoType:model.cryptoType withUserID:model.sender needBase64:NO];
            }
            [data writeToFile:path atomically:YES];
        }
        [FMDBManager updateFileNameWithMessageModel:model];
        if (success) {
            success(responseData);
        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];

//    if (blockError) {
//        *error = blockError;
//    }
//    return result;
}


@end
