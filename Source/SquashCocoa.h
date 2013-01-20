// Copyright 2012 Square Inc.
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

/*!
 Singleton class managing the interface to Squash. This class is used to
 configure exception reporting, hook the exception handlers, and report and
 record exceptions.
 
 This class must first be configured by setting its properties. At a minimum,
 the SquashCocoa::APIKey, SquashCocoa::host, SquashCocoa::revision, and
 SquashCocoa::environment properties must be set. Once configured, the
 exception handlers can be set using the SquashCocoa::hook method.
 
 When an `NSException` is caught or a signal is trapped, information about the
 occurrence is recorded to a file and the application terminates. The next time
 the application is launched, any pending occurrence data is transmitted to
 Squash if the host is available. Occurrences are not removed from this file
 queue until Squash successfully receives them.
 */
@interface SquashCocoa : NSObject {
    BOOL disabled;
    NSString *APIKey;
    NSString *environment;
    NSString *host;
    NSString *notifyPath;
    NSUInteger timeout;
    NSMutableSet *ignoredExceptions;
    NSMutableSet *handledSignals;
    NSMutableSet *filterUserInfoKeys;
    NSString *revision;
}

#pragma mark Properties

/*!
 If `YES`, Squash will not record any new exceptions or signals. Squash will
 still report any pending occurrences if SquashCocoa::reportErrors is called,
 however.
 */
@property (assign) BOOL disabled;

/*!
 The API key of your project. This property must be set before Squash can be
 used.
 */
@property (retain) NSString *APIKey;

/*!
 The environment your build is running under. This has no intrinsic meaning, but
 is typically used to distinguish between, e.g., beta builds and release builds.
 (Note that Squash records the version and build number of your app for each
 exception; this provides a more high-level way of separating exceptions into
 groups). This property must be set before Squash can be used.
 */
@property (retain) NSString *environment;

/*!
 The URL of the Squash host (minus any path), e.g., "https://my.squash.host".
 This property must be set before Squash can be used.
 */
@property (retain) NSString *host;

/*!
 The path to the API notify action, with leading slash. By default it's set to
 the usual API path, `/api/1.0/notify`.
 */
@property (retain) NSString *notifyPath;

/*!
 The maximum amount of time to wait when reporting occurrences to Squash. By
 default it's 15 seconds.
 */
@property (assign) NSUInteger timeout;

/*!
 A set of `NSException` names that will not be reported to Squash.
 */
@property (readonly) NSMutableSet *ignoredExceptions;

/*!
 A set of signals (represented as `NSNumber`s) that will be trapped by Squash.
 */
@property (readonly) NSMutableSet *handledSignals;

/*!
 A set of `NSDictionary` keys that will be removed from an `NSException`'s
 `userInfo` before being transmitted to Squash.
 */
@property (readonly) NSMutableSet *filterUserInfoKeys;

/*!
 The full SHA1 identification of the Git revision of the project repository at
 the time of the current build.
 */
@property (retain) NSString *revision;


#pragma mark Singleton

/*!
 Returns the singleton instance.
 @return The singleton instance.
 */

+ (SquashCocoa *) sharedClient;

#pragma mark Configuration

/*!
 Installs the Squash uncaught-exception handler and default signal handler. This
 method should be called when your application launches, after Squash is
 configured.
 */
- (oneway void) hook;

/*!
 Returns whether all required properties have been set.
 @return If Squash is ready to record and report exceptions.
 */
- (BOOL) isConfigured;

/*!
 Returns the client name reported back to Squash.
 @return The string "ios".
 */
- (NSString *) clientName;

#pragma mark Routes

/*!
 Returns the SquashCocoa::host and SquashCocoa::notifyPath combined into an
 `NSURL`.
 @return The URL to `POST` to to record exceptions.
 */
- (NSURL *) notifyURL;

#pragma mark Recording

/*!
 Records an `NSException` to the file queue for later transmission to Squash.
 @param exception The exception that occurred.
 */
- (oneway void) recordException:(NSException *)exception;

/*!
 Records a signal to the file queue for later transmission to Squash.
 @param signal The signal that was trapped.
 @param addresses The call stack at the time of the trap (array of `NSNumber`s).
 */
- (oneway void) recordSignal:(int)signal addresses:(NSArray *)addresses;

#pragma mark Reporting

/*!
 Returns the directory where occurrences are serialized to for later
 transmission to Squash.
 @return The directory storing pending occurrences.
 */
- (NSString *) occurrencesDirectory;

/*!
 Loads all occurrences in SquashCocoa::occurrencesDirectory and transmits them,
 one at a time, to the Squash API host.
 */
- (oneway void) reportErrors;

@end
