//
//  TransmitRecentlyViewModel.m
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "TransmitViewModel.h"

@implementation TransmitViewModel

@synthesize selectedArray = _selectedArray;

- (instancetype)initWithType:(TransmitViewType)type {
    if (self = [super init]){
        _type = type;
    }
    return self;
}

- (NSMutableArray*)selectedArray {
    if (!_selectedArray) {
        _selectedArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedArray;
}

- (void)getDataArrayWithSelectedArray:(NSArray *)array {
    switch (self.type) {
        case TransmitViewTypeRecentlySession: {
            if (!self.dataArray)
                self.dataArray = [NSMutableArray arrayWithCapacity:0];
            else
                [self.dataArray removeAllObjects];
            for (SessionModel *session in self.originArray) {
                if (session.isCrypt)
                    continue;
                else {
                    for (id model in array) {
                        NSString *roomId = [model valueForKey:@"roomId"];
                        if ([session.roomId isEqualToString:roomId]) {
                            session.transmitSelected = YES;
                            if (session.model) {
                                session.model = nil;
                                session.model = model;
                                session.model.transmitSelected = YES;
                            }
                            if (session.group) {
                                session.group = nil;
                                session.group = model;
                                session.group.transmitSelected = YES;
                            }
                            break;
                        }
                    }
                }
                [self.dataArray addObject:session];
            }
        }
            break;
        case TransmitViewTypeFriend: {
            NSMutableArray *arr = self.originArray;
            if (array.count > 0) {
                for (FriendsModel *friend in arr) {
                    for (id m in array) {
                        if ([m isKindOfClass:[FriendsModel class]]) {
                            FriendsModel *model = m;
                            if ([friend.userId isEqualToString:model.userId]) {
                                friend.disableSelect = YES;
                                break;
                            }
                        }
                    }
                }
            }
            self.indexArray = [NSMutableArray arrayWithCapacity:0];
            arr = [FriendsModel sortFriendsArray:arr toIndexArray:self.indexArray];
            self.dataArray = [NSMutableArray arrayWithCapacity:0];
            for (NSArray *a in arr) {
                [self.dataArray addObject:a];
            }
        }
            break;
        case TransmitViewTypeGroup: {
            self.dataArray = self.originArray;
            if (array.count > 0) {
                for (GroupModel *group in self.dataArray) {
                    for (id m in array) {
                        if ([m isKindOfClass:[GroupModel class]]) {
                            GroupModel *model = m;
                            if ([group.roomId isEqualToString:model.roomId]) {
                                group.disableSelect = YES;
                                break;
                            }
                        }
                    }
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)selectedOne:(id)model{
    if ([model isKindOfClass:[SessionModel class]]) {
        SessionModel *session = model;
        session.transmitSelected = YES;
        if ([session.type isEqualToString:@"singleChat"]) {
            [self.selectedArray addObject:session.model];
        }
        else {
            [self.selectedArray addObject:session.group];
        }
    }
    else {
        [self.selectedArray addObject:model];
        [model setValue:@(YES) forKey:@"transmitSelected"];
    }
    [self.selectedChangeSubject sendNext:self.selectedArray];
}

- (void)deselectedOne:(id)model{
    if ([model isKindOfClass:[SessionModel class]]) {
        SessionModel *session = model;
        session.transmitSelected = NO;
        if ([session.type isEqualToString:@"singleChat"]) {
            [self selectedArrayRemoveOne:session.model];
            session.model.transmitSelected = NO;
        }
        else {
            [self selectedArrayRemoveOne:session.group];
            session.group.transmitSelected = NO;
        }
    }
    else {
        [self selectedArrayRemoveOne:model];
        [model setValue:@(NO) forKey:@"transmitSelected"];
    }
}

- (void)selectedArrayRemoveOne:(id)model{
    if ([self.selectedArray containsObject:model]) {
        [self.selectedArray removeObject:model];
        [self.selectedChangeSubject sendNext:self.selectedArray];
    }
}

- (void)deselectedOneAtIndex:(NSInteger)index{
    if (self.selectedArray.count > index) {
        id model = [self.selectedArray objectAtIndex:index];
        for (id m in self.dataArray) {
            if ([[model valueForKey:@"roomId"] isEqualToString:[m valueForKey:@"roomId"]]) {
                [m setValue:@(NO) forKey:@"transmitSelected"];
            }
        }
        [self.selectedArray removeObjectAtIndex:index];
        [self.selectedChangeSubject sendNext:self.selectedArray];
        [self.dataChangeSubject sendNext:self.dataArray];
    }
}

- (void)addSelectedArrayFromArray:(NSArray *)array{
    [self.selectedArray addObjectsFromArray:array];
    [self.selectedChangeSubject sendNext:self.selectedArray];
    [self.dataChangeSubject sendNext:self.dataArray];
}

- (RACSubject*)selectedChangeSubject{
    if (!_selectedChangeSubject) {
        _selectedChangeSubject = [RACSubject subject];
    }
    return _selectedChangeSubject;
}

- (RACSubject*)dataChangeSubject {
    if (!_dataChangeSubject) {
        _dataChangeSubject = [RACSubject subject];
    }
    return _dataChangeSubject;
}

- (RACSubject*)clickFriendSubject{
    if (!_clickFriendSubject) {
        _clickFriendSubject = [RACSubject subject];
    }
    return _clickFriendSubject;
}

- (RACSubject*)clickGroupSubject
{
    if (!_clickGroupSubject) {
        _clickGroupSubject = [RACSubject subject];
    }
    return _clickGroupSubject;
}

- (NSMutableArray *)originArray {
    if (!_originArray) {
        switch (self.type) {
            case TransmitViewTypeRecentlySession: {
                _originArray = [FMDBManager selectConversationTable];
            }
                break;
            case TransmitViewTypeFriend: {
                _originArray = [FMDBManager selectFriendTable];
            }
                break;
            case TransmitViewTypeGroup: {
                _originArray = [FMDBManager selectedGroupList];
            }
                break;
            default:
                break;
        }
        for (id model in _originArray) {
            [model setValue:@(NO) forKey:@"transmitSelected"];
        }
    }
    return _originArray;
}

@end
