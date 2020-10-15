//
//  AWLike.m
//  LikeAnimationDemo
//
//  Created by suoxiaoxiao on 2020/10/12.
//

#import "AWLike.h"

@interface AWLike ()

/// 圆环
@property (nonatomic , strong) CAShapeLayer *circularityLayer;
/// 中间圆形
@property (nonatomic , strong) CAShapeLayer *circleLayer;
/// 承载小圆层
@property (nonatomic , strong) CALayer *innerMaskView;
/// 内圈小圆
@property (nonatomic , strong) NSMutableArray *innerCircleArray;
/// 外圈小圆
@property (nonatomic , strong) NSMutableArray *outerRingArray;

/// 做成可变动画持续时间, 可执行慢动作, 故需要这几个属性来控制
@property (nonatomic , assign, readonly) NSTimeInterval likeScaleSmallDuration;
@property (nonatomic , assign, readonly) NSTimeInterval middleScaleBigDuration;
@property (nonatomic , assign, readonly) NSTimeInterval circulartyScaleMiddleDuration;
@property (nonatomic , assign, readonly) NSTimeInterval circleMoveDuration;
@property (nonatomic , assign, readonly) NSTimeInterval circleOffsetDuration;
@property (nonatomic , assign, readonly) NSTimeInterval circleSizeDuration;

/// 等待上一个动画完成时间
@property (nonatomic , assign) NSTimeInterval waitBeforeAnimationComplate;

@end

@implementation AWLike

- (NSTimeInterval)likeScaleSmallDuration {
    return self.allDuration * 0.10;
}
- (NSTimeInterval)middleScaleBigDuration {
    return self.allDuration * 0.10;
}
- (NSTimeInterval)circulartyScaleMiddleDuration {
    return self.allDuration * 0.03;
}
- (NSTimeInterval)circleMoveDuration {
    return self.allDuration * 0.04;
}
- (NSTimeInterval)circleOffsetDuration {
    return self.allDuration * 0.03;
}
- (NSTimeInterval)circleSizeDuration {
    return self.allDuration * 0.70;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.clipsToBounds = NO;
    _logoImg = [[UIImageView alloc] init];
    _logoImg.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_logoImg];
    
    // 动画层
    self.circularityLayer = [[CAShapeLayer alloc] init];
    self.circleLayer = [[CAShapeLayer alloc] init];
    self.innerMaskView = [[CALayer alloc] init];
    
    self.innerCircleArray = [[NSMutableArray alloc] init];
    self.outerRingArray = [[NSMutableArray alloc] init];
    
    // 默认动画总共时长
    self.allDuration = 1.2f;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.logoImg.frame = self.bounds;
}

- (void)selected {
    [self animation];
}

- (void)animation {
    // step1:缩小原来图片至最小
    self.waitBeforeAnimationComplate = 0.f;
    [self aniamtionStep1Duration:self.likeScaleSmallDuration];
}

/// 图片
/// 动作:缩小图片至消失
- (void)aniamtionStep1Duration:(CGFloat)duration {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = duration;
    animation.repeatCount = 1;
    // 动画结束时不变会原来
    animation.removedOnCompletion = false;
    animation.fillMode = kCAFillModeForwards;
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0];
    animation.toValue = [NSNumber numberWithFloat:0];
    [self.logoImg.layer addAnimation:animation forKey:@"scale"];
    
    self.waitBeforeAnimationComplate += duration;
    [self aniamtionStep2Duration:self.middleScaleBigDuration];
}

