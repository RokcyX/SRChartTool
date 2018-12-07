//
//  SRChartDefaultView.h
//  SRChartToolDemo
//
//  Created by 周家民 on 2017/12/29.
//  Copyright © 2017年 starrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SRChartDefaultViewDelegate

@required
-(NSString*)valueForIndex:(int)index;
-(CGFloat)yForIndex:(int)index;

@end

@interface SRChartDefaultView : UIView

@property(nonatomic,weak)id<SRChartDefaultViewDelegate> delegate;

@property(nonatomic,strong)UILabel *showValueView;

@property(nonatomic,strong)CAShapeLayer *chartLayer;

/**
 坐标点的半径，默认为2
 */
@property(nonatomic,assign)CGFloat pointRadius;

/**
 坐标点颜色，默认白色
 */
@property(nonatomic,strong)UIColor *pointColor;

/**
 填充色，默认白色
 */
@property(nonatomic,strong)UIColor *fillColor;

/**
 x轴文字颜色，默认为白色
 */
@property(nonatomic,strong)UIColor *xTitleColor;

/**
 x轴文字字体
 */
@property(nonatomic,strong)UIFont *xTitleFont;

/**
 坐标点间的间隔，默认为50
 */
@property(nonatomic,assign)CGFloat gap;

/**
 是否关闭路径
 */
@property(nonatomic,assign,getter=isClosePath)BOOL closePath;

/**
 为提供的贝塞尔变量添加路径

 @param path 贝塞尔路径
 @param prePoint 上一个点
 @param nextPoint 下一个点
 @param currentPercent 下一个点当前的百分比
 @param springPercent 弹性效果百分比，该值域为[-1,1]，最终为0
 return 返回最新的下一个点坐标
 */
-(CGPoint)drawWithPath:(UIBezierPath*)path index:(int)index prePoint:(CGPoint)prePoint nextPoint:(CGPoint)nextPoint currentPercent:(CGFloat)currentPercent springPercent:(CGFloat)springPercent;

/**
 点击触发

 @param point 触发的坐标点
 @param valueStr 该点的值
 */
-(void)didClickWithPoint:(CGPoint)point valueStr:(NSString*)valueStr;

/**
 根据提供的最大尺寸及字体计算字符串实际的尺寸
 
 @param str 字符串
 @param maxSize 允许的最大尺寸
 @param font 字体
 @return 返回计算过后的字符串实际尺寸
 */
+(CGSize)sizeWithString:(NSString *)str maxSize:(CGSize)maxSize font:(UIFont *)font;

/**
 绘制横坐标标题

 @param xTitleArr 横坐标标题集合
 */
-(void)drawXTitleWithXTitleArr:(NSArray*)xTitleArr;

-(void)showWithPath:(UIBezierPath*)path;

@end
