//
//  FMDBManager.m
//  T-Shion
//
//  Created by together on 2018/4/24.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "FMDBManager.h"
#import "NetworkModel.h"
#import <Photos/Photos.h>

static FMDBManager *mannager;

@implementation FMDBManager
#pragma mark - 懒加载初始化数据库对象
- (FMDatabaseQueue *)DBQueue {
    if (!_DBQueue) {
        //wsp修改 切换帐号导致数据库取错问题 2019.3.18
        if (![FMDBManager DBMianPath]) {
            return nil;
        }
        NSString *path = _DBQueue.path;
        NSString *dbName = [NSString stringWithFormat:@"Aillo.db"];
        if (![path containsString:dbName]) {
            NSString *tablePath = [[FMDBManager DBMianPath] stringByAppendingPathComponent:dbName];
            _DBQueue = [FMDatabaseQueue databaseQueueWithPath:tablePath];
            [_DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
                // 打开数据库
                if ([db open]) {//  用户数据数据库表
                    BOOL userInfo = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS UserInfo (name TEXT , sex INT16, mobile TEXT NOT NULL, avatar TEXT, ID TEXT NOT NULL, introduce TEXT, address TEXT ,dialCode TEXT, region TEXT)"];
                    if (userInfo) {
                        // NSLog(@"创建userInfo表成功");
                    } else {
                        NSLog(@"创建userInfo表失败");
                    }
                    //  房间表
                    BOOL room = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Room (room_id TEXT NOT NULL , type text NOT NULL, friend_id TEXT,group_id TEXT)"];
                    if (room) {
                        // NSLog(@"创建Room表成功");
                    } else {
                        NSLog(@"创建Room表失败");
                    }
                    //  通讯录表
                    BOOL friend = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Friend (friend_id TEXT NOT NULL, room_id TEXT NOT NULL, mobile TEXT NOT NULL, sex TEXT, name TEXT, distub TEXT, block TEXT, avatar TEXT, top TEXT, show_name TEXT, nick_name TEXT, region TEXT, country TEXT, dialCode TEXT)"];
                    if (friend) {
                        //                        NSLog(@"创建Fiend表成功");
                    } else {
                        NSLog(@"创建Fiend表失败");
                    }
                    //  用户群组数据库表
                    BOOL group = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS GroupList (room_id TEXT NOT NULL, name TEXT, avatar TEXT, owner TEXT NOT NULL, deflag TEXT)"];
                    if (group) {
                        //                        NSLog(@"创建Group表成功");
                    } else {
                        NSLog(@"创建Group表失败");
                    }
                    
                    //  会话数据库表
                    BOOL conversation = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS Conversation (room_id TEXT NOT NULL, text TEXT , unreadcount INT, offline_count INT, timestamp INTEGER, type TEXT ,isMentioned BOOLEAN)"];
                    if (conversation) {
                        //                        NSLog(@"创建Conversation表成功");
                    } else {
                        NSLog(@"创建Conversation表失败");
                    }
                    
                    //  未发送表
                    BOOL UnsendMessage = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS UnsendMessage (room_id TEXT NOT NULL, message_id TEXT NOT NULL, content TEXT, sender_id TEXT, backId TEXT,type TEXT NOT NULL, timestamp INTEGER, file_name TEXT, duration TEXT, source_id TEXT, send_state TEXT, read_state TEXT, big_image TEXT,roomType TEXT , atModelList TEXT, locationInfo TEXT, isCryptSeesion INT32 DEFAULT 0)"];
                    if (UnsendMessage) {
                        //                        NSLog(@"创建UnsendMessage表成功");
                    } else {
                        NSLog(@"创建UnsendMessage表失败");
                    }
                    
                    BOOL roomSetting = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS RoomSetting (room_id TEXT NOT NULL, top BOOLEAN, disturb BOOLEAN, blacklistFlag BOOLEAN)"];
                    if (roomSetting) {
                        //                        NSLog(@"创建roomSetting表成功");
                    } else {
                        NSLog(@"创建roomSetting表失败");
                    }
                    
                    
                    //扩展被@字段
                    BOOL atResult = [FMDBManager addColumn:@"isMentioned" columnType:@"BOOLEAN" inTableWithName:@"Conversation" dataBase:db];
                    if (!atResult) {
                        NSLog(@"向Conversation表添加isMentioned字段失败");
                    }
                    
                    //扩展draftContent字段
                    BOOL draftContentResult = [FMDBManager addColumn:@"draftContent" columnType:@"TEXT" inTableWithName:@"Conversation" dataBase:db];
                    if (!draftContentResult) {
                        NSLog(@"向Conversation表添加draftContent字段失败");
                    }
                    
                    //扩展draftAtList字段
                    BOOL draftAtListResult = [FMDBManager addColumn:@"draftAtList" columnType:@"TEXT" inTableWithName:@"Conversation" dataBase:db];
                    if (!draftAtListResult) {
                        NSLog(@"向Conversation表添加draftAtList字段失败");
                    }
                
                    BOOL kickUser = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS KickUserLog (id integer PRIMARY KEY AUTOINCREMENT, user_id TEXT NOT NULL, userName TEXT, requestURL TEXT, timeStr TEXT, deviceId TEXT,token TEXT NOT NULL)"];
                    
                    if (kickUser) {
                
                    } else {
                        NSLog(@"创建kickUser表失败");
                    }
                    
                    BOOL MpushConnectLog = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS MpushConnectLog (id integer PRIMARY KEY AUTOINCREMENT, user_id TEXT NOT NULL, userName TEXT, requestURL TEXT, timeStr TEXT, deviceId TEXT,token TEXT NOT NULL)"];
                    
                    if (MpushConnectLog) {
                        
                    } else {
                        NSLog(@"创建MpushConnectLog表失败");
                    }
                    
                    BOOL NotifySet = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS NotifySet ( user_id TEXT NOT NULL, notify_switch BOOLEN DEFAULT 1,notify_voice BOOLEN DEFAULT 1,notify_shock BOOLEN DEFAULT 1, notify_switch_details BOOLEN DEFAULT 1, notify_rtc_switch BOOLEN DEFAULT 1)"];
                    if (!NotifySet) {
                        NSLog(@"创建NotifySet表失败");
                    }
                    
                    BOOL FirendRequest = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS FirendRequest (uid TEXT NOT NULL,requestId TEXT NOT NULL,data TEXT NOT NULL)"];
                    if (!FirendRequest) {
                        NSLog(@"创建FirendRequest表失败");
                    }
                }
            }];
        }
    }
    return _DBQueue;
}