/// 添加中间圆形
/// 动作: 圆形由中心点放大至图片的1.2倍
- (void)aniamtionStep2Duration:(CGFloat)duration {
    
    if (self.circleLayer.superlayer) {
        [self.circleLayer removeFromSuperlayer];
    }
    [self.circleLayer removeAllAnimations];
    
    // 设置颜色
    self.circleLayer.fillColor   = [UIColor colorWithRed:0x5B / 255.f
                                                   green:0xBA / 255.f
                                                    blue:0xCE / 255.f alpha:1.0].CGColor;
    [self.layer addSublayer:self.circleLayer];
    
    // path animation.
    CGMutablePathRef startPath      = CGPathCreateMutable();
    CGPathAddEllipseInRect(startPath, nil, CGRectMake(self.frame.size.width * 0.5,
                                                      self.frame.size.height * 0.5,
                                                      0.1,
                                                      0.1));
    CGMutablePathRef endPath      = CGPathCreateMutable();
    CGPathAddEllipseInRect(endPath, nil, CGRectMake(-self.frame.size.width * 0.1,
                                                    -self.frame.size.height * 0.1,
                                                    self.frame.size.width * 1.2,
                                                    self.frame.size.height * 1.2));
    
    CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration            = duration;
    basicAnimation.fromValue           = (__bridge id)startPath;
    basicAnimation.toValue             = (__bridge id)endPath;
    basicAnimation.fillMode            = kCAFillModeBoth;
    basicAnimation.removedOnCompletion = false;
    basicAnimation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    [self.circleLayer addAnimation:basicAnimation forKey:@"path"];
    CGPathRelease(startPath);
    CGPathRelease(endPath);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + self.likeScaleSmallDuration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.circleLayer removeFromSuperlayer];
    });
    
    self.waitBeforeAnimationComplate += duration;
    [self aniamtionStep3Duration:self.circulartyScaleMiddleDuration];

}

/// 显示圆环
/// 动作: 圆环半径往外放大 + 圆线宽度变窄
- (void)aniamtionStep3Duration:(CGFloat)duration {
    
    if (self.circularityLayer.superlayer) [self.circularityLayer removeFromSuperlayer];
    [self.circularityLayer removeAllAnimations];
    ;
    self.circularityLayer.strokeColor = [UIColor colorWithRed:0xE6 / 255.f green:0x85 / 255.f blue:0xbe / 255.0 alpha:1.0].CGColor;
    self.circularityLayer.fillColor   = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.circularityLayer];
    
    CGFloat startScale     = 1.2;
    CGFloat endScale       = 1.9;
    CGFloat startLineWidth = self.frame.size.width * 0.3;
    CGFloat endLineWidth   = self.frame.size.width * 0.15;
    // line width animation
    CAKeyframeAnimation *animation  = [CAKeyframeAnimation animationWithKeyPath:@"lineWidth"];
    animation.values                = @[@(startLineWidth),@(endLineWidth)];
    animation.repeatCount           = 1;
    animation.removedOnCompletion   = false;
    animation.duration              = duration;
    animation.fillMode              = kCAFillModeForwards;
    animation.beginTime             = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    animation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.circularityLayer addAnimation:animation forKey:@"lineWidth"];
    
    // path animation.
    CGMutablePathRef solidPath        = CGPathCreateMutable();
    CGPathAddEllipseInRect(solidPath, nil, CGRectMake(-self.frame.size.width * (startScale - 1) * 0.5,
                                                      -self.frame.size.height * (startScale - 1) * 0.5,
                                                      self.frame.size.width * startScale,
                                                      self.frame.size.height * startScale));
    CGMutablePathRef solidPathani      = CGPathCreateMutable();
    CGPathAddEllipseInRect(solidPathani, nil, CGRectMake(-self.frame.size.width * (endScale - 1) * 0.5,
                                                         -self.frame.size.height * (endScale - 1) * 0.5,
                                                         self.frame.size.width * endScale,
                                                         self.frame.size.height * endScale));
    CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration            = duration;
    basicAnimation.fromValue           = (__bridge id)(solidPath);
    basicAnimation.toValue             = (__bridge id)solidPathani;
    basicAnimation.fillMode            = kCAFillModeForwards;
    basicAnimation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    basicAnimation.removedOnCompletion = false;
    basicAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.circularityLayer addAnimation:basicAnimation forKey:@"path"];
    CGPathRelease(solidPath);
    CGPathRelease(solidPathani);
    
    self.waitBeforeAnimationComplate += duration;
    [self aniamtionStep4Duration:self.circleMoveDuration];
}

