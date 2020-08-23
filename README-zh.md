## DYFStoreKit

一个用于应用内购买的轻量级易用 iOS 库。(Objective-C)

`DYFStoreKit`使用代码块和[通知](#通知)包装`StoreKit`，提供[收据验证](#收据验证)和[交易持久化](#交易持久化)。`DYFStoreKit`不需要任何外部依赖项。

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/DYFStoreKit.svg?style=flat)](http://cocoapods.org/pods/DYFStoreKit)&nbsp;
![CocoaPods](http://img.shields.io/cocoapods/p/DYFStoreKit.svg?style=flat)&nbsp;


## 特点

- 超级简单的应用内购买
- 内置支持记住您的购买
- 内置收据验证（远程）
- 内置托管内容下载和通知


## QQ群 (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/dgynfi/DYFStoreKit/raw/master/images/g614799921.jpg" width="30%" />
</div>


## 安装

使用 [CocoaPods](https://cocoapods.org):

``` 
pod 'DYFStoreKit', '~> 1.1.5'
```

Or

```
pod 'DYFStoreKit'
```

或者从 [DYFStoreKit](https://github.com/dgynfi/DYFStoreKit/tree/master/DYFStoreKit) 目录手动添加文件。

查看 [wiki](https://github.com/dgynfi/DYFStoreKit/wiki/Installation) 以获取更多选项。


## 使用

接下来我会教你如何使用 `DYFStoreKit`.

### 初始化

初始化如下所示。

- 是否允许将日志输出到控制台，在 Debug 模式下设置 `true`，查看内购整个过程的日志，在 Release 模式下发布 App 时将 enableLog 设置 `false`。
- 添加交易的观察者，监听交易的变化。
- 实例化数据持久，存储交易的相关信息。
- 遵守协议 `DYFStoreAppStorePaymentDelegate`，处理从 App Store 购买产品的付款。

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

你可以处理用户从应用商店发起的购买，并使用 `DYFStoreAppStorePaymentDelegate` 协议提供自己的实现：

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


### 创建商品查询的请求

有两种策略可用于从应用程序商店获取有关产品的信息。

**策略1：** 在开始购买过程，首先必须清楚有哪些产品标识符。App 可以使用其中一个产品标识符来获取应用程序商店中可供销售的产品的信息，并直接提交付款请求。

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

**策略2：** 在开始购买过程，首先必须清楚有哪些产品标识符。App 从应用程序商店获取有关产品的信息，并向用户显示其商店用户界面。App 中销售的每个产品都有唯一的产品标识符。App 使用这些产品标识符获取有关应用程序商店中可供销售的产品的信息，例如定价，并在用户购买这些产品时提交付款请求。

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


### 创建购买产品的付款请求

判断设备是否允许用户付款。

```
if (![DYFStore canMakePayments]) {
    [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
    return;
}
```

使用给定的产品标识符请求产品付款。

```
[DYFStore.defaultStore purchaseProduct:@"com.hncs.szj.coin210"];
```

如果需要系统上用户帐户的不透明标识符来添加付款，可以使用用户帐户名的单向哈希来计算此属性的值。

计算 SHA256 哈希值函数：

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

使用给定的产品标识符和系统中用户帐户的不透明标识符请求产品付款。

```
[DYFStore.defaultStore purchaseProduct:@"com.hncs.szj.coin210" userIdentifier:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
```


### 恢复已购买的付款交易

在某些场景（如切换设备），App 需要提供恢复购买按钮，用来恢复之前购买的非消耗型的产品。

- 无绑定用户帐户 ID 的恢复

```
[DYFStore.defaultStore restoreTransactions];
```

- 绑定用户帐户 ID 的恢复

```
[DYFStore.defaultStore restoreTransactions:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
```


### 创建刷新收据请求

如果 `Bundle.main.appStoreReceiptURL` 为空，就需要创建刷新收据请求，获取付款交易的收据。

```
[DYFStore.defaultStore refreshReceiptOnSuccess:^{
    [self storeReceipt];
} failure:^(NSError *error) {
    [self failToRefreshReceipt];
}];
```


### 通知

`DYFStore`发送与`StoreKit`相关事件的通知，并扩展`NSNotification`以提供相关信息。要接收它们，请将观察者添加到`DYFStore`管理员。

#### 添加商店观察者，监听购买和下载通知

```
- (void)addStoreObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(processPurchaseNotification:) name:DYFStorePurchasedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(processDownloadNotification:) name:DYFStoreDownloadedNotification object:nil];
}
```

#### 在适当的时候，移除商店观察者

```
- (void)removeStoreObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self name:DYFStorePurchasedNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:DYFStoreDownloadedNotification object:nil];
}
```

#### 付款交易的通知处理

付款交易的通知是在请求付款后发送的，或是为每个恢复的交易发送的。

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

#### 下载的通知处理

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


### 收据验证

`DYFStoreKit`默认情况下不执行收据验证，但提供引用实现。您可以实现自己的自定义验证或使用库提供的引用验证程序。

引用验证程序概述如下。有关更多信息，请查看 [wiki](https://github.com/dgynfi/DYFStoreKit/wiki/Receipt-verification).

#### 引用验证器

通过使用延迟加载创建并返回收据验证器（`DYFStoreReceiptVerifier`）。

```
- (DYFStoreReceiptVerifier *)receiptVerifier {
    if (!_receiptVerifier) {
        _receiptVerifier = [[DYFStoreReceiptVerifier alloc] init];
        _receiptVerifier.delegate = self;
    }
    return _receiptVerifier;
}
```

收据验证程序委托收据验证，使您能够使用`DYFStoreReceiptVerifierDelegate`协议提供自己的实现：

```
- (void)verifyReceiptDidFinish:(nonnull DYFStoreReceiptVerifier *)verifier didReceiveData:(nullable NSDictionary *)data;

- (void)verifyReceipt:(nonnull DYFStoreReceiptVerifier *)verifier didFailWithError:(nonnull NSError *)error;
```

你可以开始验证应用内购买收据。

```
// Fetches the data of the bundle’s App Store receipt. 
NSData *data = receiptData ?: [NSData dataWithContentsOfURL:DYFStore.receiptURL];
DYFStoreLog(@"data: %@", data);

[_receiptVerifier verifyReceipt:data];

// Only used for receipts that contain auto-renewable subscriptions.
//[_receiptVerifier verifyReceipt:data sharedSecret:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
```

如果担心安全性，你可能希望避免使用开源验证逻辑，而是提供自己的自定义验证程序。

最好使用你自己的服务器获取从客户端上传的参数，以验证来自App Store服务器的收据的响应信息（C -> 上传的参数 -> S -> App Store S -> S -> 接收并解析数据 -> C，C:客户端，S:服务器）。


### 完成交易

只有客户机与服务器采用安全通信和数据加密并且收据验证通过后，才能完成交易。这样，我们可以避免刷新订单和破解应用内购买。如果我们无法完成验证，我们希望`StoreKit`不断提醒我们还有未完成的交易。

```
[DYFStore.defaultStore finishTransaction:transaction];
```


## 交易持久化

`DYFStoreKit`提供了两个可选的引用实现，用于将交易信息存储在 Keychain（`DYFStoreKeychainPersistence`) ）或 NSUserDefaults（`DYFStoreUserDefaultsPersistence`）中。

当客户端在付款过程中发生崩溃，导致 App 闪退，这时存储交易信息尤为重要。当 StoreKit 再次通知未完成的付款时，直接从 Keychain 中取出数据，进行收据验证，直至完成交易。

### 存储交易信息

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

### 移除交易信息

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


## 要求

`DYFStoreKit`需要`iOS 7.0`或更高版本和ARC。


## 演示

如需了解更多，请克隆此项目（`git clone https://github.com/dgynfi/DYFStoreKit.git`）到本地目录。


## 欢迎反馈

如果你注意到任何问题，被卡住或只是想聊天，请随意创建一个问题。我很乐意帮助你。

