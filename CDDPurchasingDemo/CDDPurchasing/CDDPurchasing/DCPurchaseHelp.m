//
//  DCPurchaseHelp.m
//  CDDPurchasing
//
//  Created by 陈甸甸 on 2019/11/30.
//  Copyright © 2019 RocketsChen. All rights reserved.
//

#import "DCPurchaseHelp.h"


@interface DCPurchaseHelp() <SKPaymentTransactionObserver,SKProductsRequestDelegate>


@property(nonatomic,strong)NSMutableDictionary *productDict;


@property(nonatomic,assign)BOOL canMakePay;

@end

@implementation DCPurchaseHelp


+ (DCPurchaseHelp *)sharedHelp
{
    static dispatch_once_t once;
    static id sharedHelp;
    dispatch_once(&once, ^{
        sharedHelp = [self new];
    });
    return sharedHelp;
}


- (instancetype)init
{
    self = [super init];
    if (self) {

        [self initBaseValue];
    }
    return self;
}


- (void)initBaseValue
{
    self.checkAfterPay = YES;
    self.canMakePay = [self canMakePayments];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}


- (void)setCheckAfterPay:(BOOL)checkAfterPay
{
    _checkAfterPay = checkAfterPay;

}

#pragma mark - 是否允许支付（环境）
- (BOOL)canMakePayments
{
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - 向苹果服务器请求商品信息
- (void)getProductsInfoWithArray:(NSArray *)products
{
    if (!self.canMakePay) { NSLog(@"当前环境不支持支付。");
        if (self.delegate && [self.delegate respondsToSelector:@selector(getErrorCode:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate getErrorCode:PAY_FILEDCOED_NOTSUPPORT];
            });
        }
        return;
    }
    if (!products) { NSLog(@"商品id 为空，请先获取商品信息检查是否支持购买。");
        if (self.delegate && [self.delegate respondsToSelector:@selector(getErrorCode:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate getErrorCode:PAY_FILEDCOED_NOTPRODUCTID];
            });
        }
        return;
    }
    
    NSSet *set = [[NSSet alloc] initWithArray:products];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    
    [request start];
}

#pragma mark - 向苹果服务器购买商品
- (void)payWithProduct:(NSString *)productID;
{
    if (!self.canMakePay) { NSLog(@"当前环境不支持支付。");
        if (self.delegate && [self.delegate respondsToSelector:@selector(getErrorCode:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate getErrorCode:PAY_FILEDCOED_NOTSUPPORT];
            });
        }
        return;
    }
    if (!self.productDict || !productID) { NSLog(@"商品id 为空，请先获取商品信息检查是否支持购买，或者再次请求下信息。");
        if (self.delegate && [self.delegate respondsToSelector:@selector(getErrorCode:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate getErrorCode:PAY_FILEDCOED_NOTPRODUCTID];
            });
        }
        return;
    }
    SKProduct *product = self.productDict[productID];
    
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}



#pragma mark - 苹果服务器验证商品
- (void)validationWithProduct:(NSString *)productID
{
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *contentData = [NSData dataWithContentsOfURL:receiptURL];

#if defined(DEBUG)||defined(_DEBUG)
#define verifyURL @"https://sandbox.itunes.apple.com/verifyReceipt"
#else
#define verifyURL @"https://buy.itunes.apple.com/verifyReceipt"
#endif
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:verifyURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // 10秒超时
    request.HTTPMethod = @"POST";
    NSString *encodeStr = [contentData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = payloadData;
    NSURLSessionDataTask *sessionDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error){
        NSError *dataError;
        NSDictionary *checkResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&dataError];
        if (!error || !dataError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate checkSuccessedWithProduct:productID checkResult:checkResult];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate checkFailedWithProduct:productID checkResult:checkResult];
            });
        }
    }];
    [sessionDataTask resume];
}

#pragma mark - 恢复交易
- (void)restorePurchase
{
    if (!self.canMakePay) { NSLog(@"当前环境不支持支付。");
        if ([self.delegate respondsToSelector:@selector(getErrorCode:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate getErrorCode:PAY_FILEDCOED_NOTSUPPORT];
            });
        }
        return;
    }
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.productDict = [NSMutableDictionary dictionaryWithCapacity:response.products.count];
    
    NSMutableArray *productArray = [NSMutableArray array];
    for (SKProduct *product in response.products) {
        [self.productDict setObject:product forKey:product.productIdentifier];
        [productArray addObject:product];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate getPurchaseProductsInfo:productArray];
    });
}


#pragma mark - SKPaymentTransactionObserver
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    NSMutableArray <SKPaymentTransaction *>*restoredArrauy = [NSMutableArray array];
    for (SKPaymentTransaction *transaction in transactions) {
        
        if (SKPaymentTransactionStatePurchased == transaction.transactionState) {
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            if(self.checkAfterPay){  // 验证
                if ([self.delegate respondsToSelector:@selector(paySuccessedPrepareCheck:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate paySuccessedPrepareCheck:transaction.payment.productIdentifier];
                    });
                    [self validationWithProduct:transaction.payment.productIdentifier];
                }
            }else{
                
                if ([self.delegate respondsToSelector:@selector(paySuccessedWithProduct:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate paySuccessedWithProduct:transaction.payment.productIdentifier];
                    });
                }
            }
        } else if (SKPaymentTransactionStateRestored == transaction.transactionState) {
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            [restoredArrauy addObject:transaction];
            
        } else if (SKPaymentTransactionStateFailed == transaction.transactionState){
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            
            if(transaction.error.code != SKErrorPaymentCancelled) { // 支付失败

                if ([self.delegate respondsToSelector:@selector(payFailedWithProduct:)]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate payFailedWithProduct:transaction.payment.productIdentifier];
                    });
                }

            } else { // 取消支付
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate payCancelWithProduct:transaction.payment.productIdentifier];
                });
            }
            
        }else if(SKPaymentTransactionStatePurchasing == transaction.transactionState){

            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate waitingWithProduct:transaction.payment.productIdentifier];
            });
            
        }else{
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(restoreWithProduct:)] && restoredArrauy.count > 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate restoreWithProduct:restoredArrauy];
        });
    }
}

- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


@end
