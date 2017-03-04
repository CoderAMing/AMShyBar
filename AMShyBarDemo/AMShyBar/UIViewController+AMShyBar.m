//
//  UIViewController+AMShyBar.m
//  Copyright © 2017年 Min. All rights reserved.
//

#import "UIViewController+AMShyBar.h"
#import "UIView+AMShyBar.h"
#import <objc/runtime.h>

@implementation UIViewController (AMShyBar)

#pragma mark - Public Method
- (void)am_shyBarWithScrollView:(UIView *)scrollableView
{
    if (self.am_scrollableView != scrollableView) {
        [self.am_scrollableView removeFromSuperview];
        self.am_scrollableView = scrollableView;
    }
    [self am_setup];
}

- (void)am_stopFollowingScrollView
{
    [self am_expand];
    [self.am_scrollableView removeGestureRecognizer:self.am_panGesture];
    
    self.am_scrollableView = nil;
    self.am_panGesture = nil;
    if (![self.am_shyBar isKindOfClass:[UINavigationBar class]]) {
        self.am_shyBar = nil;
    }
    [self removeNotifications];
}

- (void)am_customShyBar:(UIView *)shyBar
{
    self.am_shyBar = shyBar;
    [self.view insertSubview:shyBar belowSubview:self.navigationController.navigationBar];
}

- (void)am_expand
{
    [self.am_shyBar am_expand];
}

- (void)am_contract
{
    [self.am_shyBar am_contract];
}

- (void)am_shyBarDidChangeStateBlock:(AMShyBarDidChangeBlock)block {
    self.am_shyBarStateBlock = block;
}

- (void)am_setup
{
    self.am_entirelyContractedShyBar = YES;
    
    if (!self.am_panGesture) {
        self.am_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(am_handlePan:)];
        self.am_panGesture.delegate = self;
        [self.am_panGesture setMaximumNumberOfTouches:1];
        self.am_panGesture.cancelsTouchesInView = NO;
    }
    
    if (self.am_panGesture.view) {
        [self.am_panGesture.view removeGestureRecognizer:self.am_panGesture];
    }
    
    if (self.am_scrollableView) {
        [self.am_scrollableView addGestureRecognizer:self.am_panGesture];
        self.am_scrollableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    [self addNotifications];
}

#pragma mark - Gesture
- (void)am_handlePan:(UIPanGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.am_topInset = CGRectGetHeight(self.navigationController.navigationBar.frame) + self.am_statusBarHeight+CGRectGetHeight(self.am_shyBar.frame);
            self.am_previousOffsetY = self.am_scrollView.contentOffset.y;
            break;
        }
        case UIGestureRecognizerStateChanged: {
            [self am_handleScrolling];
            break;
        }
        default: {
            CGFloat velocity = [gesture velocityInView:self.am_scrollableView].y;
            [self am_handleScrollingEnded:velocity];
            break;
        }
    }
}

#pragma mark - Private Mehod
- (CGFloat)am_statusBarHeight
{
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        return 0;
    }
    
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}

- (BOOL)am_isViewControllerVisible
{
    return self.isViewLoaded && self.view.window != nil;
}

- (void)am_handleScrolling {
    //在push不执行
    if (!(self.isViewLoaded && self.view.window != nil)) {
        return;
    }
    
    CGFloat contentOffsetY = self.am_scrollView.contentOffset.y;
    CGFloat deltaY = (contentOffsetY - self.am_previousOffsetY)*1.001;
    
    CGFloat start = -self.am_topInset;
    if (self.am_previousOffsetY <= start) {
        deltaY = MAX(0, deltaY + (self.am_previousOffsetY - start));
    }
    
    CGFloat maxContentOffset = self.am_scrollView.contentSize.height - self.am_scrollView.frame.size.height + self.am_scrollView.contentInset.bottom;
    CGFloat end = maxContentOffset;
    if (self.am_previousOffsetY >= end) {
        deltaY = MIN(0, deltaY + (self.am_previousOffsetY - maxContentOffset));
    }

    [self.am_shyBar am_updateOffsetY:deltaY];

    self.am_previousOffsetY = contentOffsetY;
    
    AMShyBarState state = [self am_getShyBarStateWithDelta:deltaY];
    if (self.am_shyBarStateBlock) {
        self.am_shyBarStateBlock(state);
    }
}

- (void)am_handleScrollingEnded:(CGFloat)velocity
{
    CGFloat minVelocity = 300.f;
    if (![self am_isViewControllerVisible] || ([self.am_shyBar am_isContracted] && velocity < minVelocity)) {
        return;
    }
    
    if (!self.am_shyBar) {
        return;
    }
    
    //shyBar展开还是收起
    BOOL shouldExpanded = YES;
    if (self.am_shyBar) {
        shouldExpanded = [self.am_shyBar am_shouldExpand];
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat navBarOffsetY = 0;
        if (shouldExpanded) {
            navBarOffsetY = [self.am_shyBar am_expand];
        } else {
            navBarOffsetY = [self.am_shyBar am_contract];
        }
        
        [self am_adjustScrollViewOffset];
        
        if (shouldExpanded) {
            CGPoint contentOffset = self.am_scrollView.contentOffset;
            contentOffset.y += navBarOffsetY;
            self.am_scrollView.contentOffset = contentOffset;
        }

    }];
}

- (void)am_adjustScrollViewOffset
{
    UIEdgeInsets scrollViewInset = self.am_scrollView.contentInset;
    if (self.am_shyBar) {
        CGFloat navBarMaxY = CGRectGetMaxY(self.am_shyBar.frame);
        scrollViewInset.top = navBarMaxY;
    }
    self.am_scrollView.contentInset = scrollViewInset;
    self.am_scrollView.scrollIndicatorInsets = scrollViewInset;
}