/// 绘制14个小圆, 小圆的直径是圆环动画完成之后的线宽, 小圆组成2组(分内环外环)平分放在圆环之上
/// 动作:
///    1: 圆环半径减小线宽距离, 线宽减小致0,
///    2: 小圆往外扩散, 一组扩散一圈距离多另外一组一个小圆半径
- (void)aniamtionStep4Duration:(CGFloat)duration {
    
    if (self.innerMaskView.superlayer) {
        [self.innerMaskView removeFromSuperlayer];
    }
    self.innerMaskView.frame = self.bounds;
    [self.layer addSublayer:self.innerMaskView];
    
    
    CGFloat circleCount      = 7.f;
    CGFloat endScale         = 1.9;
    CGFloat endLineWidth     = self.frame.size.width * 0.15;
    // 圆心
    CGFloat circleCenterX    = self.frame.size.width * 0.5;
    CGFloat circleCenterY    = self.frame.size.height * 0.5;
    // 小圆半径
    CGFloat circleRadius     = endLineWidth * 0.5;
    // 小圆路径在一个圆上,这个圆的半径
    CGFloat circlePathRadius = self.frame.size.height * endScale * 0.5;
    // 每个圆相隔的角度
    CGFloat angle            = 2.f * M_PI * 1.f / circleCount;
    // 第一个小圆的圆心
    CGPoint firstSmallCircleCenter = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
    
    CGMutablePathRef innerPath = CGPathCreateMutable();
    CGPathAddArc(innerPath, NULL, firstSmallCircleCenter.x, firstSmallCircleCenter.y, circleRadius, 0, M_2_PI, true);
    
    for (int i = 0; i < circleCount; i++) {
        CALayer *secondCircleMaskLayer  = [CALayer layer];
        CAShapeLayer *secondCircleLayer = CAShapeLayer.layer;
        secondCircleLayer.fillColor     = [UIColor colorWithRed:0xE6 / 255.f green:0x85 / 255.f blue:0xbe / 255.0 alpha:1.0].CGColor;
        [secondCircleMaskLayer addSublayer:secondCircleLayer];
        secondCircleMaskLayer.frame     = self.bounds;
        // 旋转角度
        secondCircleMaskLayer.transform = CATransform3DMakeRotation(angle * i, 0, 0, 1);
        [self.innerMaskView addSublayer:secondCircleMaskLayer];
        [self.innerCircleArray addObject:secondCircleMaskLayer];
    }
    
    for (int i = 0; i < circleCount; i++) {
        CALayer *secondCircleMaskLayer  = [CALayer layer];
        CAShapeLayer *secondCircleLayer = CAShapeLayer.layer;
        secondCircleLayer.fillColor     = [UIColor colorWithRed:0xE6 / 255.f green:0x85 / 255.f blue:0xbe / 255.0 alpha:1.0].CGColor;
        
        [secondCircleMaskLayer addSublayer:secondCircleLayer];
        secondCircleMaskLayer.frame     = self.bounds;
        // 求出圆直径所对应的角度
        CGFloat offsetAngle             = (circleRadius * 2.3f / (circlePathRadius * 2 * M_PI)) * 360 * ( M_PI / 180.f);
        secondCircleMaskLayer.transform = CATransform3DMakeRotation(angle * i + offsetAngle , 0, 0, 1);
        [self.innerMaskView addSublayer:secondCircleMaskLayer];
        [self.outerRingArray addObject:secondCircleMaskLayer];
    }
    
    // 动画过程: 将圆环线宽变细,并往里缩小小圆半径, 小圆外圈开始往外位移, 大小不变
    
    // line width animation
    CAKeyframeAnimation *animation  = [CAKeyframeAnimation animationWithKeyPath:@"lineWidth"];
    animation.values                = @[@(endLineWidth),@(0)];
    animation.repeatCount           = 1;
    animation.removedOnCompletion   = false;
    animation.duration              = duration;
    animation.fillMode              = kCAFillModeForwards;
    animation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    animation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.circularityLayer addAnimation:animation forKey:@"aniamtionStep4DurationlineWidth"];
    
    
    // path animation.
    CGMutablePathRef startPath      = CGPathCreateMutable();
    CGPathAddEllipseInRect(startPath, nil, CGRectMake(-self.frame.size.width * (endScale - 1) * 0.5,
                                                      -self.frame.size.height * (endScale - 1) * 0.5,
                                                      self.frame.size.width * endScale,
                                                      self.frame.size.height * endScale));
    CGMutablePathRef solidPathani      = CGPathCreateMutable();
    CGPathAddEllipseInRect(solidPathani, nil, CGRectMake(-self.frame.size.width * (endScale - 1) * 0.5 + circleRadius * 0.5,
                                                         -self.frame.size.height * (endScale - 1) * 0.5 + circleRadius * 0.5,
                                                         self.frame.size.width * endScale - circleRadius,
                                                         self.frame.size.height * endScale - circleRadius));
    CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
    basicAnimation.duration            = duration;
    basicAnimation.fromValue           = (__bridge id)(startPath);
    basicAnimation.toValue             = (__bridge id)solidPathani;
    basicAnimation.fillMode            = kCAFillModeForwards;
    basicAnimation.removedOnCompletion = false;
    basicAnimation.beginTime = CACurrentMediaTime() +self.waitBeforeAnimationComplate;
    basicAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.circularityLayer addAnimation:basicAnimation forKey:@"aniamtionStep4Durationpath"];
    CGPathRelease(solidPathani);
    
    
    circlePathRadius = self.frame.size.height * endScale * 0.5 + circleRadius;
    CGPoint outSmallCircleCenter = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
    CGMutablePathRef outPath = CGPathCreateMutable();
    CGPathAddArc(outPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, circleRadius, 0, M_2_PI, true);

    for (CALayer * obj in self.outerRingArray) {
        CGMutablePathRef anioutpath = CGPathCreateMutableCopy(outPath);
        CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
        basicAnimation.duration            = duration;
        basicAnimation.fromValue           = (__bridge id)(innerPath);
        basicAnimation.toValue             = (__bridge id)anioutpath;
        basicAnimation.fillMode            = kCAFillModeForwards;
        basicAnimation.removedOnCompletion = false;
        basicAnimation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
        basicAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep4Durationpath"];
        CGPathRelease(anioutpath);
    }
    for (CALayer * obj in self.innerCircleArray) {
        CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
        basicAnimation.duration            = duration;
        basicAnimation.fromValue           = (__bridge id)(innerPath);
        basicAnimation.toValue             = (__bridge id)innerPath;
        basicAnimation.fillMode            = kCAFillModeForwards;
        basicAnimation.removedOnCompletion = false;
        basicAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
        basicAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep4Durationpath"];
    }
        
    CGPathRelease(outPath);
    CGPathRelease(innerPath);
    
    //  放大中间的心
    CABasicAnimation *logoScaleAnimation   = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    logoScaleAnimation.duration            = duration; // 动画持续时间
    logoScaleAnimation.repeatCount         = 1; // 重复次数
    logoScaleAnimation.removedOnCompletion = false; // 动画结束时不变会原来
    logoScaleAnimation.fillMode            = kCAFillModeForwards;
    logoScaleAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    // 缩放倍数
    logoScaleAnimation.fromValue           = [NSNumber numberWithFloat:0.3]; // 开始时的倍率
    logoScaleAnimation.toValue             = [NSNumber numberWithFloat:1.5]; // 结束时的倍率
    [self.logoImg.layer addAnimation:logoScaleAnimation forKey:@"aniamtionStep4Durationscale"];
    
    self.waitBeforeAnimationComplate += duration;
    [self aniamtionStep5Duration:self.circleOffsetDuration];
}

