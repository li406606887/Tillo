//
//  ALContactManager.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ALSysPerson.h"

/**
 通讯录变更回调（未分组的通讯录）
 */
typedef void (^ALContactChangeHandler) (void);


@interface ALContactManager : NSObject

+ (instancetype)sharedInstance;

/**
 通讯录变更回调
 */
@property (nonatomic, copy) ALContactChangeHandler contactChangeHandler;

/**
 请求授权
 
 @param completion 回调
 */
- (void)requestAddressBookAuthorization:(void (^) (BOOL authorization))completion;

/**
 获取联系人列表（未分组的通讯录）
 
 @param completcion 回调
 */
- (void)al_accessContactsComplection:(void (^)(BOOL, NSArray<ALSysPerson *> *))completcion;

- (void)al_accessSectionContactsComplection:(void (^)(BOOL, NSArray<ALSectionPerson *> *, NSArray<NSString *> *keys))completcion;

- (NSString *)al_firstCharacterWithString:(NSString *)string;

#pragma mark - 自己传数据进行塞选
- (void)al_accessSectionContactsWithDataSource:(NSArray *)dataArray Complection:(void (^)(BOOL, NSArray<ALSectionPerson *> *, NSArray<NSString *> *keys))completcion;


@end


