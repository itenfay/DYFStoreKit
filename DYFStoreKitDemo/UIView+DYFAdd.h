//
//  UIView+DYFAdd.h
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

/** The block is called when the corners are set.
 
 @param rectCorner The corners of a rectangle.
 @param radius The radius of each corner.
 */
typedef void (^DYFSetCornerBlock)(UIRectCorner rectCorner, CGFloat radius);

/** The block is called when the border is set.
 
 @param rectCorner The corners of a rectangle.
 @param radius The radius of each corner.
 @param lineWidth Specifies the line width of the shape’s path.
 @param color The color used to stroke the shape’s path.
 */
typedef void (^DYFSetBorderBlock)(UIRectCorner rectCorner, CGFloat radius, CGFloat lineWidth, UIColor *color);

@interface UIView (DYFAdd)

/** This method is used to set the corner.
 
 @return A block with a `UIRectCorner` value and radius.
 */
- (DYFSetCornerBlock)setCorner;

/** This method is used to set the border.
 
 @return A block with a `UIRectCorner` value, radius, line width and a color.
 */
- (DYFSetBorderBlock)setBorder;

@end
