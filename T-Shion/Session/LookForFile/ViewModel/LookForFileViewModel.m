//
//  LookForFileViewModel.m
//  AilloTest
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForFileViewModel.h"

@implementation LookForFileViewModel
- (RACSubject *)refreshTableSubject {
    if (!_refreshTableSubject) {
        _refreshTableSubject = [RACSubject subject];
    }
    return _refreshTableSubject;
}

- (NSMutableArray *)assetArray {
    if (!_assetArray) {
        _assetArray = [NSMutableArray array];
    }
    return _assetArray;
}

- (NSMutableArray *)assetIndexArray {
    if (!_assetIndexArray) {
        _assetIndexArray = [NSMutableArray array];
        NSDictionary *dictionary = [FMDBManager selectImageOrVideoWithRoom:self.roomId messageId:nil];
        NSArray *array = dictionary.allKeys;
        if (array.count > 0) {
            NSString *key = array[0];
            NSArray *data = [dictionary objectForKey:key];
            if (data.count>0) {
                NSArray *sortArray = [self messageSortWithArray:data index:self.assetIndexArray];
                [self.assetArray addObjectsFromArray:sortArray];
            }
        }
    }
    return _assetIndexArray;
}

- (NSMutableArray *)fileArray {
    if (!_fileArray) {
        _fileArray = [NSMutableArray array];
    }
    return _fileArray;
}

- (NSMutableArray *)fileIndexArray {
    if (!_fileIndexArray) {
        _fileIndexArray = [NSMutableArray array];
        NSArray *array = [FMDBManager selectFileWithRoom:self.roomId keyWord:nil];
        if (array.count > 0) {
                NSArray *sortArray = [self messageSortWithArray:array index:self.fileIndexArray];
                [self.fileArray addObjectsFromArray:sortArray];
        }
    }
    return _fileIndexArray;
}

- (NSArray *)messageSortWithArray:(NSArray *)array index:(NSMutableArray *)indexArray {
    [indexArray removeAllObjects];
    NSMutableArray *sortArray = [NSMutableArray array];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (MessageModel *msg in array) {
        if (msg.msgType == MESSAGE_File) {
            if (self.type != 1) {
                MemberModel *member = [FMDBManager selectedMemberWithRoomId:self.roomId memberID:msg.sender];
                msg.member = member;
            }else {
                msg.senderInfo = [FMDBManager selectFriendTableWithRoomId:self.roomId];
            }
        }
        int timestamp = [msg.timestamp doubleValue]/1000;
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitHour | NSCalendarUnitDay fromDate:msgDate];
        NSInteger billYear = [components year];
        NSInteger billMonth = [components month];
        NSString *key = [NSString stringWithFormat:@"%ld-%ld",billYear,billMonth];
        NSMutableArray *monthArray = [dic objectForKey:key];
        if (!monthArray) {
            monthArray = [NSMutableArray array];
            [dic setObject:monthArray forKey:key];
        }
        [monthArray addObject:msg];
        if (![indexArray containsObject:key]) {
            [indexArray addObject:key];
        }
    }
    for (NSString *key in indexArray) {
        NSArray *monthArray = [dic objectForKey:key];
        [sortArray addObject:monthArray];
    }
    
    return sortArray;
}

//    NSDate *nowDate = [NSDate new];
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitHour | NSCalendarUnitDay fromDate:nowDate];
//    NSInteger currentYear = [components year];
//    NSInteger currentMonth = [components month];

- (RACSubject *)clickFileSubject {
    if (!_clickFileSubject) {
        _clickFileSubject = [RACSubject subject];
    }
    return _clickFileSubject;
}

- (RACSubject *)clickAssetSubject {
    if (!_clickAssetSubject) {
        _clickAssetSubject = [RACSubject subject];
    }
    return _clickAssetSubject;
}
@end
