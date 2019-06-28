//
//  GroupMessageModel.h
//  T-Shion
//
//  Created by together on 2018/7/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupModel : NSObject
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *owner;
@property (copy, nonatomic) NSString *roomId;
@property (copy, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSDictionary *settings;
@property (copy, nonatomic) NSString *block;//0不屏蔽 1屏蔽
@property (copy, nonatomic) NSString *distub;//0可打扰 1免打扰
@property (assign, nonatomic) BOOL inviteSwitch;//false 关  true  开
@property (assign, nonatomic) int memberCount;//：群成员数  （整形 10）
@property (copy, nonatomic) NSString *top;//置顶
@property (copy, nonatomic) NSString *deflag;//是否被删除 0 没有 1删除

@property (nonatomic, copy) NSString *nickNameInGroup;//群聊里面的昵称

+ (GroupModel *)initModelWithResult:(FMResultSet *)result;

@property (nonatomic, assign) BOOL isCrypt;
@end
