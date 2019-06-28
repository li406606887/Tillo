//
//  NetworkModel.m
//  T-Shion
//
//  Created by together on 2019/1/8.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NetworkModel.h"
#import <CommonCrypto/CommonCryptor.h>
//add by chw 2019.04.16 for Encryption
#import "YMEncryptionManager.h"

@class SocketViewModel;

static NSString *const key= @"y4s60Xmw0Z2ucm85";
static dispatch_queue_t uploadFileQueue;

@implementation NetworkModel

+ (void)sendMessageWithMessage:(MessageModel *)model {
    NSString *chatType = model.receiver ? @"singleChat" : @"groupChat";

    if (model.receiver && model.isCryptoMessage) {//如果是加密消息传入接收者身份密钥
        model.remoteIdentityKey = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:model.receiver];
    }
    
    BOOL state = [SocketViewModel getSaveMessageWayWithType:chatType roomId:model.roomId];
    
    [SocketViewModel updateSessionDataWithWay:state type:chatType message:[model copy] count:0];
    
    if (model.msgType == MESSAGE_IMAGE) {
        //发送图片消息
        [self sendImgMessageWithModel:model];
        
    } else if (model.msgType == MESSAGE_File || model.msgType == MESSAGE_AUDIO || model.msgType == MESSAGE_Location) {
        //发送文件类型消息包括语音和位置消息
        [self sendFileMessageWithModel:model];
        
    } else if (model.msgType == MESSAGE_Video) {
        //发送视频类型消息
        [self sendVideoMessageWithModel:model];
        
    } else if (model.msgType == MESSAGE_TEXT||model.msgType == MESSAGE_Contacts_Card) {
        //发送文本类型消息
        [self sendTextMessageWithModel:model];
    }
}

+ (void)sendMessageWithApi:(NSString *)api params:(NSMutableDictionary *)params count:(NSInteger)count resend:(void(^)(void))resendBlock{
    __block NSString *roomId = [params objectForKey:@"roomId"];
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:roomId forKey:@"roomId"];
    [dictionary setObject:params[@"type"] forKey:@"type"];
    [dictionary setObject:@"2" forKey:@"sendStatus"];
    if (![params[@"type"] isEqualToString:@"withdraw"]) {
        [dictionary setObject:[params objectForKey:@"backId"] forKey:@"backId"];
    }
    NSMutableDictionary *sendParam = [params mutableCopy];
    if ([sendParam objectForKey:@"originalContent"])
        [sendParam removeObjectForKey:@"originalContent"];
    if ([params objectForKey:@"originalLocationInfo"])
        [sendParam removeObjectForKey:@"originalLocationInfo"];
    [NetworkModel sendMessageWithParam:sendParam api:api success:^(id x){
        [dictionary setObject:@"1" forKey:@"sendStatus"];
        NSString *data = [NSString ym_decryptAES:x];
        NSDictionary *dic = [NSString dictionaryWithJsonString:data];
        MessageModel *new = [MessageModel mj_objectWithKeyValues:dic];
        new.readStatus = @"1";
        if (new.isCryptoMessage) {
            if ([params objectForKey:@"originalContent"])
                new.content = [params objectForKey:@"originalContent"];
            if ([params objectForKey:@"originalLocationInfo"])
                new.locationInfo = [params objectForKey:@"originalLocationInfo"];
        }
        if (new.msgType == MESSAGE_Withdraw) {
            [FMDBManager withdrawMessageWithMsgId:new.messageId roomId:new.roomId];
            new.content = Localized(@"Self_Withdraw");
            NSString *receiver = params[@"receiver"];
            if (receiver.length>5) {
                [FMDBManager insertSessionOnlineWithType:@"singleChat" message:new withCount:0];
            }else {
                [FMDBManager insertSessionOnlineWithType:@"groupChat" message:new withCount:0];
            }
        }else {
            if (new.msgType == MESSAGE_Contacts_Card) {
                new.content = [params objectForKey:@"content"];
            }
            [FMDBManager updateSendSuccessMessageModelWithContentModel:new];
        }
        
        if ([[SocketViewModel shared].room isEqualToString:new.roomId]) {
            [TShionSingleCase playMessageSentSound];
            [dictionary setObject:new forKey:@"model"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dictionary];
        }
    } fail:^(NSInteger failCode) {
        if (failCode == 9998) { //加密密钥错误了，要重新加密发送
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (resendBlock)
                    resendBlock();
            });
            return;
        }
        else if (failCode == -1001) { //发送超时了，重发4次，总共发送5次
            NSInteger n = count+1;
            if (n < 5) {
                [self sendMessageWithApi:api params:params count:n resend:resendBlock];
                return;
            }
        }
        if ([[SocketViewModel shared].room isEqualToString:roomId]) {
            [dictionary setObject:@"2" forKey:@"sendStatus"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dictionary];
        } else {
            if ([dictionary[@"type"] isEqualToString:@"withdraw"]) return;
            [FMDBManager updateUnsendMessageStatusWithRoomId:dictionary[@"roomId"] backId:dictionary[@"backId"] sendState:@"2"];
        }
    }];
}

