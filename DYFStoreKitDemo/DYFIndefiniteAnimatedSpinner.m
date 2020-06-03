//
//  DYFIndefiniteAnimatedSpinner.h
//
//  Created by dyf on 2014/11/4. ( https://github.com/dgynfi/DYFStoreKit )
//  Copyright © 2014 dyf. All rights reserved.
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

#import "DYFIndefiniteAnimatedSpinner.h"

/** Animation Key */
NSString *const DYFSpinnerStrokeAnimationKey   = @"spinner.animkey.stroke";
NSString *const DYFSpinnerRotationAnimationKey = @"spinner.animkey.rotation";

@interface DYFIndefiniteAnimatedSpinner ()

/** A layer that draws a arc progress in its coordinate space. */
@property (nonatomic, readonly) CAShapeLayer *progressLayer;

@property (nonatomic, readwrite) BOOL isAnimating;

@end

@implementation DYFIndefiniteAnimatedSpinner

@synthesize progressLayer = _progressLayer;

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    if (self) {
        // Supports an Interface Builder archive, or nib file.
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (void)setup {
    [self.layer addSublayer:self.progressLayer];
    self.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (BOOL)isAnimating {
    return _isAnimating;
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped {
    _hidesWhenStopped = hidesWhenStopped;
    self.hidden = !self.isAnimating && hidesWhenStopped;
}

- (CGFloat)lineWidth {
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth {
    self.progressLayer.lineWidth = lineWidth;
    [self updatePath];
}

- (UIColor *)lineColor {
    CGColorRef color = self.progressLayer.strokeColor;
    
    if (color) {
        return [UIColor colorWithCGColor:color];
    }
    
    return nil;
}

- (void)setLineColor:(UIColor *)lineColor {
    self.progressLayer.strokeColor = lineColor.CGColor;
}

#pragma mark - Lazy Load

- (CAShapeLayer *)progressLayer {
    
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        
        _progressLayer.strokeColor = nil;
        _progressLayer.fillColor   = nil;
        _progressLayer.lineWidth   = 1.f;
    }
    
    return _progressLayer;
}

- (void)startAnimating {
    if (self.isAnimating) {
        return;
    }
    
    self.isAnimating = YES;
    [self addLayerAnimations];
    self.hidden = NO;
}

- (void)stopAnimating {
    if (!self.isAnimating) {
        return;
    }
    
    self.isAnimating = NO;
    
    [self.progressLayer removeAnimationForKey:DYFSpinnerRotationAnimationKey];
    [self.progressLayer removeAnimationForKey:DYFSpinnerStrokeAnimationKey];
    
    if (self.hidesWhenStopped) {
        self.hidden = YES;
    }
}

- (void)addLayerAnimations {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 2.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animation forKey:DYFSpinnerRotationAnimationKey];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.25f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.f);
    tailAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.f;
    endHeadAnimation.duration = 0.5f;
    endHeadAnimation.fromValue = @(0.25f);
    endHeadAnimation.toValue = @(1.f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.f;
    endTailAnimation.duration = 0.5f;
    endTailAnimation.fromValue = @(1.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    [animGroup setDuration:1.5f];
    [animGroup setAnimations:@[headAnimation,
                               tailAnimation,
                               endHeadAnimation,
                               endTailAnimation]];
    animGroup.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animGroup forKey:DYFSpinnerStrokeAnimationKey];
}

- (void)resetAnimations {
    if (self.isAnimating) {
        [self stopAnimating];
        [self startAnimating];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat sW = CGRectGetWidth(self.bounds);
    CGFloat sH = CGRectGetHeight(self.bounds);
    self.progressLayer.frame = CGRectMake(0, 0, sW, sH);
    
    [self updatePath];
}

#pragma mark - Private

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds),
                                 CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2) - self.lineWidth/2;
    CGFloat startAngle = (CGFloat)(0);
    CGFloat endAngle = (CGFloat)(2*M_PI);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    self.progressLayer.path = path.CGPath;
    
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd   = 0.f;
}

- (void)executeWhenReleasing {
    [self stopAnimating];
    
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
#if DEBUG
    NSLog(@"%s", __func__);
#endif
    [self executeWhenReleasing];
}

@end
