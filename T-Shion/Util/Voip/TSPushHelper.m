
//  TSPushHelper.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/8.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSPushHelper.h"
#import <UserNotifications/UserNotifications.h>
#import "VoipHelper.h"
#import "AppDelegate.h"
#import "ALSlideMenu.h"
#import "GroupMessageRoomController.h"
#import "MessageRoomViewController.h"
#import "ALCameraRecordViewController.h"
#import "AtManModel.h"
#import "YMRTCBrowser.h"
#import "TSRTCChatViewController.h"

@interface TSPushHelper () <VoipHelperDelegate,UNUserNotificationCenterDelegate>

@end

@implementation TSPushHelper

+ (instancetype)shareInstance {
    
    static  TSPushHelper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [[TSPushHelper alloc] init];
            [VoipHelper shareInstance].delegate = instance;
        }
    });
    return instance;
}

- (void)registerNotifications {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error) {
                NSLog(@"request authorization succeeded!");
            }
        }];
        
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"%@",settings);
        }];
    } else {
        // Fallback on earlier versions
        UIUserNotificationType types = (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert);
        
        UIUserNotificationSettings * notificationSettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
}

#pragma mark - VoipHelperDelegate
- (void)didReceiveIncomingPushWithPayload:(PKPushPayload *)payload {
    //如果没用户已退出不处理
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]) {
        return;
    }
    
    NSDictionary *userInfo = payload.dictionaryPayload;
    
    NSDictionary *apsData = userInfo[@"aps"];
    
    if (!apsData) {
        return;
    }
    
    NSString *route = apsData[@"route"];
    
    //踢下线
    if ([route isEqualToString:@"sso"]) {
        [SocketViewModel kickUserRequest:NO];
        return;
    }
    
    if ([route isEqualToString:@"rtc"]) {
        [self createVoipNotification:apsData];
    } else {
        [self createMessageNotification:apsData];
    }
}

//modify by chw 2019.04.20 for "林总要求消息和推送同步到达，先拉取离线消息成功后再推送"
- (void)createMessageNotification:(NSDictionary *)apsData {
    NSString *route = apsData[@"route"];
    NSDictionary *alertData = apsData[@"alert"];

    __block NSString *messageId;
    __block NSString *roomId;
    
    __block NSString *subtitle;
    __block NSString *titleStr = alertData[@"title"];
    __block NSString *bodyStr = alertData[@"body"];
    
    if ([apsData objectForKey:@"isCryptoMessage"]) {
        BOOL isCryptoMessage = [[apsData objectForKey:@"isCryptoMessage"] boolValue];
        if (isCryptoMessage)
            bodyStr = Localized(@"crypt_push_body");
    }
    
    //如果关闭推送则不进行下一步
//    if (![FMDBManager selectedNotifyWithReceiveSwitch]) return;
    
    if ([route isEqualToString:@"singleChat"]) {
        
        messageId = apsData[@"messageId"];
        roomId = apsData[@"roomId"];
        MessageModel *msgModel = [MessageModel new];
        msgModel.roomId = roomId;
        msgModel.messageId = messageId;
        
        //消息已存在或者免打扰不进行下一步操作
        if ([FMDBManager isAlreadyHadMsg:msgModel]) return;
        if ([FMDBManager selectedRoomDisturbWithRoomId:roomId]) return;
        
        //如果是好友显示备注
        FriendsModel *friendModel = [FMDBManager selectFriendTableWithRoomId:roomId];
        if (friendModel) titleStr = friendModel.showName;
        
    } else if ([route isEqualToString:@"groupChat"]) {
        
        messageId = apsData[@"msgId"];
        roomId = apsData[@"roomId"];
        MessageModel *msgModel = [MessageModel new];
        msgModel.roomId = roomId;
        msgModel.messageId = messageId;
        
        if ([FMDBManager isAlreadyHadMsg:msgModel]) return;
        
        GroupModel *model = [FMDBManager selectGroupModelWithRoomId:roomId];
        MemberModel *member = [FMDBManager selectedMemberWithRoomId:roomId memberID:apsData[@"sender"]];
        subtitle = [MemberModel getShowNameWithMember:member];
        titleStr = model.name;
        
    } else if ([route isEqualToString:@"addFriend"]) {
        NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
        NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:key];
        int numbers = [number intValue] + 1;
        [[NSUserDefaults standardUserDefaults] setObject:@(numbers) forKey:key];
        titleStr = Localized(@"Voip_NewFried");
        bodyStr = nil;

    } else if ([route isEqualToString:@"passFriend"]) {
        bodyStr = Localized(@"Chat_Msg_PassFriend");
        [[SocketViewModel shared] receiverNewMessage:apsData];
    }
    
    @weakify(self);
    void (^complete)(void) = ^(void) {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            return;
        }
        
        if (![FMDBManager selectedNotifyWithReceiveSwitch]) return;
        
        @strongify(self);
        
        __block BOOL isMentioned = NO;
        if ([route isEqualToString:@"groupChat"]) {
            MessageModel *msg;
            if (messageId.length > 1 && roomId.length > 1) {
                msg = [FMDBManager selectMessageWithRoomId:roomId msgId:messageId];
            }
            
            [msg.atModelList enumerateObjectsUsingBlock:^(AtManModel *atModel, NSUInteger idx, BOOL * _Nonnull stop) {
                //如果有@的人并且遍历到自己
                if ([atModel.userId isEqualToString:[SocketViewModel shared].userModel.ID] || [atModel.userId isEqualToString:@"-1"]) {
                    isMentioned = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (![FMDBManager selectedNotifyWithReceiveDetailsSwitch]) {
            //如果不显示详情
            titleStr = Localized(@"Have_New_message");
            subtitle = nil;
            bodyStr = nil;
        }
        
        if (isMentioned == YES) {
            //如果是群聊@到自己
            titleStr = Localized(@"Chat_Msg_Mentioned");
        } else {
            //如果房间设置消息免打扰不弹出
            if ([FMDBManager selectedRoomDisturbWithRoomId:roomId]) return;
        }
        
        //生成本地推送通知
        [self fireLocalNotificationWithTitle:titleStr subtitle:subtitle bodyStr:bodyStr userInfo:apsData];
        
        int newBadgeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushBadgeCount"] intValue] + 1 ;
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",newBadgeCount] forKey:@"PushBadgeCount"];
        
        if (newBadgeCount > 0) {
            [UIApplication sharedApplication].applicationIconBadgeNumber = newBadgeCount;
        }
    };
    
    if ([route isEqualToString:@"groupChat"]) {
        //注意这边不能跟单聊的isThis用同个名字
        __block BOOL isThisGroupChat = YES;
        [[SocketViewModel shared].getGroupChatOfflineMessageCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
            if (isThisGroupChat && x)
                complete();
            isThisGroupChat = NO;
        }];
        
        //注意这边一定要写在获取信号量的后面
        [[SocketViewModel shared].getGroupChatOfflineMessageCommand execute:@{@"roomId":roomId}];
        
    } else if ([route isEqualToString:@"singleChat"]) {
        
        __block BOOL isThis = YES;
        //add by chw 2019.04.20 for "林总要求消息和推送同步到达"
        [[SocketViewModel shared].getSingleChatOfflineMessageCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
            if (isThis && x)
                complete();
            isThis = NO;
        }];
        
        //注意这边一定要写在获取信号量的后面
        [[SocketViewModel shared].getSingleChatOfflineMessageCommand execute:@{@"roomId":roomId}];
        
    } else {
        complete();
    }
}

