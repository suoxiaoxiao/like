//
//  AWLike.h
//  LikeAnimationDemo
//
//  Created by suoxiaoxiao on 2020/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AWLike : UIView

@property (nonatomic , strong) UIImageView *logoImg;

/// 所有动作执行的时间, default is 1.2 S
@property (nonatomic , assign) NSTimeInterval allDuration;

- (void)selected;
- (void)unSelected;

@end

NS_ASSUME_NONNULL_END
