//
//  LookForFileViewController.m
//  T-Shion
//
//  Created by together on 2019/4/12.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForFileViewController.h"
#import "LookForFileViewModel.h"
#import "LookForFileMainView.h"
#import "LookImageDetailsViewController.h"
#import "ALMoviePlayerView.h"
#import "DownFileViewController.h"

@interface LookForFileViewController ()
@property (strong, nonatomic) LookForFileMainView *mainView;
@property (strong, nonatomic) LookForFileViewModel *viewModel;
@property (copy, nonatomic) NSString *roomId;
@end

@implementation LookForFileViewController
- (instancetype)initWithRoomId:(NSString *)roomId type:(int)type {
    self = [super init];
    if (self) {
        self.viewModel.type = type;
        self.roomId = roomId;
        self.viewModel.roomId = roomId;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:Localized(@"Chat_file")];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
}

- (void)bindViewModel {
    @weakify(self)
    [self.viewModel.clickFileSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        DownFileViewController *downFile = [[DownFileViewController alloc] initWithMessage:x];
        [self.navigationController pushViewController:downFile animated:YES];
    }];
    
    [self.viewModel.clickAssetSubject subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        MessageModel *model = (MessageModel *)x;
        if (model.msgType == MESSAGE_IMAGE) {
            [self lookBigImageWithModel:model];
        }else {
            [self lookVideoWithModel:model];
        }
    }];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)lookVideoWithModel:(MessageModel *)model {
    ALMoviePlayerView *playerView = [[ALMoviePlayerView alloc] init];
    NSString *filePath = [[FMDBManager getMessagePathWithMessage:model] stringByAppendingPathComponent:model.fileName];
    if ([FMDBManager seletedFileIsSaveWithPath:model]) {
        playerView.movieURL = [NSURL fileURLWithPath:filePath];
    } else {
        NSString *hostUrl = [NSString stringWithFormat:@"%@/file/getFile?id=%@",UploadHostUrl,model.sourceId];
        playerView.filePath = filePath;
        playerView.movieURL = [NSURL URLWithString:hostUrl];
    }
    [playerView showWithMessageId:model.messageId isSoundOff:NO];
}

- (void)lookBigImageWithModel:(MessageModel *)model {
    NSDictionary *dictionary = [FMDBManager selectImageWithRoom:model.roomId messageId:model.messageId];
    NSArray *array = dictionary.allKeys;
    if (array.count>0) {
        int index = [[NSString stringWithFormat:@"%@",array[0]] intValue];
        NSArray *dataArray = [dictionary objectForKey:@(index)];
        dispatch_async(dispatch_get_main_queue(), ^{
            LookImageDetailsViewController *lookDetails = [[LookImageDetailsViewController alloc] initWithArray:dataArray currentIndex:index];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:lookDetails animated:YES completion:nil];
        });
    }
}

- (LookForFileMainView *)mainView {
    if (!_mainView) {
        _mainView = [[LookForFileMainView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (LookForFileViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LookForFileViewModel alloc] init];
    }
    return _viewModel;
}

- (void)dealloc {
    NSLog(@"%@界面释放",self);
}
@end
