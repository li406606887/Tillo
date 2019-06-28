//
//  NSDate+AL.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2019/1/20.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "NSDate+AL.h"
#import "NSDate+Relation.h"

@implementation NSDate (AL)
#pragma mark - # 基本时间参数
- (NSUInteger)year {
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear) fromDate:self];
#else
    NSDateComponents *dayComponents = [calendar components:(NSYearCalendarUnit) fromDate:self];
#endif
    return [dayComponents year];
}

- (NSUInteger)month {
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMonth) fromDate:self];
#else
    NSDateComponents *dayComponents = [calendar components:(NSMonthCalendarUnit) fromDate:self];
#endif
    return [dayComponents month];
}

- (NSUInteger)day {
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitDay) fromDate:self];
#else
    NSDateComponents *dayComponents = [calendar components:(NSDayCalendarUnit) fromDate:self];
#endif
    return [dayComponents day];
}


- (NSUInteger)hour {
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitHour) fromDate:self];
#else
    NSDateComponents *dayComponents = [calendar components:(NSHourCalendarUnit) fromDate:self];
#endif
    return [dayComponents hour];
}

- (NSUInteger)minute {
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMinute) fromDate:self];
#else
    NSDateComponents *dayComponents = [calendar components:(NSMinuteCalendarUnit) fromDate:self];
#endif
    return [dayComponents minute];
}

- (NSUInteger)second {
    NSCalendar *calendar = [NSCalendar currentCalendar];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitSecond) fromDate:self];
#else
    NSDateComponents *dayComponents = [calendar components:(NSSecondCalendarUnit) fromDate:self];
#endif
    return [dayComponents second];
}

- (NSUInteger)weekday
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekday) fromDate:self];
    NSInteger weekday = [comps weekday] - 1;
    weekday = weekday == 0 ? 7 : weekday;
    return weekday;
}

- (NSUInteger)dayInMonth
{
    switch (self.month) {
        case 1: case 3: case 5: case 7: case 8: case 10: case 12:
            return 31;
        case 2:
            return self.isLeapYear ? 29 : 28;
    }
    return 30;
}

- (BOOL)isLeapYear {
    if ((self.year % 4  == 0 && self.year % 100 != 0) || self.year % 400 == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - # 日期格式化
/// YYYY年MM月dd日
- (NSString *)formatYMD
{
    return [NSString stringWithFormat:@"%lu年%02lu月%02lu日", (unsigned long)self.year, (unsigned long)self.month, (unsigned long)self.day];
}

/// 自定义分隔符
- (NSString *)formatYMDWithSeparate:(NSString *)separate
{
    return [NSString stringWithFormat:@"%lu%@%02lu%@%02lu", (unsigned long)self.year, separate, (unsigned long)self.month, separate, (unsigned long)self.day];
}

/// MM月dd日
- (NSString *)formatMD
{
    return [NSString stringWithFormat:@"%02lu月%02lu日", (unsigned long)self.month, (unsigned long)self.day];
}

/// 自定义分隔符
- (NSString *)formatMDWithSeparate:(NSString *)separate
{
    return [NSString stringWithFormat:@"%02lu%@%02lu", (unsigned long)self.month, separate, (unsigned long)self.day];
}

/// HH:MM:SS
- (NSString *)formatHMS
{
    return [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)self.hour, (unsigned long)self.minute, (unsigned long)self.second];
}

/// HH:MM
- (NSString *)formatHM
{
    return [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)self.hour, (unsigned long)self.minute];
}

/// 星期几
- (NSString *)formatWeekday
{
    switch([self weekday]) {
        case 1:
            return Localized(@"date_mon");
        case 2:
            return Localized(@"date_tue");
        case 3:
            return Localized(@"date_wed");
        case 4:
            return Localized(@"date_thu");
        case 5:
            return Localized(@"date_fri");
        case 6:
            return Localized(@"date_sat");
        case 7:
            return Localized(@"date_sun");
        default:
            break;
    }
    return @"";
}

