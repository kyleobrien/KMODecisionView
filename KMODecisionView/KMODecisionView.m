//
//  KMODecisionView.m
//  KMODecisionView
//
//  Created by Kyle O'Brien on 2013.5.23.
//  Copyright (c) 2013 Kyle O'Brien. All rights reserved.
//

#import "KMODecisionView.h"

@import QuartzCore;

@interface KMODecisionView ()

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableArray *otherButtons;

@property (nonatomic, weak) UIViewController *presentingViewController;

- (void)layoutViewInViewController:(UIViewController *)viewController;
- (void)removeAfterTappingButtonIndex:(NSInteger)index withAnimation:(BOOL)animated;

- (UIImage *)backgroundImageForButton:(UIButton *)button withColor:(UIColor *)color;

@end

@implementation KMODecisionView

CGFloat const kKMODecisionViewMessageFontSize = 18.0;
CGFloat const kKMODecisionViewButtonFontSize = 21.0;

@synthesize visible = _visible;

- (instancetype)initWithMessage:(NSString *)message
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
        self.delegate = delegate;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];

        
        // 14.0 is a dummy value, I'm only interested in the name.
        _fontName = [UIFont systemFontOfSize:14.0].fontName;
        _message = message;
        _color = [UIColor blackColor];
        
        _destructiveButtonIndex = -1;
        _destructiveColor = [UIColor redColor];
        
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        
        // We're just estimating the height here. It'll get recomputed during layoutView and set accordingly.
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 264.0) / 2.0,
                                                                      (self.bounds.size.height - 132.0) / 2.0,
                                                                      264.0,
                                                                      132.0)];
        self.containerView.backgroundColor = [UIColor whiteColor];
        self.containerView.layer.shadowOpacity = 0.75;
        self.containerView.layer.shadowRadius = 3.0;
        self.containerView.layer.shadowOffset = CGSizeMake(3.0, 3.0);
        self.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.containerView.opaque = YES;
        
        
        self.messageLabel = [[UILabel alloc] init];
        self.messageLabel.font = [UIFont fontWithName:self.fontName size:kKMODecisionViewMessageFontSize];
        self.messageLabel.textColor = [UIColor blackColor];
        self.messageLabel.textAlignment = NSTextAlignmentCenter;
        self.messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.messageLabel.numberOfLines = 0;
        
        [self.containerView addSubview:self.messageLabel];
        
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cancelButton.titleLabel.font = [UIFont fontWithName:self.fontName size:kKMODecisionViewButtonFontSize];
        self.cancelButton.layer.borderColor = [UIColor blackColor].CGColor;
        self.cancelButton.layer.borderWidth = 2.0;
        
        [self.cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self.cancelButton addTarget:self action:@selector(userTappedCancelButton) forControlEvents:UIControlEventTouchUpInside];
        
        [self.containerView addSubview:self.cancelButton];
        
        
        self.otherButtons = [NSMutableArray arrayWithCapacity:otherButtonTitles.count];
        for (NSString *buttonTitle in otherButtonTitles)
        {
            UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
            otherButton.titleLabel.font = [UIFont fontWithName:self.fontName size:kKMODecisionViewButtonFontSize];
            otherButton.layer.borderColor = [UIColor blackColor].CGColor;
            otherButton.layer.borderWidth = 2.0;
            
            [otherButton setTitle:buttonTitle forState:UIControlStateNormal];
            [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            [otherButton addTarget:self action:@selector(userTappedOtherButton:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.otherButtons addObject:otherButton];
            
            [self.containerView addSubview:otherButton];
        }
        
        [self addSubview:self.containerView];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
    UIButton *otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    otherButton.titleLabel.font = [UIFont fontWithName:self.fontName size:kKMODecisionViewButtonFontSize];
    otherButton.layer.borderColor = [UIColor blackColor].CGColor;
    otherButton.layer.borderWidth = 2.0;
    
    [otherButton setTitle:title forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [otherButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [otherButton addTarget:self action:@selector(userTappedOtherButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.otherButtons addObject:otherButton];
    
    [self.containerView addSubview:otherButton];
    
    // Adding 1 to the index (by not subtracting 1) since 0 is reserved for the cancel button.
    return [self.otherButtons count];
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        return [self.cancelButton titleForState:UIControlStateNormal];
    }
    else
    {
        // Decrement the button index to account for the cancel button.
        buttonIndex -= 1;
        
        if (buttonIndex < [self.otherButtons count])
        {
            UIButton *otherButton = [self.otherButtons objectAtIndex:buttonIndex];
            return [otherButton titleForState:UIControlStateNormal];
        }
        else
        {
            return nil;
        }
    }
}

- (void)showInViewController:(UIViewController *)viewController
{
    [self showInViewController:viewController andDimBackgroundWithPercent:0.25];
}

- (void)showInViewController:(UIViewController *)viewController andDimBackgroundWithPercent:(CGFloat)dimPercent
{
    self.presentingViewController = viewController;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentDecisionView:)])
    {
        [self.delegate willPresentDecisionView:self];
    }
    
    [self layoutViewInViewController:viewController];
    self.containerView.frame = CGRectMake((viewController.view.bounds.size.width - self.containerView.frame.size.width) / 2.0,
                                          self.containerView.frame.origin.y - viewController.view.bounds.size.height,
                                          self.containerView.frame.size.width,
                                          self.containerView.frame.size.height);

    dispatch_async(dispatch_get_main_queue(), ^
    {
        [viewController.view addSubview:self];
        
        _visible = YES;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^
                         {
                             self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:dimPercent];
                             self.containerView.frame = CGRectMake((viewController.view.bounds.size.width - self.containerView.frame.size.width) / 2.0,
                                                                   (viewController.view.bounds.size.height - self.containerView.frame.size.height) / 2.0,
                                                                   self.containerView.frame.size.width,
                                                                   self.containerView.frame.size.height);
                         }
                         completion:^(BOOL finished)
                         {
                             if (finished)
                             {
                                 self.userInteractionEnabled = YES;
                                 
                                 if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentDecisionView:)])
                                 {
                                     [self.delegate didPresentDecisionView:self];
                                 }
                             }
                         }];
    });
}

