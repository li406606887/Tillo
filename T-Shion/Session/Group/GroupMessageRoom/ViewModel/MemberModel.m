//
//  MemberModel.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MemberModel.h"

@implementation MemberModel
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"uid":@"_id",@"groupName":@"nickName"};
}

- (void)setUserId:(NSString *)userId {
    @weakify(self)
    [super setUserId:userId];
    _uid = userId;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self)
        if ([userId isEqualToString:[SocketViewModel shared].userModel.ID]) {
            self.isHad = 2;
        }else {
            FriendsModel *model = [FMDBManager selectFriendTableWithUid:userId];
            self.isHad = model == nil? 1: 0;
        }
    });
}

- (void)setGroupName:(NSString *)groupName {
    _groupName = groupName;
}

+ (MemberModel *)initMemberWithResult:(FMResultSet *)result {
    MemberModel *member = [[MemberModel alloc] init];
    member.name = [result stringForColumn:@"name"];
    member.userId = [result stringForColumn:@"member_id"];
    member.avatar = [result stringForColumn:@"avatar"];
    member.delFlag = [result intForColumn:@"delFlag"];
    
    //add by wsp: 成员在群聊里面的昵称 2019.4.25
    member.groupName = [result stringForColumn:@"nickName"];
    if (member.groupName.length > 0) {
        member.name = member.groupName;
    }
    //end
    return member;
}

+ (NSMutableArray *)sortMembersArray:(NSArray *)members toIndexArray:(NSMutableArray *)indexArray {
    [indexArray removeAllObjects];
    if (!members || members.count < 1)
        return nil;
    NSMutableArray *modelArr = [members mutableCopy];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i='A';i<='z';i++) {
        NSMutableArray *rulesArray = [[NSMutableArray alloc] init];
        NSString *letter = [NSString stringWithFormat:@"%c",i];
        for(int j=0; j < modelArr.count; j++) {
            MemberModel *model = [modelArr objectAtIndex:j];
            if (model.delFlag==0) {
                if([model.firstLetter isEqualToString:letter]) {
                    [rulesArray addObject:model];//把首字母相同的人物model 放到同一个数组里面
                    [modelArr removeObject:model];//从总的modelArr里面删除
                    j--;
                }
            }
        }
        if (rulesArray.count !=0) {
            [array addObject:rulesArray];
            [indexArray addObject:[NSString stringWithFormat:@"%c",i]];
        }
    }
    NSMutableArray *lastArray = [NSMutableArray array];
    if (modelArr.count !=0) {
        for(int i=0; i<=9; i++) {
            NSString *letter = [NSString stringWithFormat:@"%d",i];
            for(int j=0; j < modelArr.count; j++) {
                MemberModel *model = [modelArr objectAtIndex:j];
                if (model.delFlag==0) {
                    if([model.firstLetter isEqualToString:letter]) {
                        [lastArray addObject:model];//把首字母相同的人物model 放到同一个数组里面
                        [modelArr removeObject:model];//从总的modelArr里面删除
                        j--;
                    }
                }
            }
        }
    }
    if (modelArr.count>0) {
        for (MemberModel * mem in modelArr) {
            if (mem.delFlag==0) {
                [lastArray addObject:mem];
            }
        }
    }
    [indexArray addObject:@"#"];
    [array addObject:lastArray];
    return array;
}

+ (NSString *)getShowNameWithMember:(MemberModel *)member {
    if (member) {
        NSString *name = member.groupName.length > 0 ? member.groupName : member.nickName;
        if (name.length < 1 || name == nil) {
            name = member.name;
        }
        return name;
    }else {
        return @"";
    }
}
@end
