//
//  UIView+DYFAdd.m
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

#import "UIView+DYFAdd.h"

@implementation UIView (DYFAdd)

- (DYFSetCornerBlock)setCorner {
    
    DYFSetCornerBlock block = ^(UIRectCorner rectCorner, CGFloat radius) {
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        CGFloat w = self.bounds.size.width;
        CGFloat h = self.bounds.size.height;
        maskLayer.frame = CGRectMake(0, 0, w, h);
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(radius, radius)];
        maskLayer.path = path.CGPath;
        
        [self.layer setMask:maskLayer];
    };
    
    return block;
}

- (DYFSetBorderBlock)setBorder {
    
    DYFSetBorderBlock block = ^(UIRectCorner rectCorner, CGFloat radius, CGFloat lineWidth, UIColor *color) {
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        CGFloat w = self.bounds.size.width;
        CGFloat h = self.bounds.size.height;
        maskLayer.frame = CGRectMake(0, 0, w, h);
        
        CAShapeLayer *borderLayer = [CAShapeLayer layer];
        borderLayer.frame = CGRectMake(0, 0, w, h);
        borderLayer.lineWidth = lineWidth;
        borderLayer.strokeColor = color.CGColor;
        borderLayer.fillColor = [UIColor clearColor].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(radius, radius)];
        borderLayer.path = path.CGPath;
        maskLayer.path = path.CGPath;
        
        [self.layer insertSublayer:borderLayer atIndex:0];
        [self.layer setMask:maskLayer];
    };
    
    return block;
}

@end
