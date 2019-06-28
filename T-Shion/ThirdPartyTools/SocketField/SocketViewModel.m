//
//  SocketViewModel.m
//  T-Shion
//
//  Created by together on 2018/4/8.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "SocketViewModel.h"
#import "CallRTCModel.h"
#import "TSRTCChatViewController.h"
#import "BaseNavigationViewController.h"
#import "AppDelegate.h"
#import <AudioToolbox/AudioToolbox.h>
#import "NetworkModel.h"
#import "WebRTCHelper.h"
#import "RoomSetModel.h"
#import "ALSlideMenu.h"
#import "ALCameraRecordViewController.h"
#import "GSKeyChainDataManager.h"
//add by chw 2019.04.17 for Encryption
#import "YMEncryptionManager.h"
#import "WebRTCHelper.h"

#import "YMDownloadSession.h"
#import "YMRTCBrowser.h"
#import "YMRTCHelper.h"
#import "YMIBUtilities.h"

#import "YMDownSettingManager.h"

static SocketViewModel *socketViewModel;
static dispatch_queue_t connectLoadingDataQueue;

@interface SocketViewModel()
@property (strong, nonatomic) dispatch_source_t socketTimer;

@property (nonatomic, strong) RACCommand *getUserInfoCommand;
@property (nonatomic, strong) RACCommand *kickUserVerifyCommand;//设备踢出二次验证，以服务端为准

@end

@implementation SocketViewModel
+ (SocketViewModel *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        socketViewModel = [[SocketViewModel alloc] init];
        connectLoadingDataQueue = dispatch_queue_create("Aillo.cc", DISPATCH_QUEUE_SERIAL);
    });
    return socketViewModel;
}

#pragma mark 提交推送token
- (void)uploadDeviceToken {
    if (self.deviceToken) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error;
            RequestModel *model = [TSRequest postRequetWithApi:api_post_device_token withParam:@{@"deviceToken":self.deviceToken} error:&error];
            if (!error) {
                NSLog(@"%@",model.data);
            }
        });
    }
}

- (void)beginConnect:(BOOL)afterLogin {
    
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if (userID.length == 0) return;
    //wsp 修改 设备被踢出问题 2019.3.25
//    [[WebRTCHelper sharedInstance] initiatingData];
    [self.client disconnect];
    
    if (afterLogin) {
        if (!self.client.isRunning) {
            self.status = 2;
            [self.client connectToHost];
        }
    } else {
        if (!self.client.isRunning) {
            [self.getUserInfoCommand execute:nil];
        }
    }
}

- (void)endDisConnect {
//    [FMDBManager updateUnsendMessageStatus];
    [self.client disconnect];
    self.client = nil;
}

+ (void)kickUserRequest:(BOOL)unauthorized {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topVC = (UIViewController *)YMIBGetTopController();
        
        if ([topVC isKindOfClass:[YMRTCBrowser class]]) {
            YMRTCBrowser *rtcVC = (YMRTCBrowser  *)topVC;
            [[YMRTCHelper sharedInstance].currentRtcItem closeRtcCall:YES];
            [rtcVC hide];
        }
        [SocketViewModel showkickUserAlert:unauthorized];
    });
}

+ (void)showkickUserAlert:(BOOL)unauthorized {
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        return;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"Tips") message:Localized(unauthorized ?@"Tips_Unauthorized" :@"Tips_KickUser")
                                                   delegate:nil cancelButtonTitle:Localized(@"Confirm") otherButtonTitles: nil];
    [alert show];
    
    [SocketViewModel cleanUserData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"exitLogin" object:nil];
    
}

+ (void)forbidUser {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localized(@"Tips") message:@"你的账户已被封禁"
                                                   delegate:nil cancelButtonTitle:Localized(@"Confirm") otherButtonTitles: nil];
    [alert show];
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        return;
    }
    [SocketViewModel cleanUserData];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"exitLogin" object:nil];
}

+ (void)cleanUserData {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *appRootViewController = window.rootViewController;
    [appRootViewController dismissViewControllerAnimated:NO completion:nil];
    
    //add by wsp 2019 3月30
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [[SocketViewModel shared].client unbindUserWithUserId:userID];
    
    [[SocketViewModel shared] endDisConnect];
    [[SocketViewModel shared].userModel outLoginCleanInfomation];

    [SocketViewModel shared].userModel = nil;
    [[FMDBManager shared].db close];
    [FMDBManager shared].DBQueue = nil;
}

- (void)bindUser {
    //add by wsp 2019 3月30
    NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [MPConfig defaultConfig].userId = userID;
    [self.client bindUserWithUserId:userID];
}


#pragma mark - MPClientDelegate
-(void)client:(MPClient *)client onConnectedSock:(GCDAsyncSocket *)sock{
    MPLog(@"MPClientDelegate onConnectedSock");
    
    
    //add by wsp 2019.5.7:如果应用杀死情况下被唤醒去链接mupsh成功，应用在后台断开，否则apns收不到
    dispatch_async(dispatch_get_main_queue(), ^{
        UIApplicationState aaaa = [UIApplication sharedApplication].applicationState;
        NSLog(@"-------");
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            [[SocketViewModel shared] endDisConnect];
            return;
        }
    });
    //end

    NSString *myId = [SocketViewModel shared].userModel.ID;
    if (myId.length < 1) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"exitLogin" object:nil];
        return;
    }
    
    //add by wsp 2019 3月30
    [self bindUser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFirendPrompt" object:nil];
    self.status = 1;
    [self.getFriendsCommand execute:nil];
    [self.getGroupsCommand execute:nil];
    [self.getUnreadSessionCommand execute:nil];
    if (self.room.length > 1) {
        [self.reconnectGetNetDataSubject sendNext:nil];
    }
    NSLog(@"我的ID是-----%@",[SocketViewModel shared].userModel.ID);
    
    //wsp 修改 统计mpush连接绑定
    NSMutableDictionary *logData = [NSMutableDictionary dictionary];
    [logData setObject:self.userModel.ID forKey:@"user_id"];
    [logData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
    [logData setObject:self.userModel.name forKey:@"userName"];
    [logData setObject:[GSKeyChainDataManager readUUID] forKey:@"deviceId"];
    [logData setObject:@"mpush connetct" forKey:@"requestURL"];
    [logData setObject:[NSDate getNowTimestamp] forKey:@"timeStr"];
    
    [FMDBManager updateMpushConnectLog:logData];
    
    //add by chw 2019.04.20 for "修改rtc的一些bug"
//    [[WebRTCHelper sharedInstance] initiatingData];
}

- (void)clientOnRecieveHeartBeat:(MPClient *)client {
    NSLog(@"心一跳~~~");
}

- (void)client:(MPClient *)client onKickUser:(MPKickUserMessage *)kickUser {
    NSLog(@"-------被t下线了");
    
    NSMutableDictionary *kickData = [NSMutableDictionary dictionary];
    [kickData setObject:self.userModel.ID forKey:@"user_id"];
    [kickData setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"token"] forKey:@"token"];
    [kickData setObject:self.userModel.name forKey:@"userName"];
    [kickData setObject:[GSKeyChainDataManager readUUID] forKey:@"deviceId"];
    [kickData setObject:@"mpush onKickUser" forKey:@"requestURL"];
    [kickData setObject:[NSDate getNowTimestamp] forKey:@"timeStr"];

    [FMDBManager updateKickLog:kickData];

    [self.kickUserVerifyCommand execute:nil];
}

- (void)client:(MPClient *)client onDisConnectedSock:(GCDAsyncSocket *)sock{
    MPLog(@"MPClientDelegate onDisConnectedSock----断开连接");

    self.status = 0;
}

- (void)client:(MPClient *)client onHandshakeOk:(int32_t)heartbeat{
    MPLog(@"MPClientDelegate heartbeat: %d", heartbeat);
}

- (void)client:(MPClient *)client onRecieveOkMsg:(MPOkMessage *)okMsg{
    MPLog(@"MPClientDelegate onRecieveOkMsg: %@",[okMsg debugDescription]);
    //接收成功消息
    [NSString stringWithFormat:@"%@", okMsg.data];
}

