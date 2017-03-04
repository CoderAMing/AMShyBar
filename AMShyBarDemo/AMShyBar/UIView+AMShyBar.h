//
//  UIView+AMShyBar.h
//  Copyright © 2017年 Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AMShyBar)

/** Bar是否完全收起 默认:YES */
- (void)setAm_entirelyContractedShyBar:(BOOL)enabled;

- (void)setAm_ExpandedExposedHeight:(CGFloat)height;

- (CGFloat)am_expandedOffsetY;

- (CGFloat)am_contractedOffsetY;

- (CGFloat)am_updateOffsetY:(CGFloat)deltaY;

- (CGFloat)am_expand;

- (CGFloat)am_contract;

- (BOOL)am_shouldExpand;

- (BOOL)am_isExpanded;

- (BOOL)am_isContracted;

@end
