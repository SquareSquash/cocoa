Squash Client Library: Cocoa/Objective-C (iOS & Mac OS X)
=========================================================

This client library reports exceptions to Squash, the Squarish exception
reporting and management system.

Documentation
-------------

Comprehensive documentation is written in YARD- and Markdown-formatted comments
throughout the source. To view this documentation as an HTML site, run Doxygen
with `doxygen Doxyfile`. Doxygen and Graphviz must be installed.

For an overview of the various components of Squash, see the website
documentation at https://github.com/SquareSquash/web.

Compatibility
-------------

This library is compatible with projects targeting iOS version 5.0 and above,
or Mac OS X 10.5 and above, and written using Objective-C 2.0 or above.

Requirements
------------

This library uses PLCrashReporter (by Landon Fuller), Apple's Reachability
library, and Peter Hosey's ISO8601DateFormatter library. The latter two are
compiled directly into the library. The former is included as a sub-project and
compiled as part of the build process. For iOS, the libCrashReporter static
library is created alongside the libSquashCocoa static library. For Mac OS X,
the CrashReporter framework is embedded inside the SquashCocoa framework.

Usage
-----

### iOS

Compile the code with the correct scheme and architecture, creating a
`libSquashCocoa iOS.a` library. Add this library to your project, being sure it
is included in your project's Link Binary With Libraries build phase.

### Mac OS X

Compile the code with the correct scheme and architecture, creating a
`SquashCocoa OSX.framework` framework. Add this framework to your project, being
sure that it is included in your project's Link Binary with Libraries build
phase.

### Both Platforms

Add the SquashCocoa.h header file to your project and import it:

```` objective-c
#import "SquashCocoa.h"
````

Add the following code somewhere in your application that gets invoked on
startup, such as your app delegate's
`application:didFinishLaunchingWithOptions:` method:

```` objective-c
[SquashCocoa sharedClient].APIKey = @"YOUR_API_KEY";
[SquashCocoa sharedClient].environment = @"production";
[SquashCocoa sharedClient].host = @"https://your.squash.host";
[SquashCocoa sharedClient].revision = @"GIT_REVISION_OF_RELEASED_PRODUCT";
[[SquashCocoa sharedClient] reportErrors];
[[SquashCocoa sharedClient] hook];
````

The `reportErrors` method loads any errors recorded from previous crashes and
transmits them to Squash. Errors are only removed from this queue when Squash
successfully receives them.

the `hook` method adds the uncaught-exception and default signal handlers that
allow Squash to record new crashes.

Configuration
-------------

You can configure the client using the properties of the
`[SquashCocoa sharedClient]` singleton instance. The following properties are
available:

### General

* `disabled`: If `YES`, the Squash client will not report any errors.
* `APIKey`: The API key of the project that exceptions will be associated with.
  This configuration option is required. The value can be found by going to the
  project's home page on Squash.
* `environment`: The environment that exceptions will be associated with.
* `revision`: The revision of the Git repository that was compiled to make this
  build. This field is required.

### Error Transmission

* `host`: The host on which Squash is running. This field is required.
* `notifyPath`: The path to post new exception notifications to. By default it's
  set to `/api/1.0/notify`.
* `notifyPath`: The path to post new exception notifications to. By default it's
  set to `/api/1.0/notify`.
* `timeout`: The amount of time to wait before giving up on trasmitting an
  error. By default it's 15 seconds.

### Exception Filtering

* `ignoredExceptions`: A set of `NSException` names that will not be reported to
  Squash.
* `handledSignals`: A set of signals (represented as `NSNumber`s) that Squash
  will trap. By default it's `SIGABRT`, `SIGBUS`, `SIGFPE`, `SIGILL`, `SIGSEGV`,
  and `SIGTRAP`.
* `filterUserInfoKeys`: Keys to remove from the `userInfo` dictionary of any
  `NSException`. These keys might contain sensitive or personal information, for
  example.

Error Transmission
------------------

Exceptions are transmitted to Squash using JSON-over-HTTPS. A default API
endpoint is pre-configured, though you can always set your own (see
**Configuration** above).

The Example "Tester" Targets
----------------------------

Both the iOS and OS X sub-projects each have a target that compiles a simple
application from which you can raise a signal or an exception. You can use this
to test your Squash integration, or as a template to integrating Squash into
your own project.

The easiest way to use the "tester" targets is to run the Squash web server
locally on port 3000, and alter the Build configuration variable
`SQUASH_API_KEY` to the API key of a project you create in your local web
server. That should be all you need; both products should begin uploading
deploy notifications, symbolications, and exception notifications. Remember that
exception notifications are not uploaded until the app is re-launched following
a crash.

If you want to use the tester target as a guide to integrating Squash into your
own projects, there are a few things you should be aware of:

* The Precompiled header macro `SQUASH_API_KEY` is defined to be equal to the
  build setting `SQUASH_API_KEY`, wrapped into an `NSString` atom. This allows
  us to use the constant `SQUASH_API_KEY` in the code, which the preprocessor
  will replace with the API key from the build settings.
* There are two build scripts that notify Squash of a new symbolication and a
  new release. These build scripts assume that the developer is using RVM
  (Ruby Version Manager) and has installed the squash_ios_symbolicator gem into
  an RVM gemset. You should run `which symbolicate` and `which squash_release`
  in your build environment to get the correct absolute path to these binaries
  to use in your Squash build scripts.
* The build script that notifies Squash of a new deploy associates the deploy
  with an environment named either "development" or "release" depending on the
  value of the `SKIP_INSTALL` build setting. The default build settings have
  been altered so that `SKIP_INSTALL` is false for debug builds. In practice,
  you probably want to notify Squash of release builds only, so you should
  configure your project to run that script only on release builds, and skip
  development builds entirely.
* The debugger, when used in conjunction with the iOS Simulator, suppresses
  Squash's ability to record exceptions. The debugger has been disabled for the
  iOS tester build scheme.
* Both targets have a build script that grabs the current Git revision of the
  project and writes it to a file in the application bundle. This is how the
  application knows which Git revision to report exceptions under.
* The path "@loader_path/../Frameworks" was added to the application's Runpath
  Search Paths build setting. This allows it to find the embedded SquashCocoa
  framework.

Sub-Licenses
------------

PLCrashReporter by Landon Fuller is distributed under the MIT license. See the
LICENSE file under the project directory for more information.

ISO8601DateFormatter by Peter Hosey is distributed under the MIT license. See
the LICENSE.txt file under the project directory for more information.

Reachability by Apple, Inc. is distributed under Apple's open-source license.
See the Reachability.h file for more information.
