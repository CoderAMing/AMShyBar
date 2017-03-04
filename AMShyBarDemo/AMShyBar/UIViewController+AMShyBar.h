//
//  UIViewController+AMShyBar.h
//  Copyright © 2017年 Min. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AMShyBarState) {
    /** 展开状态 默认状态 */
    AMShyBarStateExpanded = 0,
    /** 展开中状态 */
    AMShyBarStateExpanding,
    /** 收起中状态 */
    AMShyBarStateContracting,
    /** 收起状态 */
    AMShyBarStateContracted
};

@interface UIViewController (AMShyBar)<UIGestureRecognizerDelegate>

- (void)am_shyBarWithScrollView:(UIView *)scrollableView;

/** 删除scrollview跟踪 */
- (void)am_stopFollowingScrollView;

- (void)am_customShyBar:(UIView *)shyBar;

- (void)am_expand;

- (void)am_contract;

typedef void(^AMShyBarDidChangeBlock)(AMShyBarState shyBarState);

- (void)am_shyBarDidChangeStateBlock:(AMShyBarDidChangeBlock)block;

@end
