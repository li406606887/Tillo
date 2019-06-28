//
//  EaseFaceView.m
//  T-Shion
//
//  Created by together on 2018/8/22.
//  Copyright © 2018年 With_Dream. All rights reserved.
//

#import "EaseFaceView.h"

#define kButtomNum 7

@interface EaseFaceView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSArray *emojiWithArray;
@end

@implementation EaseFaceView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addChildView];
    }
    return self;
}

#pragma mark - private

- (void)addChildView {    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    [self addSubview:self.scrollView];
    [self addFaceView];
}

- (void)addFaceView {
    int number = (int)self.emojiWithArray.count;
    if (number <= 1) {
        return;
    }
    for (int i = 0; i<number ; i++) {
        NSArray *array = self.emojiWithArray[i];
        UIView *faceView = [self getFaceViewWithArray:array];
        faceView.frame = CGRectMake(i*SCREEN_WIDTH, 0, SCREEN_WIDTH, 130);
        [self.scrollView addSubview:faceView];
    }
    [self.scrollView setContentSize:CGSizeMake(number*SCREEN_WIDTH, 0)];
}

- (UIView*)getFaceViewWithArray:(NSArray *)array {
    UIView *view = [[UIView alloc] init];
    int count = (int)array.count+1;
   CGFloat width = (SCREEN_WIDTH-30)/7;
    for (int i = 0; i < count; i++) {
        int line = i/7;
        int column = i%7;
        float x = 15 + width* column;
        float y = 10 + line* 33;
        if (i+1==count) {
            UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton setBackgroundColor:[UIColor clearColor]];
            deleteButton.frame = CGRectMake(15 + width* 6, 109, width, 30);
            [deleteButton setImage:[UIImage imageNamed:@"Session_face_Delete"] forState:UIControlStateNormal];
            [deleteButton setImage:[UIImage imageNamed:@"Session_face_Delete"] forState:UIControlStateHighlighted];
            [deleteButton addTarget:self action:@selector(deleteEmoji:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:deleteButton];
        }else {
            UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
            defaultButton.frame = CGRectMake(x, y, width, 30);
            [defaultButton setTitle:array[i] forState:UIControlStateNormal];
            [defaultButton addTarget:self action:@selector(didSelect:) forControlEvents:UIControlEventTouchUpInside];
            [defaultButton.titleLabel setFont:[UIFont systemFontOfSize:26]];
            [view addSubview:defaultButton];
        }
    }
    return view;
}

#pragma mark - action
- (void)didSelect:(id)sender {
    UIButton *btn = (UIButton*)sender;
    NSString *face = btn.titleLabel.text;
    [self.delegate selectedFaceWithEmoji:face];
}

- (void)deleteEmoji:(id)sender {
    [self.delegate deleteFace];
}
#pragma mark - public
- (NSArray *)emojiWithArray {
    if (!_emojiWithArray) {
        _emojiWithArray = @[
        @[@"😀",@"😁",@"😂",@"🤣",@"😃",@"😄",@"😅",@"😆",@"😉",@"😊",@"😋",@"😎",@"😍",@"😘",@"😙",@"🙂",@"🤗",@"😜",@"🤔",@"😳",@"😶",@"🙄",@"😏",@"😥",@"🤐",@"😪",@"😫"],
        @[@"😴",@"😛",@"🤥",@"😝",@"🤤",@"😒",@"😓",@"😔",@"🙃",@"🤑",@"😲",@"😨",@"😩",@"🤕",@"😬",@"😰",@"😱",@"🤓",@"🤧",@"😵",@"😡",@"😠",@"😤",@"😇",@"😷",@"🤒",@"😺"],
        @[@"😻",@"🙀",@"😼",@"😾",@"😿",@"😽",@"😹",@"😸",@"😺",@"😈",@"💀",@"👻",@"👽",@"🤖",@"💩",@"🙎‍♀️",@"🙎‍♂️",@"🙅‍♀️",@"🙅‍♂️",@"🙋‍♂️",@"🙋‍♀️",@"🤦‍♀️",@"🤦‍♂️",@"👫",@"👬",@"👭",@"💑"],
        @[@"🕺",@"👨‍👩‍👧‍👦",@"💃",@"💪",@"👈",@"👉",@"☝️",@"👇",@"🤞",@"🤘",@"✋",@"🖐",@"👌",@"👍",@"👎",@"✊",@"👊",@"🤛",@"🤜",@"🤝",@"🙌",@"👏",@"🙏",@"👃",@"👂",@"👀",@"💋"],
        @[@"🎱",@"👄",@"🏊",@"👓",@"🕶",@"👔",@"👕",@"👖",@"👣",@"💘",@"👗",@"👙",@"👜",@"🍟",@"🎓",@"👑",@"🎧",@"💍",@"👠",@"👟",@"🔀",@"💭",@"📖",@"⚡",@"💡",@"🔥",@"☘"],
        @[@"🌱",@"🍦",@"🏈",@"🎾",@"⚽",@"💻",@"🍔",@"💥",@"💧",@"💦",@"💨",@"💯",@"🍥",@"🍧",@"🍚",@"🍖",@"🍢"]];
    }
    return _emojiWithArray;
}
@end
