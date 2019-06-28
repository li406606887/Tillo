//
//  TransmitRecentlyViewModel.h
//  T-Shion
//
//  Created by mac on 2019/2/27.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "BaseViewModel.h"
#import "SessionModel+Transmit.h"

typedef NS_ENUM(NSUInteger, TransmitViewType) {
    TransmitViewTypeRecentlySession  = 0,   //最近联系人
    TransmitViewTypeFriend,                 //好友
    TransmitViewTypeGroup,                  //群组
};

@interface TransmitViewModel : BaseViewModel

@property (nonatomic, assign, readonly) TransmitViewType type;

//已选中的联系人,存FriendModel或者GroupModel，设置只读是不让外部操作，免得数据被打乱
@property (nonatomic, strong, readonly) NSMutableArray *selectedArray;

//全部的会话，TransmitViewTypeRecentlySession存SessionModel,TransmitViewTypeFriend存FriendModel,TransmitViewTypeGroup存GroupModel
@property (nonatomic, strong) NSMutableArray *originArray;
//全部的会话，TransmitViewTypeRecentlySession存SessionModel,TransmitViewTypeFriend存FriendModel,TransmitViewTypeGroup存GroupModel
@property (nonatomic, strong) NSMutableArray *dataArray;

//索引数组, TransmitViewTypeFriend时才有(暂时不做索引)
@property (nonatomic, strong) NSMutableArray *indexArray;

//选择的数组变化
@property (nonatomic, strong) RACSubject *selectedChangeSubject;

//数据数组变化
@property (nonatomic, strong) RACSubject *dataChangeSubject;

//最近会话点击通讯录
@property (nonatomic, strong) RACSubject *clickFriendSubject;

//通讯录点击群聊
@property (nonatomic, strong) RACSubject *clickGroupSubject;


- (instancetype)initWithType:(TransmitViewType)type;


/**
 获取数据并判断是否已选中

 @param array 已选中的联系人数组
 */
- (void)getDataArrayWithSelectedArray:(NSArray*)array;


/**
 列表中选中一个

 @param model 可为SessionModel\FriendModel\GroupModel
 */
- (void)selectedOne:(id)model;

/**
 列表中取消选中一个
 
 @param model 可为SessionModel\FriendModel\GroupModel
 */
- (void)deselectedOne:(id)model;

///根据位置取消选中一个
- (void)deselectedOneAtIndex:(NSInteger)index;


/**
 融合下级页面选中的联系人

 @param array FriendModel\GroupModel
 */
- (void)addSelectedArrayFromArray:(NSArray*)array;

@end

