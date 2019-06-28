//
//  GroupMessageRoomViewModel.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupMessageRoomViewModel.h"
#import "MemberModel.h"
#import "NetworkModel.h"
#import "AtManModel.h"

@implementation GroupMessageRoomViewModel
- (void)initialize {
    @weakify(self)
    [[[SocketViewModel shared].getGroupChatOfflineMessageSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x intValue]>0) {
            self.unreadCount = self.unreadCount>0 ? self.unreadCount + [x intValue]: [x intValue];
            self.msgCount = [x intValue] + self.msgCount;
            [self getLocationHistoryMessage];
        }
        [FMDBManager clearMessageOfflineCountWithRoomId:self.groupModel.roomId];
    }];
    
    [self.getMemberCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        for (NSDictionary *data in x) {
            MemberModel *model = [MemberModel mj_objectWithKeyValues:data];
            [FMDBManager updateGroupMemberWithRoomId:self.groupModel.roomId member:model];
            MemberModel *member = [self.members objectForKey:model.userId];
            if (member) {
                member.avatar = model.avatar;
                FriendsModel *friend = [FMDBManager selectFriendTableWithUid:member.userId];
                if (friend) {
                    member.name = friend.name;
                    member.showName = friend.showName;
                    member.nickName = friend.nickName;
                    member.groupName = model.groupName;
                }
            }else {
                [self.memberArray addObject:model];
                [self.members setObject:model forKey:model.userId];
            }
        }
//        [self getLocationHistoryMessage];
//        self.type = REFRESH_Table_MESSAGES;
//        [self.refreshTableSubject sendNext:@(REFRESH_Table_MESSAGES)];
    }];
    
    [[[SocketViewModel shared].sendMessageSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            MessageModel *model = (MessageModel *)x;
            @strongify(self)
            if (model.sendType == OtherSender) {
                model.member = [self.members objectForKey:model.sender];
                if (!model.member) {
                    MemberModel *member = [FMDBManager selectedMemberWithRoomId:self.groupModel.roomId memberID:model.sender];
                    model.member =member;
                }
            }
            if (model.messageId.length > 0 && [self.dataSet containsObject:model.messageId]) {
                return;
            }
            if (model.backId.length > 0 && [self.dataSet containsObject:model.backId]) {
                return;
            }
            self.lastDate = [self isAddDateMsg:model date:self.lastDate array:self.dataList];
            [self.dataSet addObject:model.messageId];
            if (model.msgType == MESSAGE_AUDIO) {
                if (![FMDBManager seletedFileIsSaveWithPath:model]) {
                    [self.downLoadingDictionary setObject:model forKey:model.messageId];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshTableSubject sendNext:@(REFRESH_NEW_MESSAGE)];
                if (model.msgType != MESSAGE_System) {
                }else {
                    [FMDBManager insertSessionOnlineWithType:@"groupChat" message:model withCount:0];
                }
            });
        });
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"sendMessageResult" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        NSDictionary *dic = [(NSDictionary *)x.object mutableCopy];
        if ([[dic objectForKey:@"type"] isEqualToString:@"withdraw"]) {
            MessageModel *model = [self.unsendDictionary objectForKey:dic[@"messageId"]];
            model.type = @"withdraw";
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.refreshTableSubject sendNext:@(REFRESH_Table_MESSAGES)];
            });
        }else {
            MessageModel *model = [self.unsendDictionary objectForKey:dic[@"backId"]];
            if (model != nil && [model.sendStatus isEqualToString:@"3"]) {
                model.sendStatus = [dic objectForKey:@"sendStatus"];
            }
            MessageModel *new = dic[@"model"];
            if ([[dic objectForKey:@"sendStatus"] isEqualToString:@"1"]) {
                model.messageId = new.messageId;
            }
            model.timestamp = new.timestamp;
            if ([[dic objectForKey:@"sendStatus"] isEqualToString:@"2"] ) {
                [FMDBManager updateUnsendMessageWithContentModel:model];
            }
        }
    }];
    
    [[[SocketViewModel shared].messageNotifySubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        NSDictionary *data = (NSDictionary *)x;
        NSString *type = data[@"type"];
        if ([type isEqualToString:@"bebelete"]) {
            self.groupModel.deflag = @"1";
        }else if ([type isEqualToString:@"modifyName"]) {
            self.groupModel.name = data[@"groupName"];
        }else if ([type isEqualToString:@"add"]) {
            if ([self.groupModel.deflag isEqualToString:@"1"]) {
                self.groupModel.deflag = @"0";
            }
        }
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"downloadingMessage" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSDictionary *dic = (NSDictionary *)x.object;
        MessageModel *model = [self.downLoadingDictionary objectForKey:dic[@"messageId"]];
        if (model != nil) {
            model.downloading = NO;
        }
    }];
}

