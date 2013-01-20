//
//  STAppDelegate.h
//  SquashCocoa OSX Tester
//
//  Created by Tim Morgan on 1/19/13.
//  Copyright (c) 2013 Square. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

- (IBAction) exception:(id)sender;
- (IBAction) signal:(id)sender;

@end
