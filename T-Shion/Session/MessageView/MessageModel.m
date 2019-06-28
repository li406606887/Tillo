
//
//  MessageModel.m
//  T-Shion
//
//  Created by together on 2018/7/5.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageModel.h"
#import "AtManModel.h"

#define MAX_IMAGE_WH 140.0
#define MAX_IMAGE_HG 140.0

static CGFloat kMaxVideoWidth = 150;
static CGFloat kMaxVideoHeight = 150;

@implementation MessageModel

- (void)setSender:(NSString *)sender{
    _sender = sender;
    if ([sender isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]]) {
        _sendType = SelfSender;
    }else {
        _sendType = OtherSender;
    }
}

- (NSString *)times {
    double timeInterval = [self.timestamp doubleValue]/ 1000.0;
    return [NSDate distanceTimeWithBeforeTime:timeInterval];
}

- (void)setType:(NSString *)type {
    _type = type;
    if ([type isEqualToString:@"text"]) {
        _msgType = MESSAGE_TEXT;
    } else if ([type isEqualToString:@"audio"]) {
        _msgType = MESSAGE_AUDIO;
    } else if ([type isEqualToString:@"image"]) {
        _msgType = MESSAGE_IMAGE;
    } else if ([type isEqualToString:@"file"]) {
        _msgType = MESSAGE_File;
    } else if ([type isEqualToString:@"rtc_video"]) {
        _msgType = MESSAGE_RTC;
    } else if ([type isEqualToString:@"rtc_audio"]) {
        _msgType = MESSAGE_RTC;
    } else if ([type isEqualToString:@"location"]) {
        _msgType = MESSAGE_Location;
    } else if ([type isEqualToString:@"passFriend"]) {
        _msgType = MESSAGE_Passfriend;
    } else if ([type isEqualToString:@"system"]) {
        _msgType = MESSAGE_System;
    } else if ([type isEqualToString:@"withdraw"]) {
        _msgType = MESSAGE_Withdraw;
        self.contentHeight = 36;
    } else if ([type isEqualToString:@"video"]) {
        _msgType = MESSAGE_Video;
    } else if ([type isEqualToString:@"card"]) {
        _msgType = MESSAGE_Contacts_Card;
    }else {
        //add by wsp for unKnowMSG 2019.3.5
        if (type.length > 0) {
            _msgType = -1;
        }
    }
}
#pragma mark 计算高度
- (CGFloat)contentHeight {
    if (!_contentHeight) {
        switch (self.msgType) {
            case MESSAGE_TEXT:
                _contentHeight = [self getTextSize].height;
                break;
            case MESSAGE_AUDIO:
                _contentHeight = [self voiceHeight];
                break;
            case MESSAGE_IMAGE:
                _contentHeight = [self getImageSize].height;
                break;
            case MESSAGE_RTC:
                _contentHeight = [self rtcHeight];
                break;
            case MESSAGE_System:
                _contentHeight = [self getSystemSize].height;
                break;
            case MESSAGE_File:
                _contentHeight = 70;
                break;
            case MESSAGE_Withdraw:
            case MESSAGE_New_Msg:
                _contentHeight = 36;
                break;
            case MESSAGE_Location:
                _contentHeight = 140;
                break;
            case MESSAGE_Contacts_Card:
                _contentHeight = 135;
                break;
            case MESSAGE_Video:
                _contentHeight = [self getVideoSize].height;
                break;
                
            default:
                break;
        }
    }
    return _contentHeight;
}

- (CGSize )getTextSize {
    YYTextView *contentView = [[YYTextView alloc] init];
    contentView.textContainerInset = UIEdgeInsetsMake(0, 8, 0, 8);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    style.alignment = NSTextAlignmentLeft;
    NSAttributedString *atttibuted = [[NSAttributedString alloc] initWithString:_content attributes:@{NSParagraphStyleAttributeName:style,NSFontAttributeName:[UIFont systemFontOfSize: 17]}];
    contentView.attributedText = atttibuted;
    CGSize size =  [contentView sizeThatFits:CGSizeMake(250, MAXFLOAT)];
    CGFloat textHeight = ceilf(size.height)+10+10;//10 顶部和底部局父view的高度
    if (textHeight<40) {
        textHeight = 40.0f;
    }
    return  CGSizeMake(size.width,textHeight);
}

- (CGSize )getSystemSize {
    CGRect rect = [_content boundingRectWithSize:CGSizeMake(250, MAXFLOAT)
                   
                                         options:NSStringDrawingUsesLineFragmentOrigin
                   
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                   
                                         context:nil];
    self.contentHeight = ceil(rect.size.height) + 5;
    double width = ceil(rect.size.width);//14内容距外边距 +15内容距内边距
    double height = ceil(self.contentHeight);
    return  CGSizeMake(width,height);
}

- (NSString *)readStatus {
    if (!_readStatus) {
        _readStatus = @"1";
    }
    return _readStatus;
}

- (CGFloat)voiceHeight {
    return 40;
}

- (CGSize)imageSize {
    if (_imageSize.height<1) {
        _imageSize = [self getImageSize];
    }
    return _imageSize;
}

- (CGSize)videoSize {
    if (_videoSize.height < 1) {
        _videoSize = [self getVideoSize];
    }
    return _videoSize;
}