+ (void)sendMessageWithParam:(NSMutableDictionary *)param api:(NSString *)api success:(void (^)(id))success fail:(void (^)(NSInteger failCode))fail {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSError * error;
        NSString *jsonString = [NSString dictionaryToJson:param];
        NSString *encryptAES = [NSString ym_encryptAES:jsonString];
        NSDictionary *paramString = @{@"EncryptAESkey":encryptAES};
        RequestModel *request = [TSRequest postRequetWithApi:api withParam:paramString error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!error) {
                success(request.data);
            }else {
                if ([error isKindOfClass:[NSError class]] && error.code == -1001) {//发送超时要重发
                    fail(-1001);
                }
                else if ([request.status isEqualToString:@"9998"]) {
                    if ([request.data isKindOfClass:[NSDictionary class]])
                        [[YMEncryptionManager shareManager] updateUserCryptInfo:request.data withUserId:[param objectForKey:@"receiver"]];
                    else if ([request.data isKindOfClass:[NSArray class]]) {
                        NSArray *array = request.data;
                        for (NSDictionary *data in array) {
                            [[YMEncryptionManager shareManager] updateUserCryptInfo:data withUserId:[data objectForKey:@"userId"]];
                        }
                    }
                    fail(9998);
                }
                else
                    fail(0);
            }
            
        });
    });
}

+ (NSMutableDictionary *)changeMessageModel:(MessageModel *)model {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:model.sender forKey:@"sender"];
    [param setObject:model.roomId forKey:@"roomId"];
    [param setObject:model.backId forKey:@"backId"];
    [param setObject:model.type forKey:@"type"];
    if (model.sourceId) {
        [param setObject:model.sourceId forKey:@"sourceId"];
    }
    
    if (model.receiver) {
        [param setObject:model.receiver forKey:@"receiver"];
    }
    if ([model.type isEqualToString:@"text"]||[model.type isEqualToString:@"withdraw"]||[model.type isEqualToString:@"card"]) {
        if ([model.type isEqualToString:@"withdraw"]) {//如果是撤回需要传消息ID
            [param setObject:model.messageId forKey:@"messageId"];
        }
        [param setObject:model.content forKey:@"content"];
    } else if (model.fileName!=nil){
        [param setObject:model.fileName forKey:@"fileName"];
    }
    
    if ([model.type isEqualToString:@"file"]) {
        [param setObject:model.fileSize forKey:@"fileSize"];
    }
    
    if ([model.type isEqualToString:@"audio"]||[model.type isEqualToString:@"video"]) {
        [param setObject:model.duration forKey:@"duration"];
    }
    
    if (model.atModelList.count > 0) {
        [param setObject:model.atModelList forKey:@"atModelList"];
    }
    
    if (model.measureInfo) {
        [param setObject:model.measureInfo forKey:@"measureInfo"];
    }
    //add by chw 2019.04.17 for Encryption
    if (model.isCryptoMessage) {
        [param setObject:@(model.cryptoType) forKey:@"cryptoType"];
        [param setObject:@(1) forKey:@"isCryptoMessage"];
        if (model.remoteIdentityKey)
            [param setObject:model.remoteIdentityKey forKey:@"remoteIdentityKey"];
        if (model.originalContent)
            [param setObject:model.originalContent forKey:@"originalContent"];
        if (model.originalSourceId)
            [param setObject:model.originalSourceId forKey:@"originalSourceId"];
        if (model.originalLocationInfo)
            [param setObject:model.originalLocationInfo forKey:@"originalLocationInfo"];
        if (model.fileKey)
            [param setObject:model.fileKey forKey:@"fileKey"];
    }
    
    return param;
}

