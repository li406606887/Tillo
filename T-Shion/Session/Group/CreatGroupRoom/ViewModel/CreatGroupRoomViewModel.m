//
//  CreatGroupRoomViewModel.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "CreatGroupRoomViewModel.h"
//add by chw 2019.05.22 for ‘加密群聊’
#import "FMDBManager+EncryptStore.h"
#import "YMEncryptionManager.h"

@implementation CreatGroupRoomViewModel
- (void)initialize {
    @weakify(self)
    [self.creatGroupCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        GroupModel *model = [GroupModel mj_objectWithKeyValues:x];
        if (!model.isCrypt)
            model.isCrypt = self.isCrypt;
        [FMDBManager creatMessageTableWithRoomId:model.roomId];
        [FMDBManager updateGroupListWithModel:model];
        [FMDBManager creatGroupMemberTableWithRoomId:model.roomId];
        NSSet *userIds = [x objectForKey:@"userIds"];

        MemberModel *member = [[MemberModel alloc] init];
        member.roomId = model.roomId;
        member.name = [SocketViewModel shared].userModel.name;
        member.avatar = [SocketViewModel shared].userModel.avatar;
        member.userId = [SocketViewModel shared].userModel.ID;
        member.delFlag = 0;
        [FMDBManager updateGroupMemberWithRoomId:model.roomId member:member];
        
        NSMutableArray *userIdArray = [NSMutableArray arrayWithCapacity:0];
        NSString *content = [NSString stringWithFormat:@""];
        for (MemberModel *member in self.memberArray) {
            member.roomId = model.roomId;
            long userId = [member.userId longLongValue];
            if ([userIds containsObject:@(userId)]) {
                member.delFlag = 0;
                [FMDBManager updateGroupMemberWithRoomId:model.roomId member:member];
            }
            content = [NSString stringWithFormat:@"%@“%@”、",content,member.name];
            [userIdArray addObject:member.userId];
        }
        if (content.length>1) {
            content = [content substringWithRange:NSMakeRange(0, [content length] - 1)];
        }
        MessageModel *message = [[MessageModel alloc] init];
        message.messageId = [NSUUID UUID].UUIDString;
        message.type = @"system";
        message.sender = [SocketViewModel shared].userModel.ID;
        message.timestamp = [NSDate getNowTimestamp];
        message.roomId = model.roomId;
        if (self.isCrypt) {
            message.messageId = @"999";
            message.content = [NSString stringWithFormat:@"%@%@%@%@",Localized(@"You"),Localized(@"Invite"),Localized(content),Localized(@"crypt_join_group")];
            message.isCryptoMessage = self.isCrypt;
        }
        else
            message.content = [NSString stringWithFormat:@"%@%@%@%@",Localized(@"You"),Localized(@"Invite"),Localized(content),Localized(@"Join_Room")];
        [FMDBManager insertMessageWithContentModel:message];
        [FMDBManager insertSessionOnlineWithType:@"groupChat" message:message withCount:0];
        if (self.isCrypt) {
            [[YMEncryptionManager shareManager] getGroupUserKeys:userIdArray];
            MessageModel *m = [message copy];
            m.timestamp = [NSString stringWithFormat:@"%lld", [message.timestamp longLongValue]+1];
            m.messageId = @"1000";
            m.backId = @"1000";
            m.content = [NSString stringWithFormat:@"%@\n%@\n%@", Localized(@"crypt_tip1"), Localized(@"crypt_tip3"), Localized(@"crypt_tip4")];
            [FMDBManager insertMessageWithContentModel:m];
        }
        [self.creatSuccessSubject sendNext:model];
    }];
}

- (RACCommand *)creatGroupCommand {
    if (!_creatGroupCommand) {
        _creatGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingView(@"")
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest postRequetWithApi:api_post_creat_session withParam:input error:&error];
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
    return _creatGroupCommand;
}

#pragma mark method
- (NSMutableArray *)userSorting:(NSMutableArray *)modelArr {
    ///modify by chw for reduce code redundancy 2019.02.27
    if (self.indexArray.count>0) {
        [self.indexArray removeAllObjects];
    }
    return [FriendsModel sortFriendsArray:modelArr toIndexArray:self.indexArray];
}

- (RACSubject *)creatSuccessSubject {
    if (!_creatSuccessSubject) {
        _creatSuccessSubject = [RACSubject subject];
    }
    return _creatSuccessSubject;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        NSMutableArray *array = nil;
        //add by chw 2019.05.22 for ‘加密群聊’
        if (self.isCrypt)
            array = [[FMDBManager shared] selectEncryptionFriend];
        else
            array = [FMDBManager selectFriendTable];
        _dataArray = [self userSorting:array];
    }
    return _dataArray;
}

- (NSMutableArray *)memberArray {
    if (!_memberArray) {
        _memberArray = [NSMutableArray array];
    }
    return _memberArray;
}

- (NSMutableArray *)indexArray {
    if(!_indexArray) {
        _indexArray = [NSMutableArray array];
    }
    return _indexArray;
}
@end
