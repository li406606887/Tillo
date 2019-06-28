//
//  FMDBManager+UserInfo.m
//  T-Shion
//
//  Created by together on 2018/6/29.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager+UserInfo.h"

@implementation FMDBManager (UserInfo)
#pragma mark 插入用户数据
/*
 * 根据UserInfoModel查询是否存在数据
 */
+ (void)checkUserInfoWithModel:(UserInfoModel *)model isExist:(void(^)(BOOL isExist, FMDatabase *db))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM UserInfo WHERE ID = ?", model.ID];
        while (result.next) {
            e = YES;
            NSString *friendId = [result stringForColumnIndex:0];
            NSLog(@"friendId===%@",friendId);
            break;
        }
        [result close];
        exist(e, db);
    }];
}

+ (BOOL)updateUserInfo:(UserInfoModel *)model {
    __block BOOL result ;
    [self checkUserInfoWithModel:model isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            result = [db executeUpdate:@"INSERT INTO UserInfo (ID, name, avatar, mobile, sex, introduce, address, dialCode, region) VALUES (?, ?, ?, ?, ?, ?, ? , ? ,?)",model.ID,model.name,model.avatar,model.mobile,@(model.sex),model.introduce,model.address,model.dialCode ,model.region];
            if (result) {
                NSLog(@"插入用户信息成功");
            }
        }else {
            NSString *address ;
            if (model.address == nil) {
                address = @"";
            }else {
                address = model.address;
            }
            
            if (model.dialCode == nil) {
                model.dialCode = @"";
            }
            
            if (model.introduce == nil) {
                model.introduce = @"";
            }
            
            result = [db executeUpdate:@"UPDATE UserInfo SET name = ?,avatar = ?,mobile = ?,sex = ?, introduce = ?, address = ?, dialCode = ? , region = ? WHERE ID = ?",model.name,model.avatar,model.mobile,@(model.sex),model.introduce,address, model.dialCode , model.region,model.ID];
            if (result) {
                NSLog(@"更新用户信息成功");
            }
        }
    }];
    return result;
}

+ (UserInfoModel*)selectUserModel {
    __block UserInfoModel *model;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        NSLog(@"%@",userID);
        //wsp修改，获取用户错误问题
        FMResultSet *result = [db executeQuery:@"SELECT * FROM UserInfo WHERE ID = ?",userID];
        while (result.next) {
            model = [[UserInfoModel alloc] init];
            model.ID = [result stringForColumn:@"ID"];
            model.name = [result stringForColumn:@"name"];
            model.sex = [[result stringForColumn:@"sex"] intValue];
            model.introduce = [result stringForColumn:@"introduce"];
            model.avatar = [result stringForColumn:@"avatar"];
            model.mobile = [result stringForColumn:@"mobile"];
            model.address = [result stringForColumn:@"address"];
            model.dialCode = [result stringForColumn:@"dialCode"];
            model.region = [result stringForColumn:@"region"];
            if (model.ID == nil||model.ID.length<4) {
                model = nil;
            }
        }
        [result close];
    }];
    return model;
}

+ (void)setNotifySeting {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM NotifySet WHERE user_id = ?",userID];
        __block BOOL state = NO;
        while (result.next) {
            state = YES;
        }
        [result close];
        if (state == NO) {
            BOOL insertResult = [db executeUpdate:@"INSERT INTO NotifySet (user_id) VALUES (?)",userID];
            if (insertResult) {
                NSLog(@"插入成功");
            }
        }
    }];
}

+ (void)setNotifyWithReceiveSwitch:(BOOL)state {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        BOOL result = [db executeUpdate:@"UPDATE NotifySet SET notify_switch = ? WHERE user_id = ?",@(state),userID];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}

+ (BOOL)selectedNotifyWithReceiveSwitch {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM NotifySet WHERE user_id = ?",userID];
        while (result.next) {
            state = [result boolForColumn:@"notify_switch"];
        }
        [result close];
    }];
    return state;
}

+ (void)setNotifyWithReceiveDetailsSwitch:(BOOL)state {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        BOOL result = [db executeUpdate:@"UPDATE NotifySet SET notify_switch_details = ? WHERE user_id = ?",@(state),userID];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}

+ (BOOL)selectedNotifyWithReceiveDetailsSwitch {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM NotifySet WHERE user_id = ?",userID];
        while (result.next) {
            state = [result boolForColumn:@"notify_switch_details"];
        }
        [result close];
    }];
    return state;
}

+ (void)setNotifyWithRTCSwitch:(BOOL)state {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        BOOL result = [db executeUpdate:@"UPDATE NotifySet SET notify_rtc_switch = ? WHERE user_id = ?",@(state),userID];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}

+ (BOOL)selectedNotifyWithRTCSwitch {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM NotifySet WHERE user_id = ?",userID];
        while (result.next) {
            state = [result boolForColumn:@"notify_rtc_switch"];
        }
        [result close];
    }];
    return state;
}

+ (void)setVoiceNotifySwitch:(BOOL)state {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        BOOL result = [db executeUpdate:@"UPDATE NotifySet SET notify_voice = ? WHERE user_id = ?",@(state),userID];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}

+ (BOOL)selectedVoiceNotifySwitch {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM NotifySet WHERE user_id = ?",userID];
        while (result.next) {
            state = [result boolForColumn:@"notify_voice"];
        }
        [result close];
    }];
    return state;
}

+ (void)setShockNotifySwitch:(BOOL)state {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        BOOL result = [db executeUpdate:@"UPDATE NotifySet SET notify_shock = ? WHERE user_id = ?",@(state),userID];
        if (result) {
            NSLog(@"更新成功");
        }
    }];
}

+ (BOOL)selectedShockNotifySwitch {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        FMResultSet *result = [db executeQuery:@"SELECT * FROM NotifySet WHERE user_id = ?",userID];
        while (result.next) {
            state = [result boolForColumn:@"notify_shock"];
        }
        [result close];
    }];
    return state;
}
@end
