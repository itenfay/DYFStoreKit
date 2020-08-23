## DYFStoreKit

A lightweight and easy-to-use iOS library for In-App Purchases. (Objective-C)

`DYFStoreKit` uses blocks and [notifications](#Notifications) to wrap `StoreKit`, provides [receipt verification](#Receipt-verification) and [transaction persistence](#Transaction-persistence). `DYFStoreKit` doesn't require any external dependencies. 

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/DYFStoreKit.svg?style=flat)](http://cocoapods.org/pods/DYFStoreKit)&nbsp;
![CocoaPods](http://img.shields.io/cocoapods/p/DYFStoreKit.svg?style=flat)&nbsp;

[Chinese Instructions (中文说明)](README-zh.md)


## Features

- Super simple in-app purchases.
- Built-in support for remembering your purchases.
- Built-in receipt validation (remote).
- Built-in hosted content downloads and notifications.


## Group (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/dgynfi/DYFStoreKit/raw/master/images/g614799921.jpg" width="30%" />
</div>


## Installation

Using [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFStoreKit', '~> 1.1.5'
```

Or

```
pod 'DYFStoreKit'
```

Or manually add the files from the [DYFStoreKit](https://github.com/dgynfi/DYFStoreKit/tree/master/DYFStoreKit) directory.

Check out the [wiki](https://github.com/dgynfi/DYFStoreKit/wiki/Installation) for more options.


## Usage

Next I'll show you how to use `DYFStoreKit`.

### Initialization

The initialization is as follows.

- Whether to allow the logs output to the console, set 'true' in debug mode, view the logs of the whole process of in-app purchase, and set 'false' when publishing app in release mode.
- Adds the observer of transactions and monitors the change of transactions.
- Instantiates data persistent object and stores the related information of transactions.
- Follows the agreement `DYFStoreAppStorePaymentDelegate` and processes payments for products purchased from the App Store.

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Adds an observer that responds to updated transactions to the payment queue.
    // If an application quits when transactions are still being processed, those transactions are not lost. The next time the application launches, the payment queue will resume processing the transactions. Your application should always expect to be notified of completed transactions.
    // If more than one transaction observer is attached to the payment queue, no guarantees are made as to the order they will be called in. It is recommended that you use a single observer to process and finish the transaction.
    [DYFStore.defaultStore addPaymentTransactionObserver];

    // Sets the delegate processes the purchase which was initiated by user from the App Store.
    DYFStore.defaultStore.delegate = self;

    DYFStore.defaultStore.keychainPersister = [[DYFStoreKeychainPersistence alloc] init];

    return YES;
}
```

You can process the purchase which was initiated by user from the App Store and provide your own implementation using the `DYFStoreAppStorePaymentDelegate` protocol:

```
// Processes the purchase which was initiated by user from the App Store.
- (void)didReceiveAppStorePurchaseRequest:(SKPaymentQueue *)queue payment:(SKPayment *)payment forProduct:(SKProduct *)product {
    
    if (![DYFStore canMakePayments]) {
        [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    
    [DYFStore.defaultStore purchaseProduct:product.productIdentifier userIdentifier:userIdentifier];
}
```


### Request products

There are two strategies for retrieving information about the products from the App Store.

**Strategy 1:** To begin the purchase process, your app must know its product identifiers. Your app can uses a product identifier to fetch information about product available for sale in the App Store and to submit payment request directly.

```
- (IBAction)fetchesProductAndSubmitsPayment:(id)sender {
    [self showLoading:@"Loading..."];
    
    NSString *productId = @"com.hncs.szj.coin48";
    
    [DYFStore.defaultStore requestProductWithIdentifier:productId success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        if (products.count == 1) {
            
            NSString *productId = ((SKProduct *)products[0]).productIdentifier;
            [self addPayment:productId];
            
        } else {
            
            [self showTipsMessage:@"There is no this product for sale!"];
        }
        
    } failure:^(NSError *error) {
        
        [self hideLoading];
        
        NSString *value = error.userInfo[NSLocalizedDescriptionKey];
        NSString *msg = value ?: error.localizedDescription;
        [self sendNotice:[NSString stringWithFormat:@"An error occurs, %zi, %@", error.code, msg]];
    }];
}

- (void)addPayment:(NSString *)productId {
    
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    
    [DYFStore.defaultStore purchaseProduct:productId userIdentifier:userIdentifier];
}
```

**Strategy 2:** To begin the purchase process, your app must know its product identifiers so it can retrieve information about the products from the App Store and present its store UI to the user. Every product sold in your app has a unique product identifier. Your app uses these product identifiers to fetch information about products available for sale in the App Store, such as pricing, and to submit payment requests when users purchase those products.

```
- (NSArray *)fetchProductIdentifiersFromServer {
    
    NSArray *productIds = @[@"com.hncs.szj.coin42",   // 42 gold coins for ￥6.
                            @"com.hncs.szj.coin210",  // 210 gold coins for ￥30.
                            @"com.hncs.szj.coin686",  // 686 gold coins for ￥98.
                            @"com.hncs.szj.coin1386", // 1386 gold coins for ￥198.
                            @"com.hncs.szj.coin2086", // 2086 gold coins for ￥298.
                            @"com.hncs.szj.coin4886", // 4886 gold coins for ￥698.
                            @"com.hncs.szj.vip1",     // non-renewable vip subscription for a month.
                            @"com.hncs.szj.vip2"      // Auto-renewable vip subscription for three months.
    ];
    
    return productIds;
}

- (IBAction)fetchesProductsFromAppStore:(id)sender {
    [self showLoading:@"Loading..."];
    
    NSArray *productIds = [self fetchProductIdentifiersFromServer];
    
    [DYFStore.defaultStore requestProductWithIdentifiers:productIds success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        if (products.count > 0) {
            
            [self processData:products];
            
        } else if (products.count == 0 && invalidIdentifiers.count > 0) {
            
            // Please check the product information you set up.
            [self showTipsMessage:@"There are no products for sale!"];
        }
        
    } failure:^(NSError *error) {
        
        [self hideLoading];
        
        NSString *value = error.userInfo[NSLocalizedDescriptionKey];
        NSString *msg = value ?: error.localizedDescription;
        [self sendNotice:[NSString stringWithFormat:@"An error occurs, %zi, %@", error.code, msg]];
    }];
}

- (void)processData:(NSArray *)products {
    
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:0];
    
    for (SKProduct *product in products) {
        
        DYFStoreProduct *p = [[DYFStoreProduct alloc] init];
        p.identifier = product.productIdentifier;
        p.name = product.localizedTitle;
        p.price = [product.price stringValue];
        p.localePrice = [DYFStore.defaultStore localizedPriceOfProduct:product];
        p.localizedDescription = product.localizedDescription;
        
        [modelArray addObject:p];
    }
    
    [self displayStoreUI:modelArray];
}

- (void)displayStoreUI:(NSMutableArray *)dataArray {
    
    if (![DYFStore canMakePayments]) {
        [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    
    DYFStoreViewController *storeVC = [[DYFStoreViewController alloc] init];
    storeVC.dataArray = dataArray;
    [self.navigationController pushViewController:storeVC animated:YES];
}
```


### Add payment

Whether the device is allowed to make payments.

```
if (![DYFStore canMakePayments]) {
    [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
    return;
}
```

Requests payment of the product with the given product identifier.

```
[DYFStore.defaultStore purchaseProduct:@"com.hncs.szj.coin210"];
```

If you need an opaque identifier for the user’s account on your system to add payment, you can use a one-way hash of the user’s account name to calculate the value for this property.

Calculates the SHA256 hash function:

```
CG_INLINE NSString *DYF_SHA256_HashValue(NSString *string) {

    const int digestLength = CC_SHA256_DIGEST_LENGTH; // 32
    unsigned char md[digestLength];

    const char *cStr = [string UTF8String];
    size_t cStrLen = strlen(cStr);

    // Confirm that the length of C string is small enough
    // to be recast when calling the hash function.
    if (cStrLen > UINT32_MAX) {
        NSLog(@"C string too long to hash: %@", string);
        return nil;
    }

    CC_SHA256(cStr, (CC_LONG)cStrLen, md);

    // Convert the array of bytes into a string showing its hex represention.
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < digestLength; i++) {

        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            //[hash appendString:@"-"];
        }
        [hash appendFormat:@"%02x", md[i]];
    }

    return hash;
}
```

Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.

```
[DYFStore.defaultStore purchaseProduct:@"com.hncs.szj.coin210" userIdentifier:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
```


### Restore transactions

- Restores transactions without the user account identifier.

```
[DYFStore.defaultStore restoreTransactions];
```

- Restores transactions with the user account identifier.

```
[DYFStore.defaultStore restoreTransactions:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
```


### Refresh receipt

If `Bundle.main.appStoreReceiptURL` is null, you need to create a refresh receipt request to obtain a receipt for a payment transaction.

```
[DYFStore.defaultStore refreshReceiptOnSuccess:^{
    [self storeReceipt];
} failure:^(NSError *error) {
    [self failToRefreshReceipt];
}];
```


### Notifications

`DYFStoreKit` sends notifications of `StoreKit` related events and extends `NSNotification` to provide relevant information. To receive them, add the observer to a `DYFStoreKit` manager.

#### Add the store observer

```
- (void)addStoreObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(processPurchaseNotification:) name:DYFStorePurchasedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(processDownloadNotification:) name:DYFStoreDownloadedNotification object:nil];
}
```

#### Remove the store observer

When the application exits, you need to remove the store observer.

```
- (void)removeStoreObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self name:DYFStorePurchasedNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:DYFStoreDownloadedNotification object:nil];
}
```

#### Payment transaction notifications

Payment transaction notifications are sent after a payment has been requested or for each restored transaction.

```
- (void)processPurchaseNotification:(NSNotification *)notification {

    [self hideLoading];
    self.purchaseInfo = notification.object;

    switch (self.purchaseInfo.state) {
        case DYFStorePurchaseStatePurchasing:
            [self showLoading:@"Purchasing..."];
            break;
        case DYFStorePurchaseStateCancelled:
            [self sendNotice:@"You cancel the purchase"];
            break;
        case DYFStorePurchaseStateFailed:
            [self sendNotice:[NSString stringWithFormat:@"An error occurred, %zi", self.purchaseInfo.error.code]];
            break;
        case DYFStorePurchaseStateSucceeded:
        case DYFStorePurchaseStateRestored:
            [self completePayment];
            break;
        case DYFStorePurchaseStateRestoreFailed:
            [self sendNotice:[NSString stringWithFormat:@"An error occurred, %zi", self.purchaseInfo.error.code]];
            break;
        case DYFStorePurchaseStateDeferred:
            DYFStoreLog(@"Deferred");
            break;
        default:
            break;
    }
}
```

#### Download notifications

```
- (void)processDownloadNotification:(NSNotification *)notification {

    self.downloadInfo = notification.object;

    switch (self.downloadInfo.downloadState) {
        case DYFStoreDownloadStateStarted:
            DYFStoreLog(@"The download started");
            break;
        case DYFStoreDownloadStateInProgress:
            DYFStoreLog(@"The download progress: %.2f%%", self.downloadInfo.downloadProgress);
            break;
        case DYFStoreDownloadStateCancelled:
            DYFStoreLog(@"The download cancelled");
            break;
        case DYFStoreDownloadStateFailed:
            DYFStoreLog(@"The download failed");
            break;
        case DYFStoreDownloadStateSucceeded:
            DYFStoreLog(@"The download succeeded: 100%%");
            break;
        default:
            break;
    }
}
```


### Receipt verification

`DYFStoreKit` doesn't perform receipt verification by default, but provides reference implementations. You can implement your own custom verification or use the reference verifier provided by the library.

The reference verifier is outlined below. For more info, check out the [wiki](https://github.com/dgynfi/DYFStoreKit/wiki/Receipt-verification).

#### Reference verifier

You create and return a receipt verifier(`DYFStoreReceiptVerifier`) by using lazy loading.

```
- (DYFStoreReceiptVerifier *)receiptVerifier {
    if (!_receiptVerifier) {
        _receiptVerifier = [[DYFStoreReceiptVerifier alloc] init];
        _receiptVerifier.delegate = self;
    }
    return _receiptVerifier;
}
```

The receipt verifier delegates receipt verification, enabling you to provide your own implementation using the `DYFStoreReceiptVerifierDelegate` protocol:

```
- (void)verifyReceiptDidFinish:(nonnull DYFStoreReceiptVerifier *)verifier didReceiveData:(nullable NSDictionary *)data;

- (void)verifyReceipt:(nonnull DYFStoreReceiptVerifier *)verifier didFailWithError:(nonnull NSError *)error;
```

You can start verifying the in-app purchase receipt. 

```
// Fetches the data of the bundle’s App Store receipt. 
NSData *data = receiptData ?: [NSData dataWithContentsOfURL:DYFStore.receiptURL];
DYFStoreLog(@"data: %@", data);

[_receiptVerifier verifyReceipt:data];

// Only used for receipts that contain auto-renewable subscriptions.
//[_receiptVerifier verifyReceipt:data sharedSecret:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
```

If security is a concern you might want to avoid using an open source verification logic, and provide your own custom verifier instead.

It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C, C: client, S: server).


### Finish transactions

The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.

```
[DYFStore.defaultStore finishTransaction:transaction];
```


## Transaction persistence

`DYFStoreKit` provides two optional reference implementations for storing transactions in the Keychain(`DYFStoreKeychainPersistence`) or in `NSUserDefaults`(`DYFStoreUserDefaultsPersistence`). 

When the client crashes during the payment process, it is particularly important to store transaction information. When storekit notifies the uncompleted payment again, it takes the data directly from keychain and performs the receipt verification until the transaction is completed.

### Store transaction

```
- (void)storeReceipt {
    DYFStoreLog();
    
    NSURL *receiptURL = DYFStore.receiptURL;
    NSData *data = [NSData dataWithContentsOfURL:receiptURL];
    if (!data || data.length == 0) {
        [self refreshReceipt];
        return;
    }
    
    DYFStoreNotificationInfo *info = self.purchaseInfo;
    DYFStore *store = DYFStore.defaultStore;
    DYFStoreKeychainPersistence *persister = store.keychainPersister;
    
    DYFStoreTransaction *transaction = [[DYFStoreTransaction alloc] init];
    
    if (info.state == DYFStorePurchaseStateSucceeded) {
        transaction.state = DYFStoreTransactionStatePurchased;
    } else if (info.state == DYFStorePurchaseStateRestored) {
        transaction.state = DYFStoreTransactionStateRestored;
    }
    
    transaction.productIdentifier = info.productIdentifier;
    transaction.userIdentifier = info.userIdentifier;
    transaction.transactionIdentifier = info.transactionIdentifier;
    transaction.transactionTimestamp = info.transactionDate.timestamp;
    transaction.originalTransactionTimestamp = info.originalTransactionDate.timestamp;
    transaction.originalTransactionIdentifier = info.originalTransactionIdentifier;
    
    transaction.transactionReceipt = data.base64EncodedString;
    [persister storeTransaction:transaction];
    
    // Makes the backup data.
    DYFStoreUserDefaultsPersistence *uPersister = [[DYFStoreUserDefaultsPersistence alloc] init];
    if (![uPersister containsTransaction:info.transactionIdentifier]) {
        [uPersister storeTransaction:transaction];
    }
    
    [self verifyReceipt:data];
}
```

### Remove transaction

```
dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
dispatch_after(time, dispatch_get_main_queue(), ^{
    DYFStoreNotificationInfo *info = self.purchaseInfo;
    DYFStore *store = DYFStore.defaultStore;
    DYFStoreKeychainPersistence *persister = store.keychainPersister;
    
    if (info.state == DYFStorePurchaseStateRestored) {
        
        SKPaymentTransaction *transaction = [store extractRestoredTransaction:info.transactionIdentifier];
        [store finishTransaction:transaction];
        
    } else {
        
        SKPaymentTransaction *transaction = [store extractPurchasedTransaction:info.transactionIdentifier];
        // The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.
        [store finishTransaction:transaction];
    }
    
    [persister removeTransaction:info.transactionIdentifier];
    if (info.originalTransactionIdentifier) {
        [persister removeTransaction:info.originalTransactionIdentifier];
    }
});
```


## Requirements

`DYFStoreKit` requires `iOS 7.0` or above and `ARC`.


## Demo

To learn more, please clone this project (`git clone https://github.com/dgynfi/DYFStoreKit.git`) to the local directory.


## Feedback is welcome

If you notice any issue, got stuck or just want to chat feel free to create an issue. I will be happy to help you.