/// 月份
- (NSString *)formatMonth {
    switch(self.month) {
        case 1:
            return NSLocalizedString(@"一月", nil);
        case 2:
            return NSLocalizedString(@"二月", nil);
        case 3:
            return NSLocalizedString(@"三月", nil);
        case 4:
            return NSLocalizedString(@"四月", nil);
        case 5:
            return NSLocalizedString(@"五月", nil);
        case 6:
            return NSLocalizedString(@"六月", nil);
        case 7:
            return NSLocalizedString(@"七月", nil);
        case 8:
            return NSLocalizedString(@"八月", nil);
        case 9:
            return NSLocalizedString(@"九月", nil);
        case 10:
            return NSLocalizedString(@"十月", nil);
        case 11:
            return NSLocalizedString(@"十一月", nil);
        case 12:
            return NSLocalizedString(@"十二月", nil);
        default:
            break;
    }
    return @"";
}

#pragma mark - 聊天
- (NSString *)conversaionTimeInfo {
    if ([self isToday]) {       // 今天
        
        if (self.hour < 12) {
            return [NSString stringWithFormat:@"%@ %@",Localized(@"date_am"),self.formatHM];
        } else {
            NSInteger hour = self.hour - 12;
            NSString *timeStr =  [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)hour, (unsigned long)self.minute];
            return [NSString stringWithFormat:@"%@ %@",Localized(@"date_pm"),timeStr];
        }
    }
    else if ([self isYesterday]) {      // 昨天
        return Localized(@"date_yesterday");
    }
    else if ([self isThisWeek]){        // 本周
        return self.formatWeekday;
    }
    else {
        return [self formatYMDWithSeparate:@"/"];
    }
}

/**
 *  把时间戳转换成距当前的时间
 *
 *  @return 当前日期的年
 */
+ (NSString *)distanceTimeWithBeforeTime:(double)beTime {
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"HH:mm"];
    NSString * timeStr = [df stringFromDate:beDate];
    
    [df setDateFormat:@"HH"];
    NSString * hours = [df stringFromDate:beDate];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime < 60) {//小于一分钟
        distanceStr = Localized(@"date_now");
    } else if (distanceTime <60*60) {//时间小于一个小时
        if ([hours doubleValue]<12) {
            distanceStr = [NSString stringWithFormat:@"%@ %@",Localized(@"date_am"),timeStr];
        }else {
            distanceStr = [NSString stringWithFormat:@"%@ %@",Localized(@"date_pm"),timeStr];
        }
    } else if(distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue]){//时间小于一天
        if ([hours doubleValue]<12) {
            distanceStr = [NSString stringWithFormat:@"%@ %@",Localized(@"date_am"),timeStr];
        }else {
            distanceStr = [NSString stringWithFormat:@"%@ %@",Localized(@"date_pm"),timeStr];
        }
    } else if(distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue]){
        
        if ([nowDay integerValue] - [lastDay integerValue] ==1 || ([lastDay integerValue] - [nowDay integerValue] > 10 && [nowDay integerValue] == 1)) {
            distanceStr = [NSString stringWithFormat:@"%@ %@",Localized(@"date_yesterday"),timeStr];
        }
        else{
            [df setDateFormat:@"MM-dd HH:mm"];
            distanceStr = [df stringFromDate:beDate];
        }
        
    } else if(distanceTime <24*60*60*365){
        [df setDateFormat:@"MM-dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    } else{
        [df setDateFormat:@"yyyy-MM-dd HH:mm"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}

+ (NSString *)getNowTimestamp {
    NSDate *datenow = [NSDate date];
    return [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
}

+ (int)getNowTimeBeforeMinutes:(double)betime {
    NSDate *bedate =[NSDate dateWithTimeIntervalSince1970:betime];
    NSTimeInterval time =[bedate timeIntervalSinceNow];
    
    double betweenMinutes = time/60;
    int minutes = (int)betweenMinutes;
    return abs(minutes);
}

+ (NSInteger)dateTransformTimestamp:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
//
//    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:format]; //------------将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    return timeSp*1000;;
}
@end
