//
//  ViewController.m
//  Example
//
//  Created by Francesco Di Lorenzo on 06/09/12.
//  Copyright (c) 2012 Francesco Di Lorenzo. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController {
    FDStatusBarNotifierView *_notifierView;
}

@synthesize messageField;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setMessageField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)showMessage
{
    NSString *text = self.messageField.text;
    [FDStatusBarNotifierView showMessage:text inWindow:self.view.window duration:3.0 delegate:self];
}

- (IBAction)showMessageNoAutohide:(id)sender {
    NSString *text = self.messageField.text;
    _notifierView = [FDStatusBarNotifierView showMessage:text inWindow:self.view.window duration:0 delegate:self];
}

- (IBAction)hideButtonTapped:(id)sender {
    [_notifierView hide];
}

// **Optional** StatusBarNotifierViewDelegate methods

- (void)willPresentNotifierView:(FDStatusBarNotifierView *)notifierView {
    NSLog(@"willPresentNotifierView");
}

- (void)didPresentNotifierView:(FDStatusBarNotifierView *)notifierView {
    NSLog(@"didPresentNotifierView");
}

- (void)willHideNotifierView:(FDStatusBarNotifierView *)notifierView {
    NSLog(@"willHideNotifierView");
}

- (void)didHideNotifierView:(FDStatusBarNotifierView *)notifierView {
    NSLog(@"didHideNotifierView");
}

- (void)notifierViewTapped:(FDStatusBarNotifierView *)notifierView {
    NSLog(@"notifierViewTapped");
}

@end