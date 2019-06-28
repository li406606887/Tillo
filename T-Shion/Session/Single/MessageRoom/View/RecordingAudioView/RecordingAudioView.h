//
//  RecordingAudioView.h
//  T-Shion
//
//  Created by together on 2018/5/14.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordingAudioView : UIView
@property (copy, nonatomic) NSString *folderPath;

@property (copy, nonatomic) void (^sendAudioBlock) (MessageModel *model);

//@property (copy, nonatomic) void (^updateModelBlock) (MessageModel *model);
//逻辑 method
- (void)start;

- (void)stop;

- (void)endRecord;

- (void)cancelRecord;

- (void)removeTimer;
//视图显示 method
- (void)cancelSend ;

- (void)show ;

- (void)showPrompt ;
@end
