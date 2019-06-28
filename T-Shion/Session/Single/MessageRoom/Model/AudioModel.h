//
//  AudioModel.h
//  T-Shion
//
//  Created by together on 2018/5/7.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioModel : NSObject
@property (copy, nonatomic) NSString *ID;
@property (copy, nonatomic) NSString *createAt;
@property (copy, nonatomic) NSString *extensions;
@property (copy, nonatomic) NSString *filename;
@property (copy, nonatomic) NSString *fileHash;
@property (copy, nonatomic) NSString *mimeType;
@property (copy, nonatomic) NSString *size;
@property (copy, nonatomic) NSString *url;
@property (copy, nonatomic) NSString *duration;
@property (copy, nonatomic) NSString *filePath;
@end
