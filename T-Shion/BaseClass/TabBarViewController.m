//
//  TabBarViewController.m
//  T-Shion
//
//  Created by together on 2018/3/20.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "TabBarViewController.h"
#import "BaseTabBar.h"
#import "BaseNavigationViewController.h"
#import "SessionViewController.h"
#import "MyFriendViewController.h"


@interface TabBarViewController ()
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    [FMDBManager setNotifySeting];
    BaseTabBar *tabbar = [[BaseTabBar alloc] init];
    //选中时的颜色
    [tabbar setShadowImage:[UIImage imageWithColor:[UIColor ALLineColor] size:CGSizeMake(SCREEN_WIDTH, .5)]];
    [tabbar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    //透明设置为NO，显示白色，view的高度到tabbar顶部截止，YES的话到底部
    tabbar.translucent = NO;
    //利用KVC 将自己的tabbar赋给系统tabBar
    [self setValue:tabbar forKeyPath:@"tabBar"];
    [self addChildController];
    [[SocketViewModel shared].getNewFriendCommand execute:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addChildController { 
    [self setupChildVc:[[SessionViewController alloc] init]
                 image:@"tabBar_icon_message_normal"
         selectedImage:@"tabBar_icon_message_selected"
                 title:Localized(@"home_navigation_title")];
    
    [self setupChildVc:[[MyFriendViewController alloc] init]
                 image:@"tabBar_icon_friend_normal"
         selectedImage:@"tabBar_icon_friend_selected"
                 title:Localized(@"friend_navigation_title")];

    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"NewFirendPrompt" object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *key = [NSString stringWithFormat:@"%@_Friend_Count",[SocketViewModel shared].userModel.ID];
            NSString *number = [[NSUserDefaults standardUserDefaults] objectForKey:key];
            int badge =  [number intValue];
            UITabBarItem *item = self.tabBar.items[1];
            if (badge == 0) {
                item.badgeValue = nil;
            }else {
                item.badgeValue = @"1";
            }
        });
    }];
}

- (void)buttonAction:(UIButton *)sender {
//    TakingPicturesViewController *takingPictures = [[TakingPicturesViewController alloc] init];
//    [self presentViewController:takingPictures animated:YES completion:nil];  
}


/**
 * 初始化子控制器
 */
- (void)setupChildVc:(UIViewController *)vc image:(NSString *)image selectedImage:(NSString *)selectedImage title:(NSString *)title{
    vc.title = title;
    // 设置文字和图片
    vc.tabBarItem.image = [[UIImage imageNamed:image] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    vc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    
    [vc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont ALFontSize12],
                                   NSForegroundColorAttributeName :[UIColor ALTextGrayColor]} forState:UIControlStateNormal];
    
    [vc.tabBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont ALFontSize12],
                                   NSForegroundColorAttributeName :[UIColor ALKeyColor]} forState:UIControlStateSelected];
    
    BaseNavigationViewController *nav = [[BaseNavigationViewController alloc] initWithRootViewController:vc];
    nav.view = nil;
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_image"] forBarMetrics:UIBarMetricsDefault];
    nav.navigationBar.barTintColor = [UIColor whiteColor];
    [nav.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:RGB(51, 51, 51), NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
    [self addChildViewController:nav];
}

- (void)dealloc {
//    NSLog(@"tabbar 被释放");
}
@end