+ (dispatch_queue_t)getQueue {
    if (!uploadFileQueue) {
        uploadFileQueue = dispatch_queue_create("uploadFileQueue.cc", DISPATCH_QUEUE_SERIAL);
    }
    return uploadFileQueue;
}

+ (void)withdrawMessageWithModel:(MessageModel *)model {
    NSString *type;
    NSString *api;

    if (model.receiver) {
        api = api_message_push;
        type = @"singleChat";
        if (model.isCryptoMessage) {
            model.isCryptoMessage = 2;
            model.remoteIdentityKey = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:model.receiver];
        }
    } else {

        api = api_groupMessage_push;
        type = @"groupChat";
    }
    
    NSMutableDictionary *params = [self getWithdrawMsgPramaWithModel:model];
    [self sendMessageWithApi:api params:params count:0 resend:nil];
}

+ (NSMutableDictionary *)getWithdrawMsgPramaWithModel:(MessageModel *)model {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"withdraw" forKey:@"type"];
    [param setObject:[SocketViewModel shared].userModel.name forKey:@"userName"];
    [param setObject:model.messageId forKey:@"messageId"];
    [param setObject:model.roomId forKey:@"roomId"];
    [param setObject:model.timestamp forKey:@"timestamp"];
    if (model.receiver) {
        [param setObject:model.receiver forKey:@"receiver"];
    }
    if (model.isCryptoMessage){
        [param setObject:@(model.cryptoType) forKey:@"cryptoType"];
        [param setObject:@(1) forKey:@"isCryptoMessage"];
        [param setObject:model.remoteIdentityKey forKey:@"remoteIdentityKey"];
    }
    
    return param;
}

//add by chw 2019.04.25 for Encryption Session Screen Shot
+ (void)sendScreenShotMessageWithModel:(MessageModel*)model {
    NSString *type;
    NSString *api;
    NSMutableDictionary *params = nil;
    if (model.receiver) {
        api = api_message_push;
        type = @"singleChat";
        model.remoteIdentityKey = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:model.receiver];
    } else {
        api = api_groupMessage_push;
        type = @"groupChat";
    }
    params = [self changeMessageModel:model];
    [params setObject:@"shot" forKey:@"operType"];
    [params setObject:model.content forKey:@"content"];
    BOOL state = [SocketViewModel getSaveMessageWayWithType:type roomId:model.roomId];
    [SocketViewModel updateSessionDataWithWay:state type:type message:[model copy] count:0];
    [self sendMessageWithApi:api params:params count:0 resend:nil];
}

+ (NSData *)fileDataOfMessage:(MessageModel *)model {
    NSString *filePath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    if (model.msgType == MESSAGE_File) {
        filePath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.content];
    }
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

#pragma mark - 发送文本消息相关
+ (void)sendTextMessageWithModel:(MessageModel *)model {
    NSString *api = model.receiver ? api_message_push : api_groupMessage_push;
    model.originalContent = model.content;
    if (model.isCryptoMessage) {
        NSData *data = [model.content dataUsingEncoding:NSUTF8StringEncoding];
//        [[YMEncryptionManager shareManager] addActionLog:model.originalContent content:model.content data:data crypt:@"000"];
        __block NSString *encryptData = nil;
        __block NSInteger cryptoType = 0;
        [[YMEncryptionManager shareManager] encryptData:data withUserID:model.receiver needBase64:YES complete:^(NSString * _Nonnull serialize, NSInteger cryptType) {
            encryptData = serialize;
            cryptoType = cryptType;
        }];
        model.content = encryptData;
        model.cryptoType = cryptoType;
    }

    NSMutableDictionary *msgParams = [self changeMessageModel:model];
    [self sendMessageWithApi:api params:msgParams count:0 resend:^{
        model.content = model.originalContent;
        [self sendMessageWithMessage:model];
    }];
}

