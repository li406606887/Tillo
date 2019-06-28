//
//  FriendsModel.m
//  T-Shion
//
//  Created by together on 2018/4/16.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FriendsModel.h"

@implementation FriendsModel
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{@"userId":@"id",@"enableEndToEndCrypt":@"openEndToEndEncrypt"};
}

- (void)setShowName:(NSString *)showName {
    _showName = showName;
}

- (void)setUserId:(NSString *)userId {
    _userId = userId;
}

- (NSString *)firstLetter {
    if (!_firstLetter) {
        if (_showName) {
            _firstLetter = [NSString getStringFirstLetterWithString:_showName];
        }else if (_nickName){
            _firstLetter = [NSString getStringFirstLetterWithString:_nickName];
        }else if (_name){
            _firstLetter = [NSString getStringFirstLetterWithString:_name];
        }else {
            _firstLetter = [NSString getStringFirstLetterWithString:_mobile];
        }
    }
    return _firstLetter;
}

- (void)setSettings:(NSDictionary *)settings {
    _settings = settings;
//    self.block = [settings objectForKey:@"block"];
//    self.distub = [settings objectForKey:@"not_distub"];
}

- (UIImage *)headIcon {
    if (!_headIcon) {
        NSString *path = [TShionSingleCase thumbAvatarImgPathWithUserId:self.userId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            UIImage *image = [UIImage imageWithContentsOfFile:path];
            _headIcon = image;
        }else {
            _headIcon = [UIImage imageNamed:@"Avatar_Deafult"];
        }
        [self downloadHeadIconWithPath:path];
        @weakify(self)
        [[RACObserve(self, avatar) takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
            [self downloadHeadIconWithPath:path];
        }];
    }
    return _headIcon;
}

- (void)downloadHeadIconWithPath:(NSString *)path {
    @weakify(self)
    [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:self.avatar] options:SDWebImageLowPriority progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        @strongify(self)
        if (image != nil && data != nil) {
            BOOL result = [data writeToFile:path atomically:YES];
            if (!result) {
                NSLog(@"好友头像更新失败保存到本地");
            }
            self.headIcon = image;
        }
    }];
}

+ (FriendsModel *)initModelWithResult:(FMResultSet *)result {
    FriendsModel *model = [[FriendsModel alloc] init];
    model.userId = [result stringForColumn:@"friend_id"];
    model.roomId = [result stringForColumn:@"room_id"];
    model.name = [result stringForColumn:@"name"];
    model.avatar = [result stringForColumn:@"avatar"];
    model.mobile = [result stringForColumn:@"mobile"];
    model.sex = [result stringForColumn:@"sex"];
    model.showName = [result stringForColumn:@"show_name"];
    model.nickName = [result stringForColumn:@"nick_name"];
    model.dialCode = [result stringForColumn:@"dialCode"];
    model.country = [result stringForColumn:@"country"];
    model.region = [result stringForColumn:@"region"];
    
    //add by chw 2019.04.11 for encryption
    model.enableEndToEndCrypt = [result boolForColumn:@"enableEndToEndCrypt"];
    model.encryptRoomID = [result stringForColumn:@"encryptRoomID"];
    return model;
}

+ (FriendsModel *)initMemberWith:(MemberModel *)model result:(FMResultSet *)result {
    model.userId = [result stringForColumn:@"friend_id"];
    model.roomId = [result stringForColumn:@"room_id"];
    model.name = [result stringForColumn:@"name"];
    model.avatar = [result stringForColumn:@"avatar"];
    model.mobile = [result stringForColumn:@"mobile"];
    model.sex = [result stringForColumn:@"sex"];
    model.showName = [result stringForColumn:@"show_name"];
    model.nickName = [result stringForColumn:@"nick_name"];
    model.dialCode = [result stringForColumn:@"dialCode"];
    model.country = [result stringForColumn:@"country"];
    model.region = [result stringForColumn:@"region"];
    
    //add by chw 2019.04.11 for encryption
    model.enableEndToEndCrypt = [result boolForColumn:@"enableEndToEndCrypt"];
    model.encryptRoomID = [result stringForColumn:@"encryptRoomID"];
    return model;
}

+ (NSMutableArray *)sortFriendsArray:(NSArray *)friends toIndexArray:(NSMutableArray *)indexArray {
    NSMutableArray *modelArr = [friends mutableCopy];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for(int i='A';i<='z';i++) {
        NSMutableArray *rulesArray = [[NSMutableArray alloc] init];
        NSString *letter = [NSString stringWithFormat:@"%c",i];
        for(int j=0; j < modelArr.count; j++) {
            FriendsModel *model = [modelArr objectAtIndex:j];
            if([model.firstLetter isEqualToString:letter]) {
                [rulesArray addObject:model];//把首字母相同的人物model 放到同一个数组里面
                [modelArr removeObject:model];//从总的modelArr里面删除
                j--;
            }
        }
        if (rulesArray.count !=0) {
            [array addObject:rulesArray];
            [indexArray addObject:[NSString stringWithFormat:@"%c",i]];
        }
    }
    if (modelArr.count !=0) {
        [indexArray addObject:@"#"];
        [array addObject:modelArr];
    }
    return array;
}
@end