- (RACCommand *)getMemberCommand {
    if (!_getMemberCommand) {
        _getMemberCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_group_Member withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
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
    return _getMemberCommand;
}

//第一步  进入刷新本地历史数据
- (void)getLocationHistoryMessage {
    int count = self.msgCount <= 20 ? self.msgCount +20: self.msgCount;
    [self.dataList removeAllObjects];
    [self.dataSet removeAllObjects];
    MessageModel *firMsg;
    if (self.type == Loading_HAVE_NEW_MESSAGES) {
        firMsg = [FMDBManager selectFirstUnReadMessageWithRoomId:self.groupModel.roomId];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *array = [FMDBManager selectMessageWithTableName:self.groupModel.roomId timestamp:nil count:count];
        NSMutableArray *dataArray;
        if (array.count>0) {
            dataArray = [NSMutableArray array];
        }
        for (MessageModel *model in array) {
            if (model.messageId.length > 0 && [self.dataSet containsObject:model.messageId]) {
                continue;
            }
            if (model.backId.length > 0 && [self.dataSet containsObject:model.backId]) {
                continue;
            }
            if (self.type == Loading_HAVE_NEW_MESSAGES) {
                if ([firMsg.messageId isEqualToString:model.messageId]) {
                    self.unreadFirstModel = model;
                }
            }
            [dataArray insertObject:model atIndex:0];
            [self.dataSet addObject:model.messageId];
            
            if ([model.sendStatus isEqualToString:@"3"] && model.backId) {
                [self.unsendDictionary setObject:model forKey:model.backId];
            }
            if (model.msgType == MESSAGE_AUDIO) {
                if (![model.readStatus isEqualToString:@"1"]&&![FMDBManager seletedFileIsSaveWithPath:model]) {
                    [self.downLoadingDictionary setObject:model forKey:model.messageId];
                }
            }
        }
        NSArray *tbarray = [self creatTimeMsgWithArray:dataArray];
        [self.dataList addObjectsFromArray:tbarray];
        [self.refreshTableSubject sendNext:@(self.type)];
    });
}

- (void)refreshHistoryMessage:(NSString *)timestamp {
    if (timestamp==nil||timestamp.length<1) {
        timestamp = @"";
    }
    @weakify(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        NSMutableArray *array = [FMDBManager selectGroupMessageWithTableName:self.groupModel.roomId timestamp:timestamp count:20];
        if (array.count>0) {
            NSMutableArray *dataArray = [NSMutableArray array];
            for (MessageModel *model in array) {
                if (model.messageId.length > 0 && [self.dataSet containsObject:model.messageId]) {
                    continue;
                }
                if (model.backId.length > 0 && [self.dataSet containsObject:model.backId]) {
                    continue;
                }
                [dataArray insertObject:model atIndex:0];
                if (model.messageId.length > 0) {
                    [self.dataSet addObject:model.messageId];
                }
                if ([model.sendStatus isEqualToString:@"3"]) {
                    [self.unsendDictionary setObject:model forKey:model.backId];
                }
                if (model.msgType == MESSAGE_AUDIO) {
                    if (![model.readStatus isEqualToString:@"1"]&&![FMDBManager seletedFileIsSaveWithPath:model]) {
                        [self.downLoadingDictionary setObject:model forKey:model.messageId];
                    }
                }
            }
            NSArray *tbarray = [self creatTimeMsgWithArray:dataArray];
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tbarray.count)];
            [self.dataList insertObjects:tbarray atIndexes:set];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self.refreshTableSubject sendNext:@(REFRESH_HISTORY_MESSAGES)];
        });
    });
}