#pragma mark - 发送图片消息相关
+ (void)sendImgMessageWithModel:(MessageModel *)model {
    NSString *api = model.receiver ? api_message_push : api_groupMessage_push;

    NSData *data = [self fileDataOfMessage:model];
    if (!data) return;
    
    __block CGFloat width = 0;
    __block CGFloat height = 0;
    UIImage *image = [UIImage imageWithData:data];
    width = image.size.width;
    height = image.size.height;
    
    if (model.isCryptoMessage) {
        __block NSData *cryptData = nil;
        __block NSInteger type = 0;
        [[YMEncryptionManager shareManager] encryptData:data withUserID:model.receiver needBase64:NO complete:^(id serialize, NSInteger cryptType) {
            cryptData = serialize;
            type = cryptType;
        }];
        model.cryptoType = type;
        data = cryptData;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    __block NSString *roomId = model.roomId;
    [dic setObject:model.backId forKey:@"backId"];
    [dic setObject:model.roomId forKey:@"roomId"];
    
    if (model.isCryptoMessage) {//加密聊天图片走上传文件接口
        [NetworkModel uploadSingleFileWithData:data params:@{} fileName:model.fileName mimeType:@"" success:^(id x) {
            NSString *sourceId = [x objectForKey:@"id"];
            NSMutableDictionary *msgParams = [self changeMessageModel:model];
            [msgParams setObject:sourceId forKey:@"sourceId"];
            
            NSString *imageSize = [x objectForKey:@"measure"];
            if (imageSize.length > 0) {
                NSArray *array = [imageSize componentsSeparatedByString:@"x"]; //从字符A中分隔成2个元素的数组
                NSDictionary *dictionary = @{@"width":array[0],@"height":array[1]};
                [msgParams setObject:[dictionary mj_JSONString] forKey:@"measureInfo"];
            }
            else {
                NSDictionary *dictionary = @{@"width":@(width),@"height":@(height)};
                [msgParams setObject:[dictionary mj_JSONString] forKey:@"measureInfo"];
            }
            
            [self sendMessageWithApi:api params:msgParams count:0 resend:^{
                [self sendMessageWithMessage:model];
            }];
        } fail:^{
            [dic setObject:@"2" forKey:@"sendStatus"];
            if ([[SocketViewModel shared].room isEqualToString:roomId]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dic];
            } else {
                [FMDBManager updateUnsendMessageStatusWithRoomId:dic[@"roomId"] backId:dic[@"backId"] sendState:@"2"];
            }
        }];
        
    } else {
        //普通聊天走上传图片接口,未加密可进行裁剪
        [NetworkModel uploadImageWithData:data params:@{} fileName:model.fileName success:^(id x) {
            NSString *sourceId = [x objectForKey:@"id"];
            NSMutableDictionary *msgParams = [self changeMessageModel:model];
            [msgParams setObject:sourceId forKey:@"sourceId"];
            
            NSString *imageSize = [x objectForKey:@"measure"];
            if (imageSize.length > 0) {
                NSArray *array = [imageSize componentsSeparatedByString:@"x"]; //从字符A中分隔成2个元素的数组
                NSDictionary *dictionary = @{@"width":array[0],@"height":array[1]};
                [msgParams setObject:[dictionary mj_JSONString] forKey:@"measureInfo"];
            }
            else {
                NSDictionary *dictionary = @{@"width":@(width),@"height":@(height)};
                [msgParams setObject:[dictionary mj_JSONString] forKey:@"measureInfo"];
            }
            
            [self sendMessageWithApi:api params:msgParams count:0 resend:^{
                [self sendMessageWithMessage:model];
            }];
        } fail:^{
            [dic setObject:@"2" forKey:@"sendStatus"];
            if ([[SocketViewModel shared].room isEqualToString:roomId]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dic];
            } else {
                [FMDBManager updateUnsendMessageStatusWithRoomId:dic[@"roomId"] backId:dic[@"backId"] sendState:@"2"];
            }
        }];
    }
}

