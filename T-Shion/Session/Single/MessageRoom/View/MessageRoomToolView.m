
//
//  DialogueContentToolView.m
//  T-Shion
//
//  Created by together on 2018/3/28.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "MessageRoomToolView.h"
#import "EaseEmotionManager.h"
#import "TSImagePickerController.h"
#import "MessageRoomViewModel.h"
#import "EaseFaceView.h"
#import "TSImageHandler.h"
#import "ALDocumentPickerViewController.h"
#import "ALMoreKeyBoard.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import "ALPlaceSnapshot.h"
#import "ALAssetSource.h"
#import "ALCameraRecordViewController.h"
#import "SendCardViewController.h"

static CGFloat safeAreaInsetsBottom;
static CGFloat hiddenToolBarY;
static CGFloat superViewHeight;

@interface MessageRoomToolView ()<ToolbarDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,EMFaceDelegate,UIDocumentPickerDelegate,ALMoreKeyboardDelegate,GMSPlacePickerViewControllerDelegate>
@property (copy, nonatomic) dispatch_source_t timer;


@property (strong, nonatomic) EaseFaceView *faceView;

@property (assign, nonatomic) CGFloat duration;

@property (assign, nonatomic) CGFloat toolBarHeight;

@property (assign, nonatomic) CGFloat originalY;

@property (assign, nonatomic) CGFloat maxY;

@property (assign, nonatomic) BOOL keyBoardState;//键盘编辑状态

@property (nonatomic, strong) ALMoreKeyBoard *moreBoardView;

@end

@implementation MessageRoomToolView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self addSubview:self.toolBar];
    [self addSubview:self.faceView];
    [self addSubview:self.moreBoardView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (@available(iOS 11.0, *)) {
            safeAreaInsetsBottom = self.safeAreaInsets.bottom;
        } else {
            // Fallback on earlier versions
            safeAreaInsetsBottom = 0;
        }
        self.originalY = self.y;
        hiddenToolBarY = self.y;
        superViewHeight = self.superview.frame.size.height;
    });
    [self setlayoutSubviews];
}

- (void)setlayoutSubviews {
    self.toolBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.toolBarHeight);
    
    self.faceView.frame = CGRectMake(0, self.toolBarHeight +10, SCREEN_WIDTH, 150);
    self.moreBoardView.frame = CGRectMake(0, self.toolBarHeight, SCREEN_WIDTH, 110);
    
    [super layoutSubviews];
}

#pragma mark - 选择发送文件
- (void)chooseSendFile {
    ALDocumentPickerViewController *documentPickerVC = [ALDocumentPickerViewController config];
    documentPickerVC.delegate = self;
    documentPickerVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [[SocketViewModel getTopViewController] presentViewController:documentPickerVC animated:YES completion:nil];
}

#pragma mark - 选择发送位置
- (void)choosePosition {
    GMSPlacePickerConfig *config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
    GMSPlacePickerViewController *placePicker = [[GMSPlacePickerViewController alloc] initWithConfig:config];
    
    placePicker.modalPresentationStyle = UIModalPresentationPopover;
    placePicker.delegate = self;
    [[SocketViewModel getTopViewController] presentViewController:placePicker animated:YES completion:nil];
}
#pragma mark - 选择发送名片
- (void)chooseSendCard {
    SendCardViewController *sendCard = [[SendCardViewController alloc] initWithUid:self.uid];
    sendCard.clickCardBlock = ^(NSString* param) {
        [self sendCardWithParam:param];
    };
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:sendCard];
    [[SocketViewModel getTopViewController] presentViewController:nav animated:YES completion:nil];
}

- (void)sendCardWithParam:(NSString *)param {
    MessageModel *msg = [[MessageModel alloc] init];
    msg.type = @"card";
    msg.content = param;
    if (self.sendMessageBlock) {
        self.sendMessageBlock(msg);
    }
}

