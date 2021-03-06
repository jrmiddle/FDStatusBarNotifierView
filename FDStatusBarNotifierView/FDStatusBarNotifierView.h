//
//  StatusBarNotifierView.h
//  StatusBarNotifier
//
//  Created by Francesco Di Lorenzo on 05/09/12.
//  Copyright (c) 2012 Francesco Di Lorenzo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FDStatusBarNotifierViewDelegate;

extern NSTimeInterval const kTimeOnScreen;

@interface FDStatusBarNotifierView : UIView

@property (strong, nonatomic) NSString *message;
@property (assign, nonatomic) BOOL shouldHideOnTap;
@property (assign, nonatomic, readonly) BOOL manuallyHide; // derived from timeOnScreen; 0 == YES.
@property (assign, nonatomic) NSTimeInterval timeOnScreen; // seconds, default: 2s
@property (readonly, nonatomic) BOOL isHidden;

@property id<FDStatusBarNotifierViewDelegate> delegate;


- (id)initWithMessage:(NSString *)message;
- (id)initWithMessage:(NSString *)message delegate:(id <FDStatusBarNotifierViewDelegate>)delegate;

- (void)showInWindow:(UIWindow *)window;
- (void)hide;

+ (instancetype)showMessage:(NSString *)message
                   inWindow:(UIWindow *)window
                   duration:(NSTimeInterval)duration
                   delegate:(id<FDStatusBarNotifierViewDelegate>)delegate;

+ (instancetype)showMessage:(NSString *)message
                   inWindow:(UIWindow *)window
                   delegate:(id<FDStatusBarNotifierViewDelegate>)delegate;

@end


@protocol FDStatusBarNotifierViewDelegate <NSObject>
@optional

- (void)willPresentNotifierView:(FDStatusBarNotifierView *)notifierView;  // before animation and showing view
- (void)didPresentNotifierView:(FDStatusBarNotifierView *)notifierView;   // after animation
- (void)willHideNotifierView:(FDStatusBarNotifierView *)notifierView;     // before hiding animation
- (void)didHideNotifierView:(FDStatusBarNotifierView *)notifierView;      // after animation

- (void)notifierViewTapped:(FDStatusBarNotifierView *)notifierView; // user tap the status bar message

@end