#pragma mark - 发送文件类型消息相关
+ (void)sendFileMessageWithModel:(MessageModel *)model {
    NSString *api = model.receiver ? api_message_push : api_groupMessage_push;
    
    NSData *data = [self fileDataOfMessage:model];
    if (!data) return;
    
    if (model.isCryptoMessage) {
        __block NSData *cryptData = nil;
        __block NSInteger type = 0;
        [[YMEncryptionManager shareManager] encryptData:data withUserID:model.receiver needBase64:NO complete:^(id serialize, NSInteger cryptType) {
            cryptData = serialize;
            type = cryptType;
        }];
        model.cryptoType = type;
        data = cryptData;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    __block NSString *roomId = model.roomId;
    [dic setObject:model.backId forKey:@"backId"];
    [dic setObject:model.roomId forKey:@"roomId"];

    [NetworkModel uploadSingleFileWithData:data params:@{} fileName:model.fileName mimeType:@"" success:^(id x) {
        NSString *sourceId = [x objectForKey:@"id"];
        NSMutableDictionary *msgParams = [self changeMessageModel:model];
        [msgParams setObject:sourceId forKey:@"sourceId"];
        
        if (model.msgType == MESSAGE_Location && model.locationInfo) {
            //位置类型消息
            NSDictionary *localInfo = [model.locationInfo mj_JSONObject];
            NSMutableDictionary *localInfoDict = [NSMutableDictionary dictionaryWithDictionary:localInfo];
            
            [localInfoDict setObject:[NSString ym_fileUrlStringWithSourceId:sourceId] forKey:@"locationImg"];
            //因为位置消息有两次加密，所以在这里存一次文件加密类型
            if (model.isCryptoMessage)
            {
                [localInfoDict setObject:@(model.cryptoType) forKey:@"cryptoType"];
            }
            
            NSString *localInfoStr = [localInfoDict mj_JSONString];
            [msgParams setObject:[localInfoStr copy] forKey:@"originalLocationInfo"];
            
            if (model.isCryptoMessage) {
                NSData *data = [localInfoStr dataUsingEncoding:NSUTF8StringEncoding];
                __block NSString *str = nil;
                __block NSInteger type = 0;
                [[YMEncryptionManager shareManager] encryptData:data withUserID:model.receiver needBase64:YES complete:^(id  _Nonnull serialize, NSInteger cryptType) {
                    str = (NSString*)serialize;
                    type = cryptType;
                }];
                localInfoStr = str;
                model.cryptoType = type;
            }
            [msgParams setObject:localInfoStr forKey:@"locationInfo"];
        }
        
        [self sendMessageWithApi:api params:msgParams count:0 resend:^{
            [self sendMessageWithMessage:model];
        }];
        
    } fail:^{
        [dic setObject:@"2" forKey:@"sendStatus"];
        if ([[SocketViewModel shared].room isEqualToString:roomId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dic];
        } else {
            [FMDBManager updateUnsendMessageStatusWithRoomId:dic[@"roomId"] backId:dic[@"backId"] sendState:@"2"];
        }
    }];
}

#pragma mark - 发送视频消息相关
+ (void)sendVideoMessageWithModel:(MessageModel *)model {
    NSString *api = model.receiver ? api_message_push : api_groupMessage_push;
    
    NSString *videoFold = [FMDBManager getMessagePathWithMessage:model];
    NSString *videoPath = [videoFold stringByAppendingPathComponent:model.fileName];
    NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
    
    NSString *videoImagePath = [videoFold stringByAppendingPathComponent:model.videoIMGName];
    NSData *imgData = [NSData dataWithContentsOfFile:videoImagePath];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    __block NSString *roomId = model.roomId;
    [dic setObject:model.backId forKey:@"backId"];
    [dic setObject:model.roomId forKey:@"roomId"];
    
    //转发视频文件未加载完成
    if (!videoData || !imgData) {
        [self sendMessageWithApi:api params:[self changeMessageModel:model] count:0 resend:^{
            [self sendMessageWithMessage:model];
        }];
        return;
    }
    if (model.isCryptoMessage) {
        __block NSInteger type = 0;
        __block NSData *data1 = nil;
        [[YMEncryptionManager shareManager] encryptData:videoData withUserID:model.receiver needBase64:NO complete:^(id  _Nonnull serialize, NSInteger cryptType) {
            data1 = serialize;
            type = cryptType;
        }];
        videoData = data1;
        __block NSData *data2 = nil;
        [[YMEncryptionManager shareManager] encryptData:imgData withUserID:model.receiver needBase64:NO complete:^(id  _Nonnull serialize, NSInteger cryptType) {
            data2 = serialize;
            type = cryptType;
        }];
        imgData = data2;
        model.cryptoType = type;
    }
    
    __block NSString *videoFileName = model.fileName;
    __block NSMutableDictionary *msgParams = [self changeMessageModel:model];
    __block NSMutableDictionary *measureInfo = [NSMutableDictionary dictionaryWithDictionary:[model.measureInfo mj_JSONObject]];
    
    [NetworkModel uploadSingleFileWithData:imgData params:@{} fileName:model.videoIMGName mimeType:@"" success:^(id imgResponse) {
        NSString *imageId = [imgResponse objectForKey:@"id"];
        [measureInfo setObject:[NSString ym_fileUrlStringWithSourceId:imageId] forKey:@"frameUrl"];
        [msgParams setObject:[measureInfo mj_JSONString] forKey:@"measureInfo"];
        
        //上传第一帧成功之后，上传视频
        [NetworkModel uploadSingleFileWithData:videoData params:@{} fileName:videoFileName mimeType:@"" success:^(id videoResponse) {
            NSString *videoId = [videoResponse objectForKey:@"id"];
            [msgParams setObject:videoId forKey:@"sourceId"];
            [self sendMessageWithApi:api params:msgParams count:0 resend:^{
                [self sendMessageWithMessage:model];
            }];
            
        } fail:^{
            //上传视频失败
            [dic setObject:@"2" forKey:@"sendStatus"];
            if ([[SocketViewModel shared].room isEqualToString:roomId]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dic];
            } else {
                //add by wsp for send error 2019.3.7
                [FMDBManager updateUnsendMessageStatusWithRoomId:dic[@"roomId"] backId:dic[@"backId"] sendState:@"2"];
            }
        }];
    
    } fail:^{
        //上传第一帧失败
        [dic setObject:@"2" forKey:@"sendStatus"];
        if ([[SocketViewModel shared].room isEqualToString:roomId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dic];
        } else {
            //add by wsp for send error 2019.3.7
            [FMDBManager updateUnsendMessageStatusWithRoomId:dic[@"roomId"] backId:dic[@"backId"] sendState:@"2"];
        }
    }];
}