- (void)client:(MPClient *)client onRecieveErrorMsg:(MPErrorMessage *)errorMsg{
    MPLog(@"MPClientDelegate onRecieveErrorMsg--接收错误消息: %@",[errorMsg debugDescription]);
}

- (void)client:(MPClient *)client onRecievePushMsg:(MPPushMessage *)pushMessage{
    MPLog(@"[NSThread currentThread: %@] onRecievePushMsg pushMessage: %@",[NSThread currentThread] ,[pushMessage debugDescription]);
    //接收推送消息
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        NSDictionary *dictionary = [NSString dictionaryWithJsonString:[pushMessage.contentDict objectForKey:@"content"]];
        NSLog(@"%@",dictionary);
        NSString *route = dictionary[@"route"];
        if ([route isEqualToString:@"singleChat"]||[route isEqualToString:@"groupChat"] ) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self receiverNewMessage:dictionary];
            });
        }else if ([route isEqualToString:@"addFriend"]) {
            NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",self.userModel.ID];
            NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            int numbers = [number intValue] + 1;
            [[NSUserDefaults standardUserDefaults] setObject:@(numbers) forKey:key];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFirendPrompt" object:nil];
        }else if([route isEqualToString:@"rtc"]){
            CallRTCModel *model = [CallRTCModel mj_objectWithKeyValues:dictionary];
            if ([[dictionary objectForKey:@"isCryptoMessage"] boolValue] == YES) {
                [[YMEncryptionManager shareManager] storeCryptRoomId:model.roomId userId:model.sender isSender:NO timeStamp:[[NSDate date] timeIntervalSince1970]];
            }
            if ([model.cmd isEqualToString:@"call"]) {
                NSString *roomID = [dictionary objectForKey:@"roomId"];
                NSArray *receivers = @[[dictionary objectForKey:@"sender"]];
                NSString *type = [dictionary objectForKey:@"type"];
                NSString *receiverHost = [dictionary objectForKey:@"rtcServer"];
                NSString *messageId = [NSString stringWithFormat:@"%@",dictionary[@"id"]];
                
                FriendsModel *receiveModel = [FMDBManager selectFriendTableWithUid:[dictionary objectForKey:@"sender"]];
                
                YMRTCChatType chatType;
                chatType = [type isEqualToString:@"video"] ? YMRTCChatType_Video : YMRTCChatType_Audio;
                YMRTCDataItem *dataItem = [[YMRTCDataItem alloc] initWithChatType:chatType
                                                                             role:YMRTCRole_Callee
                                                                           roomId:roomID otherInfoData:receiveModel];
                dataItem.receiveHostURL = receiverHost;
                YMRTCBrowser *browser = [[YMRTCBrowser alloc] initWithDataItem:dataItem];
                [browser show];
                
//                RTCChatType chatType;
//                if ([type isEqualToString:@"video"]) {
//                    chatType = RTCChatType_Video;
//                } else {
//                    chatType = RTCChatType_Audio;
//                }
//                
//                UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
//                
//                if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
//                    return;
//                }
//                
//                TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Callee
//                                                                                       chatType:chatType
//                                                                                         roomID:roomID
//                                                                                 receiveIDArray:receivers
//                                                                                 receiveHostURL:receiverHost];
//                chatVC.receiveModel = receiveModel;
//                chatVC.messageId = messageId;
//                
//                if ([topVC isKindOfClass:[ALCameraRecordViewController class]]) {
//                    [topVC dismissViewControllerAnimated:NO completion:^{
//                        UIViewController *tempVC = (UIViewController *)[SocketViewModel getTopViewController];
//                        [tempVC presentViewController:chatVC animated:YES completion:nil];
//                    }];
//                    
//                } else {
//                    [topVC presentViewController:chatVC animated:YES completion:nil];
//                }
                
            }  else if ([model.cmd isEqualToString:@"hang"]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMRTCHangNoti object:nil];
            } else if ([model.cmd isEqualToString:@"busy"]) {
                //对方忙线中的时候
                [[NSNotificationCenter defaultCenter] postNotificationName:kYMRTCBusyNoti object:nil];
            }
            
//            if ([model.cmd isEqualToString:@"refused"]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"roomRequestFeedback" object:nil];
//            } else if ([model.cmd isEqualToString:@"Cancel"]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"roomRequestFeedback" object:nil];
//            } else if ([model.cmd isEqualToString:@"hang"]) {
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"roomRequestFeedback" object:nil];
//            } else if ([model.cmd isEqualToString:@"busy"]) {
//                //对方忙线中的时候
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"rtcRoom_other_isBusy" object:nil];
//            }
            
            
            
            
        } else if([route isEqualToString:@"groupInvite"]){
            [self.getGroupsCommand execute:nil];
        } else if([route isEqualToString:@"groupOper"]){
            [self dealSystemMessageWithDictionary:dictionary way:YES];
        }
    });
}


#pragma mark 收到新消息
- (void)receiverNewMessage:(NSDictionary *)dictionary {
    int count = 1;
    NSString *route = dictionary[@"route"];
    MessageModel *message = [MessageModel mj_objectWithKeyValues:dictionary];
    NSLog(@"-----%@",message.timestamp);
    
    //wsp 添加：离线推送进来 2019.4.8
    if ([route isEqualToString:@"passFriend"]) {
        message.type = @"passFriend";
        message.timestamp = [NSDate getNowTimestamp];
//        message.messageId = [NSUUID UUID].UUIDString;
        route = @"singleChat";
    }
    //end
    
    //add by chw 2019.04.19 for "加密房间号没有先给，所以收到加密消息就先存储加密房间号和创建加密消息表"“群聊会出现密聊的提示？安卓造成的，加个屏蔽”
    if (message.isCryptoMessage && ![route isEqualToString:@"groupChat"]) {
        [[YMEncryptionManager shareManager] storeCryptRoomId:message.roomId userId:message.sender isSender:NO timeStamp:[message.timestamp longLongValue]/1000.0];
    }
    message.readStatus = @"3";
    message.sendStatus = @"1";
    
    if (message.msgType == MESSAGE_AUDIO) {
        message.content = Localized(@"Chat_Msg_Voice");
    } else if (message.msgType == MESSAGE_IMAGE) {
        message.content = Localized(@"Chat_Msg_IMG");
    } else if (message.msgType == MESSAGE_File) {
        message.content = Localized(@"Chat_Msg_File");
    } else if (message.msgType == MESSAGE_Location) {
        message.content = Localized(@"Chat_Msg_Localtion");
    } else if (message.msgType == MESSAGE_Video) {
        message.content = Localized(@"Chat_Msg_Video");
    } else if (message.msgType == MESSAGE_Withdraw) {
        if ([route isEqualToString:@"singleChat"]) {
            message.content = [NSString stringWithFormat:@"%@",Localized(@"friend_Withdraw")];
        }else {
            MemberModel *member = [FMDBManager selectedMemberWithRoomId:message.roomId memberID:message.sender];
            message.content = [NSString stringWithFormat:@"\"%@\"%@",member.name,Localized(@"other_Withdraw")];
        }
        [FMDBManager withdrawMessageWithMsgId:message.messageId roomId:message.roomId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"sendMessageResult" object:@{@"messageId":message.messageId,@"type":@"withdraw"}];
    }else if ([message.type isEqualToString:@"passFriend"]) {
        message.content = Localized(@"Chat_Msg_PassFriend");
        message.type = @"text";
        [self.getFriendsCommand execute:nil];
    }
    
    if (message.msgType > MESSAGE_Contacts_Card || message.msgType < MESSAGE_NotifyTime) {
        message.content = Localized(@"Chat_Msg_UnknowInfo");
    }
    
    BOOL state = [FMDBManager selectedRoomDisturbWithRoomId:message.roomId];
    
    if ([FMDBManager isAlreadyHadMsg:message]) {
        NSLog(@"--------消息去重在线-----------------");
        count = 0;
        if (message.msgType != MESSAGE_Withdraw)//重复的消息解密会出错
        return;
    }
    if (message.isCryptoMessage) {
        if (message.msgType == MESSAGE_TEXT||message.msgType == MESSAGE_Contacts_Card) {
            //增加日志
            message.originalContent = [[YMEncryptionManager shareManager] decryptData:message.content cryptoType:message.cryptoType withUserID:message.sender];
            //                [[YMEncryptionManager shareManager] logCryptMessage:[message copy]];
            message.content = message.originalContent;
        }
        else if (message.msgType == MESSAGE_Location)
        {
            message.locationInfo = [[YMEncryptionManager shareManager] decryptData:message.locationInfo cryptoType:message.cryptoType withUserID:message.sender];
            NSDictionary *dataDict = [message.locationInfo mj_JSONObject];
            if ([dataDict objectForKey:@"cryptoType"])
            message.cryptoType = [[dataDict objectForKey:@"cryptoType"] integerValue];
        }
        else if (message.msgType == MESSAGE_System) {
            NSString *operType = [dictionary objectForKey:@"operType"];
            if (operType && [operType isEqualToString:@"shot"]) {
                if ([route isEqualToString:@"singleChat"]) {
                    FriendsModel *friend = [FMDBManager selectFriendTableWithRoomId:message.roomId];
                    message.content = [NSString stringWithFormat:Localized(@"crypt_other_shot_tip"), friend.showName];
                }
                else {
                    MemberModel *model = [FMDBManager selectedGroupMemberWithRoomId:message.roomId memberId:message.sender];
                    NSString *name = model.showName;
                    if (!name || name.length == 0)
                    name = model.mobile;
                    message.content = [NSString stringWithFormat:Localized(@"crypt_other_shot_tip"), name];
                }
            }
        }
        if (message.fileKey) {
            NSString *string = [[YMEncryptionManager shareManager] decryptData:message.fileKey cryptoType:message.cryptoType withUserID:message.sender];
#if AilloTest
            if (string && ![string hasPrefix:@"Could not parse proto"])
#else
            if (string && ![string isEqualToString:@"[未知消息]"])
#endif
            message.fileKey = string;
        }
       
    }
    BOOL way = [SocketViewModel getSaveMessageWayWithType:route roomId:message.roomId];
    [FMDBManager insertMessageWithContentModel:message];
    
    //wsp添加，加密图片自动下载，2019.6.5
    [self autoDownloadMessageFile:message];
    //end
    
    if ([message.roomId isEqualToString:self.room]) {
        [self.sendMessageSubject sendNext:message];
        [SocketViewModel updateSessionDataWithWay:way type:route message:message count:0];
//        if ([route isEqualToString:@"singleChat"])
//            [self sendSingleMessageAck:@[message.messageId] withRoomId:message.roomId withNextResponse:self.sendMessageSubject];
    } else {
        [SocketViewModel updateSessionDataWithWay:way type:route message:message count:count];
//        if ([route isEqualToString:@"singleChat"])
//            [self sendSingleMessageAck:@[message.messageId] withRoomId:message.roomId withNextResponse:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (state == NO) {
            if ([FMDBManager selectedShockNotifySwitch]) {
                [TShionSingleCase playMessageReceivedVibration];
            }
            BOOL isInRoom = [message.roomId isEqualToString:self.room];
            if ([FMDBManager selectedVoiceNotifySwitch]&&isInRoom == NO) {
                [TShionSingleCase playMessageReceivedSystemSound];
            }
            if (isInRoom) {
                if ([FMDBManager selectedVoiceNotifySwitch]) {
                    [TShionSingleCase playMessageReceivedSound];
                }
            }
        }
        if (self.room.length < 5) {
            [self.getUnreadSessionSubject sendNext:nil];
            
        }
    });
}

