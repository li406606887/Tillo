//
//  SendCardViewController.m
//  AilloTest
//
//  Created by together on 2019/6/19.
//  Copyright © 2019 With_Dream. All rights reserved.
//

#import "SendCardViewController.h"
#import "SendCardView.h"
#import "SendCardViewModel.h"

@interface SendCardViewController ()
@property (nonatomic, strong) SendCardViewModel *viewModel;

@property (nonatomic, strong) SendCardView *mainView;

@end

@implementation SendCardViewController

- (instancetype)initWithUid:(NSString *)uid {
    self = [super init];
    if (self) {
        self.viewModel.uid = uid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:Localized(@"Cancel") forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor ALBtnNormalColor] forState:UIControlStateNormal];
    @weakify(self)
    [[[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
     @strongify(self)
        [self dismissViewController];
    }];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    [[self.viewModel.clickSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        FriendsModel *model = (FriendsModel *)x;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setObject:model.userId forKey:@"friendId"];
        [dic setObject:model.name forKey:@"name"];
        [dic setObject:model.avatar forKey:@"avatar"];
        [dic setObject:[NSString stringWithFormat:@"+%@ %@",model.dialCode,model.mobile] forKey:@"mobile"];
        if (self.clickCardBlock) {
            self.clickCardBlock([NSString dictionaryToJson:dic]);
        }
        [self dismissViewController];
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (SendCardView *)mainView {
    if (!_mainView) {
        _mainView = [[SendCardView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (SendCardViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[SendCardViewModel alloc] init];
    }
    return _viewModel;
}
@end
