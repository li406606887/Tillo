//
//  DialogueContentViewModel.m
//  T-Shion
//
//  Created by together on 2018/3/26.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageRoomViewModel.h"
#import "NetworkModel.h"

@implementation MessageRoomViewModel
- (void)initialize {
    @weakify(self)
    [[[SocketViewModel shared].getSingleChatOfflineMessageSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if ([x intValue]>0) {
            self.unreadCount = self.unreadCount>0 ? self.unreadCount + [x intValue]: [x intValue];
            self.msgCount = [x intValue] + self.msgCount;
            self.type = Loading_HAVE_NEW_MESSAGES;
            [self getLocationHistoryMessage];
        }
        [FMDBManager clearMessageOfflineCountWithRoomId:self.friendModel.roomId];
    }];

    [[[SocketViewModel shared].sendMessageSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            MessageModel *model = x;
            @strongify(self)
            if (model.messageId.length > 0 && [self.dataSet containsObject:model.messageId]) {
                //add by wsp :rtc离线消息状态刷新
                if (model.msgType == MESSAGE_RTC) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.refreshMsgListSubject sendNext:@(REFRESH_NEW_MESSAGE)];
                    });
                }
                return;
            }
            if (model.backId.length > 0 && [self.dataSet containsObject:model.backId]) {
                return;
            }
            
            if (model.messageId.length > 0) {
                self.lastDate = [self isAddDateMsg:model date:self.lastDate array:self.dataList];
                [self.dataSet addObject:model.messageId];
            }
            
            if (model.msgType == MESSAGE_AUDIO) {
                if (![FMDBManager seletedFileIsSaveWithPath:model]) {
                    [self.downLoadingDictionary setObject:model forKey:model.messageId];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                //wsp 修改：收到新消息不自动滑倒第一条
                [self.refreshMsgListSubject sendNext:@(REFRESH_NEW_MESSAGE)];
                // end
            });
        });
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"sendMessageResult" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSDictionary *dic = [(NSDictionary *)x.object mutableCopy];
        if ([[dic objectForKey:@"type"] isEqualToString:@"withdraw"]) {
            MessageModel *model = [self.unsendDictionary objectForKey:dic[@"messageId"]];
            model.type = @"withdraw";
            if (model.sendType == OtherSender) {
                model.senderInfo = self.friendModel;
            }
                @strongify(self)
                [self.refreshMsgListSubject sendNext:@(REFRESH_Table_MESSAGES)];
        } else {
            @strongify(self)
            MessageModel *model = [self.unsendDictionary objectForKey:dic[@"backId"]];
            if (model != nil && [model.sendStatus isEqualToString:@"3"]) {
                model.sendStatus = dic[@"sendStatus"];
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
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"downloadingMessage" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        NSDictionary *dic = (NSDictionary *)x.object;
        MessageModel *model = [self.downLoadingDictionary objectForKey:dic[@"messageId"]];
        if (model != nil) {
            model.downloading = NO;
        }
    }];
}