- (void)fireLocalNotificationWithTitle:(NSString *)title
                              subtitle:(NSString *)subtitle
                               bodyStr:(NSString *)bodyStr
                              userInfo:(id)userInfo {
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.sound = [UNNotificationSound defaultSound];
        content.title = title;
        content.subtitle = subtitle;
        content.body = bodyStr;
        content.userInfo = userInfo;
        
        // 3.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
        
        // 4.设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString content:content trigger:trigger];
        
        // 5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
        
    } else {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertTitle = title;
        localNotification.alertBody = bodyStr;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.userInfo = userInfo;
        
        [[UIApplication sharedApplication]
         presentLocalNotificationNow:localNotification];
    }
}

- (void)createVoipNotification:(NSDictionary *)apsData {
    if (![FMDBManager selectedNotifyWithRTCSwitch]) {
        return;
    }
    int newBadgeCount = [[[NSUserDefaults standardUserDefaults] objectForKey:@"PushBadgeCount"] intValue] + 1 ;
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",newBadgeCount] forKey:@"PushBadgeCount"];
    
    if (newBadgeCount>0) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = newBadgeCount;
    }
    
    
    NSDictionary *alertData = apsData[@"alert"];
    
    NSString *titleStr = alertData[@"title"];
    
    NSDictionary *bodyData = alertData[@"body"];
    NSString *roomID = [NSString stringWithFormat:@"%@",bodyData[@"roomId"]];
    NSString *type = [bodyData objectForKey:@"type"];
    NSString *receiverHost = [bodyData objectForKey:@"rtcServer"];
    NSString *senderStr = [NSString stringWithFormat:@"%@",[bodyData objectForKey:@"sender"]];
    NSString *messageId = [NSString stringWithFormat:@"%@",bodyData[@"id"]];
    FriendsModel *receiveModel = [FMDBManager selectFriendTableWithUid:senderStr];
    
    if (receiveModel) {
        titleStr = receiveModel.showName;
    }
    
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        
        content.body = [NSString localizedUserNotificationStringForKey:[NSString
                                                                        stringWithFormat:@"%@%@", titleStr,
                                                                        Localized(@"RTC_Tip_Voip")] arguments:nil];
        content.userInfo = apsData;
        content.sound = [UNNotificationSound soundNamed:@"call.caf"];
        
        // 3.触发模式
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
        
        // 4.设置UNNotificationRequest
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSUUID UUID].UUIDString content:content trigger:trigger];
        
        // 5.把通知加到UNUserNotificationCenter, 到指定触发点会被触发
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        }];
        
    } else {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        localNotification.alertBody = [NSString stringWithFormat:@"%@%@",titleStr,Localized(@"RTC_Tip_Voip")];
        
        localNotification.soundName = @"voip_call.caf";
        localNotification.userInfo = apsData;
        
        [[UIApplication sharedApplication]
         presentLocalNotificationNow:localNotification];
    }
    
    YMRTCChatType chatType;
    chatType = [type isEqualToString:@"video"] ? YMRTCChatType_Video : YMRTCChatType_Audio;
    YMRTCDataItem *dataItem = [[YMRTCDataItem alloc] initWithChatType:chatType
                                                                 role:YMRTCRole_Callee
                                                               roomId:roomID otherInfoData:receiveModel];
    dataItem.messageId = messageId;
    dataItem.receiveHostURL = receiverHost;
    YMRTCBrowser *browser = [[YMRTCBrowser alloc] initWithDataItem:dataItem];
    [browser show];
    
