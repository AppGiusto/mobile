LumberjackPrettyClassInformation
==================================

A CocoaLumberjack log formatter for pretty class information output.

#### Usage:

```obj-c
DDLog addLogger:[DDASLLogger sharedInstance]];
[DDLog addLogger:[DDTTYLogger sharedInstance]];
[DDTTYLogger sharedInstance].logFormatter = [[PrettyClassInformationLogFormatter alloc] init];
[DDASLLogger sharedInstance].logFormatter = [[PrettyClassInformationLogFormatter alloc] init];
```

### Installation with CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries in your projects.

#### Podfile

```ruby
platform :ios, '7.0'
pod "LumberjackPrettyClassInformation", "~> 1.0.0"
```