/// 这一步动画效果:
/// 改变所有小圆的颜色, 内圈与外圈相同位置保持一致
/// 小圆: 内圈往外扩散,变小, 外圈往外扩散, 幅度与内圈一致,大小变小,大小程度比内圈圆的要小, 看着外圈圆大,内圈圆小
/// 中间图片变小
- (void)aniamtionStep5Duration:(CGFloat)duration {
    
    NSArray *colors = @[[UIColor colorWithRed:0xe2/255.f green:0xbb/255.0f blue:0xfa/255.f alpha:1.0],//#E2BBFA
                        [UIColor colorWithRed:0xfa/255.f green:0xeb/255.0f blue:0xd7/255.f alpha:1.0],
                        [UIColor colorWithRed:0x03/255.f green:0xa8/255.0f blue:0x9e/255.f alpha:1.0],
                        [UIColor colorWithRed:0xe6/255.f green:0x85/255.0f blue:0xbe/255.f alpha:1.0],//#E685BE
                        [UIColor colorWithRed:0xb8/255.f green:0xe1/255.0f blue:0xa6/255.f alpha:1.0],//#B8E1A6
                        [UIColor colorWithRed:0xf8/255.f green:0xc1/255.0f blue:0x58/255.f alpha:1.0],//#F8C158
                        [UIColor colorWithRed:0x37/255.f green:0xa0/255.0f blue:0xf2/255.f alpha:1.0]];//#37A0F2
    
    // 改变颜色
    for (int i = 0; i < self.innerCircleArray.count; i++) {
        
        { // 内圈圆添加颜色改变动画
            CALayer *obj = self.innerCircleArray[i];
            CAShapeLayer *objContentLayer = obj.sublayers.firstObject;
            
            CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            basicAnimation.duration            = duration;
            basicAnimation.fromValue           = (__bridge id)objContentLayer.fillColor;
            basicAnimation.toValue             = (__bridge id)[colors[i % colors.count] CGColor];
            basicAnimation.fillMode            = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = false;
            basicAnimation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
            basicAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep5DurationfillColor"];
            
        }
        { // 外圈圆添加颜色改变动画
            CALayer *outObj = self.outerRingArray[i];
            CAShapeLayer *outObjContentLayer = outObj.sublayers.firstObject;

            
            CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"fillColor"];
            basicAnimation.duration            = duration;
            basicAnimation.fromValue           = (__bridge id)outObjContentLayer.fillColor;
            basicAnimation.toValue             = (__bridge id)[colors[i % colors.count] CGColor];
            basicAnimation.fillMode            = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = false;
            basicAnimation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
            basicAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [((CAShapeLayer *)outObj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep5DurationfillColor"];
            
        }
    }

    //  缩小中间的心
    CABasicAnimation *logoScaleAnimation   = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    logoScaleAnimation.duration            = duration; // 动画持续时间
    logoScaleAnimation.repeatCount         = 1; // 重复次数
    logoScaleAnimation.removedOnCompletion = false; // 动画结束时不变会原来
    logoScaleAnimation.fillMode            = kCAFillModeForwards;
    // 缩放倍数
    logoScaleAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    logoScaleAnimation.fromValue           = [NSNumber numberWithFloat:1.5]; // 开始时的倍率
    logoScaleAnimation.toValue             = [NSNumber numberWithFloat:1.2]; // 结束时的倍率
    [self.logoImg.layer addAnimation:logoScaleAnimation forKey:@"aniamtionStep5Durationscale"];

    // 往外扩散
    CGFloat circleCount      = 7.f;
    CGFloat endScale         = 1.9;
    CGFloat endLineWidth     = self.frame.size.width * 0.15;
    // 圆心
    CGFloat circleCenterX    = self.frame.size.width * 0.5;
    CGFloat circleCenterY    = self.frame.size.height * 0.5;
    // 小圆半径
    CGFloat circleRadius     = endLineWidth * 0.5;
    // 小圆路径在一个圆上,这个圆的半径
    CGFloat circlePathRadius = self.frame.size.height * endScale * 0.5;
    // 每个圆相隔的角度
    CGFloat angle            = 2.f * M_PI * 1.f / circleCount;
    {
        // 内圈圆的半径
        CGPoint firstSmallCircleCenter = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
        CGMutablePathRef startPath     = CGPathCreateMutable();
        CGPathAddArc(startPath, NULL, firstSmallCircleCenter.x, firstSmallCircleCenter.y, circleRadius, 0, M_2_PI, true);
        circlePathRadius               = self.frame.size.height * endScale * 0.5 + circleRadius * 1.5;
        CGPoint outSmallCircleCenter   = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
        CGMutablePathRef outPath       = CGPathCreateMutable();
        CGPathAddArc(outPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, circleRadius * 0.7, 0, M_2_PI, true);

        for (CALayer * obj in self.innerCircleArray) {
            CGMutablePathRef anioutpath = CGPathCreateMutableCopy(outPath);
            CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
            basicAnimation.duration            = duration;
            basicAnimation.fromValue           = (__bridge id)(startPath);
            basicAnimation.toValue             = (__bridge id)anioutpath;
            basicAnimation.fillMode            = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = false;
            basicAnimation.beginTime = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
            basicAnimation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep5Durationpath"];
            CGPathRelease(anioutpath);
        }
        CGPathRelease(startPath);
        CGPathRelease(outPath);
    }
    {
        // 外圈圆的半径
        circlePathRadius               = self.frame.size.height * endScale * 0.5 + circleRadius;
        CGPoint firstSmallCircleCenter = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));

        CGMutablePathRef startPath     = CGPathCreateMutable();
        CGPathAddArc(startPath, NULL, firstSmallCircleCenter.x, firstSmallCircleCenter.y, circleRadius, 0, M_2_PI, true);

        circlePathRadius               = self.frame.size.height * endScale * 0.5 + circleRadius * 2.5;
        CGPoint outSmallCircleCenter   = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
        CGMutablePathRef outPath       = CGPathCreateMutable();
        CGPathAddArc(outPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, circleRadius * 0.9, 0, M_2_PI, true);

        for (CALayer * obj in self.outerRingArray) {
            CGMutablePathRef anioutpath        = CGPathCreateMutableCopy(outPath);
            CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
            basicAnimation.duration            = duration;
            basicAnimation.fromValue           = (__bridge id)(startPath);
            basicAnimation.toValue             = (__bridge id)anioutpath;
            basicAnimation.fillMode            = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = false;
            basicAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
            basicAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep5Durationspath"];
            CGPathRelease(anioutpath);
        }
        CGPathRelease(startPath);
        CGPathRelease(outPath);
    }

    self.waitBeforeAnimationComplate += duration;
    [self aniamtionStep6Duration:self.circleSizeDuration];
}

