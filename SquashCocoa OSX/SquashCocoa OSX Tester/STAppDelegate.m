//
//  STAppDelegate.m
//  SquashCocoa OSX Tester
//
//  Created by Tim Morgan on 1/19/13.
//  Copyright (c) 2013 Square. All rights reserved.
//

#import "STAppDelegate.h"
#import <SquashCocoa OSX/SquashCocoa.h>

@implementation STAppDelegate

- (void)dealloc {
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [SquashCocoa sharedClient].APIKey = SQUASH_API_KEY;
    [SquashCocoa sharedClient].environment = @"development";
    [SquashCocoa sharedClient].host = @"http://localhost:3000";

    NSString *revisionPath = [[NSBundle mainBundle] pathForResource:@"Revision" ofType:nil];
    NSString *revision = [NSString stringWithContentsOfFile:revisionPath encoding:NSASCIIStringEncoding error:nil];
    revision = [revision stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [SquashCocoa sharedClient].revision = revision;

    [[SquashCocoa sharedClient] reportErrors];
    [[SquashCocoa sharedClient] hook];
}

- (IBAction) exception:(id)sender {
    NSDictionary *userInfo = @{
        @"StringKey": @"Hello, world!",
        @"ArrayKey": @[[NSNumber numberWithInt:1], [NSNull null]],
        @"sender": sender
    };
    [[NSException exceptionWithName:@"STBoomException" reason:@"Boom!" userInfo:userInfo] raise];
}

- (IBAction) signal:(id)sender {
    raise(SIGABRT);
}

@end