+ (NSString *)DBMianPath {
    //wsp修改 切换帐号导致数据库取错问题 2019.3.18
    NSString *userPath = [TShionSingleCase doucumentPath];
    if (!userPath) {
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    BOOL isDirExist = [fileManager fileExistsAtPath:userPath isDirectory:&isDir];
    if(!(isDirExist && isDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:userPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
    }
    
    NSString *headPath = [userPath stringByAppendingPathComponent:@"Head"];
    BOOL isHeadDir = FALSE;
    BOOL isHeadDirExist = [fileManager fileExistsAtPath:headPath isDirectory:&isHeadDir];
    if(!(isHeadDirExist && isHeadDir)) {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:headPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
        NSLog(@"创建文件夹成功,文件路径%@",headPath);
    }
    
    return userPath;
}

+ (NSString *)getMessagePathWithMessage:(MessageModel*)model {
    NSString *documentPath;
    NSString *path = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:model.roomId];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([model.type isEqualToString:@"audio"]) {
        NSString *audioPath = [path stringByAppendingPathComponent:@"Audio"];
        BOOL isAudioDir = FALSE;
        BOOL isAudioDirExist = [fileManager fileExistsAtPath:audioPath isDirectory:&isAudioDir];
        if(!(isAudioDirExist && isAudioDir)) {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:audioPath withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"创建文件夹失败！");
            }
        }
        documentPath = audioPath;
    } else if ([model.type isEqualToString:@"image"]) {
        documentPath = [FMDBManager getImagePathWithFilePath:path];
    } else if ([model.type isEqualToString:@"file"]) {
        NSString *filePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"File"];
        BOOL isFileDir = FALSE;
        BOOL isFileDirExist = [fileManager fileExistsAtPath:filePath isDirectory:&isFileDir];
        if(!(isFileDirExist && isFileDir)) {
            BOOL bCreateDir = [fileManager createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
            if(!bCreateDir){
                NSLog(@"创建文件夹失败！");
            }
        }
        documentPath = filePath;
    } else if ([model.type isEqualToString:@"location"]) {
        documentPath = [FMDBManager getMapSnapshotPathWithFilePath:path];
    } else if ([model.type isEqualToString:@"video"]) {
        documentPath = [FMDBManager getVideoPathWithFilePath:path];
    }
    
    return documentPath;
}

