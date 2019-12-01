//
//  DCSystemAlterSheet.m
//  CDDAlterSheetDemo
//
//  Created by SnailChen on 2018/9/12.
//  Copyright © 2018年 SnailChen. All rights reserved.
//

#import "DCSystemAlterSheet.h"
#import <UIKit/UIKit.h>

@implementation DCSystemAlterSheet

#pragma mark - Alter弹框
+ (void)dc_SetUpAlterWithView:(UIViewController *)showVc WithTitle:(NSString *)title Message:(NSString *)message CancelTitle:(NSString *)cancelTitle SureTitle:(NSString *)sureTitle  CancelBlock:(dispatch_block_t)cancelBlock SureBlock:(dispatch_block_t)sureBlock CompletionBlock:(dispatch_block_t)completionBlock
{
    
    NSString *aTitle = (title.length > 0 || title != nil) ? title : nil;
    NSString *aMessage = (message.length > 0 || message != nil) ? message : nil;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:aMessage preferredStyle:UIAlertControllerStyleAlert];
    if ((cancelTitle.length > 0 || cancelTitle != nil)) { //UIAlertActionStyleCancel
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            !cancelBlock ? : cancelBlock();
        }];
        [alertController addAction:cancelAction];
    }

    if ((sureTitle.length > 0 || sureTitle != nil)) { //UIAlertActionStyleDefault
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            !sureBlock ? : sureBlock();
        }];
        [alertController addAction:sureAction];
    }
    
    if (title == nil && message == nil) return;
    if (sureTitle == nil && cancelTitle == nil) return;
    
    [showVc presentViewController:alertController animated:YES completion:completionBlock];
}


#pragma mark - sheet弹框
+ (void)dc_SetUpSheetWithView:(UIViewController *)showVc WithTitle:(NSString *)title Message:(NSString *)message ContentArray:(NSArray *)contentArray StyleArrray:(NSArray *)styleArrray CancelTitle:(NSString *)cancelTitle CancelBlock:(dispatch_block_t)cancelBlock ContentClickBlock:(void(^)(NSInteger index , NSString *titleName))contentBlock CompletionBlock:(dispatch_block_t)completionBlock
{
    NSString *aTitle = (title.length > 0 || title != nil) ? title : nil;
    NSString *aMessage = (message.length > 0 || message != nil) ? message : nil;
    UIAlertController *sheetController = [UIAlertController alertControllerWithTitle:aTitle message:aMessage preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ((cancelTitle.length > 0 || cancelTitle != nil)) { //UIAlertActionStyleCancel
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            !cancelBlock ? : cancelBlock();
        }];
        [sheetController addAction:cancelAction];
    }

    if (contentArray.count == 0) return;
    for (NSInteger  i = 0; i < contentArray.count; ++i) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:contentArray[i] style:(styleArrray != nil &&  styleArrray.count > 0) ? ([styleArrray[i] isEqualToString:@"UIAlertActionStyleDestructive"] ? UIAlertActionStyleDestructive : UIAlertActionStyleDefault) : UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            !contentBlock ? : contentBlock(i , contentArray[i]);
        }];
        [sheetController addAction:action];
    }
    
    [showVc presentViewController:sheetController animated:YES completion:completionBlock];
}



@end