#pragma mark - GMSPlacePickerViewControllerDelegate
- (void)placePicker:(GMSPlacePickerViewController *)viewController didPickPlace:(GMSPlace *)place {
    @weakify(self);
    [[ALPlaceSnapshot sharedInstance] getSnapshotWith:place snapshotCallBack:^(UIImage *Snapshot) {
        @strongify(self);
        [self createMessageModelWithLocationData:place snapshot:Snapshot];
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)placePickerDidCancel:(GMSPlacePickerViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 相机代理
- (void)chooseType:(int)index {
        @weakify(self)
        if (index == 0) {
            TSImagePickerController *imagePicker = [[TSImagePickerController alloc] init];
            imagePicker.autoJumpToPhotoSelectPage = YES;
            imagePicker.getSelectedBlock = ^(NSArray *array) {
                @strongify(self)
                //change by wsp :NSGenericException BUG
                NSMutableArray *tempImageArray = [NSMutableArray arrayWithArray:array];
                for (ALAssetSource *image in tempImageArray) {
                    [self createMessageWithAssetSource:image];
                }
            };
            [[SocketViewModel getTopViewController] presentViewController:imagePicker animated:YES completion:nil];
        } else {
            
            NSString *videoPath = [FMDBManager getVideoPathWithFilePath:self.folderPath];
            ALCameraRecordViewController *cameraVC = [[ALCameraRecordViewController alloc] initWithVideoFoldPath:videoPath];
            cameraVC.sendPhotoBlock = ^(UIImage *image) {
                @strongify(self)
                [self creatMessageModelWithImage:image];
            };
            
            cameraVC.sendVideoBlock = ^(NSString *videoFilePath, NSString *videoFileName, NSString *thumbImgFilePath, NSString *thumbImgFileName, NSDictionary *measureInfo,NSString *duration) {
                @strongify(self)
                [self createMessageWithVideoFilePath:videoFilePath
                                           videoName:videoFileName
                                    thumbImgFilePath:thumbImgFilePath
                                    thumbImgFileName:thumbImgFileName
                                         measureInfo:measureInfo
                                            duration:duration];
                
            };
            [[SocketViewModel getTopViewController] presentViewController:cameraVC animated:YES completion:nil];
        }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *endImage;
    NSData *bigData = nil;
    NSString *fileType = @"jpg";
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        endImage = [TSImageHandler fixOrientation:image];
        UIImageWriteToSavedPhotosAlbum(info[UIImagePickerControllerOriginalImage], self, nil, nil);
        bigData = UIImageJPEGRepresentation(endImage, 1);
    }else {
        if (@available(iOS 11.0, *)) {
            NSURL *url = [info objectForKey:UIImagePickerControllerImageURL];
            NSLog(@"url.class=%@, url=%@", [url class], url);
            bigData = [NSData dataWithContentsOfFile:url.path];
        } else {
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            NSLog(@"url.class=%@, url=%@", [url class], url);
            bigData = [NSData dataWithContentsOfFile:url.absoluteString];
        }
        
        BOOL isGif = [[SDImageGIFCoder sharedCoder] canDecodeFromData:bigData];
        if (isGif){
            //是gif动图
//            endImage = [UIImage sd_animatedGIFWithData:bigData];
            endImage = [UIImage sd_imageWithGIFData:bigData];
            fileType = @"gif";
        }
        else {
            //不是gif动图
            endImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            bigData = UIImageJPEGRepresentation(endImage, 1);
        }
    }
    [[SocketViewModel getTopViewController] dismissViewControllerAnimated:YES completion:nil];
    
    NSString *directoryPath = [FMDBManager getImagePathWithFilePath:self.folderPath];
    
    NSString *bigImage = [NSString stringWithFormat:@"image_big_%@.%@",[NSUUID UUID].UUIDString, fileType];
    NSString *fileName = bigImage;
    
    BOOL bigResult = [bigData writeToFile:[directoryPath stringByAppendingPathComponent:bigImage] atomically:YES];
    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"image";
    model.fileName = fileName;
    if(bigResult) {
        model.bigImage = bigImage;
        if (self.sendMessageBlock) {
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                self.sendMessageBlock(model);
            });
        }
    }
}

    
#pragma mark - 发送消息相关操作
- (void)createMessageWithAssetSource:(ALAssetSource *)assetSource {
    
    if (assetSource.sourceType == ALAssetSourceType_VIDEO) {
        [self createVideoMessageWithAssetSource:assetSource];
        return;
    }
    
    NSString * directoryPath = [FMDBManager getImagePathWithFilePath:self.folderPath];
    CGFloat width = assetSource.originalImage.size.width;
    CGFloat height = assetSource.originalImage.size.height;
    NSDictionary *dictionary = @{@"width":@(width),@"height":@(height)};
    NSString *fileType = @"jpg";
    NSData *bigData = nil;
    if (assetSource.sourceType == ALAssetSourceType_GIF) {
        bigData = assetSource.sourceData;
        fileType = @"gif";
    } else {
        bigData = UIImageJPEGRepresentation(assetSource.originalImage, 1);
    }
    
    NSString *smallName = [NSString stringWithFormat:@"image_small_%@.%@", [NSUUID UUID].UUIDString, fileType];
    NSString *smallFilePath = [directoryPath stringByAppendingPathComponent:smallName];
    
    if (assetSource.sourceType == ALAssetSourceType_GIF) {
        [assetSource.sourceData writeToFile:smallFilePath atomically:YES];
    } else {
        [UIImageJPEGRepresentation(assetSource.originalImage, 0.1) writeToFile:smallFilePath atomically:YES];
    }
    
    NSString *bigImage = [NSString stringWithFormat:@"image_big_%@.%@", [NSUUID UUID].UUIDString, fileType];
    
    BOOL bigResult = [bigData writeToFile:[directoryPath stringByAppendingPathComponent:bigImage] atomically:YES];

    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"image";
    model.fileName = smallName;
    model.measureInfo = [dictionary mj_JSONString];
    if (bigResult) {
        model.bigImage = bigImage;
        if (self.sendMessageBlock) {
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                self.sendMessageBlock(model);
            });
        }
    }
}