- (CGSize)getImageSize {
    NSDictionary *ratioData = [self.measureInfo mj_JSONObject];
    CGFloat width = [[ratioData objectForKey:@"width"] doubleValue];
    CGFloat height = [[ratioData objectForKey:@"height"] doubleValue];
    if (width >0 && height>0) {
        if (width>height) {
            CGFloat zoom;
            if (width >MAX_IMAGE_WH) {
                zoom = MAX_IMAGE_WH/width;
            }else {
                zoom = width/MAX_IMAGE_WH;
            }
            width = MAX_IMAGE_WH;
            CGFloat nomalHeight = zoom*height;
            height = nomalHeight<40.0f ? 40:nomalHeight;
        }else {
            CGFloat zoom;
            if (width >MAX_IMAGE_HG) {
                zoom = MAX_IMAGE_HG/height;
            }else {
                zoom = height/MAX_IMAGE_HG;
            }
            height = MAX_IMAGE_HG;
            CGFloat nomalWidth = zoom*width;
            width = nomalWidth<40.0f ? 40:nomalWidth;
        }
        return CGSizeMake(width, height);
    }else {
        return CGSizeMake(MAX_IMAGE_WH,MAX_IMAGE_HG);
    }
}

- (CGSize)getVideoSize {
    NSDictionary *ratioData = [self.measureInfo mj_JSONObject];
    CGFloat width = [[ratioData objectForKey:@"width"] doubleValue];
    CGFloat height = [[ratioData objectForKey:@"height"] doubleValue];
    if (width >0 && height>0) {
        if (width>height) {
            CGFloat zoom;
            if (width > kMaxVideoWidth) {
                zoom = kMaxVideoWidth/width;
            } else {
                zoom = width/kMaxVideoWidth;
            }
            width = kMaxVideoWidth;
            height = zoom * height;
        } else {
            CGFloat zoom;
            if (width > kMaxVideoHeight) {
                zoom = kMaxVideoHeight/height;
            } else {
                zoom = height/kMaxVideoHeight;
            }
            height = kMaxVideoHeight;
            width = zoom * width;
        }
        return CGSizeMake(width, height);
    } else {
        return CGSizeMake(kMaxVideoWidth,kMaxVideoHeight);
    }
}

- (CGFloat)rtcHeight {
    return 40;
}


+ (MessageModel *)initMessageWithResult:(FMResultSet *)result {
    MessageModel *model = [[MessageModel alloc] init];
    model.messageId = [result stringForColumn:@"message_id"];
    model.roomId = [result stringForColumn:@"room_id"];
    model.content = [result stringForColumn:@"content"];
    model.type = [result stringForColumn:@"type"];
    model.timestamp = [result stringForColumn:@"timestamp"];
    model.fileName = [result stringForColumn:@"file_name"];
    model.duration = [result stringForColumn:@"duration"];
    model.sourceId = [result stringForColumn:@"source_id"];
    model.sendStatus = [result stringForColumn:@"send_state"];
    model.readStatus = [result stringForColumn:@"read_state"];
    model.sender = [result stringForColumn:@"sender_id"];
    model.backId = [result stringForColumn:@"backId"];
    model.bigImage = [result stringForColumn:@"big_image"];
    model.rtcStatus = [result intForColumn:@"rtc_status"];
    model.locationInfo = [result stringForColumn:@"locationInfo"];
    NSString *atModelListStr = [result stringForColumn:@"atModelList"];
    if (atModelListStr.length > 0) {
        NSArray *atModelList = [AtManModel mj_objectArrayWithKeyValuesArray:[atModelListStr mj_JSONObject]];
        model.atModelList = atModelList;
    }
    
    model.fileSize = [result stringForColumn:@"fileSize"];
    model.measureInfo = [result stringForColumn:@"measureInfo"];
    model.videoIMGName = [result stringForColumn:@"videoIMGName"];
    model.cryptoType = [result intForColumn:@"cryptoType"];
    model.isCryptoMessage = model.cryptoType > 0;
    model.fileKey = [result stringForColumn:@"fileKey"];
    return model;
}

- (id)copyWithZone:(NSZone *)zone {
    MessageModel *model = [[MessageModel allocWithZone:zone] init];
    model.messageId = self.messageId;
    model.roomId = self.roomId;
    model.content = self.content;
    model.type = self.type;
    model.timestamp = self.timestamp;
    model.fileName = self.fileName;
    model.duration = self.duration;
    model.sourceId = self.sourceId;
    model.sendStatus = self.sendStatus;
    model.readStatus = self.readStatus;
    model.sender = self.sender;
    model.receiver = self.receiver;
    model.backId = self.backId;
    model.bigImage = self.bigImage;
    model.rtcStatus = self.rtcStatus;
    model.atModelList = self.atModelList;
    
    model.fileSize = self.fileSize;
    model.locationInfo = self.locationInfo;
    model.measureInfo = self.measureInfo;
    model.videoIMGName = self.videoIMGName;
    model.isCryptoMessage = self.isCryptoMessage;
    model.cryptoType = self.cryptoType;
    model.originalContent = self.originalContent;
    model.fileKey = self.fileKey;
    return model;
}

+ (NSString *)getFileTypeWithSuffix:(NSString *)suffix {
    NSString *type;
    NSArray *imageArray = @[@"JPG",@"PNG",@"JPEG",@"GIF",@"BMP",@"jpg",@"png",@"jpeg",@"gif",@"bmp"];
    NSArray *videoArray = @[@"AVI",@"MP4",@"FLV",@"MPG",@"RM",@"RMVB",@"MKV",@"WMV",@"avi",@"mp4",@"flv",@"mpg",@"rm",@"rmvb",@"mkv",@"wmv"];
    if ([imageArray containsObject:suffix]) {
        type = @"image";
    }else if ([videoArray containsObject:suffix]) {
        type = @"video";
    }else {
        type = @"file";
    }
    return type;
}
@end
