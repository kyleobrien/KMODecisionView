//
//  KMOViewController.m
//  KMODecisionView
//
//  Created by Kyle O'Brien on 2013.6.30.
//  Copyright (c) 2013 Kyle O'Brien. All rights reserved.
//

#import "KMOViewController.h"

@interface KMOViewController ()

@end

@implementation KMOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - User action

- (IBAction)userTappedFirstExample:(id)sender
{
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:@"Hi! This is a decision view. It has a message, but no title."
                                                                    delegate:self
                                                           cancelButtonTitle:@"Okay"
                                                           otherButtonTitles:nil];
    [decisionView show];
}

- (IBAction)userTappedSecondExample:(id)sender
{
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:@"Here's an example with two buttons, displayed side-by-side."
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@[@"Ok"]];
    [decisionView show];
}

- (IBAction)userTappedThirdExample:(id)sender
{
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:@"Here's another example with two buttons, but with a bit more text."
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel, take two"
                                                           otherButtonTitles:@[@"A bit more text"]];
    [decisionView show];
}

- (IBAction)userTappedFourthExample:(id)sender
{
    KMODecisionView *decisionView = [[KMODecisionView alloc] initWithMessage:@"This last example has three buttons."
                                                                    delegate:self
                                                           cancelButtonTitle:@"Cancel"
                                                           otherButtonTitles:@[@"Option #1", @"Option #2"]];
    [decisionView show];
}

#pragma mark - KMODecisionViewDelegate

- (void)decisionView:(KMODecisionView *)decisionView tappedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"User tapped button %d", buttonIndex);
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
