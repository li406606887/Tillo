//
//  PhotoBrowseModel.h
//  BGH-family
//
//  Created by Sunny on 17/2/24.
//  Copyright © 2017年 Zontonec. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(int, LookImageType) {
    NoImageType    = 1,// 没图
    SmallImageType = 2,// 小图
    BigImageType   = 3,// 大图
};

@interface PhotoBrowseModel : NSObject

/** 照片url */
@property(nonatomic, copy) NSString *URL;
/** messageModel */
@property(nonatomic, strong) MessageModel *message;
/** 类别 */
@property(nonatomic, assign) LookImageType type;
/** 大图 */
@property(nonatomic, strong) UIImage *big;
/** 小图 */
@property(nonatomic, strong) UIImage *small;

@property (nonatomic, assign) BOOL isGIF;

+ (instancetype)photoBrowseModelWith:(MessageModel *)message;

@end
