//
//  ZZBezierLineView.m
//  BezierPathDemo
//
//  Created by zry on 2017/7/7.
//  Copyright © 2017年 zry. All rights reserved.
//

#import "ZZBezierLineView.h"
#import "UIView+Addition.h"

@interface ZZBezierLineView()
@property (nonatomic, strong) UIBezierPath *curvePath;//曲线路径
@property (nonatomic, assign) CGFloat addHeight;//绘图完成后追加个底部label的高度
@end

@implementation ZZBezierLineView

#pragma mark - LineConfig:画线配置
-(void)addLineWithXPoints:(NSArray *)xPoints yPoints:(NSArray *)yPoints
{
    if (!self.lineColor) {
        self.lineColor = [UIColor colorWithRed:107.00/255 green:90.00/255 blue:82.00/255 alpha:1];
    }
    if (!self.fillColor) {
        self.fillColor = [UIColor colorWithRed:219.00/255 green:207.00/255 blue:202.00/255 alpha:0.5];
    }
    if (!self.devideLineColor) {
        self.devideLineColor = [UIColor colorWithRed:166.00/255 green:137.00/255 blue:124.00/255 alpha:0.4];
    }
    if (!self.xLabelTextColor) {
        self.xLabelTextColor = [UIColor blackColor];
    }
    
    //创建折线点标记
    //有时x轴数据较多，需要对x轴数据进行平均分割，则需要对xSpace和dataSpace进行调整，并需要注意画线的起始位置。（比如x轴数据为0~24的整数，可能需要调整显示为0、2、4...24的偶数形式或1、3、5...23的奇数形式，这时需要格外注意起始画线位和水平方向描点平均值）
    CGFloat xSpace = (CGFloat)self.width / (xPoints.count - 1);
    CGFloat dataSpace = (CGFloat)self.width / (xPoints.count - 1);//每条数据之间是水平距离
    
    //此处设y数组最大值为画线中y轴最大值（设置完y轴最大值再创建y轴label）
    CGFloat maxValue = [[yPoints valueForKeyPath:@"@max.floatValue"] floatValue];
    CGFloat maxLevel = maxValue;

    //    x轴label
    [self createXLabelWithPoints:xPoints xSpace:xSpace];
    
    //y轴label
    [self createYLabelWithMaxLevel:maxLevel];
    
    CGPoint start = CGPointMake(0, (maxLevel - [yPoints[0] floatValue]) /maxLevel * ChartHeight);;
    CGPoint end = CGPointMake(dataSpace *(yPoints.count - 1), (maxLevel - [yPoints[yPoints.count - 1] floatValue]) / maxLevel * ChartHeight);
    
    //转化成CGPoint数组,（x,y）是在坐标系中的实际位置
    NSMutableArray *points = [NSMutableArray arrayWithCapacity:yPoints.count];
    for (NSInteger i = 0; i< yPoints.count; i++) {
        CGFloat  y = [yPoints[i] floatValue];
        CGPoint point = CGPointMake(dataSpace * i, (maxLevel - y) /maxLevel * ChartHeight);
        NSValue *value = [NSValue valueWithCGPoint:point];
        [points addObject:value];
    }
    //画曲线
    [self drawCurveLineWithPoints:points];
    //填充颜色
    [self fillLayerWithStart:start end:end];
    //标记每个坐标点的数值
    [self markYValuesWithPoints:points yPoints:yPoints];
}

