//
//  KMODecisionView.m
//  KMODecisionView
//
//  Created by Kyle O'Brien on 2013.5.23.
//  Copyright (c) 2013 Kyle O'Brien. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "KMODecisionView.h"

@interface KMODecisionView ()
{
    UIView *containerView;

    UILabel *messageLabel;
    UIButton *cancelButton;
    NSMutableArray *otherButtons;
}

- (void)layoutView;
- (void)removeAfterTappingButtonIndex:(NSInteger)index withAnimation:(BOOL)animated;

- (UIImage *)backgroundImageForButton:(UIButton *)button withColor:(UIColor *)color;

@end


@implementation KMODecisionView

@synthesize visible = _visible;

- (id)initWithMessage:(NSString *)message
             delegate:(id)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSArray *)otherButtonTitles
{
    self = [super initWithFrame:CGRectMake(0.0,
                                           0.0,
                                           [UIScreen mainScreen].bounds.size.width,
                                           [UIScreen mainScreen].bounds.size.height)];
    if (self)
    {
        _delegate = delegate;
        _message = message;
        
        
        self.backgroundColor = [UIColor clearColor];
        
        
        // We're just estimating the height here. It'll get recomputed during layoutView and set accordingly.
        containerView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 264.0) / 2.0,
                                                                 (self.bounds.size.height - 132.0) / 2.0,
                                                                 264.0,
                                                                 132.0)];
        containerView.backgroundColor = [UIColor whiteColor];
        containerView.layer.cornerRadius = 7.0;
        containerView.layer.borderColor = [UIColor blackColor].CGColor;
        containerView.layer.borderWidth = 0.0;
        containerView.layer.shadowOpacity = 0.25;
        containerView.layer.shadowRadius = 3.0;
        containerView.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        
        
        messageLabel = [[UILabel alloc] init];
        messageLabel.font = [UIFont fontWithName:@"Avenir" size:18.0];
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        messageLabel.numberOfLines = 0;
        
        [containerView addSubview:messageLabel];
        
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:21.0];
        cancelButton.layer.cornerRadius = 14.0;
        cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
        cancelButton.layer.borderWidth = 2.0;
        
        [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [cancelButton addTarget:self action:@selector(userTappedCancelButton) forControlEvents:UIControlEventTouchUpInside];
        
        [containerView addSubview:cancelButton];
        
        
        otherButtons = [NSMutableArray arrayWithCapacity:0];
        for (NSString *buttonTitle in otherButtonTitles)
        {
            UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            otherButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:21.0];
            otherButton.layer.cornerRadius = 14.0;
            otherButton.layer.borderColor = [UIColor blackColor].CGColor;
            otherButton.layer.borderWidth = 2.0;
            
            [otherButton setTitle:buttonTitle forState:UIControlStateNormal];
            [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [otherButton addTarget:self action:@selector(userTappedOtherButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [otherButtons addObject:otherButton];
            
            [containerView addSubview:otherButton];
        }
        
        
        [self addSubview:containerView];
        [self layoutView];
    }
    
    return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.titleLabel.font = [UIFont fontWithName:@"Avenir" size:21.0];
    otherButton.layer.cornerRadius = 14.0;
    otherButton.layer.borderColor = [UIColor blackColor].CGColor;
    otherButton.layer.borderWidth = 2.0;
    
    [otherButton setTitle:title forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [otherButton addTarget:self action:@selector(userTappedOtherButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [otherButtons addObject:otherButton];
    
    [containerView addSubview:otherButton];
    [self layoutView];
    
    // Adding 1 to the index (by not subtracting 1) since 0 is reserved for the cancel button.
    return [otherButtons count];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return [cancelButton titleForState:UIControlStateNormal];
    }
    else
    {
        // Decrement the button index to account for the cancel button.
        buttonIndex -= 1;
        
        if (buttonIndex < [otherButtons count])
        {
            UIButton *otherButton = [otherButtons objectAtIndex:buttonIndex];
            return [otherButton titleForState:UIControlStateNormal];
        }
        else
        {
            return nil;
        }
    }
}

- (void)show
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentDecisionView:)])
    {
        [self.delegate willPresentDecisionView:self];
    }
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    containerView.frame = CGRectMake(containerView.frame.origin.x,
                                     containerView.frame.origin.y - self.bounds.size.height,
                                     containerView.frame.size.width,
                                     containerView.frame.size.height);
    
    [rootViewController.view addSubview:self];
    _visible = YES;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^
                     {
                         self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25];
                         containerView.frame = CGRectMake((self.bounds.size.width - containerView.frame.size.width) / 2.0,
                                                          (self.bounds.size.height - containerView.frame.size.height) / 2.0,
                                                          containerView.frame.size.width,
                                                          containerView.frame.size.height);
                     }
                     completion:^(BOOL finished)
                     {
                         if (finished)
                         {
                             if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentDecisionView:)])
                             {
                                 [self.delegate didPresentDecisionView:self];
                             }
                         }
                     }];
}