- (void)saveDataWithArray:(NSArray *)array type:(NSString *)type {
    int count = 0;
    MessageModel *message;
    
    for (NSDictionary *data in array) {
        MessageModel *model = [MessageModel mj_objectWithKeyValues:data];
        model.readStatus = @"3";
        //add by chw 2019.04.19 for "加密房间号没有先给，所以收到加密消息就先存储加密房间号和创建加密消息表"
        if (model.isCryptoMessage && ![type isEqualToString:@"groupChat"]) {
            [[YMEncryptionManager shareManager] storeCryptRoomId:model.roomId userId:model.sender isSender:NO timeStamp:[model.timestamp longLongValue]/1000.0];
        }
        
        if ([data[@"type"] isEqualToString:@"system"] && !model.receiver) {
            MessageModel *m = [self dealSystemMessageWithDictionary:data way:NO];
            if (model.content) message = m;
        } else if ([data[@"type"] isEqualToString:@"withdraw"]) {
            [FMDBManager insertMessageWithContentModel:model];
            if ([type isEqualToString:@"singleChat"]) {
                model.content = [NSString stringWithFormat:@"%@",Localized(@"friend_Withdraw")];
            }else {
                MemberModel *member = [FMDBManager selectedMemberWithRoomId:model.roomId memberID:model.sender];
                if (member) {
                    model.content = [NSString stringWithFormat:@"\"%@\"%@",member.name,Localized(@"other_Withdraw")];
                }
            }
            message = model;
            [FMDBManager withdrawMessageWithMsgId:model.messageId roomId:model.roomId];
        } else {
            if ([FMDBManager isAlreadyHadMsg:model]) {
                NSLog(@"--------消息去重离线-----------------");
                continue;
            }
            model.readStatus = @"3";
            model.sendStatus = @"1";
            if ([model.type isEqualToString:@"passFriend"]) {
                model.content = Localized(@"Chat_Msg_PassFriend");
                model.type = @"text";
            }
            //add by wsp ,rtc离线消息
            else if ([model.type isEqualToString:@"rtc-video"]) {
                model.type = @"rtc_video";
                model.content = @"RTC_Msg_Video";
                model.rtcStatus = RTCMessageStatus_OthersCancel;
            } else if ([model.type isEqualToString:@"rtc-audio"]) {
                model.type = @"rtc_audio";
                model.content = @"RTC_Msg_Audio";
                model.rtcStatus = RTCMessageStatus_OthersCancel;
            } else if ([model.type isEqualToString:@"rtc-video_audio"]) {
                model.type = @"rtc_video";
                model.content = @"RTC_Msg_Video";
                model.rtcStatus = RTCMessageStatus_OthersCancel;
            }
            
            if (model.msgType > MESSAGE_Contacts_Card || model.msgType < MESSAGE_NotifyTime) {
                message.content = Localized(@"Chat_Msg_UnknowInfo");
            }
            
            //add by chw 2019.04.17 for Encryption
            if (model.isCryptoMessage) {
                if (model.msgType == MESSAGE_TEXT||model.msgType == MESSAGE_Contacts_Card) {
                    //增加日志
                    model.originalContent = [[YMEncryptionManager shareManager] decryptData:model.content cryptoType:model.cryptoType withUserID:model.sender];
//                    [[YMEncryptionManager shareManager] logCryptMessage:[model copy]];
                    model.content = model.originalContent;
                }
                else if (model.msgType == MESSAGE_Location) {
                    model.locationInfo = [[YMEncryptionManager shareManager] decryptData:model.locationInfo cryptoType:model.cryptoType withUserID:model.sender];
                    NSDictionary *dataDict = [model.locationInfo mj_JSONObject];
                    if ([dataDict objectForKey:@"cryptoType"])
                        model.cryptoType = [[dataDict objectForKey:@"cryptoType"] integerValue];
                }
                else if (model.msgType == MESSAGE_System)
                {
                    NSString *string = [data objectForKey:@"operType"];
                    if (string && ![string isKindOfClass:[NSNull class]])
                    {
                        if ([string isEqualToString:@"shot"])
                        {
                            FriendsModel *friend = [FMDBManager selectFriendTableWithRoomId:model.roomId];
                            model.content = [NSString stringWithFormat:Localized(@"crypt_other_shot_tip"), friend.showName];
                        }
                    }
                }
                if (model.fileKey)
                    model.fileKey = [[YMEncryptionManager shareManager] decryptData:model.fileKey cryptoType:model.cryptoType withUserID:model.sender];
            }
            //end
            model.isOffLine = YES;
            message = model;
            
            [FMDBManager insertMessageWithContentModel:model];
            
            if (model.atModelList.count > 0 && [type isEqualToString:@"groupChat"]) {
                //如果有包含@成员要去更新列表展示
                BOOL state = [SocketViewModel getSaveMessageWayWithType:type roomId:message.roomId];
                [SocketViewModel updateSessionDataWithWay:state type:type message:message count:count];
            }
           
            count ++;
        }
    }
    
    if ([self.room isEqualToString:message.roomId])  count = 0;
    
    if (!message) return;
    
    BOOL state = [SocketViewModel getSaveMessageWayWithType:type roomId:message.roomId];
    
    [SocketViewModel updateSessionDataWithWay:state type:type message:message count:count];
}

