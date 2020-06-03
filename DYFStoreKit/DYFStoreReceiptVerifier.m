//
//  DYFStoreReceiptVerifier.m
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

#import "DYFStoreReceiptVerifier.h"

// Returns a Boolean value that indicates whether the receiver implements
// or inherits a method that can respond to a specified message.
#define SR_RESPONDS_TO_SEL(target, selector) (target && [target respondsToSelector:selector])

// The url for sandbox in the test environment.
static NSString *const kSandboxUrl = @"https://sandbox.itunes.apple.com/verifyReceipt";
// The url for production in the production environment.
static NSString *const kProductUrl = @"https://buy.itunes.apple.com/verifyReceipt";

// Sandbox Url: https://sandbox.itunes.apple.com/verifyReceipt
// static const char __6FD0F31B976A325E[] = {0x68, 0x74, 0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x73, 0x61, 0x6e, 0x64, 0x62, 0x6f, 0x78, 0x2e, 0x69, 0x74, 0x75, 0x6e, 0x65, 0x73, 0x2e, 0x61, 0x70, 0x70, 0x6c, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x76, 0x65, 0x72, 0x69, 0x66, 0x79, 0x52, 0x65, 0x63, 0x65, 0x69, 0x70, 0x74};

// Production Url: https://buy.itunes.apple.com/verifyReceipt
// static const char __68C346B47CD9834D[] = {0x68, 0x74, 0x74, 0x70, 0x73, 0x3a, 0x2f, 0x2f, 0x62, 0x75, 0x79, 0x2e, 0x69, 0x74, 0x75, 0x6e, 0x65, 0x73, 0x2e, 0x61, 0x70, 0x70, 0x6c, 0x65, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x76, 0x65, 0x72, 0x69, 0x66, 0x79, 0x52, 0x65, 0x63, 0x65, 0x69, 0x70, 0x74};

// Decodes C string.
//static inline NSString *DYFDecodeCString(const char *bytes) {
//    return bytes ? [NSString stringWithUTF8String:bytes] : nil;
//}

@interface DYFStoreReceiptVerifier ()

/** The data for a POST request.
 */
@property (nonatomic, copy) NSData *requestData;

/** A configuration object that defines behavior and policies for a URL session.
 */
@property (nonatomic, strong) NSURLSessionConfiguration *urlSessionConfig;

/** An object that coordinates a group of related network data transfer tasks.
 */
@property (nonatomic, strong) NSURLSession *urlSession;

/** A URL session task that returns downloaded data directly to the app in memory.
 */
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

/** Whether all outstanding tasks have been cancelled and the session has been invalidated.
 */
@property (nonatomic, assign) BOOL canInvalidateSession;

@end

@implementation DYFStoreReceiptVerifier

- (instancetype)init {
    self = [super init];
    if (self) {
        [self instantiateUrlSession];
        self.canInvalidateSession = NO;
    }
    return self;
}

/** Cancels the task.
 */
- (void)cancel {
    if (self.dataTask) {
        [self.dataTask cancel];
    }
}

/** Cancels all outstanding tasks and then invalidates the session.
 */
- (void)invalidateAndCancel {
    if (self.urlSession) {
        [self.urlSession invalidateAndCancel];
        self.canInvalidateSession = YES;
    }
}

- (NSURLSessionConfiguration *)urlSessionConfig {
    if (!_urlSessionConfig) {
        _urlSessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration;
    }
    return _urlSessionConfig;
}

/** Checks the url session configuration object.
 */
- (void)checkUrlSessionConfig {
    self.urlSessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    self.urlSessionConfig.timeoutIntervalForRequest = 15.0;
    self.urlSessionConfig.allowsCellularAccess = true;
}

/** Instantiates the url session object.
 */
- (void)instantiateUrlSession {
    [self checkUrlSessionConfig];
    self.urlSession = [NSURLSession sessionWithConfiguration:self.urlSessionConfig];
}

- (void)verifyReceipt:(NSData *)receiptData {
    [self verifyReceipt:receiptData sharedSecret:nil];
}

