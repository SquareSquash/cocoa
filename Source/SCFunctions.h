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
 Squash's exception handler. When hooked, this function becomes the uncaught
 exception handler. Sends the exception to SquashCocoa::recordException:.
 */
void SCHandleException(NSException *exception);

/*!
 Squash's signal handler. When hooked, this function becomes the default signal
 handler. Sends the signal to SquashCocoa::recordSignal:backtraces:.
 */
void SCHandleSignal(int signal);

/*!
 Serializes any `NSObject` subclass into an `NSDictionary` appropriate for
 transmitting to the Squash host. The dictionary includes various serialized
 representations of the object, including `description`, `NSKeyedArchiver`, and
 JSON (if able).
 
 Some objects can already be transmitted to Squash without further serialization
 (for example, `NSString` or `NSNumber`. These objects are returned unmodified
 by this function.
 
 This function can serialize `nil`, but no other primitives.
 
 @param object The object to prepare for transmission.
 @return `object` (if it is a simple JSON-compatible object), or an
 `NSDictionary` describing the object.
 */
id SCValueify(id object);

/*!
 Returns the Mach-O executable UUID, which is equal to the UUID used to identify
 the symbolication data for this build.
 @return The UUID for this build.
 */
NSString *SCExecutableUUID(void);
