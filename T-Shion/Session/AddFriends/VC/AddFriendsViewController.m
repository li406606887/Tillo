//
//  AddFriendsViewController.m
//  T-Shion
//
//  Created by together on 2018/4/2.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "AddFriendsViewModel.h"
#import "AddFriendsView.h"
#import "AddFriendsModel.h"
#import "ALSearchView.h"
#import "StrangerViewController.h"
#import "OtherInformationViewController.h"

@interface AddFriendsViewController ()<ALSearchVeiwDelegate>
@property (strong, nonatomic) AddFriendsViewModel *viewModel;
@property (strong, nonatomic) AddFriendsView *mainView;
@property (copy, nonatomic) NSString *lastTextContent;
@property (nonatomic, strong) ALSearchView *searchView;

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = self.searchView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildView {
//    [self.view addSubview:self.mainView];
}

- (void)viewDidLayoutSubviews {
//    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    
    [super viewDidLayoutSubviews];
}

- (void)bindViewModel {
    @weakify(self)
    
//    [self.viewModel.showAddViewSubject subscribeNext:^(AddFriendsModel *model) {
//     @strongify(self)
//        [self showAddFirendView:model];
//    }];
    
    [[self.viewModel.searchFriendsSubject takeUntil:self.rac_willDeallocSignal] subscribeNext:^(AddFriendsModel *model) {
        @strongify(self)
        if (model.roomId.length >0) {
            OtherInformationViewController *otherVC = [[OtherInformationViewController alloc] init];
            FriendsModel *friendsModel = [[FriendsModel alloc] init];
            friendsModel.userId = model.uid;
            friendsModel.avatar = model.avatar;
            friendsModel.roomId = model.roomId;
            friendsModel.name = model.name;
            friendsModel.showName = model.name;
            friendsModel.sex = model.sex;
            friendsModel.mobile = model.mobile;
            friendsModel.region = model.region;
            if (friendsModel.userId>0) {
                otherVC.model = friendsModel;
                [self.navigationController pushViewController:otherVC animated:YES];
            }
        } else {
            StrangerViewController *strangerVC = [[StrangerViewController alloc] init];
            strangerVC.model = model;
            [self.navigationController pushViewController:strangerVC animated:YES];
        }
    }];
}

- (void)showAddFirendView:(AddFriendsModel *)model {
    
    // 1.创建UIAlertController
    __block UITextField *field;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"验证信息"
                                                                             message:@""
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"";
        field = textField;
    }];
    
    @weakify(self)
    [[[field rac_textSignal] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        int bytes = [self stringConvertToInt:x];
        //设置不能超过32个字节，因为不能有半个汉字，所以以字符串长度为单位。
        if (bytes > 15){
            //超出字节数，还是原来的内容
            int lengh = [self stringConvertToInt:self.lastTextContent];
            if (lengh>15) {
                self.lastTextContent = [self.lastTextContent substringWithRange:NSMakeRange(0, lengh - 16)];
            }
            field.text = self.lastTextContent;
        }else {
            self.lastTextContent = x;
        }
    }];
    
    UIAlertAction *send = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:@"0" forKey:@"status"];//0表示申请加好友  1表示通过
            [param setObject:[SocketViewModel shared].userModel.ID forKey:@"sender"];
            [param setObject:model.uid forKey:@"receiver"];
            [param setObject:field.text forKey:@"remark"];
            [self.viewModel.addFriendsCommand execute:param];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Reset Action");
    }];
    [alertController addAction:send];
    [alertController addAction:cancel];
    // 3.显示警报控制器
    [self presentViewController:alertController animated:YES completion:nil];
}

//得到字节数函数
-  (int)stringConvertToInt:(NSString*)strtemp {
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return (strlength+1)/2;
}

#pragma mark - ALSearchVeiwDelegate
- (void)al_didCancelButtonClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)al_didSearchButtonClick:(NSString *)searchText {
    if (searchText.length == 0) {
        return;
    }
    [self.viewModel.searchFriendsCommand execute:@{@"mobile":searchText}];
}


#pragma mark - getter
- (AddFriendsView *)mainView {
    if (!_mainView) {
        _mainView = [[AddFriendsView alloc] initWithViewModel:self.viewModel];
    }
    return _mainView;
}

- (AddFriendsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[AddFriendsViewModel alloc] init];
    }
    return _viewModel;
}

- (ALSearchView *)searchView {
    if (!_searchView) {
        _searchView = [[ALSearchView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 30)];
        _searchView.placeholder = Localized(@"search_placeholder_phone");
        _searchView.placeholderFont = 13;
        _searchView.delegate = self;
        [_searchView.searchBar becomeFirstResponder];
        _searchView.cancelBtnAlways = YES;
    }
    return _searchView;
}

- (void)dealloc {
    NSLog(@"添加好友界面释放了");
}
@end