//wsp 添加：用于相册选取发送视频文件
- (void)createVideoMessageWithAssetSource:(ALAssetSource *)assetSource {
    NSData *imageData = UIImageJPEGRepresentation(assetSource.originalImage, 0.1);
    NSString *videoPath = [FMDBManager getVideoPathWithFilePath:self.folderPath];
    
    NSString *thumbImgName = [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg", [NSUUID UUID].UUIDString];

    NSString *videoName = [NSString stringWithFormat:@"VShotVideo_%@.mp4", [NSUUID UUID].UUIDString];
    
//    NSString *thumbImgName = [ALAssetSource createVideoShotImageFileName];
//    NSString *videoName = [ALAssetSource createVideoFileName];
    
    NSString *thumbImgFilePath = [videoPath stringByAppendingPathComponent:thumbImgName];
    NSString *videoFilePath = [videoPath stringByAppendingPathComponent:videoName];
    [assetSource.sourceData writeToFile:videoFilePath atomically:YES];
    [imageData writeToFile:thumbImgFilePath atomically:YES];
    
    MessageModel *model = [[MessageModel alloc] init];
    model.fileName = videoName;
    model.videoIMGName = thumbImgName;
    model.type = @"video";
    model.duration = [NSString stringWithFormat:@"%d",assetSource.duration];
    
    NSMutableDictionary *measureInfo = [NSMutableDictionary dictionary];
    [measureInfo setObject:@(assetSource.originalImage.size.width) forKey:@"width"];
    [measureInfo setObject:@(assetSource.originalImage.size.height) forKey:@"height"];
    NSString *measureInfoStr = [measureInfo mj_JSONString];
    model.measureInfo = measureInfoStr;
    
    if (self.sendMessageBlock) {
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            self.sendMessageBlock(model);
        });
    }
    
}
//end

- (void)creatMessageModelWithImage:(UIImage *)image {
    NSString * directoryPath = [FMDBManager getImagePathWithFilePath:self.folderPath];
    NSString *fileName = [NSString stringWithFormat:@"image_small_%@.jpg",[NSUUID UUID].UUIDString];
    BOOL smallResult = [UIImageJPEGRepresentation(image, 0.1) writeToFile:[directoryPath stringByAppendingPathComponent:fileName] atomically:YES];
    if(smallResult) {
        NSLog(@"创建文件夹成功，文件路径%@",[directoryPath stringByAppendingPathComponent:fileName]);
    }
    
    NSString *bigImage = [NSString stringWithFormat:@"image_big_%@.jpg",[NSUUID UUID].UUIDString];
    NSData *bigData = UIImageJPEGRepresentation(image, 1);
    BOOL bigResult = [bigData writeToFile:[directoryPath stringByAppendingPathComponent:bigImage] atomically:YES];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDictionary *dictionary = @{@"width":@(width),@"height":@(height)};
    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"image";
    model.fileName = fileName;
    model.measureInfo = [dictionary mj_JSONString];
    if(bigResult) {
        model.bigImage = bigImage;
        if (self.sendMessageBlock) {
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                self.sendMessageBlock(model);
            });
        }
    }
}

