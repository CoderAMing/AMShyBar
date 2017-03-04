//
//  StyleOne.m
//  AMShyBarDemo
//
//  Created by Min on 2017/3/5.
//  Copyright © 2017年 Min. All rights reserved.
//

#import "StyleOne.h"

@implementation StyleOne

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundColor = [UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0];
    
    
    CGFloat btnW = [UIScreen mainScreen].bounds.size.width * 0.5;
    CGFloat bntH = self.frame.size.height;
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, btnW, bntH)];
    leftBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [leftBtn setTitle:@"精选" forState:UIControlStateNormal];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnW, 0, btnW, bntH)];
    rightBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [rightBtn setTitle:@" 价格" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"1"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
    rightBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(btnW, 6, 1, self.frame.size.height-12)];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.2;
    
    [self addSubview:leftBtn];
    [self addSubview:rightBtn];
    [self addSubview:line];
}

@end