+ (NSString *)getImagePathWithFilePath:(NSString *)filePath {
    NSString *imagePath = [filePath stringByAppendingPathComponent:@"Images"];
    BOOL isImageDir = FALSE;
    BOOL isImageDirExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isImageDir];
    if(!(isImageDirExist && isImageDir)) {
        BOOL bCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
    }
    return imagePath;
}

+ (NSString *)getMapSnapshotPathWithFilePath:(NSString *)filePath {
    NSString *imagePath = [filePath stringByAppendingPathComponent:@"MapSnapshot"];
    BOOL isImageDir = FALSE;
    BOOL isImageDirExist = [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:&isImageDir];
    if(!(isImageDirExist && isImageDir)) {
        BOOL bCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:imagePath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
    }
    return imagePath;
}

+ (NSString *)getVideoPathWithFilePath:(NSString *)filePath {
    NSString *videoPath = [filePath stringByAppendingPathComponent:@"Video"];
    BOOL isVideoDir = FALSE;
    BOOL isVideoDirExist = [[NSFileManager defaultManager] fileExistsAtPath:videoPath isDirectory:&isVideoDir];
    if(!(isVideoDirExist && isVideoDir)) {
        BOOL bCreateDir = [[NSFileManager defaultManager] createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            NSLog(@"创建文件夹失败！");
        }
    }
    return videoPath;
}

+ (FMDBManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mannager = [[FMDBManager alloc] init];
    });
    return mannager;
}

+ (BOOL)seletedFileIsSaveWithPath:(MessageModel *)model {
    BOOL state = NO;
    NSString *path;
    if (model.fileName.length<1) {
        return state;
    }
    if ([model.type isEqualToString:@"audio"]) {
        path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    } else if ([model.type isEqualToString:@"image"]) {
        path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    } else if ([model.type isEqualToString:@"file"]) {
        path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    } else if ([model.type isEqualToString:@"location"]) {
        path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    } else if ([model.type isEqualToString:@"video"]) {
        path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        state = YES;
    }
    if (state == NO) {
        if ([model.type isEqualToString:@"file"]) {
            path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.content];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                state = YES;
            }
        }
    }
    return state;
}

+ (BOOL)seletedFileIsSaveWithFilePath:(NSString *)filePath {
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

+ (void)updateUnsendMessageStatus {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM UnsendMessage WHERE send_state = 3"];
        while (result.next) {
            NSString *roomid = [result stringForColumn:@"room_id"];
            NSString *msgid = [result stringForColumn:@"backId"];
            if (roomid.length>0&&msgid.length>0) {
                NSString *sqlStr = [NSString stringWithFormat:@"UPDATE Message_%@ SET send_state = 2 WHERE backId = ?",roomid];
                BOOL success = [db executeUpdate:sqlStr,msgid];
                if (success) {
                    NSLog(@"更改成功");
                }
                [db executeUpdate:@"UPDATE UnsendMessage SET send_state = 2 WHERE backId = ?",msgid];
            }
        }
        [result close];
    }];
}

