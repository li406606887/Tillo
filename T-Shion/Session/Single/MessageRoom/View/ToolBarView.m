//
//  ToolBarView.m
//  T-Shion
//
//  Created by together on 2018/9/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "ToolBarView.h"
#import "ChooseAtManViewController.h"
#import "AtManModel.h"

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

#define InputViewMinHeight 40.5
#define InputViewMaxHeight 74
#define padding 3
#define kATFormat  @"@%@ "
#define kATRegular @"@[\\u4e00-\\u9fa5\\w\\-\\_]+ "


@interface ToolBarView ()<YYTextViewDelegate,ChooseAtManViewControllerDelegate>

@property (nonatomic) CGFloat previousTextViewContentHeight;//上一次inputTextView的contentSize.height

@property (nonatomic) CGFloat zoomTextViewContentHeight;//上一次inputTextView的contentSize.height

@property (nonatomic, strong) NSMutableArray *atManArray;

@property (nonatomic, assign) BOOL isFirstLoadDraft;//第一次进来加载草稿

@property (nonatomic, strong) CTCallCenter *callCenter;//系统电话监听

@end

@implementation ToolBarView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        [self setupViews];
        
        @weakify(self);
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"cancelAudioRecording" object:nil]  takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.voiceView cancelRecord];
                [self endRecordShowView];
            });
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hadEnterBackGround) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [self addCallCenterObserver];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.fileButton];
    [self addSubview:self.addButton];
    [self addSubview:self.photoButton];
    [self addSubview:self.cameraButton];
    [self addSubview:self.voiceButton];
    [self addSubview:self.textBackView];
    [self.textBackView addSubview:self.textField];
    [self.textBackView addSubview:self.emoticonButton];
    [self addSubview:self.sendBtn];
    [self addSubview:self.voiceView];
    self.textField.contentSize = CGSizeMake(SCREEN_WIDTH-200, InputViewMinHeight);
}

- (void)layoutSubviews {
    CGFloat height = self.height;
    self.addButton.origin = CGPointMake(padding, height-50);
    self.fileButton.origin = CGPointMake(padding, height-50);
    self.cameraButton.origin = CGPointMake(self.fileButton.right, height-50);

    self.photoButton.origin = CGPointMake(self.cameraButton.right, height-50);
    self.voiceButton.origin = CGPointMake(self.photoButton.right, height-50);
    self.sendBtn.origin = CGPointMake(SCREEN_WIDTH - 50 - padding, height-50);
    if (self.state) {
        self.textBackView.frame = CGRectMake(self.addButton.right + 10, 4.25, self.sendBtn.x - self.addButton.right - padding * 2 - 10, self.previousTextViewContentHeight);
        if (self.previousTextViewContentHeight == InputViewMinHeight) {
            self.textField.size = CGSizeMake(self.textBackView.width- 50, 36);
        }else {
            self.textField.size = CGSizeMake(self.textBackView.width- 50, self.previousTextViewContentHeight);
        }
    }else {
        self.textBackView.frame = CGRectMake(self.voiceButton.right + 10, 4.25, SCREEN_WIDTH - self.voiceButton.right -padding * 2 -10, InputViewMinHeight);
        self.textField.size = CGSizeMake(self.textBackView.width- 50, 36);
    }
    
    self.textField.origin = CGPointMake(10, (self.textBackView.height - self.textField.height)*0.5);
    
    self.emoticonButton.origin = CGPointMake(self.textBackView.width - InputViewMinHeight, height-50);
//    self.voiceView.frame = CGRectMake(self.voiceButton.right, height-50, SCREEN_WIDTH - self.voiceButton.right - 2*padding, 50);
    [self.voiceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_top);
        make.centerX.equalTo(self);
        make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, 100));
    }];
    [super layoutSubviews];
}

#pragma mark - 文字草稿
- (void)loadDraftData {
    if (_groupRoomID) {
        [self loadDraftDataWithRoomId:self.groupRoomID];
    } else {
        [self loadDraftDataWithRoomId:self.singleChatRoomID];
    }
}