- (void)dismissWithTappedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:tappedButtonAtIndex:)])
    {
        [self.delegate decisionView:self tappedButtonAtIndex:buttonIndex];
    }
    
    [self removeAfterTappingButtonIndex:buttonIndex withAnimation:animated];
}

#pragma mark - User action

- (void)userTappedCancelButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:tappedButtonAtIndex:)])
    {
        [self.delegate decisionView:self tappedButtonAtIndex:0];
    }
    
    [self removeAfterTappingButtonIndex:0 withAnimation:YES];
}

- (void)userTappedOtherButton:(id)sender
{
    // Increment by 1 to account for the cancel button.
    int index = [otherButtons indexOfObject:sender] + 1;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:tappedButtonAtIndex:)])
    {
        [self.delegate decisionView:self tappedButtonAtIndex:index];
    }
    
    [self removeAfterTappingButtonIndex:index withAnimation:YES];
}

#pragma mark - Properties

- (void)setMessage:(NSString *)message
{
    _message = message;
    [self layoutView];
}

- (NSInteger)numberOfButtons
{
    // Add one to account for the cancel button.
    
    return [otherButtons count] + 1;
}

- (BOOL)isVisible
{
    return _visible;
}

#pragma mark - Internal helper methods

- (void)layoutView
{
    messageLabel.text = self.message;
    
    // Calculating the height of the message so we can adjust the label to the proper size.
    CGSize messageSize = [messageLabel.text sizeWithFont:messageLabel.font
                                       constrainedToSize:CGSizeMake(containerView.bounds.size.width - 20.0, [UIScreen mainScreen].bounds.size.height)
                                           lineBreakMode:NSLineBreakByWordWrapping];
    
    messageLabel.frame = CGRectMake(10.0,
                                    10.0,
                                    containerView.frame.size.width - 20.0,
                                    messageSize.height);
    
    NSLog(@"T: %@", messageLabel.text);
    NSLog(@"H: %f", messageSize.height);
    
    
    if ([otherButtons count] > 0)
    {
        UIButton *firstOtherButton = [otherButtons objectAtIndex:0];
        double cancelWidth = [[cancelButton titleForState:UIControlStateNormal] sizeWithFont:cancelButton.titleLabel.font].width;
        double otherWidth = [[firstOtherButton titleForState:UIControlStateNormal] sizeWithFont:firstOtherButton.titleLabel.font].width;
        
        if (([otherButtons count] == 1) && (cancelWidth <= 100.0) && (otherWidth <= 100.0))
        {
            // Place the two buttons side-by-side.
            
            cancelButton.frame = CGRectMake(10.0,
                                            messageLabel.frame.origin.y + messageLabel.frame.size.height + 10.0,
                                            117.0,
                                            44.0);
            
            firstOtherButton.frame = CGRectMake(137.0,
                                                messageLabel.frame.origin.y + messageLabel.frame.size.height + 10.0,
                                                117.0,
                                                44.0);
            
            UIImage *firstOtherBackground = [self backgroundImageForButton:firstOtherButton withColor:[UIColor blackColor]];
            [firstOtherButton setBackgroundImage:firstOtherBackground forState:UIControlStateHighlighted];
        }
        else
        {
            // We'll use the N-row, 1-column approach.
            
            double yCoordinateTracker = messageLabel.frame.origin.y + messageLabel.frame.size.height + 10.0;
            for (UIButton *otherButton in otherButtons)
            {
                otherButton.frame = CGRectMake(10.0,
                                               yCoordinateTracker,
                                               244.0,
                                               44.0);
                
                UIImage *otherBackground = [self backgroundImageForButton:otherButton withColor:[UIColor blackColor]];
                [otherButton setBackgroundImage:otherBackground forState:UIControlStateHighlighted];
                
                yCoordinateTracker += otherButton.frame.size.height + 10.0;
            }
            
            cancelButton.frame = CGRectMake(10.0,
                                            yCoordinateTracker,
                                            244.0,
                                            44.0);
        }
    }
    else
    {
        // There's only a cancel button.
        
        cancelButton.frame = CGRectMake(10.0,
                                        messageLabel.frame.origin.y + messageLabel.frame.size.height + 10.0,
                                        244.0,
                                        44.0);
    }
    
    
    UIImage *cancelBackground = [self backgroundImageForButton:cancelButton withColor:[UIColor blackColor]];
    [cancelButton setBackgroundImage:cancelBackground forState:UIControlStateHighlighted];
    
    // Now that everything is positioned, make sure the container view is appropriately positioned and sized.
    double newHeight = cancelButton.frame.origin.y + cancelButton.frame.size.height + 10.0;
    containerView.frame = CGRectMake(containerView.frame.origin.x,
                                     (self.bounds.size.height - newHeight) / 2.0,
                                     containerView.frame.size.width,
                                     newHeight);
}

