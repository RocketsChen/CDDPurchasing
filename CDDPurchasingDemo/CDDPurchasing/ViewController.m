//
//  ViewController.m
//  CDDPurchasing
//
//  Created by 陈甸甸 on 2019/11/30.
//  Copyright © 2019 RocketsChen. All rights reserved.
//

#import "ViewController.h"
#import "DCPurchaseHelp.h"
#import "DCSystemAlterSheet.h"
#import <StoreKit/StoreKit.h>

@interface ViewController () <DCPurchaseHelpDelegate>


/// bundle id
@property (weak, nonatomic) IBOutlet UITextField *bundleField;


/// 商品 id
@property (weak, nonatomic) IBOutlet UITextField *goods1Field;
@property (weak, nonatomic) IBOutlet UITextField *goods2Field;
@property (weak, nonatomic) IBOutlet UITextField *goods3Field;


/// log 内容
@property (weak, nonatomic) IBOutlet UITextView *logContent;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setUpBase];
}


- (void)setUpBase
{
    self.bundleField.enabled = NO;
    self.logContent.editable = NO;
    
    self.bundleField.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    
    self.goods1Field.text = @"com.purchasing.test01";
    self.goods2Field.text = @"com.purchasing.test02";
    self.goods3Field.text = @"com.purchasing.test03";
    
    [DCPurchaseHelp sharedHelp].delegate = self;
    
}


#pragma mark - 获取商品详情
- (IBAction)goodsInfoClick:(id)sender {
    
    [DCSystemAlterSheet dc_SetUpSheetWithView:self WithTitle:@"请选择你要获取商品" Message:nil ContentArray:@[@"商品1",@"商品2",@"商品3",@"全部获取"] StyleArrray:nil CancelTitle:@"取消" CancelBlock:nil ContentClickBlock:^(NSInteger index, NSString *titleName) {
        switch (index) {
            case 0:

                [[DCPurchaseHelp sharedHelp] getProductsInfoWithArray:@[self.goods1Field.text]];
                break;
            case 1:

                [[DCPurchaseHelp sharedHelp] getProductsInfoWithArray:@[self.goods2Field.text]];
                break;
            case 2:

                [[DCPurchaseHelp sharedHelp] getProductsInfoWithArray:@[self.goods3Field.text]];
                break;
            case 3:

                [[DCPurchaseHelp sharedHelp] getProductsInfoWithArray:@[self.goods1Field.text,self.goods2Field.text,self.goods3Field.text]];
                break;
            default:
                break;
        }
    } CompletionBlock:nil];
}

#pragma mark - 购买商品
- (IBAction)payGoods:(id)sender {
    [DCSystemAlterSheet dc_SetUpSheetWithView:self WithTitle:@"请选择你要购买的商品" Message:nil ContentArray:@[@"商品1",@"商品2",@"商品3"] StyleArrray:nil CancelTitle:@"取消" CancelBlock:nil ContentClickBlock:^(NSInteger index, NSString *titleName) {
        switch (index) {
            case 0:
                [[DCPurchaseHelp sharedHelp] payWithProduct:self.goods1Field.text];
                break;
            case 1:
                
                [[DCPurchaseHelp sharedHelp] payWithProduct:self.goods2Field.text];
                break;
            case 2:
                
                [[DCPurchaseHelp sharedHelp] payWithProduct:self.goods3Field.text];
                break;
            default:
                break;
        }
    } CompletionBlock:nil];
}

#pragma mark - 恢复商品
- (IBAction)restoreGoods:(id)sender {

    [[DCPurchaseHelp sharedHelp] restorePurchase];
}


#pragma mark - 清除日志
- (IBAction)cleanLog:(id)sender {
    self.logContent.text = @"";
}


#pragma mark - DCPurchaseHelpDelegate


- (void)getErrorCode:(PurchaseFiledCode)filedCode
{
    switch (filedCode) {
        case 0:
            [DCSystemAlterSheet dc_SetUpAlterWithView:self WithTitle:@"当前环境不支持支付，请检查" Message:nil CancelTitle:nil SureTitle:@"OK" CancelBlock:nil SureBlock:nil CompletionBlock:nil];
            break;
            
        case 1:
            [DCSystemAlterSheet dc_SetUpAlterWithView:self WithTitle:@"当前支付的商品id为空" Message:nil CancelTitle:nil SureTitle:@"OK" CancelBlock:nil SureBlock:nil CompletionBlock:nil];
            break;
        default:
            break;
    }
}


#pragma mark - 获取商品详情数组
- (void)getPurchaseProductsInfo:(NSMutableArray *)products
{
    NSString *productsInfo = @"";
    for (SKProduct *productsItem in products) {
        NSString *product = [NSString stringWithFormat:@"商品ID：%@ \n商品名称：%@ \n商品价格：%@ \n商品介绍：%@",productsItem.productIdentifier,productsItem.localizedTitle,productsItem.price,productsItem.localizedDescription];
        productsInfo = [productsInfo stringByAppendingString:[NSString stringWithFormat:@"%@%@",(productsInfo.length > 0) ? @"\n\n": @"",product]];
    }
    self.logContent.text = productsInfo;
}



- (void)payFailedWithProduct:(id)productID
{
    
    NSLog(@"支付失败");
}


- (void)paySuccessedWithProduct:(id)productID
{
    NSLog(@"支付成功");
}

#pragma mark - 购买成功
- (void)checkSuccessedWithProduct:(NSString *)productID checkResult:(NSDictionary * _Nullable)result
{
    if (result) {
        NSString *successeInfo = [NSString stringWithFormat:@"本次支付成功 \n支付环境：%@ \n商品ID：%@ \n支付时间：%@ \n支付数量：%@ ",result[@"environment"],result[@"receipt"][@"in_app"][0][@"product_id"],result[@"receipt"][@"in_app"][0][@"original_purchase_date"],result[@"receipt"][@"in_app"][0][@"quantity"]];
        self.logContent.text = successeInfo;
    }
}


#pragma mark - 购买失败
- (void)checkFailedWithProduct:(NSString *)productID checkResult:(NSDictionary * _Nullable)result
{
    self.logContent.text = @"支付失败";
}


- (void)paySuccessedPrepareCheck:(NSString *)productID
{
    NSLog(@"支付成功，向服务器check");
}


- (void)waitingWithProduct:(NSString *)productID
{
    NSLog(@"正在支付中");
}


- (void)payCancelWithProduct:(NSString *)productID
{
    NSLog(@"取消支付");
}


- (void)restoreWithProduct:(NSString *)productID
{
    NSLog(@"恢复商品");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}




@end

