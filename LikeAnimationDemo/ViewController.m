//
//  ViewController.m
//  LikeAnimationDemo
//
//  Created by suoxiaoxiao on 2020/10/12.
//

#import "ViewController.h"
#import "AWLike.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    {
        AWLike *slowLike = [AWLike new];
        slowLike.logoImg.image = [UIImage imageNamed:@"unlike"];
        slowLike.frame = CGRectMake(100, 100, 70, 70);
        slowLike.allDuration = 6;
        [slowLike addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike:)]];
        [self.view addSubview:slowLike];
        
        AWLike *smallLike = [AWLike new];
        smallLike.logoImg.image = [UIImage imageNamed:@"unlike"];
        smallLike.frame = CGRectMake(250, 100, 30, 30);
        smallLike.allDuration = 6;
        [smallLike addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike:)]];
        [self.view addSubview:smallLike];
        
        {
            UILabel *label = [UILabel new];
            label.text = @"慢";
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.frame = CGRectMake(0, 100, 100, 30);
            [self.view addSubview:label];
        }
    }
    
    
    AWLike *normalLike = [AWLike new];
    normalLike.logoImg.image = [UIImage imageNamed:@"unlike"];
    normalLike.frame = CGRectMake(100, 200, 70, 70);
    [normalLike addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike:)]];
    [self.view addSubview:normalLike];
    
    {
        AWLike *smallLike = [AWLike new];
        smallLike.logoImg.image = [UIImage imageNamed:@"unlike"];
        smallLike.frame = CGRectMake(250, 200, 30, 30);
        [smallLike addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike:)]];
        [self.view addSubview:smallLike];
    }
    
    {
        UILabel *label = [UILabel new];
        label.text = @"正常";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.frame = CGRectMake(0, 200, 100, 30);
        [self.view addSubview:label];
    }
    
    AWLike *quickLike = [AWLike new];
    quickLike.logoImg.image = [UIImage imageNamed:@"unlike"];
    quickLike.frame = CGRectMake(100, 300, 70, 70);
    quickLike.allDuration = 0.5;
    [quickLike addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike:)]];
    [self.view addSubview:quickLike];
    
    AWLike *smallLike = [AWLike new];
    smallLike.logoImg.image = [UIImage imageNamed:@"unlike"];
    smallLike.frame = CGRectMake(250, 300, 30, 30);
    smallLike.allDuration = 0.5;
    [smallLike addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLike:)]];
    [self.view addSubview:smallLike];
    
    {
        UILabel *label = [UILabel new];
        label.text = @"快";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.frame = CGRectMake(0, 300, 100, 30);
        [self.view addSubview:label];
    }
    // Do any additional setup after loading the view.
}

- (void)tapLike:(UITapGestureRecognizer *)ges {
    UIImage *unsel =  [UIImage imageNamed:@"unlike"];
    UIImage * sel =[UIImage imageNamed:@"like"];
    
    AWLike *likeView = (AWLike *)ges.view;
    
    if ([likeView.logoImg.image isEqual:unsel]) {
        likeView.logoImg.image = sel;
        [likeView selected];
    } else {
        likeView.logoImg.image = unsel;
        [likeView unSelected];
    }
}

@end