/**
 发送位置类型消息

 @param data 位置信息
 @param Snapshot 位置截图
 */
- (void)createMessageModelWithLocationData:(GMSPlace *)data snapshot:(UIImage *)Snapshot {
    
    NSString *directoryPath = [FMDBManager getMapSnapshotPathWithFilePath:self.folderPath];
    NSString *snapshotImage = [NSString stringWithFormat:@"Snapshot_%@.jpg",[NSUUID UUID].UUIDString];
    
    NSData *imageData = UIImageJPEGRepresentation(Snapshot, 0.3);
    BOOL writeResult = [imageData writeToFile:[directoryPath stringByAppendingPathComponent:snapshotImage] atomically:YES];
    
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionary];
    NSString *name = data.name.length ? data.name : @"";
    NSString *address = data.formattedAddress.length ? data.formattedAddress : @"";
    [dataDict setObject:name forKey:@"name"];
    [dataDict setObject:address forKey:@"address"];
    [dataDict setObject:@(data.coordinate.latitude) forKey:@"latitude"];
    [dataDict setObject:@(data.coordinate.longitude) forKey:@"longitude"];
    
    NSString *contentStr = [dataDict mj_JSONString];
    
    MessageModel *model = [[MessageModel alloc] init];
    model.type = @"location";
    model.fileName = snapshotImage;
    model.locationInfo = contentStr;

    if (writeResult) {
        if (self.sendMessageBlock) {
            @weakify(self)
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self)
                self.sendMessageBlock(model);
            });
        }
    }
}

//生成视频消息
- (void)createMessageWithVideoFilePath:(NSString *)videoFilePath
                             videoName:(NSString *)videoName
                      thumbImgFilePath:(NSString *)thumbImgFilePath
                      thumbImgFileName:(NSString *)thumbImgFileName
                           measureInfo:(NSDictionary *)measureInfo
                              duration:(NSString *)duration {
    
    MessageModel *model = [[MessageModel alloc] init];
    model.fileName = videoName;
    model.videoIMGName = thumbImgFileName;
    model.type = @"video";
    model.duration = duration;
    NSString *measureInfoStr = [measureInfo mj_JSONString];
    model.measureInfo = measureInfoStr;
    if (self.sendMessageBlock) {
        @weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            self.sendMessageBlock(model);
        });
    }
    
}

#pragma mark - UIKeyboardNotification
- (void)keyboardWillHideAction:(NSNotification *)note {
    NSDictionary *userInfo = note.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 1.键盘弹出需要的时间
    self.duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    id firstResponder = [keywindow performSelector:@selector(firstResponder)];
    if (firstResponder == self.toolBar.textField) {
        // 这里已经判断出来了第一响应者，可以完成相应的操作
        return;
    }
    [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame state:NO];
    self.keyBoardState = NO;
    NSLog(@"键盘回收");
}
/**
 *  键盘即将弹出
 */
- (void)keyboardWillShowAction:(NSNotification *)note {
    NSLog(@"键盘弹起");
    NSDictionary *userInfo = note.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    self.duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 1.键盘弹出需要的时间
    self.duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    id firstResponder = [keywindow performSelector:@selector(firstResponder)];
    if (firstResponder == self.toolBar.textField) {
        // 这里已经判断出来了第一响应者，可以完成相应的操作
        self.keyBoardState = YES;
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame state:YES];
    }
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame state:(BOOL)state{
    CGFloat toHeight = toFrame.size.height;
    if (state) {//展示键盘
        [self willShowBottomHeight:toHeight];
        if (self.faceView.hidden == NO) {
            self.faceView.hidden = YES;
        }
        
        if (self.moreBoardView.hidden == NO) {
            self.moreBoardView.hidden = YES;
        }
    } else if (!state) {//隐藏键盘
        if (self.faceView.hidden == NO) {
            [self willShowBottomHeight:170 + safeAreaInsetsBottom];//隐藏键盘 并展示表情栏
        } else if (self.moreBoardView.hidden == NO) {
            [self willShowBottomHeight:110 + safeAreaInsetsBottom];//隐藏键盘 并展示更多工具栏
        } else {
            [self willShowBottomHeight:0];
        }
    }
}