#pragma mark - YSplitLine&&YLabel:y轴分割线和label
-(void)createYLabelWithMaxLevel:(CGFloat)maxLevel
{
    CAShapeLayer *dottedLayer = [CAShapeLayer layer];
    dottedLayer.strokeColor = [self.devideLineColor CGColor];
    dottedLayer.fillColor = [UIColor clearColor].CGColor;
    dottedLayer.lineWidth = 1;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 1.0;
    CGFloat dashPattern[] = {3,3};
    
    [path setLineDash:dashPattern count:10 phase:1];
    [path moveToPoint:CGPointMake(0, ChartHeight)];
    [path addLineToPoint:CGPointMake(self.width, ChartHeight)];
    dottedLayer.path = path.CGPath;
    [self.layer addSublayer:dottedLayer];
    
    CGFloat Ydivision = 4;
    CGFloat labelHeight = 20;
    for (NSInteger i = 0; i <= Ydivision; i++) {
        //水平分隔线
        CAShapeLayer *dottedLayer = [CAShapeLayer layer];
        dottedLayer.strokeColor = [self.devideLineColor CGColor];
        dottedLayer.fillColor = [UIColor clearColor].CGColor;
        dottedLayer.lineWidth = 1;
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        path.lineWidth = 1.0;
        CGFloat dashPattern[] = {3,1};
        [path setLineDash:dashPattern count:10 phase:1];
        [path moveToPoint:CGPointMake(0, ChartHeight * i / Ydivision)];
        [path addLineToPoint:CGPointMake(self.width, ChartHeight * i / Ydivision)];
        dottedLayer.path = path.CGPath;
        [self.layer addSublayer:dottedLayer];
        
        if (i!= Ydivision) {
            UILabel * yLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, ChartHeight/Ydivision *i , ChartHeight/Ydivision, labelHeight)];
            yLabel.backgroundColor = [UIColor clearColor];
            if (maxLevel < 10) {
                yLabel.text = [NSString stringWithFormat:@"%.2f",(Ydivision - i)*(maxLevel / Ydivision)];
            }else if (maxLevel < 100){
                yLabel.text = [NSString stringWithFormat:@"%.1f",(Ydivision - i)*(maxLevel / Ydivision)];
            }else{
                yLabel.text = [NSString stringWithFormat:@"%.0f",(Ydivision - i)*(maxLevel / Ydivision)];
            }
            yLabel.textColor = [UIColor orangeColor];
            yLabel.font = [UIFont systemFontOfSize:12];
            [yLabel sizeToFit];
            yLabel.centerY = ChartHeight * i / Ydivision ;
            [self addSubview:yLabel];
        }
    }
}

#pragma mark - XLabel:x轴label
-(void)createXLabelWithPoints:(NSArray *)xPoints xSpace:(CGFloat)space
{
    CGFloat labelWidth = space;
    
    self.addHeight = 0;
    for (NSInteger i = 0; i <= xPoints.count - 1; i++) {
        //
        UILabel *xLabel = [[UILabel alloc] initWithFrame:CGRectMake(space * i, ChartHeight, labelWidth, 30)];
        xLabel.backgroundColor = [UIColor clearColor];
        xLabel.font = [UIFont systemFontOfSize:12];
        xLabel.text = [NSString stringWithFormat:@"%@",xPoints[i]];
        xLabel.textColor = self.xLabelTextColor;
        xLabel.font = [UIFont systemFontOfSize:12];
        [xLabel sizeToFit];
        xLabel.centerX = space * [xPoints[i] integerValue];
        [self addSubview:xLabel];
        
        self.addHeight = xLabel.height;
        
        CAShapeLayer *dottedLayer = [CAShapeLayer layer];
        dottedLayer.strokeColor = [[UIColor grayColor] CGColor];
        dottedLayer.fillColor = [UIColor clearColor].CGColor;
        dottedLayer.lineWidth = 1;
        
        UIBezierPath *path = [[UIBezierPath alloc] init];
        path.lineWidth = 1.0;
        [path moveToPoint:CGPointMake(space *[xPoints[i] integerValue], ChartHeight)];
        [path addLineToPoint:CGPointMake(space *[xPoints[i] integerValue], ChartHeight + 2)];
        dottedLayer.path = path.CGPath;
        [self.layer addSublayer:dottedLayer];
    }
    
    CAShapeLayer *firstLayer = [CAShapeLayer layer];
    firstLayer.strokeColor = [[UIColor blueColor] CGColor];
    firstLayer.fillColor = [UIColor clearColor].CGColor;
    firstLayer.lineWidth = 1;
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    path.lineWidth = 1.0;
    [path moveToPoint:CGPointMake(0, ChartHeight)];
    [path addLineToPoint:CGPointMake(0, ChartHeight + 3)];
    firstLayer.path = path.CGPath;
    [self.layer addSublayer:firstLayer];
}