#pragma mark - 新云存储上传相关
+ (void)uploadImageWithData:(NSData *)data
                     params:(NSDictionary *)params
                   fileName:(NSString *)fileName
                    success:(void(^)(id ))success
                       fail:(void(^)(void))fail {
    dispatch_async([NetworkModel getQueue], ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[TSRequest request] PostImageWithParameters:params data:data fileName:fileName success:^(id x) {
            dispatch_async(dispatch_get_main_queue(), ^{
                long status = [[x objectForKey:@"code"] longValue];
                if (status == 0) {
                    success([x objectForKey:@"data"]);
                }else {
                    fail();
                }
            });
            dispatch_semaphore_signal(semaphore);
            
        } failure:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                fail();
            });
            dispatch_semaphore_signal(semaphore);
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

+ (void)uploadSingleFileWithData:(NSData *)data
                          params:(NSDictionary *)params
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         success:(void(^)(id ))success
                            fail:(void(^)(void))fail {
    
    dispatch_async([NetworkModel getQueue], ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[TSRequest request] PostSingleFileWithParameters:params data:data fileName:fileName mimeType:mimeType success:^(id responseData) {
            dispatch_semaphore_signal(semaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
                long status = [[responseData objectForKey:@"code"] longValue];
                if (status == 0) {
                    success([responseData objectForKey:@"data"]);
                }else {
                    fail();
                }
            });
            
            
        } failure:^(NSError *error) {
            dispatch_semaphore_signal(semaphore);
            dispatch_async(dispatch_get_main_queue(), ^{
                fail();
            });
            
        }];
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    });
}

