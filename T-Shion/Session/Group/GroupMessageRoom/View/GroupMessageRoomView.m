//
//  GroupMessageRoomView.m
//  T-Shion
//
//  Created by together on 2018/7/3.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "GroupMessageRoomView.h"
#import "MessageViewCell.h"
#import "OutMessageCell.h"
#import "InMessageCell.h"
#import "MessageTextView.h"
#import "MessageAudioView.h"
#import "MessageImageView.h"
#import "MessageRTCView.h"
#import "MessageFileView.h"
#import "MessageLocaltionView.h"
#import "MessageVideoView.h"
#import "ALMoviePlayerView.h"
#import "MessageNotificationCell.h"
#import "TilloRreshHeader.h"
#import "GroupMessageRoomViewModel.h"
#import "MessageRoomToolView.h"
#import "MessageRemindLabelView.h"
#import "GroupMemberTableView.h"
#import "LookImageDetailsViewController.h"
#import "ChooseAtManViewController.h"
#import "ALMapViewController.h"
#import "ALAVAudioPlayer.h"
#import "JXPopoverView.h"
#import "YMImageBrowser.h"
#import "YMVideoBrowseCellData.h"
#import "YMImageBrowseCellData.h"
#import "ContactsCardView.h"

@interface GroupMessageRoomView ()<UITableViewDelegate,UITableViewDataSource, YMImageBrowserDataSource>
@property (weak, nonatomic) GroupMessageRoomViewModel *viewModel;

@property (strong, nonatomic) MessageRoomToolView *toolView;

@property (assign, nonatomic) BOOL refreshState;

@property (weak, nonatomic) MessageModel *playingModel;//播放中的model

@property (assign, nonatomic) int seletedRow;//被选中的位置

@property (assign, nonatomic) CGFloat toolBarHeight;

@property (assign, nonatomic) int loadingDataBeforeCount;//加载前第一条数据所在

@property (strong, nonatomic) NSMutableArray *displayArray;//显示数组

@property (nonatomic) ALAVAudioPlayer *player;
@property(assign, nonatomic) int menuHiddenState;// 0.键盘弹出 显示菜单   1.键盘关闭 显示菜单  2.键盘弹出 隐藏菜单 3 键盘关闭 隐藏菜单
@property (strong, nonatomic) MessageRemindLabelView *remindView;//提示view


@property (nonatomic, copy) NSArray *imageBrowserArray;
@property (nonatomic, weak) id imageBrowserSourceObject;
@property (nonatomic, assign) NSInteger imageBrowserShowIndex;
@property (nonatomic, assign) BOOL playVideoSoundOff;

@end

@implementation GroupMessageRoomView
-(instancetype)initWithViewModel:(id<BaseViewModelProtocol>)viewModel {
    self.viewModel = (GroupMessageRoomViewModel *)viewModel;
    return [super initWithViewModel:viewModel];
}

- (void)setupViews {
    self.menuHiddenState = 3;
    self.toolBarHeight = 50.0f;
    [self addSubview:self.table];
    [self addSubview:self.remindView];

    [self addSubview:self.toolView];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)layoutSubviews {
    [self.toolView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, self.toolBarHeight + self.safeAreaInsets.bottom));
        } else {
            make.size.mas_offset(CGSizeMake(SCREEN_WIDTH, self.toolBarHeight));
        }
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.centerX.equalTo(self);
        make.bottom.equalTo(self.toolView.mas_top);
        make.width.offset(SCREEN_WIDTH);
    }];
    
    [self.remindView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self).with.offset(10);
        make.size.mas_offset(CGSizeMake(130, 30));
    }];
    
    [super layoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.refreshTableSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id _Nullable x) {
        @strongify(self)
        if (self.table.mj_header.state == MJRefreshStateRefreshing) {
            [self.table.mj_header endRefreshing];
        }
//        if (self.viewModel.dataList.count<1) {
//            return ;
//        }
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            self.displayArray = [self.viewModel.dataList mutableCopy];
            [self.table reloadData];
            if([x intValue] == Loading_HAVE_NEW_MESSAGES) {
                [self scrollToBottomAnimated:NO];
                if (self.viewModel.unreadFirstModel) {
                    self.remindView.hidden = NO;
                    [self.remindView setUnreadCount:self.viewModel.unreadCount];
                }
            }else if ([x intValue] == Loading_NO_NEW_MESSAGES) {
                [self scrollToBottomAnimated:NO];
            }else if ([x intValue] == REFRESH_HISTORY_MESSAGES) {
                [self updateHistoryMessage];
            }else if ([x intValue] == Loading_LOOKFOR_MESSAGES) {
                [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            }else if ([x intValue] == REFRESH_NEW_MESSAGE) {
                [self scrollToBottomAnimated:YES];
            }else if([x intValue] == REFRESH_Table_MESSAGES) {
                [self.table reloadData];
            }
        });
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"DeleteAllMessage" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.viewModel.dataList removeAllObjects];
        [self.viewModel.dataSet removeAllObjects];
        [self.displayArray removeAllObjects];
        [NSThread mainThread];
        [self.table reloadData];
    }];
}

