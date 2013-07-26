// Copyright 2013 Square Inc.
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.

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
