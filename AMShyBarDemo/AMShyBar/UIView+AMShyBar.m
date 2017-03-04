//
//  UIView+AMShyBar.m
//  Copyright © 2017年 Min. All rights reserved.
//

#import "UIView+AMShyBar.h"
#import <objc/runtime.h>

#define kNearZero 0.000001f
#define IS_IPHONE_6_PLUS [UIScreen mainScreen].scale == 3
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation UIView (AMShyBar)
#pragma mark - Setter/Getter
- (void)setAm_entirelyContractedShyBar:(BOOL)am_entirelyContractedShyBar {
    objc_setAssociatedObject(self, @selector(am_entirelyContractedShyBar), @(am_entirelyContractedShyBar), OBJC_ASSOCIATION_RETAIN); }
- (BOOL)am_entirelyContractedShyBar { return [objc_getAssociatedObject(self, @selector(am_entirelyContractedShyBar)) boolValue]; }

- (void)setAm_ExpandedExposedHeight:(CGFloat)am_ExpandedExposedHeight {
    objc_setAssociatedObject(self, @selector(am_ExpandedExposedHeight), @(am_ExpandedExposedHeight), OBJC_ASSOCIATION_RETAIN);
}
- (CGFloat)am_ExpandedExposedHeight { return [objc_getAssociatedObject(self, @selector(am_ExpandedExposedHeight)) floatValue];}

- (CGFloat)am_expandedOffsetY
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || IS_IPHONE_6_PLUS) {
        return ([[UIApplication sharedApplication] isStatusBarHidden]) ? 44 : 64;
    } else {
        if ([[UIApplication sharedApplication] isStatusBarHidden]) {
            return (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 44 : 32);
        } else {
            return (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? 64 : 52);
        }
    }
}

- (CGFloat)am_contractedOffsetY
{
    return (self.am_expandedOffsetY - CGRectGetHeight(self.frame) + self.am_ExpandedExposedHeight);
}

#pragma makr - Public Method
- (CGFloat)am_updateOffsetY:(CGFloat)deltaY {
    
    CGFloat viewOffsetY = 0.f;
    CGFloat currentViewY = CGRectGetMinY(self.frame);
    CGFloat newOffsetY = [self am_offsetYWithDelta:deltaY];
    viewOffsetY = currentViewY - newOffsetY;
    
    if (0 == viewOffsetY) {
        return viewOffsetY;
    }
    
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = newOffsetY;
    self.frame = viewFrame;
    
    CGFloat alpha = 1 - fabs(viewFrame.origin.y - self.am_expandedOffsetY) * 0.5f / ([self am_ViewMaxY] - [self am_viewMinY]);
    alpha = MAX(kNearZero, alpha);
    [self am_adjustShyBarToAlpha:alpha];
    if (self.am_isContracted) {
        [self am_adjustShyBarToAlpha:kNearZero];
    }
    return viewOffsetY;
}

- (CGFloat)am_expand {
    CGFloat viewOffsetY = 0.f;
    viewOffsetY = CGRectGetMinY(self.frame) - self.am_expandedOffsetY;
    
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = self.am_expandedOffsetY;
    self.frame = viewFrame;

    [self am_adjustShyBarToAlpha:1.f];
    return viewOffsetY;
}

- (CGFloat)am_contract
{
    CGFloat viewOffsetY = 0.f;
    viewOffsetY = CGRectGetMinY(self.frame) - self.am_contractedOffsetY;
    
    CGRect viewFrame = self.frame;
    viewFrame.origin.y = self.am_contractedOffsetY;
    self.frame = viewFrame;

    [self am_adjustShyBarToAlpha:kNearZero];

    return viewOffsetY;
}

- (BOOL)am_shouldExpand
{
    CGFloat viewY = CGRectGetMinY(self.frame);
    CGFloat viewMinY = 0.f;
    viewMinY = self.am_contractedOffsetY + (self.am_expandedOffsetY - self.am_contractedOffsetY) * 0.5;
    return (viewY >= viewMinY);
}

- (CGFloat)am_viewMinY
{
    return MIN(self.am_expandedOffsetY, self.am_contractedOffsetY);
}

- (CGFloat)am_ViewMaxY
{
    return MAX(self.am_expandedOffsetY, self.am_contractedOffsetY);
}

- (BOOL)am_isExpanded
{
    return CGRectGetMinY(self.frame) == self.am_expandedOffsetY;
}

- (BOOL)am_isContracted
{
    return CGRectGetMinY(self.frame) == self.am_contractedOffsetY;
}

#pragma mark - Private Method 
- (CGFloat)am_offsetYWithDelta:(CGFloat)deltaY
{
    CGFloat newOffsetY = 0.f;
    CGFloat expandedOffsetY = self.am_expandedOffsetY;
    CGFloat contractedOffsetY = self.am_contractedOffsetY;
    
    newOffsetY = CGRectGetMinY(self.frame) - deltaY;
    return MAX(contractedOffsetY, MIN(expandedOffsetY, newOffsetY));
}

- (void)am_adjustShyBarToAlpha:(CGFloat)alpha
{
    if (self.am_entirelyContractedShyBar) {
        self.alpha = alpha;
    }
}

@end
