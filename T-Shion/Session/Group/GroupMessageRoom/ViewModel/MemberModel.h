//
//  MemberModel.h
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MemberModel : FriendsModel
@property (copy, nonatomic) NSString *uid;
@property (assign, nonatomic) int delFlag;//0 是群内成员 1不是群成员
@property (assign, nonatomic) int isHad;//是否是好友 0 是  1 不是  2自己
/* 是否选中
 * 删除或者添加群成员 逻辑判断的参数
 */
@property (assign, nonatomic) int selected;//是否是好友 0 未选中  1 已选中

@property (nonatomic, copy) NSString *groupName;//用户在群聊里面的昵称

+ (MemberModel *)initMemberWithResult:(FMResultSet *)result;

+ (NSMutableArray *)sortMembersArray:(NSArray *)members toIndexArray:(NSMutableArray *)indexArray;

+ (NSString *)getShowNameWithMember:(MemberModel *)member;

@end