#pragma 处理系统消息
- (MessageModel *)dealSystemMessageWithDictionary:(NSDictionary *)dictionary way:(BOOL)way {
    MessageModel *model = [MessageModel mj_objectWithKeyValues:dictionary];
    [FMDBManager creatMessageTableWithRoomId:model.roomId];
    [FMDBManager creatGroupMemberTableWithRoomId:model.roomId];
    if ([[dictionary objectForKey:@"operType"] isEqualToString:@"create"]) {//创建
        /**** 创建群组 ****/
        GroupModel *group = [[GroupModel alloc] init];
        group.owner = model.sender;
        group.roomId = model.roomId;
        group.name = dictionary[@"groupName"];
        group.avatar = @"";
        BOOL disturb = NO;
        BOOL top = NO;
        if ([[dictionary objectForKey:@"chatType"] isEqualToString:@"groupEncrypt"]) {
            model.isCryptoMessage = YES;
            model.cryptoType = 2;
        }
        [FMDBManager updateRoomSettingWithRoomId:model.roomId disturb:disturb top:top];
        BOOL result = [FMDBManager updateGroupListWithModel:group];
        if (result) {
            NSLog(@"群插入成功");
        }
        /**** 添加成员 ****/
        NSArray *array = [dictionary objectForKey:@"members"];
        NSDictionary *oper = [dictionary objectForKey:@"operInfo"];
        if (oper) {
            MemberModel *member = [MemberModel mj_objectWithKeyValues:oper];
            member.roomId = model.roomId;
            member.delFlag = 0;
            [FMDBManager updateGroupMemberWithRoomId:model.roomId member:member];
        }
        NSString *content = [NSString stringWithFormat:@""];
        NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dic in array) {
            MemberModel *member = [MemberModel mj_objectWithKeyValues:dic];
            member.roomId = model.roomId;
            member.delFlag = 0;
            [FMDBManager updateGroupMemberWithRoomId:model.roomId member:member];
            content = [NSString stringWithFormat:@"%@“%@”、",content,member.name];
            [userIds addObject:member.userId];
        }
        if (content.length>1) {
            content = [content substringWithRange:NSMakeRange(0, [content length] - 1)];
        }
        if (model.isCryptoMessage) {
            model.content = [NSString stringWithFormat:@"“%@”%@%@%@",oper[@"name"],Localized(@"Invite"),content,Localized(@"crypt_join_group")];
            model.messageId = @"999";
        }
        else
            model.content = [NSString stringWithFormat:@"“%@”%@%@%@",oper[@"name"],Localized(@"Invite"),content,Localized(@"Join_Room")];
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (state) {
            NSLog(@"新群创建加入成功");
        }
        if (model.isCryptoMessage) {
            [[YMEncryptionManager shareManager] getGroupUserKeys:userIds];
            MessageModel *m = [model copy];
            m.timestamp = [NSString stringWithFormat:@"%lld", [model.timestamp longLongValue]+1];
            m.messageId = @"1000";
            m.backId = @"1000";
            m.content = [NSString stringWithFormat:@"%@\n%@\n%@", Localized(@"crypt_tip1"), Localized(@"crypt_tip3"), Localized(@"crypt_tip4")];
            [FMDBManager insertMessageWithContentModel:m];
        }
    }else if([[dictionary objectForKey:@"operType"] isEqualToString:@"add"]) {
        /**** 添加成员 ****/
        [self.getGroupsCommand execute:@{@"groupId":model.roomId}];
        NSArray *array = [dictionary objectForKey:@"members"];
        BOOL includingSelf = NO;
        NSString *content = [NSString stringWithFormat:@""];
        NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:0];
        for (NSDictionary *dic in array) {
            MemberModel *member = [MemberModel mj_objectWithKeyValues:dic];
            member.roomId = model.roomId;
            member.delFlag = 0;
            [FMDBManager updateGroupMemberWithRoomId:member.roomId member:member];
            content = [NSString stringWithFormat:@"%@“%@”、",content,member.name];
            if ([self.userModel.ID isEqualToString:member.userId]) {
                includingSelf = YES;
            }
            NSLog(@"%@",content);
            [userIds addObject:member.userId];
        }
        
        if (content.length>1) {
            content = [content substringWithRange:NSMakeRange(0, [content length] - 1)];
        }
        if (model.isCryptoMessage) {
            model.content = [NSString stringWithFormat:@"“%@”%@%@%@",dictionary[@"operInfo"],Localized(@"Invite"),content,Localized(@"crypt_join_group")];
            model.messageId = @"999";
        }
        else
            model.content = [NSString stringWithFormat:@"“%@”%@%@%@",dictionary[@"operInfo"],Localized(@"Invite"),content,Localized(@"Join_Room")];
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (state) {
            NSLog(@"新群员加入成功");
        }
        
        if (includingSelf) {
            NSDictionary *dic = @{@"type":@"add"};
            [FMDBManager beDeletedWithRoomId:model.roomId deflag:@"0"];
            if ([self.room isEqualToString:model.roomId]) {
                [self.messageNotifySubject sendNext:dic];
            }
        }
        if ([model.roomId isEqualToString:self.room]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"groupMemberCountChange" object:nil];
        }
        if (model.isCryptoMessage) {
            [[YMEncryptionManager shareManager] getGroupUserKeys:userIds];
            MessageModel *m = [model copy];
            m.timestamp = [NSString stringWithFormat:@"%lld", [model.timestamp longLongValue]+1];
            m.messageId = @"1000";
            m.backId = @"1000";
            m.content = [NSString stringWithFormat:@"%@\n%@\n%@", Localized(@"crypt_tip1"), Localized(@"crypt_tip3"), Localized(@"crypt_tip4")];
            [FMDBManager insertMessageWithContentModel:m];
        }
    } else if([[dictionary objectForKey:@"operType"] isEqualToString:@"delete"]) {
        /**** 删除成员 ****/
        NSArray *userIds = dictionary[@"userIds"];
        for (NSString *usid in userIds) {
            if ([[NSString stringWithFormat:@"%@",usid] isEqualToString:self.userModel.ID]) {
                NSString *operName = dictionary[@"operInfo"];
                model.content = [NSString stringWithFormat:@"%@“%@”%@",Localized(@"been_removed"),operName,Localized(@"from_the_group")];
                BOOL result = [FMDBManager insertMessageWithContentModel:model];
                if (result) {
                    BOOL state = [FMDBManager beDeletedWithRoomId:model.roomId deflag:@"1"];
                    if (state) {
                        NSLog(@"被移除群聊");
                    }
                }
                if ([self.room isEqualToString:model.roomId]) {
                    NSDictionary *dic = @{@"type":@"bebelete"};
                    [self.messageNotifySubject sendNext:dic];
                }
            }else {
                [FMDBManager updateGroupMemberDeflagWithRoomId:model.roomId memberId:usid];
            }
        }
        if ([model.roomId isEqualToString:self.room]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"groupMemberCountChange" object:nil];
        }
    }else if([[dictionary objectForKey:@"operType"] isEqualToString:@"update"]) {
        NSString *operName = dictionary[@"operInfo"];
        NSString *groupName = dictionary[@"groupName"];
        model.content = [NSString stringWithFormat:@"%@ 已将群名称修改为 %@",operName,groupName];
        BOOL result = [FMDBManager updateGroupNameWithRoomId:model.roomId name:groupName];
        if (result) {
            NSLog(@"群名称修改成功");
        }
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (state) {
            NSLog(@"群名称修改成功");
        }
        if ([self.room isEqualToString:model.roomId]) {
            NSDictionary *dic = @{@"type":@"modifyName",@"groupName":groupName};
            [self.messageNotifySubject sendNext:dic];
        }
    }else if([[dictionary objectForKey:@"operType"] isEqualToString:@"leave"]) {
        /**** 群成员离开 ****/
        NSArray *userIds = dictionary[@"userIds"];
        for (NSString *usid in userIds) {
            if (![[NSString stringWithFormat:@"%@",usid] isEqualToString:self.userModel.ID]) {
                [FMDBManager updateGroupMemberDeflagWithRoomId:model.roomId memberId:usid];
            }
        }
        if ([model.roomId isEqualToString:self.room]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"groupMemberCountChange" object:nil];
        }
    }else if([[dictionary objectForKey:@"operType"] isEqualToString:@"transfer"]) {
        /**** 群主让位 ****/
        NSString *roomId = dictionary[@"roomId"];
        NSString *ownerId = dictionary[@"ownerId"];
        MemberModel *member = [FMDBManager selectedMemberWithRoomId:roomId memberID:ownerId];
        model.content = [NSString stringWithFormat:@"“%@”%@",member.name,Localized(@"tobe_group_manager")];
        if ([model.roomId isEqualToString:self.room]) {
            [self.groupOperSubject sendNext:@"transfer"];
        }
        [FMDBManager insertMessageWithContentModel:model];
    }else if([[dictionary objectForKey:@"operType"] isEqualToString:@"openInviteSwitch"]) {
        /**** 打开群邀请开关 ****/
        [FMDBManager updateGroupInviteSwitchWithRoomId:model.roomId state:YES];
        model.content = [NSString stringWithFormat:@"%@",Localized(@"open_invite_switch")];
        if ([model.roomId isEqualToString:self.room]) {
            [self.groupOperSubject sendNext:@"openInviteSwitch"];
        }
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (state) {
            NSLog(@"群名称修改成功");
        }
    }else if([[dictionary objectForKey:@"operType"] isEqualToString:@"closeInviteSwitch"]) {
        /**** 关闭群邀请开关 ****/
        [FMDBManager updateGroupInviteSwitchWithRoomId:model.roomId state:YES];
        model.content = [NSString stringWithFormat:@"%@",Localized(@"close_invite_switch")];
        if ([model.roomId isEqualToString:self.room]) {
            [self.groupOperSubject sendNext:@"closeInviteSwitch"];
        }
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (state) {
            NSLog(@"群名称修改成功");
        }
    }
    else if ([[dictionary objectForKey:@"operType"] isEqualToString:@"shot"]) {
        //add by chw 2019.04.17 for Encryption ScreenShot
        MemberModel *member = [FMDBManager selectedGroupMemberWithRoomId:model.roomId memberId:model.sender];
        NSString *name = member.showName;
        if (!name)
            name = member.name;
        if (!name)
            name = member.mobile;
        model.content = [NSString stringWithFormat:Localized(@"crypt_other_shot_tip"), name];
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (!state) {
            NSLog(@"插入截屏消息成功");
        }
        return model;
    }
    else if ([[dictionary objectForKey:@"operType"] isEqualToString:@"scan_group_join"]) {
        //自己扫二维码加入生成系统消息
        [self.getGroupsCommand execute:@{@"groupId":model.roomId}];
        
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        
        if (state) {
            NSLog(@"新群员加入成功");
        }
        
        [FMDBManager beDeletedWithRoomId:model.roomId deflag:@"0"];
        if ([dictionary objectForKey:@"userIds"]) {
            NSArray *array = [dictionary objectForKey:@"userIds"];
            if (![array isEqual:[NSNull null]]) {
                [[YMEncryptionManager shareManager] getGroupUserKeys:array];
            }
        }
    } else if ([[dictionary objectForKey:@"operType"] isEqualToString:@"scanJoin"]) {
        //别人扫描二维码加入群
        
        
        NSString *userName = dictionary[@"userName"];
        
        MemberModel *member = [MemberModel mj_objectWithKeyValues:dictionary[@"operInfo"]];
        if (model.isCryptoMessage) {
            model.content = [NSString stringWithFormat:Localized(@"crypt_scan_group_join_tip"),userName,member.name];
        }
        else
            model.content = [NSString stringWithFormat:Localized(@"scan_group_join_tip"),userName,member.name];

        
        BOOL state = [FMDBManager insertMessageWithContentModel:model];
        if (state) {
            NSLog(@"新群员加入成功");
        }
        if (model.isCryptoMessage)
            [[YMEncryptionManager shareManager] getGroupUserKeys:@[member.userId]];
    }
    
    if (way) {
        if (model.content.length>0) {
            if (![model.roomId isEqualToString:self.room]) {
                [self.getUnreadSessionSubject sendNext:nil];
            }else {
                [self.sendMessageSubject sendNext:model];
            }
            [FMDBManager insertSessionOnlineWithType:@"groupChat" message:model withCount:0];
        }
    }
    
    return model;
}

