//
//  KMODecisionView.h
//  KMODecisionView
//
//  Created by Kyle O'Brien on 2013.5.23.
//  Copyright (c) 2013 Kyle O'Brien. All rights reserved.
//

@import Foundation;
@import UIKit;

@class KMODecisionView;

@protocol KMODecisionViewDelegate <NSObject>

@required

- (void)decisionView:(KMODecisionView *)decisionView tappedButtonAtIndex:(NSInteger)buttonIndex;

@optional

- (void)willPresentDecisionView:(KMODecisionView *)decisionView;
- (void)didPresentDecisionView:(KMODecisionView *)decisionView;
- (void)decisionView:(KMODecisionView *)decisionView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)decisionView:(KMODecisionView *)decisionView didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end

@interface KMODecisionView : UIView

FOUNDATION_EXPORT CGFloat const kKMODecisionViewMessageFontSize;
FOUNDATION_EXPORT CGFloat const kKMODecisionViewButtonFontSize;

@property (nonatomic, weak) id<KMODecisionViewDelegate> delegate;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *fontName;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) NSInteger destructiveButtonIndex;
@property (nonatomic, strong) UIColor *destructiveColor;

@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (nonatomic, assign, readonly, getter = isVisible) BOOL visible;

- (instancetype)initWithMessage:(NSString *)message
                       delegate:(id)delegate
              cancelButtonTitle:(NSString *)cancelButtonTitle
    	otherButtonTitles:(NSArray *)otherButtonTitles;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (void)showInViewController:(UIViewController *)viewController;
- (void)showInViewController:(UIViewController *)viewController andDimBackgroundWithPercent:(CGFloat)dimPercent;
- (void)dismissWithTappedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end
