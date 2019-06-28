//
//  GroupManageViewModel.m
//  T-Shion
//
//  Created by together on 2019/4/19.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "GroupManageViewModel.h"

@implementation GroupManageViewModel
- (void)initialize {
    @weakify(self)
    [self.putGroupInviteCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        GroupModel *model = [GroupModel mj_objectWithKeyValues:x];
        model.roomId = x[@"id"];
        self.group.inviteSwitch = model.inviteSwitch;
        MessageModel *msg = [[MessageModel alloc] init];
        msg.type = @"system";
        msg.backId = msg.messageId = [NSUUID UUID].UUIDString;
        msg.sender = [SocketViewModel shared].userModel.ID;
        msg.timestamp = [NSDate getNowTimestamp];
        msg.roomId = self.group.roomId;
        if (self.group.inviteSwitch) {
            msg.content = [NSString stringWithFormat:@"%@",Localized(@"open_invite_switch")];
        }else {
            msg.content = [NSString stringWithFormat:@"%@",Localized(@"close_invite_switch")];
        }
        [FMDBManager insertMessageWithContentModel:msg];
        [[SocketViewModel shared].sendMessageSubject sendNext:msg];
        [FMDBManager updateGroupListWithModel:model];
    }];
}

- (RACCommand *)putGroupInviteCommand {
    if (!_putGroupInviteCommand) {
        _putGroupInviteCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                LoadingWin(@"");
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError *error;
                    RequestModel *model = [TSRequest putRequetWithApi:api_put_groupInviteSwitch withParam:input error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        HiddenHUD;
                        if (error == nil) {
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
    return _putGroupInviteCommand;
}
@end