- (void)loadDraftDataWithRoomId:(NSString *)roomId {
    NSDictionary *dataDict = [FMDBManager selectConversationDraftDataWithRoomId:roomId];
    NSString *draftAtListStr = [dataDict objectForKey:@"draftAtList"];
    NSString *draftContent = [dataDict objectForKey:@"draftContent"];
    
    if (draftContent.length > 0) {
        self.isFirstLoadDraft = YES;
        if (_groupRoomID) {
            //如果是群聊判断草稿里面是否有at数据,进行草稿初始化
            if (draftAtListStr.length > 0) {
                NSArray *atList = [draftAtListStr mj_JSONObject];
                self.atManArray = [AtManModel mj_objectArrayWithKeyValuesArray:atList];
                NSMutableAttributedString *draftAttributedString = [[NSMutableAttributedString alloc] initWithString:draftContent];
                draftAttributedString.yy_font = [UIFont systemFontOfSize:16];
                __block NSString *defaultContent = draftContent;
                __block NSInteger lastIndex = 0;//最后截取的位置
                
                [self.atManArray enumerateObjectsUsingBlock:^(AtManModel *atModel, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSRange bindingRange = [defaultContent rangeOfString:atModel.userName];
                    if (bindingRange.location == NSNotFound || bindingRange.length < 1) return;
                    
                    //需要对对象文本进行颜色渲染，将空格设置黑色不然编辑后面文字会变蓝
                    NSRange blueRange = NSMakeRange(lastIndex + bindingRange.location, bindingRange.length - 1);
                    
                    NSRange emptyRange = NSMakeRange(lastIndex + bindingRange.length + bindingRange.location - 1, 1);
                    
                    NSRange allRange = NSMakeRange(lastIndex + bindingRange.location, bindingRange.length);
                    
                    [draftAttributedString yy_setColor:[UIColor ALBlueColor] range:blueRange];
                    [draftAttributedString yy_setColor:[UIColor ALTextDarkColor] range:emptyRange];

                    [draftAttributedString yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:allRange];
                    
                    //该出进行截取处理，为了重复的名字也能被遍历到
                    defaultContent = [defaultContent substringFromIndex:bindingRange.location + bindingRange.length];
                    
                    lastIndex += (bindingRange.location + bindingRange.length);
                }];
                
                self.textField.attributedText = draftAttributedString;
                
            } else {
                self.textField.text = draftContent;
            }
        } else {
            self.textField.text = draftContent;
        }
    }
}

- (void)updateDraftAtList {
    // wsp 添加, 更新草稿at的人 2019.4.4
    NSString *atModelListStr;
    if (self.atManArray.count > 0) {
        NSArray *atModelList = [AtManModel mj_keyValuesArrayWithObjectArray:self.atManArray];
        atModelListStr = [atModelList mj_JSONString];
    } else {
        atModelListStr = @"";
    }
    
    [FMDBManager updateDraftAtListWithRoomId:self.groupRoomID draftAtList:atModelListStr];
    // end
}

#pragma mark 发送消息
- (void)sendMessage {
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    
    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"text";
    model.content = self.textField.text;
    if (self.groupRoomID) {
        model.atModelList = [AtManModel mj_keyValuesArrayWithObjectArray:self.atManArray];
        [self.atManArray removeAllObjects];
        //清空
        [FMDBManager updateDraftAtListWithRoomId:self.groupRoomID draftAtList:@""];
    }
    
    if (self.sendMessageBlock) {
        self.sendMessageBlock(model);
    }
    self.textField.text = @"";
    [self willShowInputTextViewToHeight:[self getTextViewContentH:self.textField]];
}

