//
//  STAppDelegate.h
//  SquashCocoa iOS Tester
//
//  Created by Tim Morgan on 1/23/13.
//  Copyright (c) 2013 Square. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STViewController;

@interface STAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) STViewController *viewController;

@end
