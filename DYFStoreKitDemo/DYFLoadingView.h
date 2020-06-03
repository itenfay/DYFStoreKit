//
//  DYFLoadingView.h
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
#import "UIView+DYFAdd.h"

/** Creates and returns a color object using the specified opacity and RGB component values.
 
 @param r The red value of the color object, specified as a value from 0.0 to 255.0.
 @param g The green value of the color object, specified as a value from 0.0 to 255.0.
 @param b The blue value of the color object, specified as a value from 0.0 to 255.0.
 @param alp The opacity value of the color object, specified as a value from 0.0 to 1.0.
 @return The color object. The color information represented by this object is in an RGB colorspace.
 */
#define COLOR_RGBA(r, g, b, alp) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(alp)]

/** Creates and returns a color object using the specified opacity and RGB component values.
 
 @param r The red value of the color object, specified as a value from 0.0 to 255.0.
 @param g The green value of the color object, specified as a value from 0.0 to 255.0.
 @param b The blue value of the color object, specified as a value from 0.0 to 255.0.
 @return The color object. The color information represented by this object is in an RGB colorspace.
 */
#define COLOR_RGB(r, g, b) COLOR_RGBA(r, g, b, 1.0)

/** Returns the width of the screen for the device.
 
 @return The width of the screen for the device.
 */
#define SCREEN_W UIScreen.mainScreen.bounds.size.width

/** Returns the height of the screen for the device.
 
 @return The height of the screen for the device.
 */
#define SCREEN_H UIScreen.mainScreen.bounds.size.height

/** The block is called when the text for label is set.
 
 @param text The text for label.
 */
typedef void (^LoadingViewConfigurationBlock)(NSString *text);

@interface DYFLoadingView : UIView

/** The color to set the background color of the content view.
 */
@property (nonatomic, strong) UIColor *color;

/** The color to set the line color of the indicator.
 */
@property (nonatomic, strong) UIColor *indicatorColor;

/** The color to set the text color of the text label.
 */
@property (nonatomic, strong) UIColor *textColor;

/** Disable this method to instantiate an object.
 */
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

/** It will be displayed on the screen with the text.
 
 @return A block with the text.
 */
- (LoadingViewConfigurationBlock)show;

/** Hides from its own superview.
 */
- (void)hide;

@end