- (void)dismissWithTappedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:tappedButtonAtIndex:)])
    {
        [self.delegate decisionView:self tappedButtonAtIndex:buttonIndex];
    }
    
    [self removeAfterTappingButtonIndex:buttonIndex withAnimation:animated];
}

#pragma mark - Player action

- (void)userTappedCancelButton
{
    self.userInteractionEnabled = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:tappedButtonAtIndex:)])
    {
        [self.delegate decisionView:self tappedButtonAtIndex:0];
    }
    
    [self removeAfterTappingButtonIndex:0 withAnimation:YES];
}

- (void)userTappedOtherButton:(id)sender
{
    self.userInteractionEnabled = NO;
    
    // Increment by 1 to account for the cancel button.
    NSInteger index = [self.otherButtons indexOfObject:sender] + 1;
    
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
}

- (void)setFontName:(NSString *)fontName
{
    _fontName = [fontName copy];
    
    self.messageLabel.font = [UIFont fontWithName:fontName size:kKMODecisionViewMessageFontSize];
    self.cancelButton.titleLabel.font = [UIFont fontWithName:self.fontName size:kKMODecisionViewButtonFontSize];
    
    for (UIButton *otherButton in self.otherButtons)
    {
        otherButton.titleLabel.font = [UIFont fontWithName:self.fontName size:kKMODecisionViewButtonFontSize];
    }
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    [self updateButtonColors];
}

- (void)setDestructiveButtonIndex:(NSInteger)destructiveButtonIndex
{
    _destructiveButtonIndex = destructiveButtonIndex;
    
    [self updateButtonColors];
}

- (void)setDestructiveColor:(UIColor *)destructiveColor
{
    _destructiveColor = destructiveColor;
    
    [self updateButtonColors];
}

- (NSInteger)numberOfButtons
{
    // Add 1 to account for the cancel button.
    return [self.otherButtons count] + 1;
}

- (BOOL)isVisible
{
    return _visible;
}

#pragma mark - Internal helper methods

