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

#import "SquashCocoa.h"
#import "SCOccurrence.h"
#import "SCFunctions.h"
#import "PLCrashReporter.h"
#import "PLCrashReport.h"
#import "Reachability.h"
#if TARGET_OS_MAC && !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
#import <ExceptionHandling/ExceptionHandling.h>
#endif

#pragma mark Constants

static NSString *SCDirectory = @"Squash Occurrences";
static SquashCocoa *sharedClient = NULL;

#pragma mark -

@interface SquashCocoa (Private)

@end

#pragma mark -

@implementation SquashCocoa

@synthesize disabled;
@synthesize APIKey;
@synthesize environment;
@synthesize host;
@synthesize notifyPath;
@synthesize timeout;
@synthesize ignoredExceptions;
@synthesize handledSignals;
@synthesize filterUserInfoKeys;
@synthesize revision;

#pragma mark Singleton

+ (SquashCocoa *) sharedClient {
    if (sharedClient == NULL) sharedClient = [[super allocWithZone:NULL] init];
    return sharedClient;
}

+ (id) allocWithZone:(NSZone *)zone {
    return [[self sharedClient] retain];
}

- (id) copyWithZone:(NSZone *)zone {
    return self;
}

- (id) retain {
    return self;
}

- (NSUInteger) retainCount {
    return NSUIntegerMax;
}

- (oneway void) release {
    // do nothing
}

- (id) autorelease {
    return self;
}

- (id) init {
    if (self = [super init]) {
        disabled = NO;
        notifyPath = @"/api/1.0/notify";
        timeout = 15;
        ignoredExceptions = [[NSMutableSet alloc] init];
        handledSignals = [[NSMutableSet alloc] initWithObjects:
                          [NSNumber numberWithInteger:SIGABRT],
                          [NSNumber numberWithInteger:SIGBUS],
                          [NSNumber numberWithInteger:SIGFPE],
                          [NSNumber numberWithInteger:SIGILL],
                          [NSNumber numberWithInteger:SIGSEGV],
                          [NSNumber numberWithInteger:SIGTRAP],
                          nil];
        filterUserInfoKeys = [[NSMutableSet alloc] init];
        
    }
    return self;
}

#pragma mark Configuration

- (oneway void) hook {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    [[PLCrashReporter sharedReporter] enableCrashReporterWithExceptionHandling:PLExceptionHandlingUncaughtOnly];
#elif TARGET_OS_MAC
    [[PLCrashReporter sharedReporter] enableCrashReporterWithExceptionHandling:PLExceptionHandlingAll];
#endif
}

- (BOOL) isConfigured {
    return (self.host && self.revision && self.APIKey && self.environment);
}

- (NSString *) clientName {
    return @"cocoa";
}

#pragma mark Routes

- (NSURL *) notifyURL {
    NSURL *baseURL = [[NSURL alloc] initWithString:self.host];
    NSURL *URL = [[NSURL alloc] initWithString:self.notifyPath relativeToURL:baseURL];
    [baseURL release];
    return [URL autorelease];
}

#pragma mark Recording

- (oneway void) recordException:(NSException *)exception {
    if (self.disabled) return;
    
    if ([self.ignoredExceptions containsObject:[exception name]]) return;
    SCOccurrence *occurrence = [[SCOccurrence alloc] initWithException:exception];
    [occurrence writeToFile];
    [occurrence release];
}

- (oneway void) recordSignal:(int)signal addresses:(NSArray *)addresses {
    if (self.disabled) return;
    
    SCOccurrence *occurrence = [[SCOccurrence alloc] initWithSignal:signal addresses:addresses];
    [occurrence writeToFile];
    [occurrence release];
}

#pragma mark Reporting

- (NSString *) occurrencesDirectory {
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    NSArray *folders = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
#else
    NSArray *folders = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
#endif
    NSString *path;
    if ([folders count]) path = [folders objectAtIndex:0];
    else path = NSTemporaryDirectory();
#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR
    path = [path stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"]];
#else
    path = [path stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleName"]];
#endif
    path = [path stringByAppendingPathComponent:SCDirectory];
    return path;
}

- (oneway void) reportErrors {
    Reachability *reachability = [Reachability reachabilityWithHostName:[[self notifyURL] host]];
    if ([reachability currentReachabilityStatus] == NotReachable) return;
    
    if ([[PLCrashReporter sharedReporter] hasPendingCrashReports]) {
        NSError *error = nil;
        [[PLCrashReporter sharedReporter] loadPendingCrashReportData:^(NSData *crashData, BOOL *purge) {
            NSError *err = nil;
            PLCrashReport *report = [[[PLCrashReport alloc] initWithData:crashData error:&err] autorelease];
            if (err) {
                NSLog(@"Error while unarchiving pending crash report: %@", err);
                return;
            }

            SCOccurrence *occurrence = [[SCOccurrence alloc] initWithCrashReport:report];
            [occurrence report];
            NSLog(@"Squash reported exception %@", occurrence);
            [occurrence release];
            *purge = YES;
        } andReturnError:&error];
        if (error) {
            NSLog(@"Error while loading pending crash report: %@", error);
            return;
        }
    }
}

@end

#pragma mark -

@implementation SquashCocoa (Private)

#if TARGET_OS_MAC && !TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
- (BOOL) exceptionHandler:(NSExceptionHandler *)sender shouldHandleException:(NSException *)exception mask:(NSUInteger)aMask {
    //TODO
    return YES;
}
#endif

@end