//    RTCChatType chatType;
//    if ([type isEqualToString:@"video"]) {
//        chatType = RTCChatType_Video;
//    } else {
//        chatType = RTCChatType_Audio;
//    }
//    
//    UIViewController *topVC = (UIViewController *)[SocketViewModel getTopViewController];
//    if ([topVC isKindOfClass:[TSRTCChatViewController class]]) {
//        return;
//    }
//    
//    TSRTCChatViewController *chatVC = [[TSRTCChatViewController alloc] initWithRole:TSRTCRole_Callee
//                                                                           chatType:chatType
//                                                                             roomID:roomID
//                                                                     receiveIDArray:@[senderStr] receiveHostURL:receiverHost];
//    chatVC.receiveModel = receiveModel;
//    chatVC.messageId = messageId;
//    
//    if ([topVC isKindOfClass:[ALCameraRecordViewController class]]) {
//        [topVC dismissViewControllerAnimated:NO completion:^{
//            UIViewController *tempVC = (UIViewController *)[SocketViewModel getTopViewController];
//            [tempVC presentViewController:chatVC animated:YES completion:nil];
//        }];
//        
//    } else {
//        [topVC presentViewController:chatVC animated:YES completion:nil];
//    }
}


#pragma mark - UNUserNotificationCenterDelegate
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)) API_AVAILABLE(ios(10.0)){
    
    NSDictionary *apsData = response.notification.request.content.userInfo;
    NSString *route = apsData[@"route"];
    
    if ([route isEqualToString:@"singleChat"] || [route isEqualToString:@"groupChat"]) {
        NSString *roomID = apsData[@"roomId"];
        [self gotoMsgRoom:roomID route:route];
    }
    
}

- (void)gotoMsgRoom:(NSString *)roomID route:(NSString *)route {
    UIWindow *window = ((AppDelegate *)[UIApplication sharedApplication].delegate).window;
    
    UIViewController *appRootViewController = window.rootViewController;
    
    if (appRootViewController.presentedViewController != nil) {
        [appRootViewController.presentedViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    if ([appRootViewController isKindOfClass:[ALSlideMenu class]]) {
        ALSlideMenu *slideMenu = (ALSlideMenu *)appRootViewController;
        TabBarViewController *tabbarVC = (TabBarViewController *)slideMenu.rootViewController;
        
        UINavigationController *selectedNav = tabbarVC.selectedViewController;
        UIViewController *topViewController = selectedNav.topViewController;
        
        if ([topViewController isKindOfClass:[GroupMessageRoomController class]] || [topViewController isKindOfClass:[MessageRoomViewController class]]) {
            //如果当前处于聊天页面
            if ([[SocketViewModel shared].room isEqualToString:roomID]) {
                return;
            }
        }
        
        //如果当前不处于聊天页面
        [selectedNav popToRootViewControllerAnimated:NO];
        if (tabbarVC.selectedIndex != 0) {
            tabbarVC.selectedIndex = 0;
        }
        
        UINavigationController *tempNav = tabbarVC.selectedViewController;
        int unReadCount = [FMDBManager selectUnreadCountWithRoomId:roomID];
        int count = unReadCount < 1 ? 20 : unReadCount;
        RefreshMessageType type = unReadCount>0 ? Loading_HAVE_NEW_MESSAGES: Loading_NO_NEW_MESSAGES;
        if ([route isEqualToString:@"singleChat"]) {
            FriendsModel *friendModel = [FMDBManager selectFriendTableWithRoomId:roomID];
            BOOL isCrypt = YES;
            if ([friendModel.roomId isEqualToString:roomID])
                isCrypt = NO;
            MessageRoomViewController *messageVC = [[MessageRoomViewController alloc] initWithModel:friendModel count:count type:type isCrypt:isCrypt];
            [tempNav pushViewController:messageVC animated:NO];
            
        } else {
            GroupModel *groupModel = [FMDBManager selectGroupModelWithRoomId:roomID];
            GroupMessageRoomController *groupVC = [[GroupMessageRoomController alloc] initWithModel:groupModel count:count type:type];
            [tempNav pushViewController:groupVC animated:NO];
        }
        
    }
}



@end


