//
//  PhotoBrowseModel.m
//  BGH-family
//
//  Created by Sunny on 17/2/24.
//  Copyright © 2017年 Zontonec. All rights reserved.
//

#import "PhotoBrowseModel.h"

@implementation PhotoBrowseModel
+ (instancetype)photoBrowseModelWith:(MessageModel *)message {
    PhotoBrowseModel *model = [[self alloc] init];
    model.message = message;
    NSString *bigimage = [FMDBManager selectBigImageWithMessageModel:message];
    NSLog(@"%@",message.fileName);
    if (bigimage.length > 5) {
        NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
        
        if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //如果存在本地大图图片
            NSData *data = [NSData dataWithContentsOfFile:path];
            BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:data];
            if (isGif) {
//                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                UIImage *gifImage = [SDAnimatedImage sd_imageWithGIFData:data];
                model.big = (id)gifImage;
                model.isGIF = YES;
            } else {
               model.big = [UIImage imageWithContentsOfFile:path];
            }
            model.type = BigImageType;
            
//            if ([message.fileName hasSuffix:@".gif"]) {
//                NSData *data = [NSData dataWithContentsOfFile:path];
//                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
//                model.big = (id)image;
//            }
//            else
//                model.big = [UIImage imageWithContentsOfFile:path];
//
//            model.type = BigImageType;
        } else {
            model.URL = [NSString ym_fileUrlStringWithSourceId:message.sourceId];
            model.type = NoImageType;
        }
    } else {
        //没有本地大图图片先展示小图片
        NSString *path = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
        
        model.URL = [NSString ym_fileUrlStringWithSourceId:message.sourceId];
        if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]) {
            
            NSData *data = [NSData dataWithContentsOfFile:path];
            BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:data];

            if (isGif) {
//                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
                UIImage *gifImage = [SDAnimatedImage sd_imageWithGIFData:data];
                model.small = (id)gifImage;
                model.isGIF = YES;
            } else {
                model.small = [UIImage imageWithContentsOfFile:path];
            }
            
//            if ([message.fileName hasSuffix:@".gif"]) {
//                NSData *data = [NSData dataWithContentsOfFile:path];
//                FLAnimatedImage *image = [FLAnimatedImage animatedImageWithGIFData:data];
//                model.small = (id)image;
//            }
//            else
//                model.small = [UIImage imageWithContentsOfFile:path];
            
            model.type = SmallImageType;
        } else {
            model.type = NoImageType;
        }
    }
   
    return model;
}

@end