#pragma mark - 加密群聊
+ (void)sendCryptGroupMessage:(MessageModel*)message {
    @weakify(self)
    BOOL state = [SocketViewModel getSaveMessageWayWithType:@"groupChat" roomId:message.roomId];
    
    [SocketViewModel updateSessionDataWithWay:state type:@"groupChat" message:[message copy] count:0];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    __block NSString *roomId = message.roomId;
    [dic setObject:message.backId forKey:@"backId"];
    [dic setObject:message.roomId forKey:@"roomId"];
    
    void (^success)(NSMutableDictionary *param) = ^(NSMutableDictionary *param) {
        [NetworkModel sendMessageWithApi:api_crypt_groupMessage_push params:param count:0 resend:^{
            [NetworkModel sendCryptGroupMessage:message];
        }];
    };
    void (^failure)(void) = ^{
        //上传文件失败
        [dic setObject:@"2" forKey:@"sendStatus"];
        if ([[SocketViewModel shared].room isEqualToString:roomId]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:dic];
        } else {
            //add by wsp for send error 2019.3.7
            [FMDBManager updateUnsendMessageStatusWithRoomId:dic[@"roomId"] backId:dic[@"backId"] sendState:@"2"];
        }
    };
    if (message.msgType == MESSAGE_Video) {
        NSString *videoFold = [FMDBManager getMessagePathWithMessage:message];
        NSString *videoPath = [videoFold stringByAppendingPathComponent:message.fileName];
        NSData *videoData = [NSData dataWithContentsOfFile:videoPath];
        
        NSString *videoImagePath = [videoFold stringByAppendingPathComponent:message.videoIMGName];
        NSData *imgData = [NSData dataWithContentsOfFile:videoImagePath];
        
        __block NSData *data1 = nil;
        __block NSString *akey = nil;
        [[YMEncryptionManager shareManager] encryptAttachment:imgData withKey:nil complete:^(NSData * _Nonnull serialize, NSString * _Nonnull key) {
            data1 = serialize;
            akey = key;
        }];
        __block NSData *data2 = nil;
        [[YMEncryptionManager shareManager] encryptAttachment:videoData withKey:akey complete:^(NSData * _Nonnull serialize, NSString * _Nonnull key) {
            data2 = serialize;
        }];
        message.fileKey = akey;
        __block NSString *videoFileName = message.fileName;
        __block NSMutableDictionary *msgParams = [self changeCryptGroupMessageModel:message];
        __block NSMutableDictionary *measureInfo = [NSMutableDictionary dictionaryWithDictionary:[message.measureInfo mj_JSONObject]];
        
        [NetworkModel uploadSingleFileWithData:data1 params:@{} fileName:message.videoIMGName mimeType:@"" success:^(id imgResponse) {
            NSString *imageId = [imgResponse objectForKey:@"id"];
            [measureInfo setObject:[NSString ym_fileUrlStringWithSourceId:imageId] forKey:@"frameUrl"];
            [msgParams setObject:[measureInfo mj_JSONString] forKey:@"measureInfo"];
            [NetworkModel uploadSingleFileWithData:data2 params:@{} fileName:videoFileName mimeType:@"" success:^(id videoResponse) {
                NSString *videoId = [videoResponse objectForKey:@"id"];
                [msgParams setObject:videoId forKey:@"sourceId"];
                success(msgParams);
            } fail:failure];
        } fail:failure];
    }
    else if (message.msgType != MESSAGE_TEXT) {
        //发送图片\文件\音频\位置消息
        NSData *data = [self fileDataOfMessage:message];
        if (!data) return;
        
        __block NSData *data1 = nil;
        __block NSString *akey = nil;
        [[YMEncryptionManager shareManager] encryptAttachment:data withKey:nil complete:^(NSData * _Nonnull serialize, NSString * _Nonnull key) {
            data1 = serialize;
            akey = key;
        }];
        message.fileKey = akey;
        NSData *d = [data1 copy];
        
        [NetworkModel uploadSingleFileWithData:d params:@{} fileName:message.fileName mimeType:@"" success:^(id x) {
            NSString *sourceId = [x objectForKey:@"id"];
            message.sourceId = sourceId;
            NSMutableDictionary *msgParams = [self changeCryptGroupMessageModel:message];
            [msgParams setObject:sourceId forKey:@"sourceId"];

            success(msgParams);
            
        } fail:failure];
    } else {
        NSMutableDictionary *dic = [self changeCryptGroupMessageModel:message];
        success(dic);
    }
}