- (BOOL)endEditing:(BOOL)force {
    [super endEditing:force];
    [self dissMissAllToolBoard];
//    [self hidenSpaceView];
//    [self hidenMoreBoardView];
    return YES;
}

- (void)willShowBottomHeight:(CGFloat)bottomHeight {
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolBarHeight + bottomHeight;
    if(bottomHeight == 0 && self.frame.size.height == self.toolBarHeight) {
        return;
    }
    
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (bottomHeight > 0) {
            CGRect toFrame = CGRectMake(fromFrame.origin.x, superViewHeight - toHeight, fromFrame.size.width, toHeight);
            self.frame = toFrame;
        } else {
            [self.toolBar showVoiceButton];
            self.frame = CGRectMake(0, superViewHeight - 50 - safeAreaInsetsBottom, SCREEN_WIDTH, 50);
        }
        
        if (self.changeHeightBlock) {
            self.changeHeightBlock(self.frame.size.height);
        }
    } completion:nil];
}

#pragma mark faceView delegate
- (void)selectedFaceWithEmoji:(NSString *)emoji {
    if (self.toolBar.state == NO) {
        [self.toolBar showTextView];
    }
    self.toolBar.textField.text = [self.toolBar.textField.text stringByAppendingString:emoji];
    CGFloat contentheight = self.toolBar.textField.contentSize.height;
    [self.toolBar willShowInputTextViewToHeight:contentheight];
    [self.toolBar textFieldScrollLastLine];
    self.faceView.frame = CGRectMake(0, self.toolBar.height + 10, SCREEN_WIDTH, 150);
}

- (void)deleteFace {
    if([self.toolBar.textField.text length] > 0){
        NSRange range = [self lastRange:self.toolBar.textField.text];
        self.toolBar.textField.text = [self.toolBar.textField.text substringToIndex:([self.toolBar.textField.text length]- range.length)];// 去掉最后一个","
        [self.toolBar willShowInputTextViewToHeight:self.toolBar.textField.contentSize.height];
        self.faceView.frame = CGRectMake(0, self.toolBarHeight+10, SCREEN_WIDTH, 150);
        CGFloat contentheight = self.toolBar.textField.contentSize.height;
        [self.toolBar willShowInputTextViewToHeight:contentheight];
        [self.toolBar textFieldScrollLastLine];
        self.faceView.frame = CGRectMake(0, self.toolBarHeight+10, SCREEN_WIDTH, 150);
    }
}

- (NSRange)lastRange:(NSString *)str {
    NSRange lastRange = [str rangeOfComposedCharacterSequenceAtIndex:str.length-1];
    return lastRange;
}

- (void)displayFaceView {
    if (self.faceView.hidden == YES) {
        CGFloat height = 170 + safeAreaInsetsBottom;
        [self willShowBottomHeight:height];
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.faceView.y = self.toolBarHeight + 10;
            self.faceView.alpha = 1;
            self.faceView.hidden = NO;
            [self setlayoutSubviews];
        } completion:nil];
    }
}

- (void)hidenSpaceView {
    if (self.keyBoardState == YES) {
        if (self.faceView.hidden) {
            [self.toolBar.textField resignFirstResponder];
        } else {
            self.faceView.hidden = YES;
        }
    }
    
    if (self.keyBoardState == NO && self.faceView.hidden == NO) {
        [self willShowBottomHeight:0];
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.faceView.alpha = 0;
            self.faceView.hidden = YES;
            [self.toolBar.textField resignFirstResponder];
        } completion:nil];
    }
}

- (void)showMoreBoardView {
    
    if (!self.moreBoardView.hidden) return;
    if (!self.faceView.hidden) {
        self.faceView.hidden = YES;
    }
    CGFloat height = 110 + safeAreaInsetsBottom;
    [self willShowBottomHeight:height];
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.moreBoardView.y = self.toolBarHeight;
        self.moreBoardView.alpha = 1;
        self.moreBoardView.hidden = NO;
        [self setlayoutSubviews];
    } completion:nil];
    
}

- (void)hidenMoreBoardView {
    if (self.moreBoardView.hidden) return;
    
    if (self.keyBoardState == YES) {
        if (self.moreBoardView.hidden) {
            [self.toolBar.textField resignFirstResponder];
        } else {
            self.moreBoardView.hidden = YES;
        }
    }
    
    if (self.keyBoardState == NO && self.moreBoardView.hidden == NO) {
        [self willShowBottomHeight:0];
        [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.moreBoardView.alpha = 0;
            self.moreBoardView.hidden = YES;
        } completion:nil];
    }
}