- (NSArray*)creatTimeMsgWithArray:(NSMutableArray *)array {
    NSDate *date = nil;
    NSMutableArray *newMessages = [NSMutableArray array];
    for (MessageModel *msg in array) {
        if (self.unreadFirstModel) {
            if (self.unreadFirstModel == msg) {
                self.unreadMsgIndex = (int)newMessages.count;
                if (self.unreadCount>8) {
                    MessageModel *new = [[MessageModel alloc] init];
                    new.msgType = MESSAGE_New_Msg;
                    new.timestamp = msg.timestamp;
                    [newMessages addObject:new];
                }
                MessageModel *tb = [[MessageModel alloc] init];
                tb.msgType = MESSAGE_NotifyTime;
                tb.timestamp = msg.timestamp;
                [newMessages addObject:tb];
                date = [NSDate dateWithTimeIntervalSince1970:[msg.timestamp doubleValue]/1000];
            }
        }
        if (msg.msgType == MESSAGE_NotifyTime) {
            continue;
        }
        if (msg.sendType == OtherSender) {
            msg.member = [self.members objectForKey:msg.sender];
        }
        date = [self isAddDateMsg:msg date:date array:newMessages];
        self.lastDate = [date laterDate:self.lastDate];
    }
    return newMessages;
}

- (NSDate *)isAddDateMsg:(MessageModel *)msg date:(NSDate*)date array:(NSMutableArray *)array {
    if (![msg.messageId isEqualToString:@"999"] && ![msg.messageId isEqualToString:@"1000"]) {
        double timeInterval = [msg.timestamp doubleValue]/1000;
        double interval = (timeInterval - date.timeIntervalSince1970);
        if (date == nil || interval > 300) {//300ms 5分钟
            MessageModel *tb = [[MessageModel alloc] init];
            tb.msgType = MESSAGE_NotifyTime;
            tb.timestamp = msg.timestamp;
            [array addObject:tb];
            date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
        }
    }
    if (msg.messageId) {
        [self.unsendDictionary setObject:msg forKey:msg.messageId];
    }
    [array addObject:msg];
    return date;
}
#pragma mark 发送消息
- (void)sendMessageWithModel:(MessageModel *)model {
    model.messageId = model.backId = [NSUUID UUID].UUIDString;
    model.timestamp = [NSDate getNowTimestamp];
    model.sender = [SocketViewModel shared].userModel.ID;
    model.roomId = self.groupModel.roomId;
    model.readStatus = @"1";
    model.sendStatus = @"3";
    if ([model.sendStatus isEqualToString:@"3"]) {
        [self.unsendDictionary setObject:model forKey:model.backId];
    }
    [FMDBManager insertUnsendMessageWithContentModel:model];
    if (model.backId.length>0) {
        self.lastDate = [self isAddDateMsg:model date:self.lastDate array:self.dataList];
        [self.dataSet addObject:model.backId];
        [self.refreshTableSubject sendNext:@(REFRESH_NEW_MESSAGE)];
    }
    model.isCryptoMessage = self.isCrypt;
    if (self.isCrypt)
        [NetworkModel sendCryptGroupMessage:model];
    else
        [NetworkModel sendMessageWithMessage:model];
}
#pragma mark 消息重发
- (void)resendMessageWithModel:(MessageModel *)model {
    model.sendStatus = @"3";
    [self.unsendDictionary setObject:model forKey:model.backId];
    [FMDBManager updateUnsendMessageStatusWithRoomId:model.roomId backId:model.backId sendState:@"3"];
    if (model.atModelList.count > 0) {
        if ([model.atModelList[0] isKindOfClass:[AtManModel class]]) {
            model.atModelList = [AtManModel mj_keyValuesArrayWithObjectArray:model.atModelList];
        }
    }
    model.isCryptoMessage = self.isCrypt;
    if (self.isCrypt)
        [NetworkModel sendCryptGroupMessage:model];
    else
        [NetworkModel sendMessageWithMessage:model];
}
//撤回消息
- (void)withdrawMsgWithModel:(MessageModel *)model {
    [self.unsendDictionary setObject:model forKey:model.messageId];
    [NetworkModel withdrawMessageWithModel:model];
}

