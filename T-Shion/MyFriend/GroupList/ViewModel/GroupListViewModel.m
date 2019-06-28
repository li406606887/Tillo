//
//  GroupMessageViewModel.m
//  T-Shion
//
//  Created by together on 2018/7/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupListViewModel.h"
#import "GroupModel.h"

@implementation GroupListViewModel
- (void)initialize {
    @weakify(self)
    [self.getGroupListCommand.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        if (x != nil) {
            NSArray *array = (NSArray *)x;
            if (array.count>0) {
                [self.dataArray removeAllObjects];
                self.dataArray = nil;
            }
            for (NSDictionary *data in array) {
                GroupModel *model = [GroupModel mj_objectWithKeyValues:data];
                [FMDBManager creatMessageTableWithRoomId:model.roomId];
                [FMDBManager creatGroupMemberTableWithRoomId:model.roomId];
                BOOL result = [FMDBManager updateGroupListWithModel:model];
                if (result) {
                    NSLog(@"群组列表插入成功");
                }
            }
        }
        [self.refreshUISubject sendNext:nil];
    }];
    
  
}

- (RACCommand *)getGroupListCommand {
    if (!_getGroupListCommand) {
        _getGroupListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
            return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSError * error;
                    RequestModel *model = [TSRequest getRequetWithApi:api_get_group_List withParam:nil error:&error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!error) {
                            [subscriber sendNext:model.data];
                        }else {
                            [subscriber sendNext:nil];
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
    return _getGroupListCommand;
}

- (RACSubject *)refreshUISubject {
    if (!_refreshUISubject) {
        _refreshUISubject = [RACSubject subject];
    }
    return _refreshUISubject;
}

- (RACSubject *)cellClickSubject {
    if (!_cellClickSubject) {
        _cellClickSubject = [RACSubject subject];
    }
    return _cellClickSubject;
}

- (RACSubject *)creatGroupSubject {
    if (!_creatGroupSubject) {
        _creatGroupSubject = [RACSubject subject];
    }
    return _creatGroupSubject;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [FMDBManager selectedGroupList];
    }
    return _dataArray;
}
@end
