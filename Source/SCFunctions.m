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

#import "SCFunctions.h"
#import "SquashCocoa.h"
#import <mach-o/ldsyms.h>

static id SCValueifyNested(id object);
static BOOL SCDictionaryKeysAllStrings(NSDictionary *dictionary);
static NSDictionary *SCCreateValueRepresentation(id object);

void SCHandleException(NSException *exception) {
    //[[SquashCocoa sharedClient] unhook];
    [[SquashCocoa sharedClient] recordException:exception];
}

void SCHandleSignal(int signal) {
    //[[SquashCocoa sharedClient] unhook];
    NSArray *addresses = [NSThread callStackReturnAddresses];
    [[SquashCocoa sharedClient] recordSignal:signal addresses:addresses];
    
    raise(signal);
}

id SCValueify(id object) {
    if (object == NULL)
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"objc", @"language",
                @"NULL", @"description",
                NULL];
    // we need to wrap the object in an array because isValidJSONObject: only
    // returns true for valid TOP-LEVEL JSON objects (i.e., hashes and arrays)
    else if (![object isKindOfClass:[NSArray class]] &&
             ![object isKindOfClass:[NSDictionary class]] &&
             [NSJSONSerialization isValidJSONObject:[NSArray arrayWithObject:object]])
        return object;
    else if ([object isKindOfClass:[NSDictionary class]] && SCDictionaryKeysAllStrings(object)) {
        NSMutableDictionary *valueifiedDictionary = [[NSMutableDictionary alloc] initWithCapacity:[object count]];
        for (NSString *key in object) {
            if ([[SquashCocoa sharedClient].filterUserInfoKeys containsObject:key]) continue;
            [valueifiedDictionary setObject:SCValueifyNested([object objectForKey:key]) forKey:key];
        }
        return [valueifiedDictionary autorelease];
    }
    else
        return SCCreateValueRepresentation(object);
}

id SCValueifyNested(id object) {
    if (object == NULL)
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"objc", @"language",
                @"NULL", @"description",
                NULL];
    // we need to wrap the object in an array because isValidJSONObject: only
    // returns true for valid TOP-LEVEL JSON objects (i.e., hashes and arrays)
    else if (![object isKindOfClass:[NSArray class]] &&
             ![object isKindOfClass:[NSDictionary class]] &&
             [NSJSONSerialization isValidJSONObject:[NSArray arrayWithObject:object]])
        return object;
    else
        return SCCreateValueRepresentation(object);
}

BOOL SCDictionaryKeysAllStrings(NSDictionary *dictionary) {
    for (id key in dictionary)
        if ([key isKindOfClass:[NSString class]]) return YES;
    return NO;
}

static NSDictionary *SCCreateValueRepresentation(id object) {
    NSMutableDictionary *representation = [[NSMutableDictionary alloc] initWithCapacity:3];
    [representation setObject:@"objc" forKey:@"language"];
    [representation setObject:[object description] forKey:@"description"];
    if ([object respondsToSelector:@selector(class)])
        [representation setObject:NSStringFromClass([object class]) forKey:@"class_name"];
    else
        [representation setObject:@"(native C type)" forKey:@"class_name"];
        
    if ([object conformsToProtocol:@protocol(NSCoding)]) {
        NSMutableData *encoded = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:encoded];
        [archiver setOutputFormat:NSPropertyListXMLFormat_v1_0];
        [archiver encodeRootObject:object];
        [archiver finishEncoding];
        [archiver release];
        NSString *string = [[NSString alloc] initWithData:encoded encoding:NSUTF8StringEncoding];
        [encoded release];
        [representation setObject:string forKey:@"keyed_archiver"];
        [string release];
    }
    if ([NSJSONSerialization isValidJSONObject:object]) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (data) [representation setObject:string forKey:@"json"];
        [string release];
    }
    return [representation autorelease];
}

// http://stackoverflow.com/questions/10119700/how-to-get-mach-o-uuid-of-a-running-process
NSString *SCExecutableUUID(void) {
    const uint8_t *command = (const uint8_t *)(&_mh_execute_header + 1);
    for (uint32_t idx = 0; idx < _mh_execute_header.ncmds; ++idx) {
        if (((const struct load_command *)command)->cmd == LC_UUID) {
            command += sizeof(struct load_command);
            return [NSString stringWithFormat:@"%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
                    command[0], command[1], command[2], command[3],
                    command[4], command[5],
                    command[6], command[7],
                    command[8], command[9],
                    command[10], command[11], command[12], command[13], command[14], command[15]];
        } else {
            command += ((const struct load_command *)command)->cmdsize;
        }
    }
    return nil;
}
