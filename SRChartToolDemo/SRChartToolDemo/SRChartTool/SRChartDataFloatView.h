//
//  SRChartDataFloatView.h
//  SRChartToolDemo
//
//  Created by 周家民 on 2018/12/7.
//  Copyright © 2018 starrain. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SRChartDataFloatView : UIView

/**
 最大宽度，默认100
 */
@property (nonatomic,assign) CGFloat maxWidth;

/**
 显示信息

 @param title 标题
 @param infoStrList 信息字符串集合
 @param pointColorList 信息字符串前面小圆点颜色集合
 */
- (void)showWithTitle:(NSString *)title infoStrList:(NSArray<NSString *> *)infoStrList pointColorList:(NSArray<UIColor *> *)pointColorList;

@end

NS_ASSUME_NONNULL_END