- (void)scrollToFirstUnreadMsg {
    self.remindView.hidden = YES;
    NSInteger count = [self.displayArray count];
    if (count >self.viewModel.unreadMsgIndex) {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.viewModel.unreadMsgIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [FMDBManager ChangeAllMessageReadStatusWithRoomId:self.viewModel.groupModel.roomId];
}

- (void)updateHistoryMessage {
    int index = (int)self.displayArray.count - self.loadingDataBeforeCount;
    if (0<index&&index<self.displayArray.count) {
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    NSInteger count = [self.displayArray count];
    if (count >0) {
        if (animated) {
            CGFloat maxFloat = self.table.contentSize.height;
            CGFloat offsetFloat = self.table.contentOffset.y +self.table.height;
            CGFloat offsetHeight = maxFloat - offsetFloat;
            CGFloat tableHeight = self.table.height;
            MessageModel *model = self.displayArray.lastObject;
            if (offsetHeight>tableHeight+model.contentHeight) {
                return;
            }
        }
        NSInteger lastRow = count - 1;
        [self.table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastRow inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (void)loadDraftData {
    [self.toolView.toolBar loadDraftData];
}

#pragma mark table Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageModel *model = self.displayArray[indexPath.row];
    CGFloat nameHeight = 0;//名字高度
    if (model.sendType == OtherSender) {
        nameHeight = 15;
    }
    if (model.msgType == MESSAGE_NotifyTime) {
        return 30;
    } else {
        return model.contentHeight + 10 + 15 + nameHeight;//10高度是顶部距离+15底部距离
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.displayArray.count == 0) return nil;
    MessageModel *message = self.displayArray[indexPath.row];
    
    if (message == nil) return nil;
    
    NSString *CellID = [self getMessageViewCellId:message];
    MessageViewCell *cell = (MessageViewCell *)[tableView dequeueReusableCellWithIdentifier:CellID];
    cell.tag = indexPath.row;
    
    @weakify(self)
    if (!cell) {
        if (message.msgType == MESSAGE_NotifyTime || message.msgType == MESSAGE_System) {
            cell = [[MessageNotificationCell alloc] initWithType:message.msgType reuseIdentifier:CellID];
        } else if (message.sendType == SelfSender) {
            OutMessageCell *outCell = [[OutMessageCell alloc] initWithType:message.msgType reuseIdentifier:CellID];
            outCell.resendBlock = ^(MessageModel * _Nonnull model) {
                @strongify(self)
                [self.viewModel resendMessageWithModel:model];
            };
            cell = outCell;
        } else {
            InMessageCell *inCell = [[InMessageCell alloc] initWithType:message.msgType reuseIdentifier:CellID];
            inCell.showName = YES;
            inCell.headClickBlock = ^(NSString * _Nonnull userId) {
                [self.viewModel.clickHeadIconSubject sendNext:userId];
            };
            cell = inCell;
        }
        
        if (message.msgType == MESSAGE_AUDIO) {
            MessageAudioView *audioView = (MessageAudioView*)cell.bubbleView;
            audioView.playBlock = ^(MessageModel *model) {
                @strongify(self)
                [self startPlay:model];
            };
        } else if (message.msgType == MESSAGE_IMAGE) {
            MessageImageView *imageView = (MessageImageView*)cell.bubbleView;
            imageView.lookBigImageBlock = ^(MessageModel *model, UIImageView *coverView) {
                @strongify(self)
                self.imageBrowserSourceObject = coverView;
                [self showBrowserWithModel:model isSoundOff:NO];
            };
            imageView.updateHeightBlock = ^{
                @strongify(self)
                [self.table beginUpdates];
                [self.table endUpdates];
            };
        } else if (message.msgType == MESSAGE_File) {
            MessageFileView *fileView = (MessageFileView*)cell.bubbleView;
            fileView.fileClickBlock = ^(id  _Nonnull model) {
                @strongify(self)
                [self.viewModel.messageClickFileSubject sendNext:model];
            };
        } else if (message.msgType == MESSAGE_Contacts_Card) {
            ContactsCardView *cardView = (ContactsCardView*)cell.bubbleView;
            cardView.clickBlcok = ^(id  _Nonnull data, int type) {
                switch (type) {
                    case 1://发消息
                        [self.viewModel.sendMsgSubject sendNext:data];
                        break;
                        
                    case 2://加好友
                        [self.viewModel.addFriendSubject sendNext:data];
                        break;
                        
                    default:
                        break;
                }
            };
        } else if (message.msgType == MESSAGE_Location) {
            //add by wsp for look location detail 2019.3.6
            MessageLocaltionView *locationView = (MessageLocaltionView *)cell.bubbleView;
            locationView.lookLocationDetailBlock = ^(MessageModel *model) {
                @strongify(self)
                [self lookLocationDetailWithModel:model];
            };
        } else if (message.msgType == MESSAGE_Video) {
            MessageVideoView *videoView = (MessageVideoView *)cell.bubbleView;
            videoView.lookVideoDetailBlock = ^(MessageModel *model, UIImageView *coverView) {
                @strongify(self)
                self.imageBrowserSourceObject = coverView;
                [self showBrowserWithModel:model isSoundOff:NO];
            };
        }
    }
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [recognizer setMinimumPressDuration:0.5];
    [cell.bubbleView addGestureRecognizer:recognizer];
    cell.message = message;
    
    NSInteger tag = indexPath.section<<16 | indexPath.row;
    cell.bubbleView.tag = tag;
    cell.tag = tag;
    
    if (message.messageId.integerValue == 999 || message.messageId.integerValue == 1000) {
        if ([cell.bubbleView isKindOfClass:NSClassFromString(@"MessageNotificationView")]) {
            UILabel *label = [cell.bubbleView valueForKey:@"label"];
            if (label)
                label.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (self.viewModel.unreadFirstModel) {
        [self scrollToBottomAnimated:NO];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MessageModel *msg = self.displayArray[indexPath.row];
    if (self.viewModel.unreadFirstModel == msg) {
        self.remindView.hidden = YES;
        self.viewModel.unreadCount = 0;
        self.viewModel.unreadFirstModel = nil;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([msg.readStatus isEqualToString:@"3"]) {
            msg.readStatus = @"1";
            if (msg.msgType == MESSAGE_AUDIO) {
                msg.readStatus = @"2";
            }
            [FMDBManager updateReadedMessageWithModel:msg];
        }
    });
}
/*
 * 复用ID区分来去类型
 */
- (NSString*)getMessageViewCellId:(MessageModel*)msg{
    if (msg.msgType == MESSAGE_NotifyTime) {
        return @"MessageCellNotification";
    } else if(msg.sendType == OtherSender) {
        return [NSString stringWithFormat:@"MessageCell_%d%d", msg.msgType, 0];
    } else {
        return [NSString stringWithFormat:@"MessageCell_%d%d", msg.msgType, 1];
    }
}

#pragma mark - Gestures
- (void)handleLongPress:(UILongPressGestureRecognizer *)longPress {
    if(longPress.state == UIGestureRecognizerStateBegan) {
        int row = longPress.view.tag & 0xffff;
        
        MessageModel *model = self.displayArray[row];
        if (model == nil||model.msgType == MESSAGE_System ||model.msgType == MESSAGE_NotifyTime||model.msgType == MESSAGE_Withdraw) {
            return;
        }
        
        self.seletedRow = row;
        JXPopoverView *popoverView = [JXPopoverView popoverView];
//        popoverView.showShade = YES;
        NSMutableArray *menuItems = [NSMutableArray array];
        
        if (model.msgType !=  MESSAGE_RTC && !model.isCryptoMessage) {
            JXPopoverAction *transmit = [JXPopoverAction actionWithTitle:Localized(@"Transmit") handler:^(JXPopoverAction *action) {
                MessageModel *model = self.displayArray[self.seletedRow];
                [self.viewModel.messageTransmitSubject sendNext:model];
            }];
            [menuItems addObject:transmit];
        }
        
        if (model.msgType != MESSAGE_RTC) {
            NSInteger minute = [NSDate getNowTimeBeforeMinutes:([model.timestamp doubleValue]/1000)];
            if (minute<3&&[model.sender isEqualToString:[SocketViewModel shared].userModel.ID]&&[model.sendStatus isEqualToString:@"1"]) {// MESSAGE_Withdraw
                JXPopoverAction *transmit = [JXPopoverAction actionWithTitle:Localized(@"Withdraw") handler:^(JXPopoverAction *action) {
                    MessageModel *model = self.displayArray[self.seletedRow];
                    model.type = @"withdraw";
                    [self.viewModel withdrawMsgWithModel:model];
                }];
                [menuItems addObject:transmit];
            }
        }
        
        if (model.msgType == MESSAGE_TEXT && !model.isCryptoMessage) {
            JXPopoverAction *copy = [JXPopoverAction actionWithTitle:Localized(@"Copy") handler:^(JXPopoverAction *action) {
                MessageModel *model = self.displayArray[self.seletedRow];
                [UIPasteboard generalPasteboard].string = model.content;
            }];
            [menuItems addObject:copy];
        }
        
        if (model.msgType == MESSAGE_Video) {
            JXPopoverAction *item = [JXPopoverAction actionWithTitle:Localized(@"静音播放") handler:^(JXPopoverAction *action) {
                [self playVideoWithSoundOff:nil];
            }];
            [menuItems addObject:item];
        }
        
        JXPopoverAction *delete = [JXPopoverAction actionWithTitle:Localized(@"Delete") handler:^(JXPopoverAction *action) {
            [self deleteMessage:nil];
        }];
        [menuItems addObject:delete];
        
        [popoverView showToView:longPress.view withActions:menuItems];
    }
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)playVideoWithSoundOff:(id)send {
    [self.toolView dissMissAllToolBoard];
    MessageModel *model = self.displayArray[self.seletedRow];
    MessageViewCell *cell = [self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.seletedRow inSection:0]];
    MessageVideoView *videoView = (MessageVideoView *)cell.bubbleView;
    self.imageBrowserSourceObject = videoView.previewView;
    [self showBrowserWithModel:model isSoundOff:YES]; 
}

- (void)deleteMessage:(id)delete {
    if (self.seletedRow - 1 < 0) {
        return;
    }
    BOOL isLastMsg = NO;
    MessageModel *model = self.displayArray[self.seletedRow];
    MessageModel *lastModel = self.displayArray.lastObject;
    BOOL result = [FMDBManager deleteMessageWithMessage:model];
    if (result) {
        if (lastModel == model) {
            NSArray *lastMsgArray = [FMDBManager selectMessageWithTableName:model.roomId timestamp:nil count:1];
            if (lastMsgArray.count>0) {
                MessageModel *msg = lastMsgArray[0];
                [FMDBManager updateOnlineWithType:@"groupChat" message:msg];
            }else {
                MessageModel *msg = [model copy];
                msg.type = @"text";
                msg.content = @"";
                [FMDBManager updateOnlineWithType:@"groupChat" message:msg];
            }
            isLastMsg = YES;
        }
        
        MessageModel *behindMsg;
        if (!isLastMsg) {
            behindMsg = self.displayArray[self.seletedRow+1];
        }
        MessageModel *fontMsg = self.displayArray[self.seletedRow-1];
        if (fontMsg.msgType == MESSAGE_NotifyTime||fontMsg.msgType == MESSAGE_New_Msg) {
            if (behindMsg == nil||behindMsg.msgType == MESSAGE_NotifyTime) {
                [self.displayArray removeObject:fontMsg];
                [self.viewModel.dataList removeObject:fontMsg];
            }
        }
        [self.displayArray removeObject:model];
        [self.viewModel.dataList removeObject:model];
        if (isLastMsg) {
            self.viewModel.lastDate = nil;
            for (NSInteger i = self.viewModel.dataList.count-1; i>0; i--) {
                MessageModel *dateModel = self.viewModel.dataList[i];
                if (dateModel.msgType != MESSAGE_NotifyTime ||dateModel.msgType != MESSAGE_New_Msg) {
                    double timestamp = [dateModel.timestamp doubleValue]/1000;
                    self.viewModel.lastDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    break;
                }
            }
        }
        [self.viewModel.refreshTableSubject sendNext:@(REFRESH_Table_MESSAGES)];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.toolView dissMissAllToolBoard];
}

#pragma mark 播放器
- (void)startPlay:(MessageModel *)model {
    //wsp修改 修复语音播放失败问题 2019.3.21
    if ([FMDBManager seletedFileIsSaveWithPath:model]) {
        if (model.audioPlaying) {
            [self stopAudioPlay];
            model.audioPlaying = NO;
            return;
        }
        
        if (self.playingModel) {
            self.playingModel.audioPlaying = NO;
            self.playingModel = nil;
        }
        
        if (self.player) {
            [self.player stop];
            self.player = nil;
        }
        
        self.playingModel = model;
        model.audioPlaying = YES;
        NSString *path = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
        self.player = [[ALAVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] type:1];
        @weakify(self);
        self.player.playResultBlock = ^(BOOL blockType) {
            @strongify(self)
            [self audioEndType:blockType];
        };
        [self.player startPlay];
        if ([model.readStatus intValue] != 1) {
            model.readStatus = @"1";
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [FMDBManager updateReadedMessageWithModel:model];
            });
        }
    }
}

- (void)stopAudioPlay {
    [self.player stopPlay];
}
/**
 音频消息的结束播放方式
 @param type 结束类型 yes 播放完成 no 异常 失败 或 中止
 */
- (void)audioEndType:(BOOL)type {
    self.playingModel.audioPlaying = NO;
    self.player = nil;
    if (type) {
        NSInteger index = [self.displayArray indexOfObject:self.playingModel] + 1;
        for ( NSInteger i = index; i< self.displayArray.count; i++) {
            MessageModel *message = self.displayArray[i];
            if (message.msgType == MESSAGE_AUDIO) {
                if (![message.readStatus isEqualToString:@"1"]) {
                    [self startPlay:message];
                }
                break;
            }
        }
    }
}

#pragma mark 查看大图
- (void)lookBigImageWithModel:(MessageModel *)model {
    NSDictionary *dictionary = [FMDBManager selectImageWithRoom:model.roomId messageId:model.messageId];
    NSArray *array = dictionary.allKeys;
    if (array.count > 0) {
        int index = [[NSString stringWithFormat:@"%@",array[0]] intValue];
        NSArray *dataArray = [dictionary objectForKey:@(index)];
        dispatch_async(dispatch_get_main_queue(), ^{
            LookImageDetailsViewController *lookDetails = [[LookImageDetailsViewController alloc] initWithArray:dataArray currentIndex:index];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:lookDetails animated:YES completion:nil];
        });
    }
}

/**
 点击位置消息跳转到地图
 
 @param model 消息内容
 */
- (void)lookLocationDetailWithModel:(MessageModel *)model {
    ALMapViewController *mapVC = [[ALMapViewController alloc] initWithMessage:model];
    UIViewController *tempVC = (UIViewController *)[SocketViewModel getTopViewController];
    [tempVC.navigationController pushViewController:mapVC animated:YES];
}

#pragma mark - 选择@的人
- (void)gotoChooseAtMember {
    ChooseAtManViewController *chooseVC = [[ChooseAtManViewController alloc] initWithRoomID:self.viewModel.groupModel.roomId];
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:chooseVC];
    [[SocketViewModel getTopViewController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark - 图片浏览器相关
- (void)showBrowserWithModel:(MessageModel *)model isSoundOff:(BOOL)isSoundOff {
    self.playVideoSoundOff = isSoundOff;
    NSDictionary *dictionary = [FMDBManager selectImageOrVideoWithRoom:model.roomId messageId:model.messageId];
    
    NSArray *array = dictionary.allKeys;
    if (array.count > 0) {
        int index = [[NSString stringWithFormat:@"%@",array[0]] intValue];
        NSArray *dataArray = [dictionary objectForKey:@(index)];
        self.imageBrowserShowIndex = index;
        self.imageBrowserArray = [dataArray copy];
        YMImageBrowser *browser = [[YMImageBrowser alloc] initWithType:YMImageBrowserTypeDefault];
        browser.dataSource = self;
        browser.currentIndex = index;
        [browser show];
    }
}

- (NSUInteger)ym_numberOfCellForImageBrowserView:(YMImageBrowserView *)imageBrowserView {
    return self.imageBrowserArray.count;
}

- (id<YMImageBrowserCellDataProtocol>)ym_imageBrowserView:(YMImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index {
    
    
    MessageModel *message = (MessageModel *)self.imageBrowserArray[index];
    
    if (message.msgType == MESSAGE_IMAGE) {//如果是图片消息
        
        YMImageBrowseCellData *browseCellData = [YMImageBrowseCellData new];
        browseCellData.extraData = message;//直接传入到扩展信息，用于图片加载完成操作
        
        NSString *bigImagePath = [FMDBManager selectBigImageWithMessageModel:message];
        NSString *localImgPath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
        
        if (bigImagePath.length > 5) {
            //如果数据库存在大图本地路径
            if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localImgPath]) {
                NSData *localData = [NSData dataWithContentsOfFile:localImgPath];
                
                //如果本地存在大图图片,直接加载本地大图
                browseCellData.imageBlock = ^__kindof UIImage * _Nullable{
                    return [YMImage imageWithData:localData];
                };
            }
            
        } else {
            //预先展示缩略图
            if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localImgPath]) {
                //如果存在本地缩略文件
                NSData *localData = [NSData dataWithContentsOfFile:localImgPath];
                BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:localData];
                if (isGif) {
                    //如果是gif直接打开不需要再次加载
                    browseCellData.imageBlock = ^__kindof UIImage * _Nullable{
                        return [YMImage imageWithData:localData];
                    };
                } else {
                    if (message.isCryptoMessage) {
                        //如果是加密图片则不需要请求网络加载了
                        browseCellData.imageBlock = ^__kindof UIImage * _Nullable{
                            return [YMImage imageWithData:localData];
                        };
                    } else {
                        browseCellData.thumbImage = [UIImage imageWithContentsOfFile:localImgPath];
                    }
                }
            } else {
                //如果不存在本地缩略文件则传缩略文件url
                NSString *thumbString = [NSString ym_thumbImgUrlStringWithMessage:message];
                browseCellData.thumbUrl = [NSURL URLWithString:thumbString];
            }
        }
        
        if (self.imageBrowserShowIndex == index) {
            //该方法赋值为了展示动画过度效果
            browseCellData.sourceObject = self.imageBrowserSourceObject;
        }
        
        NSString *bigImgURLStr = [NSString ym_imageUrlStringWithSourceId:message.sourceId];
        browseCellData.url = [NSURL URLWithString:bigImgURLStr];
        return browseCellData;
    }
    
    else if (message.msgType == MESSAGE_Video) {
        //如果是视频消息
        YMVideoBrowseCellData *browseCellData = [YMVideoBrowseCellData new];
        browseCellData.extraData = message;//直接传入到扩展信息，用于视频加载完成操作
        
        if (self.imageBrowserShowIndex == index) {
            //该方法赋值为了展示动画过度效果
            browseCellData.sourceObject = self.imageBrowserSourceObject;
            browseCellData.isShowIndex = YES;
            browseCellData.playSoundOff = self.playVideoSoundOff;
        }
        
        NSString *firstFramePath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.videoIMGName];
        
        if ([FMDBManager seletedFileIsSaveWithFilePath:firstFramePath] && message.videoIMGName) {
            //如果有第一帧先进行显示
            browseCellData.firstFrame = [UIImage imageWithContentsOfFile:firstFramePath];
        }
        
        NSString *localVideoPath = [[FMDBManager getMessagePathWithMessage:message] stringByAppendingPathComponent:message.fileName];
        
        if (message.fileName.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:localVideoPath]) {
            //有本地视频直接播放
            browseCellData.url = [NSURL fileURLWithPath:localVideoPath];
        } else {
            //没有本地视频则加载
            browseCellData.url = [NSURL URLWithString:[NSString ym_fileUrlStringWithSourceId:message.sourceId]];
        }
        
        return browseCellData;
    }
    
    return nil;
}