+ (void)resendUnsendMessage {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM UnsendMessage WHERE send_state = 2"];
        while (result.next) {
            NSString *roomid = [result stringForColumn:@"room_id"];
            NSString *msgid = [result stringForColumn:@"backId"];
            if (roomid.length>0&&msgid.length>0) {
                MessageModel *model = [MessageModel initMessageWithResult:result];
                [NetworkModel sendMessageWithMessage:model];
            }
        }
        [result close];
    }];
}
/* 查询房间设置数据
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (NSDictionary *)selectedRoomSettingWithRoomId:(NSString *)roomId {
    __block NSMutableDictionary *dictionary;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",roomId];
        if (result.next) {
            BOOL disturb = [result boolForColumn:@"disturb"];
            BOOL top = [result boolForColumn:@"top"];
            BOOL blacklistFlag = [result boolForColumn:@"blacklistFlag"];
            [dictionary setValue:@(disturb) forKey:@"disturb"];
            [dictionary setValue:@(top) forKey:@"top"];
            [dictionary setValue:@(blacklistFlag) forKey:@"blacklistFlag"];
        }
        [result close];
    }];
    return dictionary;
}

/* 设置房间是否免打扰
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (BOOL)selectedRoomDisturbWithRoomId:(NSString *)roomId {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",roomId];
        if (result.next) {
            state = [result boolForColumn:@"disturb"];
        }
        [result close];
    }];
    return state;
}

/* 设置房间是否置顶
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (BOOL)selectedRoomTopWithRoomId:(NSString *)roomId {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",roomId];
        if (result.next) {
            state = [result boolForColumn:@"top"];
        }
        [result close];
    }];
    return state;
}

/* 设置房间数据
 * @prarm timestamp 时间戳  tableName 表名字
 */
+ (void)updateRoomSettingWithRoomId:(NSString *)roomId disturb:(BOOL)disturb top:(BOOL)top {
    __block BOOL result;
    [self checkUserInfoWithRoomId:roomId isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            result = [db executeUpdate:@"INSERT INTO RoomSetting (room_id, disturb, top ) VALUES (?, ?, ?)",roomId,@(disturb),@(top)];
            if (result) {
                NSLog(@"房间设置参数插入成功");
            }
        }else {
            result = [db executeUpdate:@"UPDATE RoomSetting SET disturb = ?, top = ? WHERE room_id = ?",@(disturb),@(top),roomId];
            if (result) {
                NSLog(@"房间设置参数更新成功");
            }
        }
    }];
}
/*
 * 查询房间是否存在
 */
+ (void)setRoomBlackWithRoomId:(NSString *)roomId blacklistFlag:(BOOL)blacklistFlag {
    __block BOOL result;
    [self checkUserInfoWithRoomId:roomId isExist:^(BOOL isExist, FMDatabase *db) {
        if (!isExist) {
            result = [db executeUpdate:@"INSERT INTO RoomSetting (room_id,blacklistFlag) VALUES (?, ?)",roomId,@(blacklistFlag)];
            if (result) {
                NSLog(@"房间设置参数插入成功");
            }
        }else {
            result = [db executeUpdate:@"UPDATE RoomSetting SET blacklistFlag = ? WHERE room_id = ?",@(blacklistFlag),roomId];
            if (result) {
                NSLog(@"房间设置参数更新成功");
            }
        }
    }];
}
/*
 * 查询房间是否存在
 */
+ (BOOL)selectedRoomBlackWithRoomId:(NSString *)roomId {
    __block BOOL state = NO;
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        FMResultSet *result = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?",roomId];
        if (result.next) {
            state = [result boolForColumn:@"blacklistFlag"];
        }
        [result close];
    }];
    return state;
}
/*
 * 查询房间是否存在
 */
+ (void)checkUserInfoWithRoomId:(NSString *)roomId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist {
    [[FMDBManager shared].DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        BOOL e = NO;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM RoomSetting WHERE room_id = ?", roomId];
        while (result.next) {
            e = YES;
            NSString *data = [result stringForColumnIndex:0];
            NSLog(@"%@",data);
            break;
        }
        [result close];
        exist(e, db);
    }];
}

