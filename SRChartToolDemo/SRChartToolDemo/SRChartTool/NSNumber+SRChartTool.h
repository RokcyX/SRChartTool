//
//  NSNumber+SRChartTool.h
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/12/8.
//  Copyright © 2018 starrain. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (SRChartTool)

/**
 获取number根据保留小数位和千万位分隔符格式化的字符串形式
 
 @param quantities 小数保留位数 0到3位
 @return 返回格式化后的字符串
 */
- (NSString *)getStringBySeparatorWithQuantities:(int)quantities;

@end

NS_ASSUME_NONNULL_END
