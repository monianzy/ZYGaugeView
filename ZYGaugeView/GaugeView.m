//
//  GaugeView.m
//  Test
//
//  Created by yi on 16/1/5.
//  Copyright © 2016年 yi. All rights reserved.
//

#import "GaugeView.h"

#define DEGREES_TO_RADIANS(degrees) (degrees+90) / 180.0 * M_PI

#define DEGREES(degrees) (degrees) / 180.0 * M_PI


#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/255.0]
#define CGRGB(r,g,b) RGB(r,g,b).CGColor
#define CGRGBA(r,g,b,a) RGBA(r,g,b,a).CGColor

@interface GaugeView ()
{
    CALayer *rootNeedleLayer;

}



@end

@implementation GaugeView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];

}

- (void)initialize
{
    _value = 4.0;
    _minValue = 0.0;
    _maxValue = 18.0;
    _startAngle = 0.0;
    _endAngle = 270.0;
    _lineWidth = 35;
    _count = 10;
    _startColor = RGB(95,177,237);
    _endColor = [UIColor whiteColor];
}


- (void)setValue:(float)value
{
    _value = value;
    
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    [self drawRangeLabels:context];
}



- (CGFloat)needleAngleForValue:(double)value
{
    return DEGREES_TO_RADIANS(_startAngle + (value - _minValue) / (_maxValue - _minValue) * (_endAngle - _startAngle));
}


- (CGFloat)needleAngleDEGREES:(double)value
{
    return DEGREES(_startAngle + (value - _minValue) / (_maxValue - _minValue) * (_endAngle - _startAngle));
}

- (void)drawRangeLabels:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(0.0, 0.0), 0.0);
  
    //start
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 -_lineWidth/2-30 startAngle:DEGREES_TO_RADIANS(_startAngle - 8)  endAngle:[self needleAngleForValue:self.value]  clockwise:YES];
    UIColor *color = _startColor;
    [color setStroke];
    path.lineWidth = self.lineWidth;
    [path stroke];

    //end
    UIBezierPath *path2 = [UIBezierPath bezierPath];
    [path2 addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 -_lineWidth/2-30 startAngle:[self needleAngleForValue:self.value]  endAngle:DEGREES_TO_RADIANS(_endAngle + 8)  clockwise:YES];
    UIColor *color2 = _endColor;
    [color2 setStroke];
    path2.lineWidth = self.lineWidth;
    [path2 stroke];
    
    
    //外环
    UIBezierPath *path3 = [UIBezierPath bezierPath];
    [path3 addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:self.bounds.size.width/2 - 15 startAngle:DEGREES_TO_RADIANS(_startAngle)  endAngle:DEGREES_TO_RADIANS(_endAngle)  clockwise:YES];
    UIColor *color3 = RGB(201,222,238);
    [color3 setStroke];
    path3.lineWidth = 2;
    [path3 stroke];
    
    
    //内圆
    UIBezierPath *path4 = [UIBezierPath bezierPath];
    [path4 addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:10 startAngle:DEGREES_TO_RADIANS(0)  endAngle:DEGREES_TO_RADIANS(360)  clockwise:YES];
    UIColor *color4 = RGB(201,222,238);
    [color4 setStroke];
    path4.lineWidth = 5;
    [path4 stroke];

    //外圆
    UIBezierPath *path5 = [UIBezierPath bezierPath];
    [path5 addArcWithCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:20 startAngle:DEGREES_TO_RADIANS(0)  endAngle:DEGREES_TO_RADIANS(360)  clockwise:YES];
    UIColor *color5 = RGB(201,222,238);
    [color5 setStroke];
    path5.lineWidth = 1;
    [path5 stroke];
    
    

    [self drawDail:context];
    
    [self drawPointer:context];
    

    
}

/**
 *  画指针
 */
- (void)drawPointer:(CGContextRef)context
{
    CGFloat cenx = CGRectGetMidX(self.bounds);
    CGFloat ceny = CGRectGetMidY(self.bounds);
    [self rotateContext:context fromCenter:CGPointMake(cenx, ceny) withAngle:[self needleAngleDEGREES:_value]];
    //画指针
    CGContextSetStrokeColorWithColor(context, RGB(201,222,238).CGColor);//线条颜色
    CGContextSetLineWidth(context, 2.0);//线条宽度
    CGContextMoveToPoint(context, self.bounds.size.width/2, self.bounds.size.height/2+20); //开始画线, x，y 为开始点的坐标
    CGContextAddLineToPoint(context, self.bounds.size.width/2, self.bounds.size.height/2+50);//画直线, x，y 为线条结束点的坐标
    CGContextStrokePath(context);
}

/**
 *  画刻度
 */
- (void)drawDail:(CGContextRef)context
{
    CGFloat allAngle = 0.0;
    //刻度
    CGFloat cenx = CGRectGetMidX(self.bounds);
    CGFloat ceny = CGRectGetMidY(self.bounds);
    [self rotateContext:context fromCenter:CGPointMake(cenx, ceny) withAngle:DEGREES_TO_RADIANS(_startAngle+90)];
    for(int i = 0; i < (_count+1); i++)
    {
        //画一条线
        CGContextSetStrokeColorWithColor(context, RGB(201,222,238).CGColor);//线条颜色
        CGContextSetLineWidth(context, 2.0);//线条宽度
        CGContextMoveToPoint(context, self.bounds.size.width/2, 16); //开始画线, x，y 为开始点的坐标
        CGContextAddLineToPoint(context, self.bounds.size.width/2, 25);//画直线, x，y 为线条结束点的坐标
        CGContextStrokePath(context);
        
        NSString *valueString = [NSString stringWithFormat:@"%.0f",_minValue+i*((_maxValue-_minValue)/_count)];
        UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
        NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : [UIColor whiteColor] };
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:valueString attributes:stringAttrs];
        CGSize fontWidth = [valueString sizeWithAttributes:stringAttrs];
        [attrStr drawAtPoint:CGPointMake(self.bounds.size.width/2 - fontWidth.width / 2.0,  0)];
        
        [self rotateContext:context fromCenter:CGPointMake(cenx, ceny) withAngle:DEGREES((_endAngle-_startAngle)/_count)];
    }
    
    //旋转了角度，画完刻度需要将坐标旋转回初始状态
    allAngle = DEGREES((_endAngle-_startAngle)/_count)*(_count+1);
    [self rotateContext:context fromCenter:CGPointMake(cenx, ceny) withAngle:-DEGREES_TO_RADIANS(_startAngle+90)];
    [self rotateContext:context fromCenter:CGPointMake(cenx, ceny) withAngle:-allAngle];
}


- (void)rotateContext:(CGContextRef)context fromCenter:(CGPoint)center_ withAngle:(CGFloat)angle
{
    CGContextTranslateCTM(context, center_.x, center_.y);
    CGContextRotateCTM(context, angle);
    CGContextTranslateCTM(context, -center_.x, -center_.y);
}


@end