/**
 *  获得刚才添加到【相机胶卷】中的图片
 */
+ (PHFetchResult<PHAsset *> *)createdAssets:(UIImage *)image{
    __block NSString *createdAssetId = nil;
    
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    
    if (createdAssetId == nil) return nil;
    
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}

/*
 *  获得【自定义相册】
 */
+ (PHAssetCollection *)createdCollection {
    // 获取软件的名字作为相册的标题
    NSString *title = @"Aillo";
    // 获得所有的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            return collection;
        }
    }
    // 代码执行到这里，说明还没有自定义相册
    __block NSString *createdCollectionId = nil;
    // 创建一个新的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    if (createdCollectionId == nil){
        return nil;
    }else {// 创建完毕后再取出相册
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdCollectionId] options:nil].firstObject;
    }
}

/*
 *  保存图片到相册
 */
+ (NSString *)saveImageIntoAlbum:(UIImage *)image {
    // 获得相片
    PHFetchResult<PHAsset *> *createdAssets = [self createdAssets:image];
    
    // 获得相册
    PHAssetCollection *createdCollection = [self createdCollection];
    
    if (createdAssets == nil || createdCollection == nil) {
        NSLog(@"保存失败！");
        return @"";
    }
   
    // 将相片添加到相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 保存结果
    if (error) {
        NSLog(@"保存失败！");
        return @"";
    } else {
        NSLog(@"%@",createdAssets);
        if (createdAssets.count>0) {
            PHAsset *asset  = createdAssets[0];
            NSString *fileName = asset.localIdentifier;
            NSLog(@"保存成功！ filename:%@",fileName);
            return fileName;
        }
        return @"";
    }
}

+ (void)deleteImageWithImageName:(NSString *)fileName {
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 查找set
        PHFetchResult<PHAsset *> * result = [PHAsset fetchAssetsWithLocalIdentifiers:@[fileName] options:nil];
        [PHAssetChangeRequest deleteAssets:result];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"删除成功！");
        } else {
            NSLog(@"删除失败：%@", error);
        }
    }];
        
//        if (asset.mediaType == PHAssetMediaTypeImage) {
//            //得到一个图片类型资源
//        }else if (asset.mediaType == PHAssetMediaTypeVideo) {
//            //得到一个视频类型资源
//        }else if (asset.mediaType == PHAssetMediaTypeAudio) {
//            //音频，PHAsset的mediaType属性有三个枚举值，笔者对PHAssetMediaTypeAudio暂时没有进行处理
//        }

}
//- (void)save {
//    /*
//     requestAuthorization方法的功能
//     1.如果用户还没有做过选择，这个方法就会弹框让用户做出选择
//     1> 用户做出选择以后才会回调block
//
//     2.如果用户之前已经做过选择，这个方法就不会再弹框，直接回调block，传递现在的授权状态给block
//     */
//
//    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
//
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            switch (status) {
//                case PHAuthorizationStatusAuthorized: {
//                    //  保存图片到相册
//                    [self saveImageIntoAlbum];
//                    break;
//                }
//
//                case PHAuthorizationStatusDenied: {
//                    if (oldStatus == PHAuthorizationStatusNotDetermined) return;
//                    NSLog(@"提醒用户打开相册的访问开关");
//                    break;
//                }
//
//                case PHAuthorizationStatusRestricted: {
//                    ShowWinMessage(@"因系统原因，无法访问相册!");
//                    break;
//                }
//
//                default:
//                    break;
//            }
//        });
//    }];
//}


#pragma mark - 新增字段
+ (BOOL)addColumn:(NSString *)column
       columnType:(NSString *)columnType
  inTableWithName:(NSString *)tableName
         dataBase:(FMDatabase *)db {
    if (![db columnExists:column inTableWithName:tableName]) {
        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tableName,column,columnType];
        BOOL worked = [db executeUpdate:alertStr];
        return worked;
    }
    return YES;
}

@end