- (void)dissMissAllToolBoard {
    //如果是键盘那就隐藏键盘
    if (self.faceView.hidden && self.moreBoardView.hidden) {
        [self.toolBar.textField resignFirstResponder];
        return;
    }
    
    [self willShowBottomHeight:0];
    [UIView animateWithDuration:self.duration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.faceView.alpha = 0;
        self.faceView.hidden = YES;
        
        self.moreBoardView.alpha = 0;
        self.moreBoardView.hidden = YES;
    } completion:nil];
}

- (void)setFolderPath:(NSString *)folderPath {
    _folderPath = folderPath;
    self.toolBar.folderPath = folderPath;
}

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight toolBarHeight:(CGFloat)toolBarHeight{
    if (self.toolBarHeight == toolBarHeight) {
        return;
    }
    
    CGRect rect = self.frame;
    rect.origin.y -= toHeight;
    rect.size.height += toHeight;
    self.toolBar.height = rect.size.height;
    self.toolBarHeight = toolBarHeight;
    self.frame = rect;
    if (self.changeHeightBlock) {
        self.changeHeightBlock(self.frame.size.height);
    }
    [self setlayoutSubviews];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    //获取授权
    BOOL fileUrlAuthozied = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileUrlAuthozied) {
        //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error;
        @weakify(self)
        [fileCoordinator coordinateReadingItemAtURL:urls.firstObject options:0 error:&error byAccessor:^(NSURL *newURL) {
            @strongify(self)
            //读取文件
            NSString *fileName = [newURL lastPathComponent];//带后缀文件名
            NSString *suffix = [newURL pathExtension];//文件后缀
            NSLog(@"---%@",suffix);
            NSError *error = nil;
            
            NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
            if (error) {
                //读取出错
            } else {
                MessageModel *message = [[MessageModel alloc] init];
                message.type = [MessageModel getFileTypeWithSuffix:suffix];
                message.fileName = fileName;
                if ([message.type isEqualToString:@"image"]) {
                    [self creatImageMsgWithMsg:message data:fileData];
                }else if ([message.type isEqualToString:@"video"]) {
                    [self creatVideoMsgWithNSURL:newURL msg:message data:fileData];
                }else if ([message.type isEqualToString:@"file"]) {
                    message.content = [NSString stringWithFormat:@"%@%@",[NSDate getNowTimestamp],fileName];
                    message.fileSize = [NSString stringWithFormat:@"%ld",fileData.length];
                    NSString * directoryPath = [FMDBManager getMessagePathWithMessage:message];
                    BOOL result = [fileData writeToFile:[directoryPath stringByAppendingPathComponent:message.content] atomically:YES];
                    if (result) {
                        NSLog(@"写入成功");
                    }
                }
                if (self.sendMessageBlock) {
                    self.sendMessageBlock(message);
                }
            }
            
            [controller dismissViewControllerAnimated:YES completion:NULL];
        }];
        
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        //授权失败
    }
}

- (void)creatVideoMsgWithNSURL:(NSURL*)url msg:(MessageModel *)message  data:(NSData*)data {
    NSString *videoPath = [FMDBManager getVideoPathWithFilePath:self.folderPath];

    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    NSString *thumbImgName = [NSString stringWithFormat:@"VideoThumbIMG_%@.jpg", [NSUUID UUID].UUIDString];
    NSString *videoName = [NSString stringWithFormat:@"VShotVideo_%@.mp4", [NSUUID UUID].UUIDString];
    [data writeToFile:[videoPath stringByAppendingPathComponent:videoName] atomically:YES];
    NSData *imageData = UIImageJPEGRepresentation(videoImage, 0.1);
    [imageData writeToFile:[videoPath stringByAppendingPathComponent:thumbImgName] atomically:YES];
    message.fileName = videoName;
    message.videoIMGName = thumbImgName;
    message.duration = [NSString stringWithFormat:@"%f",CMTimeGetSeconds(asset.duration)];
    
    NSMutableDictionary *measureInfo = [NSMutableDictionary dictionary];
    [measureInfo setObject:@(videoImage.size.width) forKey:@"width"];
    [measureInfo setObject:@(videoImage.size.height) forKey:@"height"];
    NSString *measureInfoStr = [measureInfo mj_JSONString];
    message.measureInfo = measureInfoStr;
}