+ (NSMutableDictionary*)changeCryptGroupMessageModel:(MessageModel*)model {
    NSMutableDictionary *ret = [self changeMessageModel:model];
    NSArray *array = [FMDBManager getAllMemberUserIdByGroupId:model.roomId];
    NSString *content = nil;
    if ([ret objectForKey:@"content"]) {
        content = [ret objectForKey:@"content"];
        [ret removeObjectForKey:@"content"];
        [ret setObject:content forKey:@"originalContent"];
    }
    NSMutableDictionary *locationInfo = nil;
    if (model.locationInfo) {
        [ret removeObjectForKey:@"locationInfo"];
        NSDictionary *localInfo = [model.locationInfo mj_JSONObject];
        locationInfo = [NSMutableDictionary dictionaryWithDictionary:localInfo];
        
        [locationInfo setObject:[NSString ym_fileUrlStringWithSourceId:model.sourceId] forKey:@"locationImg"];
        
        NSString *localInfoStr = [locationInfo mj_JSONString];
        [ret setObject:localInfoStr forKey:@"originalLocationInfo"];
    }
    NSMutableArray *contentArray = [NSMutableArray arrayWithCapacity:array.count];
    for (NSString *userId in array) {
        if ([userId isEqualToString:model.sender])
            continue;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:userId forKey:@"receiver"];
        NSString *remoteKey = [[YMEncryptionManager shareManager] remoteIdentityKeyWithUserID:userId];
        if (!remoteKey)
            continue;
        [dic setObject:remoteKey forKey:@"remoteIdentityKey"];
        if (content) {
            __block NSString *str = nil;
            __block NSInteger type = 0;
            NSData *infoData = [content dataUsingEncoding:NSUTF8StringEncoding];
            [[YMEncryptionManager shareManager] encryptData:infoData withUserID:userId needBase64:YES complete:^(id  _Nonnull serialize, NSInteger cryptType) {
                str = (NSString*)serialize;
                type = cryptType;
            }];
            if (str == nil)
                return nil;
            [dic setObject:str forKey:@"content"];
            [dic setObject:@(type) forKey:@"cryptoType"];
        }
        if (model.fileKey) {
            __block NSString *str = nil;
            __block NSInteger type = 0;
            NSData *infoData = [model.fileKey dataUsingEncoding:NSUTF8StringEncoding];
            [[YMEncryptionManager shareManager] encryptData:infoData withUserID:userId needBase64:YES complete:^(id  _Nonnull serialize, NSInteger cryptType) {
                str = (NSString*)serialize;
                type = cryptType;
            }];
            [dic setObject:str forKey:@"fileKey"];
            if (locationInfo) {
                [locationInfo setObject:@(type) forKey:@"cryptoType"];
                NSString *localInfoStr = [locationInfo mj_JSONString];
                __block NSString *str = nil;
                __block NSInteger type = 0;
                NSData *infoData = [localInfoStr dataUsingEncoding:NSUTF8StringEncoding];
                [[YMEncryptionManager shareManager] encryptData:infoData withUserID:userId needBase64:YES complete:^(id  _Nonnull serialize, NSInteger cryptType) {
                    str = (NSString*)serialize;
                    type = cryptType;
                }];
                [dic setObject:str forKey:@"locationInfo"];
                [dic setObject:@(type) forKey:@"cryptoType"];
            }
            else {
                [dic setObject:@(type) forKey:@"cryptoType"];
            }
        }
        [contentArray addObject:dic];
    }
    [ret setObject:@(1) forKey:@"isCryptoMessage"];
    [ret setObject:contentArray forKey:@"encryptGroupChatData"];
    return ret;
}

@end