#pragma mark - getter
- (BaseTableView *)table {
    if (!_table) {
        _table = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _table.delegate = self;
        _table.dataSource = self;
        _table.backgroundColor  = RGB(246, 246, 246);
        _table.separatorStyle = UITableViewCellSeparatorStyleNone;
        _table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _table.keyboardDismissMode  = UIScrollViewKeyboardDismissModeInteractive;
        @weakify(self)
        _table.touchBeginBlock = ^{
            @strongify(self)
            switch (self.menuHiddenState) {
                case 0:
                    self.menuHiddenState = 2;
                    break;
                case 1:{
                    UIMenuController *menu = [UIMenuController sharedMenuController];
                    [menu setMenuVisible:NO];
                    menu.menuItems = nil;
                    self.menuHiddenState = 2;
                }
                    break;
                case 2:
                    [self.toolView dissMissAllToolBoard];
                    self.menuHiddenState = 3;
                    break;
                case 3:
                    [self.toolView dissMissAllToolBoard];
                    break;
                default:
                    break;
            }
        };
        _table.mj_header = [TilloRreshHeader headerWithRefreshingBlock:^{
            @strongify(self)
            MessageModel *model;
            if (self.displayArray.count>0) {
                model = self.displayArray[0];
            }
            self.loadingDataBeforeCount = (int)self.displayArray.count;
            [self.viewModel refreshHistoryMessage:model.timestamp];
        }];
    }
    return _table;
}