#pragma mark - 选择群聊@的人
- (void)chooseATMan {
    ChooseAtManViewController *chooseVC = [[ChooseAtManViewController alloc] initWithRoomID:self.groupRoomID];
    chooseVC.delegate = self;
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:chooseVC];
    [[SocketViewModel getTopViewController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark - ChooseAtManViewControllerDelegate
- (void)didChooseAtUserWithData:(MemberModel *)userData {
    NSRange selectedRange = self.textField.selectedRange;
    
    //先去除@
    NSMutableString *nowStr = [[NSMutableString alloc] initWithString:self.textField.text];
    [nowStr deleteCharactersInRange:NSMakeRange(selectedRange.location - 1, 1)];
    
    NSString *userStr = [NSString stringWithFormat:@"%@%@ ",@"@",userData.name];
    
    //用于存储@的人的信息
    NSMutableAttributedString *tagText = [[NSMutableAttributedString alloc] initWithString:userStr];
    NSRange allRange = tagText.yy_rangeOfAll;
    
    //需要对对象文本进行颜色渲染，将空格设置黑色不然编辑后面文字会变蓝
    [tagText yy_setColor:[UIColor ALBlueColor] range:NSMakeRange(0, allRange.length - 1)];
    [tagText yy_setColor:[UIColor ALTextDarkColor] range:NSMakeRange(allRange.length - 1, 1)];
    
    [tagText yy_setTextBinding:[YYTextBinding bindingWithDeleteConfirm:NO] range:tagText.yy_rangeOfAll];
    tagText.yy_font = [UIFont systemFontOfSize:16];
    
    NSMutableAttributedString *oldAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textField.attributedText];
    
    [oldAttStr deleteCharactersInRange:NSMakeRange(selectedRange.location - 1, 1)];
    [oldAttStr insertAttributedString:tagText atIndex:selectedRange.location - 1];
    
    //这边加判断userId = -1的就是@所有人
    AtManModel *atManData = [[AtManModel alloc] init];
    atManData.userName = userStr;
    atManData.userId = userData.userId;
    [self.atManArray addObject:atManData];
    
    // wsp 添加, 更新草稿at的人 2019.4.4
    [self updateDraftAtList];
    // end
    
    self.textField.attributedText = oldAttStr;
    self.textField.selectedRange = NSMakeRange(selectedRange.location - 1 + userStr.length, 0);
    [self.textField becomeFirstResponder];
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(YYTextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.textField];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(YYTextView *)textView {
    [textView becomeFirstResponder];
    if (!self.state) {
        [self showTextView];
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.textField];
    }
}

- (void)textViewDidEndEditing:(YYTextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(YYTextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    //如果是群聊
    if (self.groupRoomID) {
        //跳转选择联系人
        if ([text isEqualToString:@"@"] && !self.isFirstLoadDraft) {
            [self chooseATMan];
        }
        
        //当文本用户对象进行删除时候
        if (range.length > 1 && text.length == 0) {
            NSLog(@"删除位置----%ld",range.location);
            NSLog(@"删除长度----%ld",range.length);
            
            if (textView.text.length > 0) {//发送的时候需要判断text.length
                NSString *userName = [textView.text substringWithRange:range];
                NSLog(@"%@",userName);
                
                //删除的时候清除对应的用户信息
                [self.atManArray enumerateObjectsUsingBlock:^(AtManModel *atManData, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([atManData.userName isEqualToString:userName]) {
                        [self.atManArray removeObject:atManData];
                        // wsp 添加, 更新草稿at的人 2019.4.4
                        [self updateDraftAtList];
                        // end
                        *stop = YES;
                    }
                }];
                
                if (range.location == 0) textView.textColor = [UIColor ALTextDarkColor];
            } else {
                //发送之后文本要变黑色
                textView.textColor = [UIColor ALTextDarkColor];
            }
        }
    }
    
    if ([text isEqualToString:@"\n"]) {
        [self sendMessage];
        textView.text = nil;
        textView.attributedText = nil;
        
        [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(YYTextView *)textView {
    
    // wsp 添加, 草稿初次加载 2019.4.4
    if (self.isFirstLoadDraft) {
        self.previousTextViewContentHeight = [self getTextViewContentH:textView];
        self.previousTextViewContentHeight = self.previousTextViewContentHeight >= InputViewMaxHeight ? InputViewMaxHeight:self.previousTextViewContentHeight;
    
        [self showTextView];
        [textView becomeFirstResponder];
        [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
//        [self showTextView];
        self.isFirstLoadDraft = NO;
        return;
    }
    // end
    
    if (self.state == NO) {
        [self showTextView];
    }
    
    // wsp 添加, 更新草稿文本内容 2019.4.4
    if (self.singleChatRoomID) {
        [FMDBManager updateDraftContentWithRoomId:self.singleChatRoomID draftContentText:textView.text isSingleChat:YES];

    } else if (self.groupRoomID) {
        [FMDBManager updateDraftContentWithRoomId:self.groupRoomID draftContentText:textView.text isSingleChat:NO];
    }
    // end
    
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight {
    if (toHeight <= InputViewMinHeight) {
        toHeight = InputViewMinHeight;
    }
    
    if (toHeight >= InputViewMaxHeight) {
        toHeight = InputViewMaxHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight) {
        return;
    } else {     //14.5          55 +9.5         40.5 +9.5
        CGFloat changeHeight = toHeight - self.previousTextViewContentHeight;
        
        _previousTextViewContentHeight = toHeight;
        self.zoomTextViewContentHeight = toHeight;
        self.textField.height = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(chatToolbarDidChangeFrameToHeight:toolBarHeight:)]) {
            if (_previousTextViewContentHeight<50) {
                 [_delegate chatToolbarDidChangeFrameToHeight:changeHeight toolBarHeight:50];
            }else {
                 [_delegate chatToolbarDidChangeFrameToHeight:changeHeight toolBarHeight:_previousTextViewContentHeight +9.5];
            }

        }
        [self textFieldScrollLastLine];
        [self layoutSubviews];
    }
}

- (CGFloat)getTextViewContentH:(YYTextView *)textView {
    return textView.contentSize.height;
}


#pragma mark 显示VoiceView
- (void)showVoiceButton {
    self.state = NO;
    self.fileButton.hidden = self.photoButton.hidden = self.cameraButton.hidden = self.voiceButton.hidden = NO;
    self.sendBtn.hidden = self.addButton.hidden = YES;
    CGFloat voiceRight = self.voiceButton.right + 10 ;
    CGFloat width = SCREEN_WIDTH - voiceRight - 2 * padding -10;
    self.textBackView.frame = CGRectMake(voiceRight, 4.25, width, InputViewMinHeight);
    self.emoticonButton.origin = CGPointMake(self.textBackView.width- InputViewMinHeight, 0);
    if (self.previousTextViewContentHeight<50) {
        [self.delegate chatToolbarDidChangeFrameToHeight:0 toolBarHeight:50];
    }else {
        CGFloat changeHeight = InputViewMinHeight - self.zoomTextViewContentHeight;
        self.zoomTextViewContentHeight = InputViewMinHeight;
        [self.delegate chatToolbarDidChangeFrameToHeight:changeHeight toolBarHeight:50];
    }
    [self textFieldScrollLastLine];
    [self layoutSubviews];
}

#pragma mark 显示TextView
- (void)showTextView {
    self.state = YES;
    self.fileButton.hidden = self.photoButton.hidden = self.cameraButton.hidden = self.voiceButton.hidden = YES;
    self.sendBtn.hidden = self.addButton.hidden = NO;
    CGFloat addRight = self.addButton.right;
    CGFloat width = self.sendBtn.x - addRight - 2 * padding;
    
    self.textBackView.frame = CGRectMake(addRight, 4.25, width, self.previousTextViewContentHeight);
    self.emoticonButton.origin = CGPointMake(self.textBackView.width - InputViewMinHeight, self.textBackView.height - InputViewMinHeight);
    if (self.previousTextViewContentHeight<50) {
        [self.delegate chatToolbarDidChangeFrameToHeight:0 toolBarHeight:50];
    }else {
        CGFloat changeHeight = self.previousTextViewContentHeight - InputViewMinHeight;
        [self.delegate chatToolbarDidChangeFrameToHeight:changeHeight toolBarHeight:self.previousTextViewContentHeight+9.5];
    }
    [self textFieldScrollLastLine];
    [self layoutSubviews];
}

//文本垂直居中
- (void)textFieldScrollLastLine {
    CGFloat contentHeight = self.textField.contentSize.height;
    CGFloat textHeight = self.textField.height;
    [self.textField setContentOffset:CGPointMake(0.0f, contentHeight-textHeight) animated:NO];
}

#pragma mark 长按录制语音
- (void)longGesture:(UILongPressGestureRecognizer *)gesture {
    int sendState = 0;
    CGPoint  point = [gesture locationInView:self.voiceButton];
    if (point.y<0) {//松开手指，取消发送
        [self.voiceView cancelSend];
        sendState = 1;
    } else { //重新进入长按录音范围内
        [self.voiceView show];
        sendState = 0;
    }
    //手势状态
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {//这里开始录音
            [self.voiceView start];
//            [self.textBackView setHidden:YES];
//            [self.emoticonButton setHidden:YES];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            if (sendState == 0) {//长按手势结束 结束录音并发送录音
                [self.voiceView stop];
            } else {//取消发送删除录音
                [self.voiceView cancelRecord];
            }
//            [self endRecordShowView];
        }
            break;
        case UIGestureRecognizerStateFailed://长按手势失败
            [self.voiceView cancelRecord];
//            [self endRecordShowView];
            break;
        default:
            break;
    }
}

- (void)endRecordShowView {
    [self.textBackView setHidden:NO];
    [self.emoticonButton setHidden:NO];
}

- (void)hadEnterBackGround{
    [self.voiceView cancelRecord];
    [self endRecordShowView];
    NSLog(@"进入后台");
}


#pragma mark - 监听系统电话
- (void)addCallCenterObserver {
    //录制中收到系统电话需要取消录制
    self.callCenter = [[CTCallCenter alloc] init];
    
    @weakify(self);
    self.callCenter.callEventHandler = ^(CTCall * call) {
        if([call.callState isEqualToString:CTCallStateIncoming]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                [self.voiceView cancelRecord];
                [self endRecordShowView];
            });
        }
    };
}

#pragma mark 设置文件路径
- (void)setFolderPath:(NSString *)folderPath {
    _folderPath = folderPath;
    self.voiceView.folderPath = folderPath;
}

#pragma mark  懒加载
- (ALTextView *)textField {
    if (!_textField) {
        _textField = [[ALTextView alloc] initWithFrame:CGRectMake(0, 0, 100, InputViewMinHeight)];
        
        _textField.font = [UIFont systemFontOfSize:16];
        _textField.returnKeyType = UIReturnKeySend;
        _textField.delegate = self;
        _textField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textField.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
        _textField.backgroundColor = [UIColor clearColor];
        _textField.tintColor = [UIColor ALKeyColor];
        _textField.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0);
        _previousTextViewContentHeight = InputViewMinHeight;
        _textField.height = _previousTextViewContentHeight;
    }
    return _textField;
}

