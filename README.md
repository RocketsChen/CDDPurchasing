# CDDPurchasing

苹果内购封装工具 / Easy to use

![](https://tva1.sinaimg.cn/large/006tNbRwgy1g9hnjvwkhkj30ku1127g6.jpg)


#### 提供如下方法：

```
/// 是否允许支付（环境）
- (BOOL)canMakePayments;


/// 向苹果服务器请求商品信息
/// @param products 商品id数组 @[@"product_01",@"product_02"]
- (void)getProductsInfoWithArray:(NSArray *)products;



/// 向苹果服务器购买商品
/// @param productID 商品id
- (void)payWithProduct:(NSString *)productID;



/// 恢复交易
- (void)restorePurchase;
```

#### 代理回调：

```
typedef NS_ENUM(NSInteger, PurchaseFiledCode) {
    
    PAY_FILEDCOED_NOTSUPPORT = 0, /// 不支持（canMakePayments方法同）
    
    PAY_FILEDCOED_NOTPRODUCTID = 1, /// 请求商品id为空
};

/// 自定义代理
@protocol DCPurchaseHelpDelegate <NSObject>


/// 获取商品详情数组
/// @param products 商品详情
- (void)getPurchaseProductsInfo:(NSMutableArray *)products;


/// 支付成功
/// @param productID 商品 ID
- (void)paySuccessedWithProduct:(NSString *)productID;


/// 支付失败
/// @param productID 商品 ID
- (void)payFailedWithProduct:(NSString *)productID;


/// 恢复购买
/// @param productID 商品 ID
- (void)restoreWithProduct:(NSString *)productID;


@optional //购买完之后是否向iOS服务器验证


/// 取消购买
/// @param productID 商品 ID
- (void)payCancelWithProduct:(NSString *)productID;

/// 正在支付
/// @param productID 商品 ID
- (void)waitingWithProduct:(NSString *)productID;


/// 购买成功正在验证
/// @param productID 商品 ID
- (void)paySuccessedPrepareCheck:(NSString *)productID;


/// check成功
/// @param productID 商品 ID
/// @param result check回调
- (void)checkSuccessedWithProduct:(NSString *)productID checkResult:(NSDictionary * _Nullable)result;


/// check失败
/// @param productID 商品 ID
/// @param result check回调
- (void)checkFailedWithProduct:(NSString *)productID checkResult:(NSDictionary * _Nullable)result;



/// 失败code码
/// @param filedCode PurchaseFiledCode
- (void)getErrorCode:(PurchaseFiledCode)filedCode;

@end
```


#### 封装逻辑：

* 1：向苹果服务器请球商品详情
   
   * 获取商品详情回调
   
* 2：根据商品id支付商品

   * 获取商品支付回调
     
     * 是否向苹果服务器验证购买凭证（verifyReceipt：走接口）
     * 验证回调

* 3：错误调用代理

#### Demo实现了封装内购方法的实现＋页面显示，欢迎下载，有问题issues吧~

