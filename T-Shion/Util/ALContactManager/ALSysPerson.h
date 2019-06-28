//
//  ALSysPerson.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/9.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>

@class ALSysPhone, ALSysEmail, ALSysMessage, ALSysContactRelation , ALSysSocialProfile, ALSysBirthday, ALSysUrlAddress , ALSysAddress;

typedef NS_ENUM(NSUInteger, ALContactType)
{
    ALContactTypePerson = 0,
    ALContactTypeOrigination,
};

@interface ALSysPerson : NSObject
/**
 是否被选中
 */
@property (nonatomic, assign) BOOL selected;

/**
 联系人类型
 */
@property (nonatomic) ALContactType contactType;

/**
 姓名
 */
@property (nonatomic, copy) NSString *fullName;

/**
 姓
 */
@property (nonatomic, copy) NSString *familyName;

/**
 名
 */
@property (nonatomic, copy) NSString *givenName;

/**
 姓名前缀
 */
@property (nonatomic, copy) NSString *namePrefix;

/**
 姓名后缀
 */
@property (nonatomic, copy) NSString *nameSuffix;

/**
 昵称
 */
@property (nonatomic, copy) NSString *nickname;

/**
 中间名
 */
@property (nonatomic, copy) NSString *middleName;

/**
 公司
 */
@property (nonatomic, copy) NSString *organizationName;

/**
 部门
 */
@property (nonatomic, copy) NSString *departmentName;

/**
 职位
 */
@property (nonatomic, copy) NSString *jobTitle;

/**
 备注
 */
@property (nonatomic, copy) NSString *note;

/**
 名的拼音或音标
 */
@property (nonatomic, copy) NSString *phoneticGivenName;

/**
 中间名的拼音或音标
 */
@property (nonatomic, copy) NSString *phoneticMiddleName;

/**
 姓的拼音或音标
 */
@property (nonatomic, copy) NSString *phoneticFamilyName;

/**
 头像 Data
 */
@property (nonatomic, copy) NSData *imageData;

/**
 头像图片
 */
@property (nonatomic, strong) UIImage *image;

/**
 头像的缩略图 Data
 */
@property (nonatomic, copy) NSData *thumbnailImageData;

/**
 头像缩略图片
 */
@property (nonatomic, strong) UIImage *thumbnailImage;

/**
 获取创建当前联系人的时间
 */
@property (nonatomic, strong) NSDate *creationDate;

/**
 获取最近一次修改当前联系人的时间
 */
@property (nonatomic, strong) NSDate *modificationDate;

/**
 电话号码数组
 */
@property (nonatomic, copy) NSArray <ALSysPhone *> *phones;

/**
 邮箱数组
 */
@property (nonatomic, copy) NSArray <ALSysEmail *> *emails;

/**
 地址数组
 */
@property (nonatomic, copy) NSArray <ALSysAddress *> *addresses;

/**
 生日对象
 */
@property (nonatomic, strong) ALSysBirthday *birthday;

/**
 即时通讯数组
 */
@property (nonatomic, copy) NSArray <ALSysMessage *> *messages;

/**
 社交数组
 */
@property (nonatomic, copy) NSArray <ALSysSocialProfile *> *socials;

/**
 关联人数组
 */
@property (nonatomic, copy) NSArray <ALSysContactRelation *> *relations;

/**
 url数组
 */
@property (nonatomic, copy) NSArray <ALSysUrlAddress *> *urls;

/**
 便利构造 （Contacts）
 
 @param contact 通讯录
 @return 对象
 */
- (instancetype)initWithCNContact:(CNContact *)contact;

@end


#pragma mark - 电话
@interface ALSysPhone : NSObject

/**
 电话
 */
@property (nonatomic, copy) NSString *phone;

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;


@end;

#pragma mark - 电子邮件
@interface ALSysEmail : NSObject

/**
 邮箱
 */
@property (nonatomic, copy) NSString *email;

/**
 标签
 */
@property (nonatomic, copy) NSString *label;


/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;


@end


#pragma mark - 地址
@interface ALSysAddress : NSObject

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 街道
 */
@property (nonatomic, copy) NSString *street;

/**
 城市
 */
@property (nonatomic, copy) NSString *city;

/**
 州
 */
@property (nonatomic, copy) NSString *state;

/**
 邮政编码
 */
@property (nonatomic, copy) NSString *postalCode;

/**
 城市
 */
@property (nonatomic, copy) NSString *country;

/**
 国家代码
 */
@property (nonatomic, copy) NSString *ISOCountryCode;

/**
 标准格式化地址
 */
@property (nonatomic, copy) NSString *formatterAddress NS_AVAILABLE_IOS(9_0);

/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;


@end

#pragma mark - 生日
@interface ALSysBirthday : NSObject

/**
 生日日期
 */
@property (nonatomic, strong) NSDate *brithdayDate;

/**
 农历标识符（chinese）
 */
@property (nonatomic, copy) NSString *calendarIdentifier;

/**
 纪元
 */
@property (nonatomic, assign) NSInteger era;

/**
 年
 */
@property (nonatomic, assign) NSInteger year;

/**
 月
 */
@property (nonatomic, assign) NSInteger month;

/**
 日
 */
@property (nonatomic, assign) NSInteger day;

/**
 便利构造 （Contacts）
 
 @param contact 通讯录
 @return 对象
 */
- (instancetype)initWithCNContact:(CNContact *)contact;



@end


#pragma mark - 即时通讯
@interface ALSysMessage : NSObject

/**
 即时通讯名字（QQ）
 */
@property (nonatomic, copy) NSString *service;

/**
 账号
 */
@property (nonatomic, copy) NSString *userName;

/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;



@end

#pragma mark - 社交

@interface ALSysSocialProfile : NSObject

/**
 社交名字（Facebook）
 */
@property (nonatomic, copy) NSString *service;

/**
 账号
 */
@property (nonatomic, copy) NSString *username;

/**
 url字符串
 */
@property (nonatomic, copy) NSString *urlString;

/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

@end

#pragma mark - URL
@interface ALSysUrlAddress : NSObject

/**
 标签
 */
@property (nonatomic, copy) NSString *label;

/**
 url字符串
 */
@property (nonatomic, copy) NSString *urlString;

/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;

@end


#pragma mark - 关联人
@interface ALSysContactRelation : NSObject

/**
 标签（父亲，朋友等）
 */
@property (nonatomic, copy) NSString *label;

/**
 名字
 */
@property (nonatomic, copy) NSString *name;

/**
 便利构造 （Contacts）
 
 @param labeledValue 标签和值
 @return 对象
 */
- (instancetype)initWithLabeledValue:(CNLabeledValue *)labeledValue;


@end

#pragma mark - 排序分组模型
@interface ALSectionPerson : NSObject

@property (nonatomic, copy) NSString *key;

@property (nonatomic, copy) NSArray <ALSysPerson *> *persons;

@end