- (UIButton *)sendBtn {
    if (!_sendBtn) {
        _sendBtn = [self creatButtonWithImage:@"Send_Message_btn" tag:3];
        _sendBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        @weakify(self)
        [[_sendBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self sendMessage];
        }];
        _sendBtn.hidden = YES;
    }
    return _sendBtn;
}

- (UIButton *)addButton {
    if (!_addButton) {
        _addButton = [self creatButtonWithImage:@"Chat_Toolbar_back" tag:0];
        @weakify(self)
        [[_addButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
           [self showVoiceButton];
        }];
        _addButton.hidden = YES;
    }
    return _addButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [self creatButtonWithImage:@"Dialogue_Tool_Photo" tag:1];
        @weakify(self)
        [[_photoButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.textField resignFirstResponder];
            if (self.toolBarClickBlock) {
                self.toolBarClickBlock(1);
            }
        }];
    }
    return _photoButton;
}

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [self creatButtonWithImage:@"Dialogue_Tool_Camera" tag:2];
        @weakify(self)
        [[_cameraButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            [self.textField resignFirstResponder];
            if (self.toolBarClickBlock) {
                self.toolBarClickBlock(2);
            }
        }];
    }
    return _cameraButton;
}

- (UIButton *)fileButton {
    if (!_fileButton) {
        _fileButton = [self creatButtonWithImage:@"Dialogue_Tool_More" tag:5];
        @weakify(self)
        [[_fileButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.toolBarClickBlock) {
                self.toolBarClickBlock(5);
            }
            [self.textField resignFirstResponder];
        }];
    }
    return _fileButton;
}

