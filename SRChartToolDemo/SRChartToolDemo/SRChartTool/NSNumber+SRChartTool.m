//
//  NSNumber+SRChartTool.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/12/8.
//  Copyright © 2018 starrain. All rights reserved.
//

#import "NSNumber+SRChartTool.h"

@implementation NSNumber (SRChartTool)

- (NSString *)getStringBySeparatorWithQuantities:(int)quantities {
    NSDecimalNumberHandler *behavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:quantities raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithDecimal:self.decimalValue];
    NSDecimalNumber *resultNumber = [number decimalNumberByRoundingAccordingToBehavior:behavior];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [numberFormatter stringFromNumber:resultNumber];
}

@end