- (void)verifyReceipt:(NSData *)receiptData sharedSecret:(NSString *)secretKey {
    
    if (receiptData == nil) {
        
        NSString *message = @"The received data is null.";
        NSError *error = [NSError errorWithDomain:@"SRErrorDomain.DYFStore"
                                             code:-12
                                         userInfo:@{NSLocalizedDescriptionKey: message}];
        
        if (SR_RESPONDS_TO_SEL(self.delegate, @selector(verifyReceipt:didFailWithError:))) {
            [self.delegate verifyReceipt:self didFailWithError:error];
        }
        return;
    }
    
    NSString *receiptBase64 = [receiptData base64EncodedStringWithOptions:kNilOptions];
    
    // Creates the JSON object that describes the request.
    NSMutableDictionary *requestContents = [NSMutableDictionary dictionaryWithCapacity:0];
    [requestContents setValue:receiptBase64 forKey:@"receipt-data"];
    if (secretKey && secretKey.length > 0) {
        [requestContents setValue:secretKey forKey:@"password"];
    }
    
    NSError *error = nil;
    self.requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:kNilOptions error:&error];
    
    if (!error) {
        [self connectWithUrl:kProductUrl];
        return;
    }
    
    if (SR_RESPONDS_TO_SEL(self.delegate, @selector(verifyReceipt:didFailWithError:))) {
        [self.delegate verifyReceipt:self didFailWithError:error];
    }
}

// Make a connection to the iTunes Store on a background queue.
- (void)connectWithUrl:(NSString *)url {
    NSURL *aURL = [NSURL URLWithString:url];
    
    // Creates a POST request with the receipt data.
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aURL];
    request.HTTPMethod = @"POST";
    request.HTTPBody = self.requestData;
    
    if (self.canInvalidateSession) {
        [self instantiateUrlSession];
        self.canInvalidateSession = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    self.dataTask = [self.urlSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [weakSelf didReceiveData:data response:response error:error];
    }];
    [self.dataTask resume];
}

- (void)didReceiveData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    
    if (!error) {
        [self processResult:data];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (SR_RESPONDS_TO_SEL(self.delegate, @selector(verifyReceipt:didFailWithError:))) {
            [self.delegate verifyReceipt:self didFailWithError:error];
        }
    });
}

- (void)processResult:(NSData *)data {
    NSError *error = nil;
    
    id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *dict = (NSDictionary *)jsonObj;
    
    if (!error) {
        
        NSInteger status = [[dict objectForKey:@"status"] integerValue];
        if (status == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (SR_RESPONDS_TO_SEL(self.delegate, @selector(verifyReceiptDidFinish:didReceiveData:))) {
                    [self.delegate verifyReceiptDidFinish:self didReceiveData:dict];
                }
            });
        } else if (status == 21007) { // sandbox
            
            [self connectWithUrl:kSandboxUrl];
        } else {
            
            NSString *message = [self matchMessageWithStatus:status];
            NSError *error = [NSError errorWithDomain:@"SRErrorDomain.DYFStore"
                                                 code:status
                                             userInfo:@{NSLocalizedDescriptionKey: message}];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (SR_RESPONDS_TO_SEL(self.delegate, @selector(verifyReceipt:didFailWithError:))) {
                    [self.delegate verifyReceipt:self didFailWithError:error];
                }
            });
        }
        
    } else {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (SR_RESPONDS_TO_SEL(self.delegate, @selector(verifyReceipt:didFailWithError:))) {
                [self.delegate verifyReceipt:self didFailWithError:error];
            }
        });
    }
}

/**
 Matches the message with the status code.
 
 @param status The status code of the request response. More, please see [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1)
 @return A string that contains the description of status code.
 */
- (NSString *)matchMessageWithStatus:(NSInteger)status {
    NSString *message = @"";
    
    switch (status) {
        case 0:
            message = @"The receipt as a whole is valid.";
            break;
        case 21000:
            message = @"The App Store could not read the JSON object you provided.";
            break;
        case 21002:
            message = @"The data in the receipt-data property was malformed or missing.";
            break;
        case 21003:
            message = @"The receipt could not be authenticated.";
            break;
        case 21004:
            message = @"The shared secret you provided does not match the shared secret on file for your account.";
            break;
        case 21005:
            message = @"The receipt server is not currently available.";
            break;
        case 21006:
            message = @"This receipt is valid but the subscription has expired. When this status code is returned to your server, the receipt data is also decoded and returned as part of the response. Only returned for iOS 6 style transaction receipts for auto-renewable subscriptions.";
            break;
        case 21007:
            message = @"This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead.";
            break;
        case 21008:
            message = @"This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead.";
            break;
        case 21010:
            message = @"This receipt could not be authorized. Treat this the same as if a purchase was never made.";
            break;
        default: /* 21100-21199 */
            message = @"Internal data access error.";
            break;
    }
    
    return message;
}

@end