- (UIButton *)emoticonButton {
    if (!_emoticonButton) {
        _emoticonButton = [self creatButtonWithImage:@"Dialogue_Tool_Emoji" tag:3];
        _emoticonButton.backgroundColor = self.textBackView.backgroundColor;
        _emoticonButton.size = CGSizeMake(InputViewMinHeight-2, InputViewMinHeight);
        @weakify(self)
        [[_emoticonButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self)
            if (self.toolBarClickBlock) {
                self.toolBarClickBlock(3);
            }
            if (self.superview.frame.size.height>100) {
                [self showTextView];
            }
            [self.textField resignFirstResponder];
        }];
    };
    return _emoticonButton;
}

- (UIButton *)voiceButton {
    if (!_voiceButton) {
        _voiceButton = [self creatButtonWithImage:@"Dialogue_Tool_Voice" tag:4];
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longGesture:)];
        longGesture.minimumPressDuration = 0.2;
        longGesture.numberOfTouchesRequired = 1;
        [_voiceButton addGestureRecognizer:longGesture];
    }
    return _voiceButton;
}

- (UIView *)textBackView {
    if (!_textBackView) {
        _textBackView = [[UIView alloc] init];
        _textBackView.layer.cornerRadius = 20;
        _textBackView.layer.masksToBounds = YES;
        _textBackView.layer.borderWidth = 0.5;
        _textBackView.layer.borderColor = RGB(221, 221, 221).CGColor;
        _textBackView.backgroundColor = RGB(248, 248, 248);
    }
    return _textBackView;
}

