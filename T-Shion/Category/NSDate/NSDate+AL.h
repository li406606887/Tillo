//
//  NSDate+AL.h
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/20.
//  Copyright © 2019年 With_Dream. All rights reserved.
//


@interface NSDate (AL)

#pragma mark - 基本时间参数
@property (nonatomic, assign, readonly) NSUInteger year;
@property (nonatomic, assign, readonly) NSUInteger month;
@property (nonatomic, assign, readonly) NSUInteger day;
@property (nonatomic, assign, readonly) NSUInteger hour;
@property (nonatomic, assign, readonly) NSUInteger minute;
@property (nonatomic, assign, readonly) NSUInteger second;
/// 时期几，整数
@property (nonatomic, assign, readonly) NSUInteger weekday;
/// 当前月份的天数
@property (nonatomic, assign, readonly) NSUInteger dayInMonth;
/// 是不是闰年
@property (nonatomic, assign, readonly) BOOL isLeapYear;

#pragma mark - 日期格式化
/// YYYY年MM月dd日
- (NSString *)formatYMD;
/// 自定义分隔符
- (NSString *)formatYMDWithSeparate:(NSString *)separate;
/// MM月dd日
- (NSString *)formatMD;
/// 自定义分隔符
- (NSString *)formatMDWithSeparate:(NSString *)separate;
/// HH:MM:SS
- (NSString *)formatHMS;
/// HH:MM
- (NSString *)formatHM;
/// 星期几
- (NSString *)formatWeekday;
/// 月份
- (NSString *)formatMonth;

#pragma mark - 聊天
- (NSString *)conversaionTimeInfo;

/*
 *  把时间戳转换成距当前的时间
 *  @return 当前日期的年
 */
+ (NSString *)distanceTimeWithBeforeTime:(double)beTime;

/*
 *  把时间戳转换成距当前的时间
 *  @return 当前日期的年
 */
+ (NSString *)getNowTimestamp;
/*
 *  把时间戳转换成距当前时间的分钟
 *  @return 相距现在时间多少分钟
 */
+ (int)getNowTimeBeforeMinutes:(double)betime;
/*
 *  把时间转换时间戳
 *  @return 时间戳
 */
+ (NSInteger)dateTransformTimestamp:(NSString*)format;
@end