+ (BOOL)getSaveMessageWayWithType:(NSString *)type roomId:(NSString *)roomId {
    BOOL result = NO;
    if ([type isEqualToString:@"singleChat"]) {
        FriendsModel *friend = [FMDBManager selectFriendTableWithRoomId:roomId];
        if (friend.roomId.length>5) {
            result = YES;
        }
    }else {
        GroupModel *group = [FMDBManager selectGroupModelWithRoomId:roomId];
        if (group.roomId.length>5) {
            result = YES;
        }
    }
    BOOL state = [FMDBManager selectedRoomDisturbWithRoomId:roomId];
    if (state == NO && result == YES) {
        result = YES;
    }else {
        result = NO;
    }
    return result;
}

+ (void)updateSessionDataWithWay:(BOOL)way type:(NSString *)type message:(MessageModel *)message count:(int)count {
    if (way) {
        [FMDBManager insertSessionOnlineWithType:type message:message withCount:count];
    } else {
        [FMDBManager insertSessionOfflineWithType:type message:message withCount:count];
    }
}

#pragma mark - 自动下载相关
- (void)autoDownloadMessageFile:(MessageModel *)msgModel {
    if (msgModel.msgType == MESSAGE_IMAGE && msgModel.isCryptoMessage) {
        if ([YMDownSettingManager photoAutoDownload])
            [self autoDownloadCryptoImage:msgModel];
    }
}
    
- (void)autoDownloadCryptoImage:(MessageModel *)msgModel {
    //在线收到加密图片自动加载
    NSString *filePath = [[FMDBManager getMessagePathWithMessage:msgModel] stringByAppendingPathComponent:msgModel.fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])return;
    
    YMDownloadItem *item = nil;
    item = [YMImageDownloadManager itemWithFileId:msgModel.messageId];
    NSMutableDictionary *msgDict = [NSMutableDictionary dictionary];
    [msgDict setObject:msgModel.roomId forKey:@"roomId"];
    [msgDict setObject:msgModel.messageId forKey:@"messageId"];
    [msgDict setObject:msgModel.sourceId forKey:@"sourceId"];
    [msgDict setObject:msgModel.type forKey:@"type"];
    [msgDict setObject:msgModel.fileName forKey:@"fileName"];
    [msgDict setObject:@(msgModel.isCryptoMessage) forKey:@"isCryptoMessage"];
    [msgDict setObject:@(msgModel.cryptoType) forKey:@"cryptoType"];
    [msgDict setObject:msgModel.sender forKey:@"sender"];
    //加密群聊用到
    NSString *fileKey = msgModel.fileKey.length > 0 ? msgModel.fileKey : @"";
    [msgDict setObject:fileKey forKey:@"fileKey"];
    
    id msgData = [msgDict mj_JSONData];
    
    if (!item) {
        item = [YMDownloadItem itemWithUrl:[NSString ym_fileUrlStringWithSourceId:msgModel.sourceId] fileId:msgModel.messageId];
        item.enableSpeed = NO;
        
        item.extraData = msgData;
        [YMImageDownloadManager startDownloadWithItem:item];
    } else {
        item.extraData = msgData;
        if (item.downloadStatus == YMDownloadStatusFinished || item.downloadStatus == YMDownloadStatusDownloading) {
            return;
        } else {
            [YMImageDownloadManager resumeDownloadWithItem:item];
        }
    }
}

