//
//  ToolBarView.h
//  T-Shion
//
//  Created by together on 2018/9/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "TSTextView.h"
#import "RecordingAudioView.h"
#import "YYText.h"
#import "ALTextView.h"

@protocol ToolbarDelegate <NSObject>

@optional
/**
 *  长按语音
 *
 *  @param longpress 长按手势
 */
- (void)longGesture:(UILongPressGestureRecognizer *)longpress;
/**
 *  文字输入框开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(YYTextView *)inputTextView;

/**
 *  文字输入框将要开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(YYTextView *)inputTextView;

/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 *  @param ext 扩展消息
 */
- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext;

/**
 *  发送第三方表情，不会添加到文字输入框中
 *
 *  @param faceLocalPath 选中的表情的本地路径
 */
- (void)didSendFace:(NSString *)faceLocalPath;

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView;

/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;

/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView;

/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction:(UIView *)recordView;

/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction:(UIView *)recordView;


@required
/**
 *  高度变到toHeight
 */
- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight toolBarHeight:(CGFloat )toolBarHeight;

@end

@interface ToolBarView : UIView
@property (strong, nonatomic) ALTextView *textField;

@property (strong, nonatomic) UIButton *fileButton;

@property (strong, nonatomic) UIButton *cameraButton;

@property (strong, nonatomic) UIButton *emoticonButton;

@property (strong, nonatomic) UIButton *addButton;

@property (strong, nonatomic) UIButton *photoButton;

@property (strong, nonatomic) UIButton *voiceButton;

@property (strong, nonatomic) UIView *textBackView;

@property (strong, nonatomic) UIButton *sendBtn;

@property (strong, nonatomic) RecordingAudioView *voiceView;//语音提示;

@property (copy, nonatomic) NSString *folderPath;

@property (nonatomic, assign) id<ToolbarDelegate> delegate;

@property (copy, nonatomic) void (^toolBarClickBlock) (int index);

@property (copy, nonatomic) void (^sendMessageBlock) (MessageModel *model);

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate;

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight;

- (void)textFieldScrollLastLine;

- (void)showVoiceButton;

- (void)showTextView;

- (void)loadDraftData;

@property (nonatomic ,assign) BOOL state;//上一次inputTextView的contentSize.height

@property (nonatomic, copy) NSString *groupRoomID;//群聊房间id
@property (nonatomic, copy) NSString *singleChatRoomID;//单聊房间id

@end