//add by chw 2019.04.25 for Encryption Session Screen Shot
- (void)sendScreenShotMessage {
    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"system";
    model.content = Localized(@"crypt_self_shot_tip");
    model.messageId = model.backId = [NSUUID UUID].UUIDString;
    model.timestamp = [NSDate getNowTimestamp];
    model.sender = [SocketViewModel shared].userModel.ID;
    model.isCryptoMessage = YES;
    model.roomId = self.groupModel.roomId;
    model.readStatus = @"1";
    model.sendStatus = @"3";
    
    [self.unsendDictionary setObject:model forKey:model.backId];
    [FMDBManager insertUnsendMessageWithContentModel:model];
    [self.dataSet addObject:[model.backId copy]];
    [self.dataList addObject:model];
    [self.refreshTableSubject sendNext:@(REFRESH_NEW_MESSAGE)];
    MessageModel *modelCopy = [model copy];
    [NetworkModel sendScreenShotMessageWithModel:modelCopy];
}

- (void)transmitMessageWithModel:(MessageModel*)model {
    model.sender = [SocketViewModel shared].userModel.ID;//要把发送者改成自己
    model.messageId = model.backId = [NSUUID UUID].UUIDString;
    model.timestamp = [NSDate getNowTimestamp];
    model.readStatus = @"1";
    model.sendStatus = @"3";
//    model.videoIMGName = nil;
    [FMDBManager insertUnsendMessageWithContentModel:model];
    [NetworkModel sendMessageWithMessage:model];
}

- (void)setMsgCount:(int)msgCount {
    _msgCount = msgCount;
}

- (void)setGroupModel:(GroupModel *)groupModel {
    _groupModel = groupModel;
}

- (RACSubject *)refreshTableSubject {
    if (!_refreshTableSubject) {
        _refreshTableSubject = [RACSubject subject];
    }
    return _refreshTableSubject;
}

- (RACSubject *)choosePhotoSubject {
    if (!_choosePhotoSubject) {
        _choosePhotoSubject = [RACSubject subject];
    }
    return _choosePhotoSubject;
}

- (RACSubject *)clickHeadIconSubject {
    if (!_clickHeadIconSubject) {
        _clickHeadIconSubject = [RACSubject subject];
    }
    return _clickHeadIconSubject;
}

- (RACSubject *)showMemberSubject {
    if (!_showMemberSubject) {
        _showMemberSubject = [RACSubject subject];
    }
    return _showMemberSubject;
}

- (RACSubject *)clickMemberSubject {
    if (!_clickMemberSubject) {
        _clickMemberSubject = [RACSubject subject];
    }
    return _clickMemberSubject;
}

- (RACSubject *)messageClickUrlSubject {
    if (!_messageClickUrlSubject) {
        _messageClickUrlSubject = [RACSubject subject];
    }
    return _messageClickUrlSubject;
}

- (RACSubject *)messageClickFileSubject {
    if (!_messageClickFileSubject) {
        _messageClickFileSubject = [RACSubject subject];
    }
    return _messageClickFileSubject;
}

- (RACSubject *)messageTransmitSubject {
    if (!_messageTransmitSubject) {
        _messageTransmitSubject = [RACSubject subject];
    }
    return _messageTransmitSubject;
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableSet *)dataSet {
    if (!_dataSet) {
        _dataSet = [NSMutableSet set];
    }
    return _dataSet;
}

- (NSMutableDictionary *)unsendDictionary {
    if (!_unsendDictionary) {
        _unsendDictionary = [[NSMutableDictionary alloc] init];
    }
    return _unsendDictionary;
}

- (NSMutableDictionary *)downLoadingDictionary {
    if (!_downLoadingDictionary) {
        _downLoadingDictionary = [[NSMutableDictionary alloc] init];
    }
    return _downLoadingDictionary;
}

- (NSMutableDictionary *)members {
    if (!_members) {
        _members = [NSMutableDictionary dictionary];
       self.memberArray = [FMDBManager selectedAllMemberWithRoomId:self.groupModel.roomId];
        for (MemberModel *member in self.memberArray) {
            [_members setObject:member forKey:member.userId];
        }
    }
    return _members;
}
- (RACSubject *)sendMsgSubject {
    if (!_sendMsgSubject) {
        _sendMsgSubject = [RACSubject subject];
    }
    return _sendMsgSubject;
}

- (RACSubject *)addFriendSubject {
    if (!_addFriendSubject) {
        _addFriendSubject = [RACSubject subject];
    }
    return _addFriendSubject;
}

- (void)dealloc {
    self.members = nil;
    self.downLoadingDictionary = nil;
    self.unsendDictionary = nil;
    self.dataList = nil;
    self.dataSet = nil;
}
@end