#pragma mark get common net data
- (void)initialize {
    @weakify(self)
    [self.getFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSMutableArray *modelArray = [[NSMutableArray alloc] init];
        for (NSDictionary *param in x) {
            FriendsModel *model = [FriendsModel mj_objectWithKeyValues:param];
            
            RoomSetModel *roomSet = [RoomSetModel mj_objectWithKeyValues:param];
            BOOL disturb = roomSet.shieldFlag;
            BOOL top = roomSet.topFlag;
            BOOL blacklistFlag = roomSet.blacklistFlag;
            
            [FMDBManager updateRoomSettingWithRoomId:model.roomId disturb:disturb top:top];
            [FMDBManager setRoomBlackWithRoomId:model.roomId blacklistFlag:blacklistFlag];
            [FMDBManager creatMessageTableWithRoomId:model.roomId];
            [FMDBManager updateFriendTableWithFriendsModel:model];
            [modelArray addObject:model];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.getFriendsSubject sendNext:nil];
            [self.getUnreadSessionSubject sendNext:nil];
        });
    }];
    
    [self.getGroupsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x != nil) {
            for (NSDictionary *data in x) {
                GroupModel *model = [GroupModel mj_objectWithKeyValues:data];
                BOOL disturb = [[data objectForKey:@"shieldFlag"] boolValue];
                BOOL top = [[data objectForKey:@"topFlag"] boolValue];
                [FMDBManager updateRoomSettingWithRoomId:model.roomId disturb:disturb top:top];
                [FMDBManager creatMessageTableWithRoomId:model.roomId];
                [FMDBManager creatGroupMemberTableWithRoomId:model.roomId];
                BOOL result = [FMDBManager updateGroupListWithModel:model];
                if (result) {
                    NSLog(@"群插入成功");
                }
                if (model.isCrypt)
                    [self getGroupMemberWithParam:@{@"roomId":model.roomId, @"isCrypt":@"1"}];
                else
                    [self getGroupMemberWithParam:@{@"roomId":model.roomId}];
            }
        }
        [self.getUnreadSessionSubject sendNext:nil];
    }];
    
    [self.getUnreadSessionCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x != nil) {
            for (NSDictionary *dic in x) {
                NSString *type = [dic objectForKey:@"chatType"];
                NSString *roomId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"roomId"]];
                
                if ([type isEqualToString:@"single"]) {
                    [self getSingleChatOfflineMessageWithParam:@{@"roomId":roomId}];
                }else if([type isEqualToString:@"group"]) {
                    [self getGroupChatOfflineMessageWithParam:@{@"roomId":roomId}];
                }
            }
        }
    }];
    
    [self.getSingleChatOfflineMessageCommand.executionSignals.switchToLatest subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        [self sendSingleOfflineMsgs:x];
    }];
    
    [self.getGroupChatOfflineMessageCommand.executionSignals.switchToLatest subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        [self sendGroupOfflineMsgs:x];
    }];
    
    [self.sendSingleOfflineMessageSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self sendSingleOfflineMsgs:x];
    }];
    
    [self.sendGroupOfflineMessageSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self sendGroupOfflineMsgs:x];
    }];
    
    [self.getRoomSettingCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSString *roomId = [x objectForKey:@"roomId"];
        BOOL disturb = [[x objectForKey:@"shieldFlag"] boolValue];
        BOOL top = [[x objectForKey:@"topFlag"] boolValue];
        [FMDBManager updateRoomSettingWithRoomId:roomId disturb:disturb top:top];
        if (disturb) {
            BOOL state = [FMDBManager offlineCountConvertedToOnlineCountWithRoomId:roomId];
            if (state) {
                NSLog(@"消息数转换成功");
            }
        }else {
            BOOL state = [FMDBManager OnlineCountConvertedToOfflineCountWithRoomId:roomId];
            if (state) {
                NSLog(@"消息数转换成功");
            }
        }
    }];
    
    [self.settingRoomCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSString *roomId = [x objectForKey:@"roomId"];
        BOOL disturb = [[x objectForKey:@"shieldFlag"] boolValue];
        if (disturb) {
            [FMDBManager OnlineCountConvertedToOfflineCountWithRoomId:roomId];
        }else {
            [FMDBManager offlineCountConvertedToOnlineCountWithRoomId:roomId];
        }
        BOOL top = [[x objectForKey:@"topFlag"] boolValue];
        [FMDBManager updateRoomSettingWithRoomId:roomId disturb:disturb top:top];
        if (self.room.length<1) {
            [self.getUnreadSessionSubject sendNext:nil];
        }
    }];
    
    [self.getNewFriendCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        
        @strongify(self);
        [self beginConnect:YES];
        
        if (!x) return;
        
        BOOL state = [[x objectForKey:@"isNewFlag"] boolValue];
        if (state) {
            NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
            [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:key];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewFirendPrompt" object:nil];
        }
    }];
    
    [self.postRTCCommand.executionSignals.switchToLatest subscribeNext:^(id _Nullable x) {
        @strongify(self)
        [self.rtcSubject sendNext:x];
    }];
    
    [self.postCancelRTCCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.rtcCancelSubject sendNext:nil];
    }];
    
    [self.blackUserCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.blackUserEndSubject sendNext:x];
    }];
    
    [self.addFriendsCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self.addSuccessSucject sendNext:nil];
    }];
    
    [self.getUserInfoCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (!self.client.isRunning) {
            self.status = 2;
            [self.client connectToHost];
        }
    }];
    
    [self.kickUserVerifyCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x) {
            [self beginConnect:NO];
        }
    }];
    
    [self.exitGroupCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.exitGroupSubject sendNext:nil];
        });
    }];
}

- (RACCommand *)getFriendsCommand {
    if (!_getFriendsCommand) {
        @weakify(self)
        _getFriendsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(connectLoadingDataQueue, ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_friends withParam:nil error:&error];
                    if (!error) {
                        [subscriber sendNext:model.data];
                    }
                    [subscriber sendCompleted];
                    if (error) {
                        if ([SocketViewModel shared].status == 1&&[input intValue]<5) {
                            int index = [input intValue] + 1;
                            @strongify(self)
                            [self.getFriendsCommand execute:@(index)];
                        }
                    }
                });
                return nil;
            }];
        }];
    }
    return _getFriendsCommand;
}

- (RACCommand *)getUnreadSessionCommand {
    if (!_getUnreadSessionCommand) {
        _getUnreadSessionCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @weakify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(connectLoadingDataQueue, ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_session withParam:nil error:&error];
                    if (!error) {
                        [subscriber sendNext:model.data];
                    }
                    [subscriber sendCompleted];
                    if (error) {
                        if ([SocketViewModel shared].status == 1&&[input intValue]<5) {
                            int index = [input intValue] + 1;
                            @strongify(self)
                            [self.getUnreadSessionCommand execute:@(index)];
                        }
                    }
                });
                return nil;
            }];
        }];
    }
    return _getUnreadSessionCommand;
}

- (RACCommand *)getGroupsCommand {
    if (!_getGroupsCommand) {
        _getGroupsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            @weakify(self)
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(connectLoadingDataQueue, ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_group_List withParam:nil error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            if ([input isKindOfClass:[NSDictionary class]]) {
                                NSString *groupId = [input objectForKey:@"groupId"];
                                for (NSDictionary *dic in model.data) {
                                    if ([[[dic objectForKey:@"roomId"] stringValue] isEqualToString:groupId]) {
                                        [subscriber sendNext:@[dic]];
                                        groupId = @"";
                                        break;
                                    }
                                }
                                if (groupId.length == 0)
                                    [subscriber sendNext:model.data];
                            }
                            else
                                [subscriber sendNext:model.data];
                        }
                        [subscriber sendCompleted];
                        if (error) {
                            if ([SocketViewModel shared].status == 1&&[input intValue]<5) {
                                int index = [input intValue] + 1;
                                @strongify(self)
                                [self.getGroupsCommand execute:@(index)];
                            }
                        }
                    });
                });
                return nil;
            }];
        }];
    }
    return _getGroupsCommand;
}

- (void)getGroupInfoWithParam:(NSDictionary *)param {//
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        RequestModel *model = [TSRequest getRequetWithApi:api_get_group_offline withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                GroupModel *group = [GroupModel mj_objectWithKeyValues:model.data];
                [FMDBManager updateGroupListWithModel:group];
                if (group.isCrypt) {
                    [self getGroupMemberWithParam:@{@"roomId":group.roomId,@"isCrypt":@"1"}];
                }else {
                    [self getGroupMemberWithParam:@{@"roomId":group.roomId}];
                }
            }
        });
    });
}

