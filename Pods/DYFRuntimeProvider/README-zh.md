## DYFRuntimeProvider

`DYFRuntimeProvider`包装了 Runtime，可以快速用于字典和模型的转换、存档和解档、添加方法、交换两个方法、替换方法以及获取类的所有变量名、属性名和方法名。

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFRuntimeProvider.svg?style=flat)](http://cocoapods.org/pods/DYFRuntimeProvider)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFRuntimeProvider.svg?style=flat)&nbsp;


## QQ群 (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/dgynfi/DYFRuntimeProvider/raw/master/images/g614799921.jpg" width="30%" />
</div>


## 安装

使用 [CocoaPods](https://cocoapods.org):

``` 
target 'Your target name'

pod 'DYFRuntimeProvider', '~> 1.0.3'
```


## 使用

将 `#import "DYFRuntimeProvider.h"` 添加到源代码中。

### 获取某类的所有方法名

**1. 获取实例的所有方法名**

```
NSArray *methodNames = [DYFRuntimeProvider methodListWithClass:UITableView.class];
for (NSString *name in methodNames) {
    NSLog("The method name: %@", name);
}
```

**2. 获取类的所有方法名**

```
NSArray *clsMethodNames = [DYFRuntimeProvider classMethodList:self];
for (NSString *name in clsMethodNames) {
    NSLog("The class method name: %@", name);
}
``` 

### 获取某类所有的变量名

```
NSArray *ivarNames = [DYFRuntimeProvider ivarListWithClass:UILabel.class];
for (NSString *name in ivarNames) {
    NSLog("The var name: %@", name);
}
```

### 获取某类所有的属性名

```
NSArray *propertyNames = [DYFRuntimeProvider propertyListWithClass:UILabel.class];
for (NSString *name in propertyNames) {
    NSLog("The property name: %@", name);
}
```

### 添加一个方法

```
+ (void)load {
    [DYFRuntimeProvider addMethodWithClass:self.class selector:NSSelectorFromString(@"verifyCode") impClass:self.class impSelector:@selector(verifyQRCode)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:NSSelectorFromString(@"verifyCode")];
#pragma clang diagnostic pop
}

- (void)verifyQRCode {
    NSLog(@"Verifies QRCode");
}
```

### 交换两个方法

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DYFRuntimeProvider exchangeMethodWithClass:self.class selector:@selector(verifyCode1) targetClass:self.class targetSelector:@selector(verifyQRCode)];
    
    [self verifyCode1];
    [self verifyQRCode];
}

- (void)verifyCode1 {
    NSLog(@"Verifies Code1");
}

- (void)verifyQRCode {
    NSLog(@"Verifies QRCode");
}
```

### 替换一个方法

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [DYFRuntimeProvider replaceMethodWithClass:self.class selector:@selector(verifyCode2) targetClass:self.class targetSelector:@selector(verifyQRCode)];
    
    [self verifyCode2];
    [self verifyQRCode];
}

- (void)verifyCode2 {
    NSLog(@"Verifies Code2");
}

- (void)verifyQRCode {
    NSLog(@"Verifies QRCode");
}
```

### 字典和模型互转

**1. 字典转模型**

```
// e.g.: DYFStoreTransaction: NSObject
DYFStoreTransaction *transaction = [DYFRuntimeProvider modelWithDictionary:dict forClass:DYFStoreTransaction.class];
```

**2. 模型转字典**

```
DYFStoreTransaction *transaction = [[DYFStoreTransaction alloc] init];
NSDictionary *dict = [DYFRuntimeProvider dictionaryWithModel:transaction];
```

### 归档解档

**1. 归档**

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"DYFStoreTransaction.data"];
    
    [self archive:filePath];
}

- (void)archive:(NSString *)path {
    // e.g.: DYFStoreTransaction: NSObject <NSCoding>
    DYFStoreTransaction *transaction = [[DYFStoreTransaction alloc] init];
    [DYFRuntimeProvider archiveWithObject:transaction forClass:DYFStoreTransaction.class toFile:path];
}
```

Or

```
// e.g.: DYFStoreTransaction: NSObject <NSCoding>

@implementation DYFStoreTransaction

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [DYFRuntimeProvider encode:aCoder forObject:self];
}

@end
```

**2. 解档**

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) lastObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"YFModel.plist"];
    
    [self unarchive:filePath];
}

- (void)unarchive:(NSString *)path {
    // e.g.: DYFStoreTransaction: NSObject <NSCoding>
    DYFStoreTransaction *transaction = [DYFRuntimeProvider unarchiveWithFile:path forClass:DYFStoreTransaction.class];
}
```

Or

```
// e.g.: DYFStoreTransaction: NSObject <NSCoding>

@implementation DYFStoreTransaction

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        [DYFRuntimeProvider decode:aDecoder forObject:self];
    }
    return self;
}

@end
```


## 演示

`DYFRuntimeProvider` 在此 [演示](https://github.com/dgynfi/DYFStoreKit) 下学习如何使用。


## 欢迎反馈

如果你注意到任何问题，被卡住或只是想聊天，请随意制造一个问题。我乐意帮助你。
