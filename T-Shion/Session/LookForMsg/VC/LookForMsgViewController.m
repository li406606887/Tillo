//
//  LookForMsgViewController.m
//  AilloTest
//
//  Created by together on 2019/4/22.
//  Copyright © 2019年 With_Dream. All rights reserved.
//

#import "LookForMsgViewController.h"
#import "GFCalendarView.h"
#import "SearchMsgViewController.h"
#import "QueryHistoryViewController.h"
#import "MessageRoomViewController.h"
#import "GroupMessageRoomController.h"

@interface LookForMsgViewController ()
@property (strong, nonatomic) GFCalendarView *mainView;
@property (strong, nonatomic) UIButton *searchView;
@property (strong, nonatomic) UIView *titleView;
@property (copy, nonatomic) NSString *roomId;
@end

@implementation LookForMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)addChildView {
    [self.view addSubview:self.mainView];
    
}

- (void)viewDidLayoutSubviews {
//    [self.mainView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.mainView);
//    }];
    [super viewDidLayoutSubviews];
}

- (UIView *)centerView {
    return self.titleView;
}

- (void)setFModel:(FriendsModel *)fModel {
    _fModel = fModel;
    self.roomId = fModel.roomId;
}

- (void)setGroup:(GroupModel *)group {
    _group = group;
    self.roomId = group.roomId;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (GFCalendarView *)mainView {
    if (!_mainView) {
        _mainView = [[GFCalendarView alloc] initWithFrameOrigin:CGPointMake(0, 0) width:SCREEN_WIDTH];
        @weakify(self)
        _mainView.didSelectDayHandler = ^(NSInteger y, NSInteger m, NSInteger d) {
            @strongify(self)
            NSString *format = [NSString stringWithFormat:@"%ld-%ld-%ld 00:00:00",y,m,d];
            NSInteger timestamp = [NSDate dateTransformTimestamp:format];
            NSString *times = [NSString stringWithFormat:@"%ld",timestamp];
            int count = [FMDBManager selectedHistoryMsgWithRoomId:self.roomId timestamp:times];
            if (self.fModel) {
                MessageRoomViewController *single = [[MessageRoomViewController alloc] initWithModel:self.fModel count:count type:Loading_LOOKFOR_MESSAGES];
                [self.navigationController pushViewController:single animated:YES];
            }else {
                GroupMessageRoomController *group = [[GroupMessageRoomController alloc] initWithModel:self.group count:count type:Loading_LOOKFOR_MESSAGES];
                [self.navigationController pushViewController:group animated:YES];
            }
        };
        _mainView.backgroundColor = [UIColor whiteColor];
    }
    return _mainView;
}

- (UIButton *)searchView {
    if (!_searchView) {
        _searchView = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_searchView setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateNormal];
        
        [_searchView setBackgroundImage:[UIImage imageWithColor:[UIColor ALGrayBgColor]] forState:UIControlStateHighlighted];
        
        _searchView.layer.masksToBounds = YES;
        _searchView.layer.cornerRadius = 15;
        _searchView.frame = CGRectMake(0, 0, SCREEN_WIDTH - 120, 30);
        
        UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"public_search"]];
        [_searchView addSubview:searchIcon];
        searchIcon.x = 15;
        searchIcon.centerY = 15;
        
        UILabel *tipLabel = [UILabel constructLabel:CGRectMake(searchIcon.x + searchIcon.width + 4, 0, 200, 20)
                                               text:Localized(@"search_placeholder")
                                               font:[UIFont systemFontOfSize:13]
                                          textColor:[UIColor ALTextGrayColor]];
        tipLabel.textAlignment = NSTextAlignmentLeft;
        [_searchView addSubview:tipLabel];
        tipLabel.centerY = 15;
        
        @weakify(self);
        [[_searchView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            SearchMsgViewController *search;
            if (self.fModel) {
                search = [[SearchMsgViewController alloc] initWithRoomId:self.fModel.roomId type:1];
            }else {
                search = [[SearchMsgViewController alloc] initWithRoomId:self.group.roomId type:0];
            }
            search.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:search];
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }
    return _searchView;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 120, 30)];
        [_titleView addSubview:self.searchView];
    }
    return _titleView;
}

@end