- (void)layoutViewInViewController:(UIViewController *)viewController
{
    self.messageLabel.text = self.message;
    
    // Extend the frame (which is the dimmed background) so that we don't see any of the root view controller on rotation.
    CGFloat extension = viewController.view.bounds.size.width - viewController.view.bounds.size.height;
    if (extension < 0)
    {
        extension = -extension;
    }
    
    self.frame = CGRectMake(0.0,
                            0.0,
                            viewController.view.bounds.size.width + extension,
                            viewController.view.bounds.size.height + extension);
    
    // Calculating the height of the message so we can adjust the label to the proper size.
    
    CGSize maxSize = CGSizeMake(self.containerView.bounds.size.width - 20.0, viewController.view.bounds.size.height);
    CGSize actualSize = [self.messageLabel sizeThatFits:maxSize];
    
    self.messageLabel.frame = CGRectMake(10.0,
                                         10.0,
                                         self.containerView.frame.size.width - 20.0,
                                         actualSize.height);
    
    if ([self.otherButtons count] > 0)
    {
        UIButton *firstOtherButton = [self.otherButtons objectAtIndex:0];
        
        CGFloat cancelWidth = [[self.cancelButton titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName: self.cancelButton.titleLabel.font}].width;
        CGFloat otherWidth = [[firstOtherButton titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName: firstOtherButton.titleLabel.font}].width;
        
        if (([self.otherButtons count] == 1) && (cancelWidth <= 100.0) && (otherWidth <= 100.0))
        {
            // Place the two buttons side-by-side.
            self.cancelButton.frame = CGRectMake(10.0,
                                                 self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 10.0,
                                                 117.0,
                                                 44.0);
            
            firstOtherButton.frame = CGRectMake(137.0,
                                                self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 10.0,
                                                117.0,
                                                44.0);
            
            UIImage *firstOtherBackground;
            if (self.destructiveButtonIndex == 1)
            {
                firstOtherBackground = [self backgroundImageForButton:firstOtherButton withColor:self.destructiveColor];
            }
            else
            {
                firstOtherBackground = [self backgroundImageForButton:firstOtherButton withColor:self.color];
            }
    
            [firstOtherButton setBackgroundImage:firstOtherBackground forState:UIControlStateHighlighted];
        }
        else
        {
            // We'll use the N-row, 1-column approach.
            
            double yCoordinateTracker = self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 10.0;
            for (NSInteger i = 0; i < self.otherButtons.count; i++)
            {
                UIButton *otherButton = self.otherButtons[i];
                
                otherButton.frame = CGRectMake(10.0,
                                               yCoordinateTracker,
                                               244.0,
                                               44.0);
                
                UIImage *otherBackground;
                if (self.destructiveButtonIndex == (i + 1))
                {
                    otherBackground = [self backgroundImageForButton:otherButton withColor:self.destructiveColor];
                }
                else
                {
                    otherBackground = [self backgroundImageForButton:otherButton withColor:self.color];
                }

                [otherButton setBackgroundImage:otherBackground forState:UIControlStateHighlighted];
                
                yCoordinateTracker += otherButton.frame.size.height + 10.0;
            }
            
            self.cancelButton.frame = CGRectMake(10.0,
                                                 yCoordinateTracker,
                                                 244.0,
                                            	44.0);
        }
    }
    else
    {
        // There's only a cancel button.
        
        self.cancelButton.frame = CGRectMake(10.0,
                                             self.messageLabel.frame.origin.y + self.messageLabel.frame.size.height + 10.0,
                                             244.0,
                                             44.0);
    }
    
    
    UIColor *backgroundColor;
    if (self.destructiveButtonIndex == 0)
    {
        backgroundColor = self.destructiveColor;
    }
    else
    {
        backgroundColor = self.color;
    }
    
    UIImage *cancelBackground = [self backgroundImageForButton:self.cancelButton withColor:backgroundColor];
    [self.cancelButton setBackgroundImage:cancelBackground forState:UIControlStateHighlighted];
    
    // Now that everything is positioned, make sure the container view is appropriately positioned and sized.
    double newHeight = self.cancelButton.frame.origin.y + self.cancelButton.frame.size.height + 10.0;
    self.containerView.frame = CGRectMake((viewController.view.bounds.size.width - self.containerView.frame.size.width) / 2.0,
                                          (viewController.view.bounds.size.height - newHeight) / 2.0,
                                          self.containerView.frame.size.width,
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
        dispatch_async(dispatch_get_main_queue(), ^
        {
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^
                             {
                                 self.backgroundColor = [UIColor clearColor];
                                 self.containerView.frame = CGRectMake(self.containerView.frame.origin.x,
                                                                       self.containerView.frame.origin.y + self.bounds.size.height,
                                                                       self.containerView.frame.size.width,
                                                                       self.containerView.frame.size.height);
                             }
                             completion:^(BOOL finished)
                             {
                                 if (finished)
                                 {
                                     [self removeFromSuperview];
                                     _visible = NO;
                                     
                                     self.presentingViewController = nil;
                                     
                                     if (self.delegate && [self.delegate respondsToSelector:@selector(decisionView:didDismissWithButtonIndex:)])
                                     {
                                         [self.delegate decisionView:self didDismissWithButtonIndex:index];
                                     }
                                 }
                             }];
        });
    }
    else
    {
        [self removeFromSuperview];
        _visible = NO;
    }
}

- (UIImage *)backgroundImageForButton:(UIButton *)button withColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(button.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPathRef backgroundRect = CGPathCreateWithRect(button.bounds, NULL);
    
	[color set];
    
    CGContextAddPath(context, backgroundRect);
	CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	
    CGPathRelease(backgroundRect);
    
    return image;
}

- (void)updateButtonColors
{
    self.cancelButton.layer.borderColor = self.color.CGColor;
    [self.cancelButton setTitleColor:self.color forState:UIControlStateNormal];
    
    for (NSInteger i = 0; i < self.otherButtons.count; i++)
    {
        UIButton *otherButton = self.otherButtons[i];
        
        if (self.destructiveButtonIndex == (i + 1))
        {
            otherButton.layer.borderColor = self.destructiveColor.CGColor;
            [otherButton setTitleColor:self.destructiveColor forState:UIControlStateNormal];
        }
        else
        {
            otherButton.layer.borderColor = self.color.CGColor;
            [otherButton setTitleColor:self.color forState:UIControlStateNormal];
        }
    }
}

- (void)deviceOrientationChange:(NSNotification *)notification
{
    [self layoutViewInViewController:self.presentingViewController];
}

@end
