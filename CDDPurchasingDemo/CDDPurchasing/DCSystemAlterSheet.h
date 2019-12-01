//
//  DCSystemAlterSheet.h
//  CDDAlterSheetDemo
//
//  Created by SnailChen on 2018/9/12.
//  Copyright © 2018年 SnailChen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DCSystemAlterSheet : NSObject


/**
 Alter弹框

 @param showVc 当前控制器
 @param title 标题
 @param message 内容
 @param cancelTitle 取消事件名称
 @param sureTitle 确定事件名称
 @param cancelBlock 取消回调
 @param sureBlock 确定回调
 @param completionBlock 完成回调
 */
+ (void)dc_SetUpAlterWithView:(UIViewController *)showVc WithTitle:(NSString *)title Message:(NSString *)message CancelTitle:(NSString *)cancelTitle SureTitle:(NSString *)sureTitle  CancelBlock:(dispatch_block_t)cancelBlock SureBlock:(dispatch_block_t)sureBlock CompletionBlock:(dispatch_block_t)completionBlock;


/**
 sheet弹框

 @param showVc 当前控制器
 @param title 标题
 @param message 内容
 @param contentArray sheet Item 名数组
 @param cancelTitle 取消事件名
 @param cancelBlock 取消回调
 @param contentBlock sheet Item 名数组 回调
 @param completionBlock 完成回调
 */
+ (void)dc_SetUpSheetWithView:(UIViewController *)showVc WithTitle:(NSString *)title Message:(NSString *)message ContentArray:(NSArray *)contentArray StyleArrray:(NSArray *)styleArrray CancelTitle:(NSString *)cancelTitle CancelBlock:(dispatch_block_t)cancelBlock ContentClickBlock:(void(^)(NSInteger index , NSString *titleName))contentBlock CompletionBlock:(dispatch_block_t)completionBlock;

@end