- (void)removeAfterTappingButtonIndex:(NSInteger)index withAnimation:(BOOL)animated;
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:willDismissWithButtonIndex:)])
    {
        [self.delegate decisionView:self willDismissWithButtonIndex:index];
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^
                         {
                             self.backgroundColor = [UIColor clearColor];
                             containerView.frame = CGRectMake(containerView.frame.origin.x,
                                                              containerView.frame.origin.y + self.bounds.size.height,
                                                              containerView.frame.size.width,
                                                              containerView.frame.size.height);
                         }
                         completion:^(BOOL finished)
                         {
                             if (finished)
                             {
                                 [self removeFromSuperview];
                                 _visible = NO;
                                 
                                 if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:didDismissWithButtonIndex:)])
                                 {
                                     [self.delegate decisionView:self didDismissWithButtonIndex:index];
                                 }
                             }
                         }];
    }
    else
    {
        [self removeFromSuperview];
        _visible = NO;
    }
}

- (UIImage *)backgroundImageForButton:(UIButton *)button withColor:(UIColor *)color
{
    // Modified version of example code:
    // http://www.cocoanetics.com/2010/02/drawing-rounded-rectangles/
    
    UIGraphicsBeginImageContextWithOptions(button.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGRect outerRect = button.bounds;
    outerRect = CGRectMake(outerRect.origin.x + 4.0,
                           outerRect.origin.y + 4.0,
                           outerRect.size.width - 8.0,
                           outerRect.size.height - 8.0);
	double radius = 11.0;
    CGRect innerRect = CGRectInset(outerRect, radius, radius);
    
    CGMutablePathRef roundedRectPath = CGPathCreateMutable();
    
	CGFloat insideRight = innerRect.origin.x + innerRect.size.width;
	CGFloat outsideRight = outerRect.origin.x + outerRect.size.width;
	CGFloat insideBottom = innerRect.origin.y + innerRect.size.height;
	CGFloat outsideBottom = outerRect.origin.y + outerRect.size.height;
	CGFloat insideTop = innerRect.origin.y;
	CGFloat outsideTop = outerRect.origin.y;
    CGFloat insideLeft = innerRect.origin.x;
	CGFloat outsideLeft = outerRect.origin.x;
    
	CGPathMoveToPoint(roundedRectPath, NULL, insideLeft, outsideTop);
	CGPathAddLineToPoint(roundedRectPath, NULL, insideRight, outsideTop);
	CGPathAddArcToPoint(roundedRectPath, NULL, outsideRight, outsideTop, outsideRight, insideTop, radius);
	CGPathAddLineToPoint(roundedRectPath, NULL, outsideRight, insideBottom);
	CGPathAddArcToPoint(roundedRectPath, NULL,  outsideRight, outsideBottom, insideRight, outsideBottom, radius);
	CGPathAddLineToPoint(roundedRectPath, NULL, insideLeft, outsideBottom);
	CGPathAddArcToPoint(roundedRectPath, NULL,  outsideLeft, outsideBottom, outsideLeft, insideBottom, radius);
	CGPathAddLineToPoint(roundedRectPath, NULL, outsideLeft, insideTop);
	CGPathAddArcToPoint(roundedRectPath, NULL,  outsideLeft, outsideTop, insideLeft, outsideTop, radius);
    
	CGPathCloseSubpath(roundedRectPath);
    
	[color set];
    
	CGContextAddPath(context, roundedRectPath);
	CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	CGPathRelease(roundedRectPath);
    
    return image;
}

@end
