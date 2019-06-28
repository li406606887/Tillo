//
//  TSRTCChatViewController.m
//  T-Shion
//
//  Created by 与梦信息的Mac on 2018/12/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TSRTCChatViewController.h"
#import "FriendsModel.h"
#import "WebRTCHelper.h"
#import "FTPopOverMenu.h"

@interface TSRTCChatViewController ()<TSRTCChatViewDelegate>


@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSArray *receiveIDArray;
@property (nonatomic, copy) NSString *receiveHostURL;

@property (nonatomic, assign) RTCChatType chatType;//呼叫类型：视频或语音

@end

@implementation TSRTCChatViewController

- (void)dealloc {
    NSLog(@"-----控制器释放了");
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (instancetype)initWithRole:(RTCRole)role
                    chatType:(RTCChatType)chatType
                      roomID:(NSString *)roomID
              receiveIDArray:(NSArray *)receiveIDArray
              receiveHostURL:(NSString *)receiveHostURL {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelAudioRecording" object:nil];
        _role = role;
        _chatType = chatType;
        _roomID = roomID;
        _receiveIDArray = receiveIDArray;
        _receiveHostURL = receiveHostURL;
        
        if (chatType == RTCChatType_Video) {
            //频幕常亮
            [UIApplication sharedApplication].idleTimerDisabled = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [FTPopOverMenu dismiss];
    [self.view addSubview:self.chatView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewConstraints {
    [self.chatView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super updateViewConstraints];
}

- (void)bindViewModel {
    NSError * error;
    [TSRequest getRequetWithApi:api_get_RTCToken withParam:nil error:&error];
}

#pragma mark - TSRTCCallingViewDelegate
- (void)rtcChatViewShouldDissmiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter
- (TSRTCChatView *)chatView {
    if (!_chatView) {
        _chatView = [[TSRTCChatView alloc] initWithRole:_role chatType:_chatType roomID:_roomID receiveIDArray:_receiveIDArray receiveHostURL:self.receiveHostURL];
        
        _chatView.receiveModel = _receiveModel;
        _chatView.delegate = self;
    }
    return _chatView;
}

- (void)setMessageId:(NSString *)messageId {
    _messageId = messageId;
    self.chatView.messageId = messageId;
}

@end