#pragma mark - DrawCurveLine:画曲线
-(void)drawCurveLineWithPoints:(NSArray *)points
{
    //曲线layer
    self.curvePath = [self quadCurvedPathWithPoints:points];
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.strokeColor = [self.lineColor CGColor];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineWidth = 1.0;
    layer.lineCap = kCALineCapRound;
    layer.lineJoin = kCALineJoinRound;
    layer.path = self.curvePath.CGPath;
    [self.layer addSublayer:layer];
}

#pragma mark - CurvePath:曲线路径
-(UIBezierPath *)quadCurvedPathWithPoints:(NSArray *)points
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSValue *value = points[0];
    CGPoint p1 = [value CGPointValue];
    [path moveToPoint:p1];
    
    if (points.count == 2) {
        value = points[1];
        CGPoint p2 = [value CGPointValue];
        [path addLineToPoint:p2];
        return path;
    }
    
    for (NSUInteger i = 1; i < points.count; i++) {
        value = points[i];
        CGPoint p2 = [value CGPointValue];
        CGPoint midPoint = midPointForPoints(p1, p2);
        [path addQuadCurveToPoint:midPoint controlPoint:controlPointForPoints(midPoint, p1)];
        [path addQuadCurveToPoint:p2 controlPoint:controlPointForPoints(midPoint, p2)];
        p1 = p2;
    }
    return path;
}

#pragma mark - 两个点连线的中心点
static CGPoint midPointForPoints(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

#pragma mark - 获取controlPoint
static CGPoint controlPointForPoints(CGPoint p1, CGPoint p2) {
    CGPoint controlPoint = midPointForPoints(p1, p2);
    CGFloat diffY = fabs(p2.y - controlPoint.y);
    
    if (p1.y < p2.y)
        controlPoint.y += diffY;
    else if (p1.y > p2.y)
        controlPoint.y -= diffY;
    
    return controlPoint;
}

#pragma mark - FillColor:用颜色填充曲线范围
-(void)fillLayerWithStart:(CGPoint)start end:(CGPoint)end
{
    NSLog(@"start=======%@",[NSValue valueWithCGPoint:start]);
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithCGPath:self.curvePath.CGPath];
    [fillPath moveToPoint:end];
    [fillPath addLineToPoint:CGPointMake(end.x, ChartHeight)];
    [fillPath addLineToPoint:CGPointMake(start.x, ChartHeight)];
    [fillPath addLineToPoint:start];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = fillPath.CGPath;
    fillLayer.strokeColor = [UIColor clearColor].CGColor;
    fillLayer.fillColor = self.fillColor.CGColor;
    fillLayer.lineCap = kCALineCapRound;
    fillLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:fillLayer];
}

#pragma mark - 数据标记
-(void)markYValuesWithPoints:(NSArray *)points yPoints:(NSArray *)yPoints
{
    //从x = 1开始标记
    for (NSInteger i = 0; i < points.count; i++) {
        //每个数据上的label
        NSValue *pointValue = points[i];
        CGPoint point = [pointValue CGPointValue];
        
        //每个数据上的圆点
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(point.x - 1.5, point.y - 1.5, 3, 3) cornerRadius:1.5];
        CAShapeLayer *roundLayer = [CAShapeLayer layer];
        roundLayer.path = roundPath.CGPath;
        roundLayer.fillColor = [self.lineColor CGColor];
        roundLayer.strokeColor = [self.lineColor CGColor];
        [self.layer addSublayer:roundLayer];
    }
}


@end