- (void)creatImageMsgWithMsg:(MessageModel *)message data:(NSData *)data {
    NSString * directoryPath = [FMDBManager getImagePathWithFilePath:self.folderPath];
    UIImage *image = [UIImage imageWithData:data];
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    NSDictionary *dictionary = @{@"width":@(width),@"height":@(height)};
    NSString *fileType = @"jpg";
    uint8_t c;
    [data getBytes:&c length:1];
    if (c == 0x47) {
        fileType = @"gif";
    }
    NSData *smalldata = UIImageJPEGRepresentation(image, 0.1);
    NSString *smallName = [NSString stringWithFormat:@"image_small_%@.%@", [NSUUID UUID].UUIDString, fileType];
    NSString *smallFilePath = [directoryPath stringByAppendingPathComponent:smallName];
    
    [smalldata writeToFile:smallFilePath atomically:YES];
    
    NSString *bigImage = [NSString stringWithFormat:@"image_big_%@.%@", [NSUUID UUID].UUIDString, fileType];
    
    [data writeToFile:[directoryPath stringByAppendingPathComponent:bigImage] atomically:YES];
    
    message.fileName = smallName;
    message.measureInfo = [dictionary mj_JSONString];
    message.bigImage = bigImage;
}

#pragma mark - ALMoreKeyboardDelegate
- (void)moreKeyboard:(id)keyboard didSelectedFunctionItem:(ALMoreKeyboardItem *)funcItem {
    switch (funcItem.type) {
        case ALMoreKeyboardItemTypeFile:
            [self chooseSendFile];
            break;
            
        case ALMoreKeyboardItemTypePosition:
            [self choosePosition];
            break;
        case ALMoreKeyboardItemTypeCard:
            [self chooseSendCard];
            break;
            
        default:
            break;
    }
}

#pragma mark  懒加载
- (ToolBarView *)toolBar {
    if (!_toolBar) {
        _toolBar = [[ToolBarView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.toolBarHeight) delegate:self];
        @weakify(self)
        _toolBar.toolBarClickBlock = ^(int index) {
            @strongify(self)
            switch (index) {
                case 1:
                    [self chooseType:0];//相册
                    break;
                    
                case 2:
                    [self chooseType:1];//相机
                    break;
                    
                case 3:{
                    [self hidenMoreBoardView];
                    if (self.faceView.hidden == YES) {
                        [self displayFaceView];
                    }else {
                        [self hidenSpaceView];
                    }
                }
                    break;
                    
                case 5:
                    if (self.moreBoardView.hidden) {
                        [self showMoreBoardView];
                    }
                    break;
                    
                default:
                    break;
            }
        };
        
        _toolBar.sendMessageBlock = ^(MessageModel *model) {
            @strongify(self)
            if (self.sendMessageBlock) {
                self.sendMessageBlock(model);
            }
        };
    }
    return _toolBar;
}

- (EaseFaceView *)faceView {
    if (!_faceView) {
        _faceView = [[EaseFaceView alloc] initWithFrame:CGRectMake(0, self.toolBarHeight+10, SCREEN_WIDTH, 150)];
        [_faceView setDelegate:self];
        _faceView.hidden = YES;
    }
    return _faceView;
}

- (ALMoreKeyBoard *)moreBoardView {
    if (!_moreBoardView) {
        _moreBoardView = [[ALMoreKeyBoard alloc] initWithFrame:CGRectMake(0, self.toolBarHeight, SCREEN_WIDTH, 110)];
        _moreBoardView.backgroundColor = [UIColor ALGrayBgColor];
        _moreBoardView.hidden = YES;
        _moreBoardView.delegate = self;
    }
    return _moreBoardView;
}

- (UIButton *)creatButtonWithImage:(NSString *)image tag:(int)tag {
    UIButton *button =[UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setTag:tag];
    return button;
}

- (CGFloat)toolBarHeight {
    if (_toolBarHeight == 0) {
        _toolBarHeight = 50;
    }
    return _toolBarHeight;
}

- (CGFloat)duration {
    if (_duration <= 0.1) {
        _duration = 0.25;
    }
    return _duration;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end

