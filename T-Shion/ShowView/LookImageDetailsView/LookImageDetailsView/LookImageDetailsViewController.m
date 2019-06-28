//
//  LookImageDetailsViewController.m
//  T-Shion
//
//  Created by together on 2018/12/27.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "LookImageDetailsViewController.h"
#import "LookImageDetailsView.h"

@interface LookImageDetailsViewController ()
@property (strong, nonatomic) LookImageDetailsView *detailsView;
@property (strong, nonatomic) NSMutableArray *array;
@property (assign, nonatomic) int index;
@end

@implementation LookImageDetailsViewController

- (instancetype)initWithArray:(NSArray *)photosArr currentIndex:(int)currentIndex {
    self = [super init];
    if (self) {
        self.array = [NSMutableArray array];
        [self.array addObjectsFromArray:photosArr];
        self.index = currentIndex;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.detailsView];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [UIApplication sharedApplication].statusBarHidden = YES;
    [self.detailsView.collectionView setContentOffset:CGPointMake((self.view.width + 20) * self.index, 0) animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
    [super viewWillDisappear:animated];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (LookImageDetailsView *)detailsView {
    if (!_detailsView) {
        _detailsView = [[LookImageDetailsView alloc] initWithFrame:self.view.frame array:self.array currentIndex:self.index];
    }
    return _detailsView;
}

@end
