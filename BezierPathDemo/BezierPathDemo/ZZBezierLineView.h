//
//  ZZBezierLineView.h
//  BezierPathDemo
//
//  Created by zry on 2017/7/7.
//  Copyright © 2017年 zry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ChartHeight     180

@interface ZZBezierLineView : UIView

@property (nonatomic, strong) UIColor *lineColor;//曲线颜色
@property (nonatomic, strong) UIColor *fillColor;//填充色
@property (nonatomic, strong) UIColor *devideLineColor;//水平分割线颜色
@property (nonatomic, strong) UIColor *xLabelTextColor;//x轴label字体颜色

-(void)addLineWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints;
@end
