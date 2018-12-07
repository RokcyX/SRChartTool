//
//  NSString+SRChartTool.m
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/12/7.
//  Copyright © 2018 starrain. All rights reserved.
//

#import "NSString+SRChartTool.h"

@implementation NSString (SRChartTool)

- (CGSize)sizeWithMaxSize:(CGSize)maxSize font:(UIFont *)font {
    CGSize textSize = CGSizeZero;
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
    CGRect rect = [self boundingRectWithSize:maxSize options:opts attributes:attributes context:nil];
    textSize = rect.size;
    return textSize;
}

@end