- (RecordingAudioView *)voiceView {
    if (!_voiceView) {
        _voiceView = [[RecordingAudioView alloc] init];
        @weakify(self)
        _voiceView.sendAudioBlock = ^(MessageModel *model) {
            @strongify(self)
            if (self.sendMessageBlock) {
                self.sendMessageBlock(model);
            }
        };
    }
    return _voiceView;
}

- (UIButton *)creatButtonWithImage:(NSString *)image tag:(int)tag {
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setTag:tag];
//    button.size = CGSizeMake(tag == 4 ? 50 : ((SCREEN_WIDTH - 60)/2)/3, 50);
    if (SCREEN_WIDTH > 375.0f) {
       button.size = CGSizeMake(50, 50);
    } else {
        button.size = CGSizeMake(tag == 4 ? 50 : 45, 50);
    }
    
    return button;
}

- (NSMutableArray *)atManArray {
    if (!_atManArray) {
        _atManArray = [NSMutableArray array];
    }
    return _atManArray;
}

//- (void)setGroupRoomID:(NSString *)groupRoomID {
//    _groupRoomID = groupRoomID;
//    [self loadDraftDataWithRoomId:groupRoomID];
//}
//
//- (void)setSingleChatRoomID:(NSString *)singleChatRoomID {
//    _singleChatRoomID = singleChatRoomID;
//    [self loadDraftDataWithRoomId:singleChatRoomID];
//}

- (void)dealloc {
    NSLog(@"toolbarview---释放了");
}

@end
