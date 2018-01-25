//
//  ViewController.m
//  BezierPathDemo
//
//  Created by zry on 2017/7/7.
//  Copyright © 2017年 zry. All rights reserved.
//

#import "ViewController.h"
#import "ZZBezierLineView.h"
#import "UIView+Addition.h"

@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *hours;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *today = [NSDate date];
    NSUInteger unitFlags = NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitWeekday;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:today];
    NSInteger hour =  [dateComponent hour];

    //显示hour个数据
    NSArray *yArray = @[@50,@176.2,@509.8,@374.9,@408,@290,@345,@405,@12,@297,@90,@389,@234,@158,@37,@89,@332,@490,@100,@190,@38,@0,@129,@87];
    
    NSMutableArray *yPoints = [NSMutableArray arrayWithCapacity:yArray.count];
    ZZBezierLineView *lineView = [[ZZBezierLineView alloc] initWithFrame:CGRectMake(10, 240, self.view.width - 20, ChartHeight)];
    yPoints = [[yArray subarrayWithRange:NSMakeRange(0, hour + 1)] mutableCopy];
    [lineView addLineWithXPoints:self.hours yPoints:yPoints];
    [self.view addSubview:lineView];
}


#pragma mark - x轴数组（不包含0）
-(NSMutableArray *)hours
{
    if (!_hours) {
        _hours = [NSMutableArray arrayWithCapacity:24];
        for (NSInteger i = 0; i <= 24; i++) {
            [_hours addObject:@(i)];
        }
    }
    return _hours;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
