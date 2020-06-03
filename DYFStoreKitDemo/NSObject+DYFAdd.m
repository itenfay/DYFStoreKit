//
//  NSObject+DYFAdd.m
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

#import "NSObject+DYFAdd.h"
#import "DYFLoadingView.h"
#import <objc/message.h>

NSString *const LoadingViewKey = @"LoadingViewKey";

@implementation NSObject (DYFAdd)

- (UIViewController *)currentViewController {
    UIApplication *sharedApp = UIApplication.sharedApplication;
    
    UIWindow *window = sharedApp.keyWindow ?: sharedApp.windows[0];
    UIViewController *viewController = window.rootViewController;
    
    return [self findCurrentViewControllerFrom:viewController];
}

- (UIViewController *)findCurrentViewControllerFrom:(UIViewController *)viewController {
    UIViewController *vc = viewController;
    
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

- (void)showTipsMessage:(NSString *)message {
    if ([self.currentViewController isKindOfClass:UIAlertController.class]) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [self.currentViewController presentViewController:alertController animated:YES completion:NULL];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:NULL];
    });
}

- (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
                    cancel:(void (^)(UIAlertAction *))cancelHandler
        confirmButtonTitle:(NSString *)confirmButtonTitle
                   execute:(void (^)(UIAlertAction *))executableHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelButtonTitle && cancelButtonTitle.length > 0) {
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:cancelHandler];
        [alertController addAction:cancelAction];
    }
    
    if (confirmButtonTitle && confirmButtonTitle.length > 0) {
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:confirmButtonTitle style:UIAlertActionStyleDefault handler:executableHandler];
        [alertController addAction:confirmAction];
    }
    
    [self.currentViewController presentViewController:alertController animated:YES completion:NULL];
}

- (void)showLoading:(NSString *)text {
    
    id value = objc_getAssociatedObject(self, &LoadingViewKey);
    if (value) {
        return;
    }
    
    DYFLoadingView *loadingView = [[DYFLoadingView alloc] init];
    loadingView.show(text);
    loadingView.color = COLOR_RGBA(10, 10, 10, 0.75);
    loadingView.indicatorColor = COLOR_RGB(54, 205, 64);
    loadingView.textColor = COLOR_RGB(248, 248, 248);
    
    objc_setAssociatedObject(self, &LoadingViewKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)hideLoading {
    
    id value = objc_getAssociatedObject(self, &LoadingViewKey);
    if (!value) {
        return;
    }
    
    DYFLoadingView *loadingView = (DYFLoadingView *)value;
    [loadingView hide];
    
    objc_setAssociatedObject(self, &LoadingViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
