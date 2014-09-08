//
//  KMOViewController.m
//  KMODecisionView
//
//  Created by Kyle O'Brien on 2013.6.30.
//  Copyright (c) 2013 Kyle O'Brien. All rights reserved.
//

#import "KMOViewController.h"

@implementation KMOViewController

#pragma mark - User action

- (IBAction)userTappedFirstExample:(id)sender
{
    NSString *message = NSLocalizedString(@"Hi! This is a decision view. It has a message, but no title.", nil);
    
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:message
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Okay", nil)
                                                           otherButtonTitles:nil];
    
    [decisionView showInViewController:self];
}

- (IBAction)userTappedSecondExample:(id)sender
{
    NSString *message = NSLocalizedString(@"Here's an example with two buttons, displayed side-by-side. The background is dimmed to 75%.", nil);
    
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:message
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                           otherButtonTitles:@[NSLocalizedString(@"OK", nil)]];
    
    [decisionView showInViewController:self andDimBackgroundWithPercent:0.75];
}

- (IBAction)userTappedThirdExample:(id)sender
{
    NSString *message = NSLocalizedString(@"Here's another example with two buttons, but with a bit more text. Button text and color is altered to make it appear destructive.", nil);
    
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:message
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@[@"Yes, Delete"]];
    decisionView.destructiveColor = [UIColor redColor];
    decisionView.destructiveButtonIndex = 1;
    
    [decisionView showInViewController:self];
}

- (IBAction)userTappedFourthExample:(id)sender
{
    NSString *message = @"This last example has three buttons and a custom font (Futura Medium).";
    NSArray *otherButtonTitles = @[NSLocalizedString(@"Option #1", nil), @"Option #2"];
    
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:message
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                                           otherButtonTitles:otherButtonTitles];
    decisionView.fontName = @"Futura-Medium";
    
    [decisionView showInViewController:self];
}

#pragma mark - KMODecisionViewDelegate

- (void)decisionView:(KMODecisionView *)decisionView tappedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"User tapped button %ld", buttonIndex);
}

- (void)willPresentDecisionView:(KMODecisionView *)decisionView
{
    NSLog(@"willPresentDecisionView: called");
}

- (void)didPresentDecisionView:(KMODecisionView *)decisionView
{
     NSLog(@"didPresentDecisionView: called");
}

- (void)decisionView:(KMODecisionView *)decisionView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
     NSLog(@"decisionView:willDismissWithButtonIndex: called");
}

- (void)decisionView:(KMODecisionView *)decisionView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"decisionView:didDismissWithButtonIndex: called");
}

@end
