//
//  DCPurchaseHelp.h
//  CDDPurchasing
//
//  Created by 陈甸甸 on 2019/11/30.
//  Copyright © 2019 RocketsChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

NS_ASSUME_NONNULL_BEGIN


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
/// @param transactions 商品订单模型数组
- (void)restoreWithProduct:(NSArray <SKPaymentTransaction*>*)transactions;


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




@interface DCPurchaseHelp : NSObject


+ (DCPurchaseHelp *)sharedHelp;


/// 购买完之后是否向iOS服务器验证，默认是开启验证
@property(nonatomic, assign) BOOL checkAfterPay;


/// 内购代理
@property(nonatomic, weak) id <DCPurchaseHelpDelegate> delegate;


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


@end

NS_ASSUME_NONNULL_END