- (AMShyBarState)am_getShyBarStateWithDelta:(CGFloat)delta
{
    AMShyBarState barState;
    if (delta < 0) {
        barState = AMShyBarStateExpanding;
    } else {
        barState = AMShyBarStateContracting;
    }
    
    do {
        if (!self.am_shyBar) break;
        
        if ([self am_isExpanded]) {
            barState = AMShyBarStateExpanded;
            break;
        }
        
        if ([self am_isContracted]) {
            barState = AMShyBarStateContracted;
        }
        
    } while (0);
    
    return barState;
}

- (BOOL)am_isExpanded
{
    BOOL isExpanded = NO;
    BOOL isTopBarExpanded = YES;
    
    if (self.am_shyBar) {
        isTopBarExpanded = [self.am_shyBar am_isExpanded];
    }
    
    isExpanded = (isTopBarExpanded);
    return isExpanded;
}

- (BOOL)am_isContracted
{
    BOOL isContracted = NO;
    BOOL isTopBarContracted = YES;
    
    if (self.am_shyBar) {
        isTopBarContracted = [self.am_shyBar am_isContracted];
    }
    
    isContracted = (isTopBarContracted);
    return isContracted;
}

#pragma mark - Notifications
//add remove
- (void)addNotifications
{
    [self removeNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidChangeStatusBarFrame)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidChangeStatusBarFrameNotification
                                                  object:nil];
}

//monitor
- (void)applicationDidChangeStatusBarFrame
{
    [self am_expand];
}

- (void)applicationDidBecomeActive
{
    [self am_expand];
}


#pragma mark - Setters/Getters
- (void)setAm_scrollableView:(UIView *)am_scrollableView { objc_setAssociatedObject(self, @selector(am_scrollableView), am_scrollableView, OBJC_ASSOCIATION_RETAIN); }
- (UIView *)am_scrollableView { return objc_getAssociatedObject(self, @selector(am_scrollableView)); }

- (void)setAm_shyBar:(UIView *)am_shyBar {
    am_shyBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    objc_setAssociatedObject(self, @selector(am_shyBar), am_shyBar, OBJC_ASSOCIATION_RETAIN); }
- (UIView *)am_shyBar { return objc_getAssociatedObject(self, @selector(am_shyBar)); }

- (void)setAm_panGesture:(UIPanGestureRecognizer *)am_panGesture { objc_setAssociatedObject(self, @selector(am_panGesture), am_panGesture, OBJC_ASSOCIATION_RETAIN); }
- (UIPanGestureRecognizer *)am_panGesture { return objc_getAssociatedObject(self, @selector(am_panGesture)); }

- (void)setAm_previousOffsetY:(CGFloat)am_previousOffsetY { objc_setAssociatedObject(self, @selector(am_previousOffsetY), @(am_previousOffsetY), OBJC_ASSOCIATION_RETAIN); }
- (CGFloat)am_previousOffsetY { return [objc_getAssociatedObject(self, @selector(am_previousOffsetY)) floatValue]; }

- (void)setAm_topInset:(CGFloat)am_topInset { objc_setAssociatedObject(self, @selector(am_topInset), @(am_topInset), OBJC_ASSOCIATION_RETAIN);
}
- (CGFloat)am_topInset { return [objc_getAssociatedObject(self, @selector(am_topInset)) floatValue]; }

- (void)setAm_entirelyContractedShyBar:(BOOL)am_entirelyContractedShyBar {
    [self.am_shyBar setAm_entirelyContractedShyBar:am_entirelyContractedShyBar];
    if (am_entirelyContractedShyBar) {
        [self.am_shyBar setAm_ExpandedExposedHeight:0.f];
    } else {
        [self.am_shyBar setAm_ExpandedExposedHeight:[self am_statusBarHeight]];
    }
    
    objc_setAssociatedObject(self, @selector(am_entirelyContractedShyBar), @(am_entirelyContractedShyBar), OBJC_ASSOCIATION_RETAIN);
}
- (BOOL)am_entirelyContractedShyBar { return [objc_getAssociatedObject(self, @selector(am_entirelyContractedShyBar)) boolValue]; }

- (void)setAm_hasCustomRefreshControl:(BOOL)am_hasCustomRefreshControl {
    objc_setAssociatedObject(self, @selector(am_hasCustomRefreshControl), @(am_hasCustomRefreshControl), OBJC_ASSOCIATION_RETAIN); }
- (BOOL)am_hasCustomRefreshControl { return [objc_getAssociatedObject(self, @selector(am_hasCustomRefreshControl)) boolValue]; }

- (UIScrollView *)am_scrollView {
    UIScrollView *scroll = nil;
    if ([self.am_scrollableView respondsToSelector:@selector(scrollView)]) {
        scroll = [self.am_scrollableView performSelector:@selector(scrollView)];
    } else if ([self.am_scrollableView isKindOfClass:[UIScrollView class]]) {
        scroll = (UIScrollView *)self.am_scrollableView;
    }
    return scroll;
}

- (void)setAm_shyBarStateBlock:(AMShyBarDidChangeBlock)am_shyBarStateBlock {
    objc_setAssociatedObject(self, @selector(am_shyBarStateBlock), am_shyBarStateBlock, OBJC_ASSOCIATION_RETAIN);
}
- (AMShyBarDidChangeBlock)am_shyBarStateBlock {
    return objc_getAssociatedObject(self, @selector(am_shyBarStateBlock));
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

@end
