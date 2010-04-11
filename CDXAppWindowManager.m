//
//
// CDXAppWindowManager.m
//
//
// Copyright (c) 2009-2010 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CDXAppWindowManager.h"


@implementation CDXAppWindowManager

synthesize_singleton(sharedAppWindowManager, CDXAppWindowManager);

- (id)init {
    if ((self = [super init])) {
        ivar_assign(navigationController, [[UINavigationController alloc] init]);
    }
    return self;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([viewController wantsFullScreenLayout]) {
        [navigationController pushViewController:viewController animated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:animated];
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:window cache:YES];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        }
        
        [navigationController.view removeFromSuperview];
        [window addSubview:viewController.view];
        
        if (animated) {
            [UIView commitAnimations];
        }
    } else {
        [navigationController pushViewController:viewController animated:animated];
    }
}

- (void)popViewControllerAnimated:(BOOL)animated {
    UIViewController *viewController = [navigationController visibleViewController];
    if ([viewController wantsFullScreenLayout]) {
        [navigationController popViewControllerAnimated:NO];
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:animated];
        if (animated) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:window cache:YES];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        }
        
        [viewController.view removeFromSuperview];
        [window addSubview:navigationController.view];
        
        if (animated) {
            [UIView commitAnimations];
        }
    } else {
        [navigationController popViewControllerAnimated:animated];
    }
}

- (void)makeWindowKeyAndVisible {
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
}

@end
