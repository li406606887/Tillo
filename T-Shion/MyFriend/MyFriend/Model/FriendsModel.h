//
//  FriendsModel.h
//  T-Shion
//
//  Created by together on 2018/4/16.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MemberModel;

@interface FriendsModel : NSObject
@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *mobile;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *sex;
@property (copy, nonatomic) NSString *showName;
@property (copy, nonatomic) NSString *nickName;
@property (copy, nonatomic) NSString *firstLetter;
@property (copy, nonatomic) NSString *roomId;
@property (strong, nonatomic) NSDictionary *settings;
@property (copy, nonatomic) NSString *dialCode;
@property (copy, nonatomic) NSString *region;//地区
@property (copy, nonatomic) NSString *country;//国家
@property (strong, nonatomic) UIImage *headIcon;
/*
 * 好友请求才会有下面数据
 */
@property (copy, nonatomic) NSString *remark;
@property (copy, nonatomic) NSString *requestId;//请求ID
@property (assign, nonatomic) int status;//0 待添加好友  1 已通过申请

+ (FriendsModel *)initModelWithResult:(FMResultSet *)result;

+ (FriendsModel *)initMemberWith:(MemberModel *)model result:(FMResultSet *)result;

/**
 给好友数组创建首拼索引数组
 modify by chw for reduce code redundancy 2019.02.27

 @param friends 原始数组
 @param indexArray 创建的索引数组，需外部分配好内存的NSMutableArray
 @return 按所以分组后的的数据，注意是二维数组
 */
+ (NSMutableArray*)sortFriendsArray:(NSArray*)friends toIndexArray:(NSMutableArray*)indexArray;





//add by chw 2019.04.11 for encryption
@property (nonatomic, copy) NSString *encryptRoomID;  //密聊的房间id
@property (nonatomic, assign) BOOL enableEndToEndCrypt;//是否允许发起密聊

@end