/// 动画:(此处三个动作的时间不一致)
///     1: 中间图片缩放至本身大小
///     2: 小圆内圈大小变小至0, 向外位移
///     3: 小圆外圈变小为0, 向外位移
- (void)aniamtionStep6Duration:(CGFloat)duration {
    
    //  缩小中间的心
    CABasicAnimation *logoScaleAnimation   = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    logoScaleAnimation.duration            = duration * 0.3; // 动画持续时间
    logoScaleAnimation.repeatCount         = 1; // 重复次数
    logoScaleAnimation.removedOnCompletion = false; // 动画结束时不变会原来
    logoScaleAnimation.fillMode            = kCAFillModeForwards;
    logoScaleAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
    // 缩放倍数
    logoScaleAnimation.fromValue           = [NSNumber numberWithFloat:1.2]; // 开始时的倍率
    logoScaleAnimation.toValue             = [NSNumber numberWithFloat:1.0]; // 结束时的倍率
    [self.logoImg.layer addAnimation:logoScaleAnimation forKey:@"aniamtionStep6Durationscale1"];
    
    // 内圈变小
    CGFloat circleCount      = 7.f;
    CGFloat endScale         = 1.9;
    CGFloat endLineWidth     = self.frame.size.width * 0.15;
    // 圆心
    CGFloat circleCenterX    = self.frame.size.width * 0.5;
    CGFloat circleCenterY    = self.frame.size.height * 0.5;
    // 小圆半径
    CGFloat circleRadius     = endLineWidth * 0.5;
    // 小圆路径在一个圆上,这个圆的半径
    CGFloat circlePathRadius = self.frame.size.height * endScale * 0.5;
    // 每个圆相隔的角度
    CGFloat angle            = 2.f * M_PI * 1.f / circleCount;
    {   // 内圈path动画
        CGMutablePathRef startPath   = CGPathCreateMutable();
        circlePathRadius             = self.frame.size.height * endScale * 0.5 + circleRadius * 1.5;
        CGPoint outSmallCircleCenter = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
        // 开始的路径
        CGPathAddArc(startPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, circleRadius * 0.7, 0, M_2_PI, true);
        // 结束的路径
        CGMutablePathRef outPath     = CGPathCreateMutable();
        CGPathAddArc(outPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, 0, 0, M_2_PI, true);

        for (CALayer * obj in self.innerCircleArray) {
            CGMutablePathRef anioutpath        = CGPathCreateMutableCopy(outPath);
            CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
            basicAnimation.duration            = duration * 0.9;
            basicAnimation.fromValue           = (__bridge id)(startPath);
            basicAnimation.toValue             = (__bridge id)anioutpath;
            basicAnimation.fillMode            = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = false;
            basicAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
            basicAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep6Durationpath"];
            CGPathRelease(anioutpath);
        }
        CGPathRelease(startPath);
        CGPathRelease(outPath);
    }
    {   // 外圈path动画
        // 外圈圆的半径
        circlePathRadius = self.frame.size.height * endScale * 0.5 + circleRadius;
        CGMutablePathRef startPath = CGPathCreateMutable();
        circlePathRadius = self.frame.size.height * endScale * 0.5 + circleRadius * 2.5;
        CGPoint outSmallCircleCenter = CGPointMake(circleCenterX - (circlePathRadius * sin(angle * 0.5)), circleCenterY - (circlePathRadius * sin(M_PI_2 - angle * 0.5)));
        // 开始路径
        CGPathAddArc(startPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, circleRadius * 0.9, 0, M_2_PI, true);
        // 结束路径
        CGMutablePathRef outPath = CGPathCreateMutable();
        CGPathAddArc(outPath, NULL, outSmallCircleCenter.x, outSmallCircleCenter.y, 0, 0, M_2_PI, true);

        for (CALayer * obj in self.outerRingArray) {
            CGMutablePathRef anioutpath        = CGPathCreateMutableCopy(outPath);
            CABasicAnimation *basicAnimation   = [CABasicAnimation animationWithKeyPath:@"path"];
            basicAnimation.duration            = duration;
            basicAnimation.fromValue           = (__bridge id)(startPath);
            basicAnimation.toValue             = (__bridge id)anioutpath;
            basicAnimation.fillMode            = kCAFillModeForwards;
            basicAnimation.removedOnCompletion = false;
            basicAnimation.beginTime           = CACurrentMediaTime() + self.waitBeforeAnimationComplate;
            basicAnimation.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
            [((CAShapeLayer *)obj.sublayers.firstObject) addAnimation:basicAnimation forKey:@"aniamtionStep6Durationpath"];
            CGPathRelease(anioutpath);
        }
        CGPathRelease(outPath);
        CGPathRelease(startPath);
    }
}

