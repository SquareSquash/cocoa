//
//  STViewController.m
//  SquashCocoa iOS Tester
//
//  Created by Tim Morgan on 1/23/13.
//  Copyright (c) 2013 Square. All rights reserved.
//

#import "STViewController.h"

@interface STViewController ()

@end

@implementation STViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
