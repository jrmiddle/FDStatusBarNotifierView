//
//  StatusBarNotifierView.m
//  StatusBarNotifier
//
//  Created by Francesco Di Lorenzo on 05/09/12.
//  Copyright (c) 2012 Francesco Di Lorenzo. All rights reserved.
//

#import "FDStatusBarNotifierView.h"

NSTimeInterval const kTimeOnScreen = 2.0;

@interface FDStatusBarNotifierView ()

@property (strong, nonatomic) UILabel *messageLabel;

@end


@implementation FDStatusBarNotifierView

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        self.frame = [self.class originFrameForOrientation:currentOrientation];
        self.clipsToBounds = YES;
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectInset([self.class destinationFrameForOrientation:currentOrientation], 10, 0)];
        self.shouldHideOnTap = NO;
        self.manuallyHide = NO;
        
        [self setupStyle];
        
        [self addSubview:self.messageLabel];
        self.timeOnScreen = kTimeOnScreen;
    }
    return self;
}

- (void)setupStyle
{
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.messageLabel.font = [UIFont boldSystemFontOfSize:12];
    self.messageLabel.backgroundColor = [UIColor clearColor];
    
    switch ([[UIApplication sharedApplication] statusBarStyle]) {

        case UIStatusBarStyleDefault:
            if ([self.class on7OrLater]) {
                self.messageLabel.textColor = [UIColor blackColor];
                self.backgroundColor = [UIColor clearColor];
            } else {
                self.messageLabel.textColor = [UIColor whiteColor];
                self.backgroundColor = [UIColor blackColor];
            }
            break;
            
        case UIStatusBarStyleBlackTranslucent:
            
            // On 7, essentially lightContent, with an alpha on the background in 6.
            
            if ([self.class on7OrLater]) {
                self.backgroundColor = [UIColor clearColor];
            } else {
                self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            }
            
            self.messageLabel.textColor = [UIColor whiteColor];
            break;
            
        case UIStatusBarStyleBlackOpaque: // fall through
        default:
            // This isn't UIStatusBarStyleDefault; that has its own case.
            // This is UIStatusBarStyleLightContent, which is only available
            // in 7 and above.
            if ([self.class on7OrLater]) {
                self.backgroundColor = [UIColor clearColor];
            } else {
                self.backgroundColor = [UIColor blackColor];
            }
            
            self.messageLabel.textColor = [UIColor whiteColor];
            break;
    }
}

- (id)initWithMessage:(NSString *)message
{
    self = [self initWithMessage:message delegate:nil];
    if (self) {
        
    }
    return self;
    
}

- (id)initWithMessage:(NSString *)message delegate:(id<FDStatusBarNotifierViewDelegate>)delegate
{
    self = [self init];
    if (self) {
        self.delegate           = delegate;
        self.message            = message;
        self.messageLabel.text  = message;
    }
    return self;
}

#pragma mark - Presentation

+ (BOOL)on7OrLater
{
    static BOOL on7OrLater = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        on7OrLater = [[UIApplication sharedApplication] respondsToSelector:@selector(backgroundRefreshStatus)];
    });
    return on7OrLater = YES;
}

+ (CGFloat)widthForOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait) {
        return [UIScreen mainScreen].bounds.size.width;
    }
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGRect)originFrameForOrientation:(UIInterfaceOrientation)orientation
{
    return CGRectMake(0, 20, [self widthForOrientation:orientation], 0);
}

+ (CGRect)destinationFrameForOrientation:(UIInterfaceOrientation)orientation
{
    return CGRectMake(0, 0, [self widthForOrientation:orientation], 20);
    
}

- (void)showInWindow:(UIWindow *)window
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentNotifierView:)]) {
        [self.delegate willPresentNotifierView:self];
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [window addSubview:self];

    CGFloat textWith = [self.message sizeWithFont:self.messageLabel.font
                                constrainedToSize:CGSizeMake(MAXFLOAT, 20)
                                    lineBreakMode:self.messageLabel.lineBreakMode].width;
    
    CGRect animationDestinationFrame = [self.class destinationFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    __block __weak FDStatusBarNotifierView *weakSelf = self;
    
    void (^textScrollAnimationBlock)(NSTimeInterval) = ^(NSTimeInterval duration) {};
    
    if (textWith > self.frame.size.width) {
        textScrollAnimationBlock = ^(NSTimeInterval duration) {
            if (!weakSelf.manuallyHide) {
                [weakSelf performSelector:@selector(doTextScrollAnimation:)
                           withObject:[NSNumber numberWithFloat:duration]
                           afterDelay:weakSelf.timeOnScreen / 3];
            } else {
                [weakSelf performSelector:@selector(doTextScrollAnimation:)
                           withObject:[NSNumber numberWithFloat:duration]
                           afterDelay:kTimeOnScreen / 3];
            }
        };
    }
    
    void (^hideBlock)(NSTimeInterval) = ^(NSTimeInterval delay) {
        if (!weakSelf.manuallyHide) {
            [weakSelf performSelector:@selector(hide)
                           withObject:nil
                           afterDelay:delay];
        }
    };
    
    CGRect messageFrame = self.messageLabel.frame;
    CGFloat exceed = textWith - messageFrame.size.width;
    NSTimeInterval timeExceed = 0;
    
    if (exceed > 0) {
        messageFrame.size.width = textWith;
        self.messageLabel.frame = messageFrame;
        timeExceed = exceed / 60;
    }
    
    [UIView animateWithDuration:.4
                     animations:^{
                         self.frame = animationDestinationFrame;
                     }
                     completion:^(BOOL finished){
                         
                         if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentNotifierView:)]) {
                             [self.delegate didPresentNotifierView:self];
                         }
                         hideBlock(weakSelf.timeOnScreen + timeExceed);
                         textScrollAnimationBlock(timeExceed);
                     }];
}

- (void)hide
{
    if (self.isHidden) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willHideNotifierView:)]) {
        [self.delegate willHideNotifierView:self];
    }
    
    CGRect animationDestinationFrame = [self.class originFrameForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

    [UIView animateWithDuration:.4
                     animations:^{
                         self.frame = animationDestinationFrame;
                         [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                                 withAnimation:UIStatusBarAnimationSlide];
                     } completion:^(BOOL finished){
                         if (finished) {
                             
                             if (self.delegate && [self.delegate respondsToSelector:@selector(didHideNotifierView:)]) {
                                 [self.delegate didHideNotifierView:self];
                             }
                             
                             [self removeFromSuperview];
                         }
                     }];
}

- (BOOL)isHidden
{
    return (self.superview == nil);
}

- (void)doTextScrollAnimation:(NSNumber*)timeInterval
{
    if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
        __block CGRect frame = self.messageLabel.frame;
        [UIView transitionWithView:self.messageLabel
                          duration:timeInterval.floatValue
                           options:UIViewAnimationCurveLinear
                        animations:^{
                            frame.origin.x = [UIScreen mainScreen].bounds.size.width - frame.size.width - frame.origin.x;
                            self.messageLabel.frame = frame;
                        } completion:nil];
    } else {
        // add support for landscape
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.shouldHideOnTap == YES) {
        [self hide];
    }
    [self.delegate notifierViewTapped:self];
}

#pragma mark - Accessor

- (void)setMessage:(NSString *)message
{
    _message = message;
    self.messageLabel.text = message;
}

@end