- (void)unSelected {
    
    //  清空所有图层的动画
    [self.logoImg.layer removeAllAnimations];
    [self.circularityLayer removeAllAnimations];
    [self.circleLayer removeAllAnimations];
    [self.innerMaskView removeAllAnimations];
    
    if (self.circleLayer.superlayer) {
        [self.circleLayer removeFromSuperlayer];
    }
    
    if (self.circularityLayer.superlayer) {
        [self.circularityLayer removeFromSuperlayer];
    }
    
    if (self.innerCircleArray.count) {
        [self.innerCircleArray enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
    }
    
    if (self.outerRingArray.count) {
        [self.outerRingArray enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
    }
    if (self.innerMaskView.superlayer) {
        [self.innerMaskView removeFromSuperlayer];
    }
    // 清空小圆储存数组
    [self.outerRingArray removeAllObjects];
    [self.innerCircleArray removeAllObjects];
    
    
    //  执行取消关注动画
    CAKeyframeAnimation *animation  = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    animation.values                = @[[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.2],[NSNumber numberWithFloat:1.0]];
    animation.repeatCount           = 1;
    animation.removedOnCompletion   = true;
    animation.duration              = 0.5;
    animation.keyTimes              = @[@0,@0.2,@0.5];
    animation.fillMode              = kCAFillModeForwards;
    animation.timingFunction        = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.logoImg.layer addAnimation:animation forKey:@"unselectedAnimation"];
    
}


@end
