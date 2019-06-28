//
//  GroupMessageModel.m
//  T-Shion
//
//  Created by together on 2018/7/4.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupModel.h"

@implementation GroupModel
+ (NSDictionary*)mj_replacedKeyFromPropertyName {
    return @{@"isCrypt":@"isEncryptGroup"};
}
- (void)setSettings:(NSDictionary *)settings {
    _settings = settings;
    self.block = [settings objectForKey:@"block"];
    self.distub = [settings objectForKey:@"not_distub"];
}

+ (GroupModel *)initModelWithResult:(FMResultSet *)result {
    GroupModel *model = [[GroupModel alloc] init];
    model.roomId = [result stringForColumn:@"room_id"];
    model.name = [result stringForColumn:@"name"];
    model.owner = [result stringForColumn:@"owner"];
    model.avatar = [result stringForColumn:@"avatar"];
    model.memberCount = [result intForColumn:@"memberCount"];
    model.inviteSwitch = [result boolForColumn:@"inviteSwitch"];
    model.deflag = [result stringForColumn:@"deflag"];
    model.isCrypt = [result boolForColumn:@"isCrypt"];
    return model;
}
@end