- (void)getGroupMemberWithParam:(NSDictionary *)param {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        RequestModel *model = [TSRequest getRequetWithApi:api_get_group_Member withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSMutableArray *array = nil;
                if ([param objectForKey:@"isCrypt"]) {
                    array = [NSMutableArray arrayWithCapacity:0];
                }
                NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
                for (NSDictionary *data in model.data) {
                    MemberModel *memberModel = [MemberModel mj_objectWithKeyValues:data];
                    [FMDBManager updateGroupMemberWithRoomId:memberModel.roomId member:memberModel];
                    if (![memberModel.userId isEqualToString:userID])
                        [array addObject:memberModel.userId];
                }
                if (array.count > 0) {
                    [[YMEncryptionManager shareManager] getGroupUserKeys:array];
                }
            }else {
                if (model!=nil) {
                    if (model.message.length>0) {
                        ShowWinMessage(model.message);
                    }
                }
            }
        });
    });
}

- (RACCommand *)getSingleChatOfflineMessageCommand {
    if (!_getSingleChatOfflineMessageCommand) {
        _getSingleChatOfflineMessageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:input];
                    //解决消息丢失的问题
                    NSString *roomId = [input objectForKey:@"roomId"];
                    NSString *timestamp = [FMDBManager lastedOfflineMessageTimeWithRoomId:roomId];
                    [dic setObject:timestamp forKey:@"timestamp"];
                    NSString *identity = [[YMEncryptionManager shareManager] getMyIdentityKey];
                    if (identity)
                        [dic setObject:identity forKey:@"remoteIdentityKey"];
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_offline withParam:dic error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            NSString *data = [NSString ym_decryptAES:model.data];
                            NSArray *array = [NSString arrayWithJsonString:data];
                            if (array.count>0) {
                                [subscriber sendNext:array];
                                //添加消息回执
                                NSMutableArray *messageIds = [NSMutableArray arrayWithCapacity:array.count];
                                NSString *roomId = nil;
                                for (NSDictionary *dic in array) {
                                    [messageIds addObject:[dic objectForKey:@"messageId"]];
                                    if ([dic objectForKey:@"roomId"]) {
                                        roomId = [dic objectForKey:@"roomId"];
                                    }
                                }
                                [self sendSingleMessageAck:messageIds withRoomId:roomId withNextResponse:self.getSingleChatOfflineMessageCommand.executionSignals];
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getSingleChatOfflineMessageCommand;
}

- (RACCommand *)exitGroupCommand {
    if (!_exitGroupCommand) {
        _exitGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_delete_exit_group withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model!=nil) {
                                if (model.message.length>0) {
                                    ShowWinMessage(model.message);
                                }
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _exitGroupCommand;
}

- (void)getSingleChatOfflineMessageWithParam:(NSDictionary *)param {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
        //解决消息丢失的问题
        NSString *roomId = [param objectForKey:@"roomId"];
        NSString *timestamp = [FMDBManager lastedOfflineMessageTimeWithRoomId:roomId];
        
        [dic setObject:timestamp forKey:@"timestamp"];
        NSString *identity = [[YMEncryptionManager shareManager] getMyIdentityKey];
        if (identity)
            [dic setObject:identity forKey:@"remoteIdentityKey"];
        RequestModel *model = [TSRequest getRequetWithApi:api_get_offline withParam:dic error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSString *data = [NSString ym_decryptAES:model.data];
                NSArray *array = [NSString arrayWithJsonString:data];
                if (array.count>0) {
                    [self.sendSingleOfflineMessageSubject sendNext:array];
                    //添加消息回执
                    NSMutableArray *messageIds = [NSMutableArray arrayWithCapacity:array.count];
                    NSString *roomId = nil;
                    for (NSDictionary *dic in array) {
                        [messageIds addObject:[dic objectForKey:@"messageId"]];
                        if ([dic objectForKey:@"roomId"]) {
                            roomId = [dic objectForKey:@"roomId"];
                        }
                    }
                    [self sendSingleMessageAck:messageIds withRoomId:roomId withNextResponse:self.sendSingleOfflineMessageSubject];
                }
                
            }
        });
    });
}

- (void)sendSingleOfflineMsgs:(id)x {
    NSArray *array = x;
    if (array.count>0) {
        [self saveDataWithArray:array type:@"singleChat"];
    }
    if (self.room.length<5) {
        [self.getUnreadSessionSubject sendNext:nil];
    }else {
        [self.getSingleChatOfflineMessageSubject sendNext:@(array.count)];
    }
}

- (RACCommand *)getGroupChatOfflineMessageCommand {
    if (!_getGroupChatOfflineMessageCommand) {
        _getGroupChatOfflineMessageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:input];
                    //解决消息丢失的问题
                    NSString *roomId = [input objectForKey:@"roomId"];
                    NSString *timestamp = [FMDBManager lastedOfflineMessageTimeWithRoomId:roomId];
                    [dic setObject:timestamp forKey:@"timestamp"];
                    NSString *identity = [[YMEncryptionManager shareManager] getMyIdentityKey];
                    if (identity)
                        [dic setObject:identity forKey:@"remoteIdentityKey"];
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_group_offline withParam:dic error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getGroupChatOfflineMessageCommand;
}

- (void)getGroupChatOfflineMessageWithParam:(NSDictionary *)param {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:param];
        //解决消息丢失的问题
        NSString *roomId = [param objectForKey:@"roomId"];
        NSString *timestamp = [FMDBManager lastedOfflineMessageTimeWithRoomId:roomId];
        [dic setObject:timestamp forKey:@"timestamp"];
        NSString *identity = [[YMEncryptionManager shareManager] getMyIdentityKey];
        if (identity)
            [dic setObject:identity forKey:@"remoteIdentityKey"];
        NSError * error;
        RequestModel *model = [TSRequest getRequetWithApi:api_get_group_offline withParam:dic error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                [self.sendGroupOfflineMessageSubject sendNext:model.data];
            }
        });
    });
}

