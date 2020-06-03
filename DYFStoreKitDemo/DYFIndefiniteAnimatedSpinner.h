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

#import <UIKit/UIKit.h>

@interface DYFIndefiniteAnimatedSpinner : UIView

/**
 Property indicating whether the view is currently animating.
 */
@property (nonatomic, readonly) BOOL isAnimating;

/**
 Sets whether the view is hidden when not animating.
 */
@property (nonatomic) BOOL hidesWhenStopped;

/**
 Specifies the timing function to use for the control's animation. Defaults to kCAMediaTimingFunctionEaseInEaseOut.
 */
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;

/**
 Sets the line width of the spinner's circle.
 */
@property (nonatomic) CGFloat lineWidth;

/**
 Sets the line color of the spinner's circle.
 */
@property (nonatomic, strong) UIColor *lineColor;

/**
 Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end
