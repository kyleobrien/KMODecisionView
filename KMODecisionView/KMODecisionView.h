//
//  KMODecisionView.h
//  KMODecisionView
//
//  Created by Kyle O'Brien on 2013.5.23.
//  Copyright (c) 2013 Kyle O'Brien. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

@property (weak) id<KMODecisionViewDelegate> delegate;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, readonly) NSInteger numberOfButtons;
@property (assign, readonly, getter = isVisible) BOOL visible;

- (id)initWithMessage:(NSString *)message
           delegate:(id)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;

- (void)show;
- (void)dismissWithTappedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@end