- (MessageRoomToolView *)toolView {
    if (!_toolView) {
        _toolView = [[MessageRoomToolView alloc] init];
        _toolView.toolBar.groupRoomID = self.viewModel.groupModel.roomId;
        _toolView.folderPath = [[TShionSingleCase doucumentPath] stringByAppendingPathComponent:self.viewModel.groupModel.roomId];
        _toolView.backgroundColor = [UIColor whiteColor];
        _toolView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        @weakify(self)
        _toolView.changeHeightBlock = ^(CGFloat height) {
            @strongify(self)
            self.toolBarHeight = height;
            CGRect rect = self.table.frame;
            rect.size.height =  self.toolView.frame.origin.y;
            CGFloat contentY = self.table.contentSize.height - rect.size.height;
            [self.table setFrame:rect];
            if (self.table.contentSize.height > rect.size.height) {
                [self.table setContentOffset:CGPointMake(0, contentY) animated:NO];
            }
        };
        
        _toolView.sendMessageBlock = ^(MessageModel *model) {
            @strongify(self)
            [self.viewModel sendMessageWithModel:model];
        };
        
    };
    return _toolView;
}

- (MessageRemindLabelView *)remindView {
    if (!_remindView) {
        _remindView = [[MessageRemindLabelView alloc] init];
        _remindView.hidden = YES;
        @weakify(self)
        _remindView.readFirstMsgBlock = ^{
            @strongify(self)
            [self scrollToFirstUnreadMsg];
        };
    }
    return _remindView;
}

- (void)dealloc {
    self.table = nil;
    [self.player stop];
    self.player = nil;
    self.toolView = nil;
    self.remindView = nil;
}
@end

