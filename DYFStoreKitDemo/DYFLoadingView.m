//
//  DYFLoadingView.m
//
//  Created by dyf on 2014/11/4.
//  Copyright © 2014 dyf. ( https://github.com/dgynfi/DYFStoreKit )
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

#import "DYFLoadingView.h"

@interface DYFLoadingView ()

@property (nonatomic, strong) UIView *mask;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation DYFLoadingView

- (LoadingViewConfigurationBlock)show {
    
    LoadingViewConfigurationBlock block = ^(NSString *text) {
        [self setText:text];
        [self showWithAnimation];
    };
    
    return block;
}

- (void)hide {
    if ([self.indicatorView isAnimating]) {
        [self.indicatorView stopAnimating];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0.f;
    } completion:^(BOOL finished) {
        [self removeAllViews];
        [self safetyRelease];
    }];
}

- (void)safetyRelease {
    if (_mask) { _mask = nil; }
    if (_contentView) { _contentView = nil; }
    if (_indicatorView) { _indicatorView = nil; }
    if (_textLabel) { _textLabel = nil; }
}

- (void)removeAllViews {
    UIWindow *window = self.keyWindow ?: [UIApplication.sharedApplication windows][0];
    
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in window.subviews) {
        if ([view isKindOfClass:self.class]) {
            [view removeFromSuperview];
        }
    }
}

- (UIView *)mask {
    if (!_mask) {
        _mask = [[UIView alloc] init];
        _mask.backgroundColor = COLOR_RGBA(20, 20, 20, 0.5);
    }
    return _mask;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = COLOR_RGB(255, 255, 255);
    }
    return _contentView;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.color = COLOR_RGB(60, 60, 60);
    }
    return _indicatorView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = UIColor.clearColor;
        _textLabel.textColor = COLOR_RGB(60, 60, 60);
    }
    return _textLabel;
}

- (UIWindow *)keyWindow {
    return [UIApplication.sharedApplication keyWindow];
}

- (void)showWithAnimation {
    UIWindow *window = self.keyWindow ?: [UIApplication.sharedApplication windows][0];
    [self addSubview:self.mask];
    [window addSubview:self];
    
    [self.mask addSubview:self.contentView];
    [self.contentView addSubview:self.indicatorView];
    [self.indicatorView startAnimating];
    
    self.textLabel.text = self.text;
    self.textLabel.font = [UIFont boldSystemFontOfSize:16.f];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 1;
    [self.contentView addSubview:self.textLabel];
    
    [self layoutIfNeeded];
    
    self.alpha = 0.f;
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1.f;
    }];
}

- (void)layoutSubviews {
    self.frame = CGRectMake(0, 0, SCREEN_W, SCREEN_H);
    self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                             UIViewAutoresizingFlexibleWidth      |
                             UIViewAutoresizingFlexibleTopMargin  |
                             UIViewAutoresizingFlexibleHeight);
    
    CGFloat sw = self.bounds.size.width;
    CGFloat sh = self.bounds.size.height;
    
    self.mask.frame = CGRectMake(0, 0, sw, sh);
    self.mask.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                  UIViewAutoresizingFlexibleWidth      |
                                  UIViewAutoresizingFlexibleTopMargin  |
                                  UIViewAutoresizingFlexibleHeight);
    
    CGFloat cw = 260.f;
    CGFloat ch = 130.f;
    self.contentView.center = CGPointMake(sw/2, sh/2);
    self.contentView.bounds = CGRectMake(0, 0, cw, ch);
    if (_contentView) {
        self.contentView.setCorner(UIRectCornerAllCorners, 10.f);
    }
    
    self.indicatorView.center = CGPointMake(cw/2, ch/2 - 10);
    self.textLabel.frame = CGRectMake(10, ch - 20 - 15, cw - 20, 20);
}

- (void)dealloc {
#if DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
}

@end
