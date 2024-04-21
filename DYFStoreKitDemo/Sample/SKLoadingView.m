//
//  SKLoadingView.m
//
//  Created by Teng Fei on 2014/11/4.
//  Copyright © 2014 Teng Fei. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "SKLoadingView.h"
#import "SKIndefiniteAnimatedSpinner.h"

@interface SKLoadingView ()
@property (nonatomic, strong) UIView *maskPanel;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) SKIndefiniteAnimatedSpinner *indicator;
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation SKLoadingView

/// It is used to act as background mask panel.
- (UIView *)maskPanel
{
    if (!_maskPanel) {
        _maskPanel = [[UIView alloc] init];
        _maskPanel.backgroundColor = COLOR_RGBA(20, 20, 20, 0.7);
    }
    return _maskPanel;
}

/// It is used to render the content.
- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = COLOR_RGB(255, 255, 255);
    }
    return _contentView;
}

/// The spinner is used to provide an indefinite animation.
- (SKIndefiniteAnimatedSpinner *)indicator
{
    if (!_indicator) {
        _indicator = [[SKIndefiniteAnimatedSpinner alloc] init];
        _indicator.backgroundColor = UIColor.clearColor;
        _indicator.lineColor = COLOR_RGB(100, 100, 100);
    }
    return _indicator;
}

/// It is used to show the text.
- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.textColor = COLOR_RGB(60, 60, 60);
    }
    return _textLabel;
}

/// Returns the current window of the app.
- (UIWindow *)appWindow
{
    UIApplication *sharedApp = UIApplication.sharedApplication;
    return sharedApp.keyWindow ?: sharedApp.windows[0];
}

/// Returns the background color of the content view.
- (UIColor *)color
{
    return self.contentView.backgroundColor;
}

/// The color to set the background color of the content view.
/// @param color The color you will set.
- (void)setColor:(UIColor *)color
{
    self.contentView.backgroundColor = color;
}

/// Returns the line color of the indicator.
- (UIColor *)indicatorColor
{
    return self.indicator.lineColor;
}

/// The color to set the line color of the indicator.
/// @param indicatorColor The indicator color you will set.
- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    self.indicator.lineColor = indicatorColor;
}

/// Returns the text color of the text label.
- (UIColor *)textColor
{
    return self.textLabel.textColor;
}

/// The color to set the text color of the text label.
/// @param textColor The text color you will set.
- (void)setTextColor:(UIColor *)textColor
{
    self.textLabel.textColor = textColor;
}

/// Returns an object initialized from data in a given unarchiver.
/// @param coder An unarchiver object.
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Prepares the receiver for service after it has been loaded
    // from an Interface Builder archive, or nib file.
}

/// It will be displayed on the screen with the text.
- (LoadingViewConfigurationBlock)show
{
    LoadingViewConfigurationBlock block;
    block = ^(NSString *text) {
        [self configure:text];
        [self loadView];
        [self beginAnimating];
    };
    return block;
}

/// Hides from its own superview.
- (void)hide
{
    UIViewAnimationOptions opts = UIViewAnimationOptionCurveEaseInOut;
    [UIView animateWithDuration:0.3 delay:1.0 options:opts animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self.indicator stopAnimating];
        [self removeAllViews];
        [self safetyRelease];
    }];
}

/// Removes all views at the end of the hidden animation.
- (void)removeAllViews
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [self removeFromSuperview];
}

/// When the view is hidden, the child widget object should be released safely.
- (void)safetyRelease
{
    if (_maskPanel) { _maskPanel = nil; }
    if (_contentView) { _contentView = nil; }
    if (_indicator) { _indicator = nil; }
    if (_textLabel) { _textLabel = nil; }
}

/// Configures properties for the widget used.
- (void)configure:(NSString *)text
{
    self.autoresizingMask           = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleWidth      |
                                       UIViewAutoresizingFlexibleTopMargin  |
                                       UIViewAutoresizingFlexibleHeight);
    
    self.maskPanel.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleWidth      |
                                       UIViewAutoresizingFlexibleTopMargin  |
                                       UIViewAutoresizingFlexibleHeight);
    CGFloat cW = 0.f, cH = 0.f;
    CGFloat iW = 36.f;
    CGFloat offset = 15.f;
    
    self.textLabel.text = text;
    self.textLabel.font = [UIFont boldSystemFontOfSize:14.f];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 1;
    [self.textLabel sizeToFit];
    CGSize textSize = self.textLabel.bounds.size;
    
    cW = textSize.width + 2*offset;
    cW = cW > (SCREEN_W - 40) ? SCREEN_W - 40 : cW;
    cW = cW < (iW + 4*offset) ? iW + 4*offset : cW;
    cH = textSize.height + iW + 3*offset;
    self.contentView.frame = CGRectMake(0, 0, cW, cH);
    self.contentView.setCorner(UIRectCornerAllCorners, 10.f);
    
    CGFloat ix = cW/2 - iW/2;
    CGFloat iy = cH/2 - iW + 5.f;
    if ([self.textLabel.text isEqualToString:@""]) {
        iy = cH/2 - iW/2;
    }
    self.indicator.frame = CGRectMake(ix, iy, iW, iW);
    self.indicator.lineWidth = 2.0;
    
    self.textLabel.frame = CGRectMake(offset, CGRectGetMaxY(self.indicator.frame) + offset, cW - 2*offset, textSize.height);
}

/// Addds the subviews to its corresponding superview.
- (void)loadView
{
    UIViewController *vc = self.appCurrentViewController;
    if (vc != nil) {
        [vc.view addSubview:self];
        [vc.view bringSubviewToFront:self];
    } else {
        UIWindow *window = self.appWindow;
        [window addSubview:self];
        [window bringSubviewToFront:self];
    }
    
    [self addSubview:self.maskPanel];
    [self addSubview:self.contentView];
    [self bringSubviewToFront:self.contentView];
    
    [self.contentView addSubview:self.indicator];
    [self.contentView addSubview:self.textLabel];
}

/// Prepares to begin animating.
- (void)beginAnimating
{
    [self.indicator startAnimating];
    
    self.alpha = 0.f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.f;
    }];
}

/// Finds out the current view controller.
- (UIViewController *)appCurrentViewController
{
    UIViewController *vc = self.appWindow.rootViewController;
    while (1) {
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else if ([vc isKindOfClass:UITabBarController.class]) {
            vc = ((UITabBarController *)vc).selectedViewController;
        } else if ([vc isKindOfClass:UINavigationController.class]) {
            vc = ((UINavigationController *)vc).visibleViewController;
        } else {
            if (vc.childViewControllers.count > 0) {
                vc = vc.childViewControllers.lastObject;
            }
            break;
        }
    }
    return vc;
}

- (void)layoutSubviews
{
    CGFloat s_w = 0.f;
    CGFloat s_h = 0.f;
    
    UIView *view = self.superview;
    if (view) {
        s_w = view.bounds.size.width;
        s_h = view.bounds.size.height;
    } else {
        s_w = SCREEN_W;
        s_h = SCREEN_H;
    }
    self.frame = CGRectMake(0, 0, s_w, s_h);
    self.maskPanel.frame = CGRectMake(0, 0, s_w, s_h);
    self.contentView.center = CGPointMake(s_w/2, s_h/2);
}

- (void)dealloc
{
#if DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
}

@end