//第一步  进入拉取本地历史数据
- (void)getLocationHistoryMessage {
    int count = self.msgCount<=20 ? self.msgCount +20: self.msgCount;
    [self.dataList removeAllObjects];
    [self.dataSet removeAllObjects];
    self.lastDate = nil;
    NSString *roomId = self.isCrypt ? self.friendModel.encryptRoomID : self.friendModel.roomId;
    if (!roomId)
        return;
    MessageModel *firMsg;
    if (self.type == Loading_HAVE_NEW_MESSAGES) {
        firMsg = [FMDBManager selectFirstUnReadMessageWithRoomId:roomId];
    }
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *array = [FMDBManager selectMessageWithTableName:roomId timestamp:nil count:count];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
        [self.refreshMsgListSubject sendNext:@(self.type)];
    });
}
#pragma mark 刷新历史消息
- (void)refreshHistoryMessage:(NSString *)timestamp {
    if (timestamp==nil||timestamp.length<1) {
        timestamp = @"";
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *roomId = self.isCrypt ? self.friendModel.encryptRoomID : self.friendModel.roomId;
        if (!roomId)
            return;
        NSMutableArray *array = [FMDBManager selectMessageWithTableName:roomId timestamp:timestamp count:20];
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
        [self.refreshMsgListSubject sendNext:@(REFRESH_HISTORY_MESSAGES)];
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
            msg.senderInfo = self.friendModel;
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
    //modify by chw 2019.04.16 for Encryption
    model.isCryptoMessage = self.isCrypt;
    if (self.isCrypt)
        model.roomId = self.friendModel.encryptRoomID;
    else
        model.roomId = self.friendModel.roomId;
    //end
    model.receiver = self.friendModel.userId;
    model.readStatus = @"1";
    model.sendStatus = @"3";
    
    [self.unsendDictionary setObject:model forKey:model.backId];
    [FMDBManager insertUnsendMessageWithContentModel:model];
    if (model.backId.length > 0) {
        [self.dataSet addObject:[model.backId copy]];
        self.lastDate = [self isAddDateMsg:model date:self.lastDate array:self.dataList];
        [self.refreshMsgListSubject sendNext:@(REFRESH_NEW_MESSAGE)];
    }
    //modify ”model“->”[model copy]“ by chw 2019.04.22 for Encryption
    //model的content在外部被加密后会影响UI刷新时出现密文的bug
    MessageModel *modelCopy = [model copy];
    [NetworkModel sendMessageWithMessage:modelCopy];
}

#pragma mark 消息重发
- (void)resendMessageWithModel:(MessageModel *)model {
    model.receiver = self.friendModel.userId;

    model.sendStatus = @"3";
    [self.unsendDictionary setObject:model forKey:model.backId];
    [FMDBManager updateUnsendMessageStatusWithRoomId:model.roomId backId:model.backId sendState:@"3"];
    //modify ”model“->”[model copy]“ by chw 2019.04.22 for Encryption
    //model的content在外部被加密后会影响UI刷新时出现密文的bug
    MessageModel *modelCopy = [model copy];
    [NetworkModel sendMessageWithMessage:modelCopy];
}

///消息转发
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
//撤回消息
- (void)withdrawMsgWithModel:(MessageModel *)model {
    [self.unsendDictionary setObject:model forKey:model.messageId];
    model.receiver = self.friendModel.userId;
    model.isCryptoMessage = self.isCrypt;
    [NetworkModel withdrawMessageWithModel:model];
}

#pragma mark - 加密群聊相关

//add by chw 2019.04.25 for Encryption Session Screen Shot
- (void)sendScreenShotMessage {
    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"system";
    model.content = Localized(@"crypt_self_shot_tip");
    
    model.messageId = model.backId = [NSUUID UUID].UUIDString;
    model.timestamp = [NSDate getNowTimestamp];
    model.sender = [SocketViewModel shared].userModel.ID;
    model.isCryptoMessage = YES;
    model.roomId = self.friendModel.encryptRoomID;
    model.receiver = self.friendModel.userId;
    model.readStatus = @"1";
    model.sendStatus = @"3";
    
    [self.unsendDictionary setObject:model forKey:model.backId];
    [FMDBManager insertUnsendMessageWithContentModel:model];
    if (model.backId.length > 0) {
        [self.dataSet addObject:[model.backId copy]];
        [self.dataList addObject:model];
        [self.refreshMsgListSubject sendNext:@(REFRESH_NEW_MESSAGE)];
    }
    MessageModel *modelCopy = [model copy];
    [NetworkModel sendScreenShotMessageWithModel:modelCopy];
}


#pragma mark -

- (void)setFriendModel:(FriendsModel *)friendModel {
    _friendModel = friendModel;
}

- (RACSubject *)refreshMsgListSubject {
    if (!_refreshMsgListSubject) {
        _refreshMsgListSubject = [RACSubject subject];
    }
    return _refreshMsgListSubject;
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

- (RACSubject *)rtcCallSubject {
    if (!_rtcCallSubject) {
        _rtcCallSubject = [RACSubject subject];
    }
    return _rtcCallSubject;
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

- (RACSubject *)callingVideoSubject {
    if (!_callingVideoSubject) {
        _callingVideoSubject = [RACSubject subject];
    }
    return _callingVideoSubject;
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
    self.dataSet = nil;
    self.dataList = nil;
    self.unsendDictionary = nil;
    self.downLoadingDictionary = nil;
    self.lastDate = nil;
}
@end