- (void)sendGroupOfflineMsgs:(id)x {
    NSString *data = [NSString ym_decryptAES:x];
    NSDictionary *dictionary = [NSString dictionaryWithJsonString:data];
    NSArray *array = [dictionary objectForKey:@"offlineSessionModels"];
    if (array.count>0) {
        [self saveDataWithArray:array type:@"groupChat"];
    }
    if (self.room.length<5) {
        [self.getUnreadSessionSubject sendNext:nil];
    }else {
        [self.getGroupChatOfflineMessageSubject sendNext:@(array.count)];
    }
}
//每次mpush连接先调用获取用户信息接口
- (RACCommand *)getUserInfoCommand {
    if (!_getUserInfoCommand) {
        _getUserInfoCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_userInfo withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            [subscriber sendNext:nil];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getUserInfoCommand;
}

- (RACCommand *)kickUserVerifyCommand {
    if (!_kickUserVerifyCommand) {
        _kickUserVerifyCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_userInfo withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            [subscriber sendNext:nil];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _kickUserVerifyCommand;
}



#pragma mark room setting
- (RACCommand *)getRoomSettingCommand {
    if (!_getRoomSettingCommand) {
        _getRoomSettingCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_room_setting withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model.message.length>0) {
                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getRoomSettingCommand;
}

- (RACCommand *)settingRoomCommand {
    if (!_settingRoomCommand) {
        _settingRoomCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_room_setting withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model.message.length>0) {
                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _settingRoomCommand;
}

- (RACCommand *)getNewFriendCommand {
    if (!_getNewFriendCommand) {
        _getNewFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_new_firend_prompt withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model.message.length>0) {
                                ShowWinMessage(model.message);
                            }
                            [subscriber sendNext:nil];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _getNewFriendCommand;
}

#pragma mark rtc

- (RACCommand *)postRTCCommand {
    if (!_postRTCCommand) {
        _postRTCCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSMutableDictionary *input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    //                    NSString *postURL = [NSString stringWithFormat:@"https://%@",input[@"rtcServer"]];
                    //                    [input removeObjectForKey:@"rtcServer"];
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_call withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            if (model.message.length>0) {
//                                ShowWinMessage(model.message);
                            }
                            [subscriber sendNext:nil];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _postRTCCommand;
}

- (RACCommand *)postCancelRTCCommand {
    if (!_postCancelRTCCommand) {
        _postCancelRTCCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                //                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_hangup withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
//                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            if (model.message.length > 0) {
//                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _postCancelRTCCommand;
}

- (RACCommand *)blackUserCommand {
    if (!_blackUserCommand) {
        _blackUserCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_blackUser withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (!error) {
                            [subscriber sendNext:model.data];
                        } else {
                            if (model.message.length>0) {
                                ShowWinMessage(model.message);
                            }
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _blackUserCommand;
}

- (RACCommand *)addFriendsCommand {
    if (!_addFriendsCommand) {
        _addFriendsCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_add_friend withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _addFriendsCommand;
}

- (RACCommand *)refreshTokenCommand {
    if (!_refreshTokenCommand) {
        _refreshTokenCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_refreshToken withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            UserInfoModel *userModel = [UserInfoModel mj_objectWithKeyValues:model.data];
                            [[NSUserDefaults standardUserDefaults] setObject:userModel.token forKey:@"token"];
                            [[NSUserDefaults standardUserDefaults] setObject:userModel.refreshToken forKey:@"refreshToken"];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                        [subscriber sendCompleted];
                    });
                });
                return nil;
            }];
        }];
    }
    return _refreshTokenCommand;
}

+ (id)getTopViewController {
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    
    UIViewController *appRootViewController = window.rootViewController;
    UIViewController *topViewController = appRootViewController;
    
    while (topViewController.presentedViewController != nil) {
        topViewController = topViewController.presentedViewController;
    }
    
    while ([topViewController isKindOfClass:[UINavigationController class]]) {
        
        topViewController = ((UINavigationController *)topViewController).topViewController;
    }
    
    while ([topViewController isKindOfClass:[ALSlideMenu class]]) {
        ALSlideMenu *slideVC = (ALSlideMenu *)topViewController;
        TabBarViewController *tabVC = (TabBarViewController *)slideVC.rootViewController;
        UINavigationController *tempNav = (UINavigationController *)tabVC.selectedViewController;
        topViewController = ((UINavigationController *)tempNav).topViewController;
    }
    
    return topViewController;
    
}

- (void)sendSocketPing {
    //    dispatch_queue_t queue = dispatch_queue_create("Aillo.cc", DISPATCH_QUEUE_SERIAL);
    //    _socketTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //    dispatch_source_set_timer(_socketTimer, DISPATCH_TIME_NOW, 20 * NSEC_PER_SEC, 0);
    //    @weakify(self);
    //    dispatch_source_set_event_handler(_socketTimer, ^{
    //        @strongify(self);
    //        NSLog(@"---------发送ping");
    //        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"ping"} options:NSJSONWritingPrettyPrinted error:nil];
    //        [self.client sendMessageData:data];
    //    });
    //    dispatch_resume(_socketTimer);
}

- (UserInfoModel *)userModel {
    if (!_userModel) {
        _userModel = [FMDBManager selectUserModel];
    }
    return _userModel;
}

- (MPClient *)client {
    if (!_client) {
        //wsp修改，退出帐号后避免重新懒加载
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        if (userID.length == 0) {
            return nil;
        }
        _client = [MPClient sharedClient];
        _client.delegate = self;
        self.status = 2;
    }
    return _client;
}

- (RACSubject *)rtcSubject {
    if (!_rtcSubject) {
        _rtcSubject = [RACSubject subject];
    }
    return _rtcSubject;
}

- (RACSubject *)rtcCancelSubject {
    if (!_rtcCancelSubject) {
        _rtcCancelSubject = [RACSubject subject];
    }
    return _rtcCancelSubject;
}

- (RACSubject *)getFriendsSubject {
    if (!_getFriendsSubject) {
        _getFriendsSubject = [RACSubject subject];
    }
    return _getFriendsSubject;
}

- (RACSubject *)getGroupsSubject {
    if (!_getGroupsSubject) {
        _getGroupsSubject = [RACSubject subject];
    }
    return _getGroupsSubject;
}

- (RACSubject *)getUnreadSessionSubject {
    if (!_getUnreadSessionSubject) {
        _getUnreadSessionSubject = [RACSubject subject];
    }
    return _getUnreadSessionSubject;
}

- (RACSubject *)refreshRoomListSubject {
    if (!_refreshRoomListSubject) {
        _refreshRoomListSubject = [RACSubject subject];
    }
    return _refreshRoomListSubject;
}

- (RACSubject *)reconnectGetNetDataSubject {
    if (!_reconnectGetNetDataSubject) {
        _reconnectGetNetDataSubject = [RACSubject subject];
    }
    return _reconnectGetNetDataSubject;
}

- (RACSubject *)sendMessageSubject {
    if (!_sendMessageSubject) {
        _sendMessageSubject = [RACSubject subject];
    }
    return _sendMessageSubject;
}

- (RACSubject *)sendSingleOfflineMessageSubject {
    if (!_sendSingleOfflineMessageSubject) {
        _sendSingleOfflineMessageSubject = [RACSubject subject];
    }
    return _sendSingleOfflineMessageSubject;
}

- (RACSubject *)sendGroupOfflineMessageSubject {
    if (!_sendGroupOfflineMessageSubject) {
        _sendGroupOfflineMessageSubject = [RACSubject subject];
    }
    return _sendGroupOfflineMessageSubject;
}

- (RACSubject *)getSingleChatOfflineMessageSubject {
    if (!_getSingleChatOfflineMessageSubject) {
        _getSingleChatOfflineMessageSubject = [RACSubject subject];
    }
    return _getSingleChatOfflineMessageSubject;
}

- (RACSubject *)getGroupChatOfflineMessageSubject {
    if (!_getGroupChatOfflineMessageSubject) {
        _getGroupChatOfflineMessageSubject = [RACSubject subject];
    }
    return _getGroupChatOfflineMessageSubject;
}

- (RACSubject *)addSuccessSucject {
    if (!_addSuccessSucject) {
        _addSuccessSucject = [RACSubject subject];
    }
    return _addSuccessSucject;
}

- (RACSubject *)blackUserEndSubject {
    if (!_blackUserEndSubject) {
        _blackUserEndSubject = [RACSubject subject];
    }
    return _blackUserEndSubject;
}

- (RACSubject *)messageNotifySubject {
    if (!_messageNotifySubject) {
        _messageNotifySubject = [RACSubject subject];
    }
    return _messageNotifySubject;
}

- (RACSubject *)groupOperSubject {
    if (!_getGroupsSubject) {
        _groupOperSubject = [RACSubject subject];
    }
    return _groupOperSubject;
}

- (RACSubject *)exitGroupSubject {
    if (!_exitGroupSubject) {
        _exitGroupSubject = [RACSubject subject];
    }
    return _exitGroupSubject;
}




#pragma mark - MessageAck
//添加消息回执 chw 19.06.20
- (void)sendSingleMessageAck:(NSArray*)messageIds withRoomId:(NSString*)roomId withNextResponse:(id)response {
    if (messageIds.count == 0)
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError * error;
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:0];
        [param setObject:messageIds forKey:@"messageIds"];
        [param setObject:roomId forKey:@"roomId"];
//        NSString *identity = [[YMEncryptionManager shareManager] getMyIdentityKey];
//        if (identity)
//            [param setObject:identity forKey:@"remoteIdentityKey"];
        RequestModel *model = [TSRequest postRequetWithApi:api_single_message_ack withParam:param error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSString *data = [NSString ym_decryptAES:model.data];
                NSArray *array = [NSString arrayWithJsonString:data];
                if (array.count>0) {
                    if ([response respondsToSelector:@selector(sendNext:)])
                        [response sendNext:array];
                    //添加消息回执
                    NSMutableArray *messageIds = [NSMutableArray arrayWithCapacity:array.count];
                    NSString *roomId = nil;
                    for (NSDictionary *dic in array) {
                        [messageIds addObject:[dic objectForKey:@"messageId"]];
                        if ([dic objectForKey:@"roomId"]) {
                            roomId = [dic objectForKey:@"roomId"];
                        }
                    }
                    [self sendSingleMessageAck:messageIds withRoomId:roomId withNextResponse:response];
                }
            }
        });
    });
}

@end



