//
//  GIAppDelegate.m
//  Giusto
//
//  Created by Vincil Bishop on 8/21/14.
//  Copyright (c) 2014 CabForward. All rights reserved.
//

#import "GIAppDelegate.h"
#import "GIAppearanceBD.h"
#import "Helpshift.h"
/*#import <Appsee/Appsee.h>*/
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Heap.h"
#import <UbertestersSDK/Ubertesters.h>
#import <Intercom/Intercom.h>

@interface GIAppDelegate ()

@end

@implementation GIAppDelegate

#pragma mark - Class Methods

+ (GIAppDelegate *)sharedDelegate
{
    return (GIAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)setupApplication
{
    
    // Custom logging
    //[DDLog setupMyDefaultLogging];
    
    // Data model
    [GIModel setupModel];
    
    [GIAppearanceBD setAppearanceProxies];
    
    // Attempt to log in the current user
    [[GIUserStore sharedStore] loginWithDefaultCredentialsAndError:nil];
    
    
#pragma message "TODO: We need to determine if the user is already logged in, and set the root view controller accordingingly."
    
}


#pragma mark - UIApplicationDelegate Methods

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
//    [Fabric with:@[CrashlyticsKit]]; // Old
    [Fabric with:@[[Crashlytics class]]];
    
    [Parse setApplicationId:kParse_AppID clientKey:kParse_ClientKey];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    [self setupApplication];
    
    // Initialize Hockey
    //    [self initializeHockeyKit];
    
    // Check for recent crashes
    //    [self checkForRecentCrashes];
    
    [self initializeHelpShift];
    
    //    [Flurry startSession:@"M9HGGN26V39H338FNJ2G" withOptions:launchOptions];
    //    [Flurry setSessionReportsOnCloseEnabled:YES];
   
    /*
     //Appsee configuration
#ifdef CONFIGURATION_Debug
    [Appsee start:@"962a70b94d194e4eb7b37f5226b578a0"];
#endif
#ifdef CONFIGURATION_Adhoc
    [Appsee start:@"962a70b94d194e4eb7b37f5226b578a0"];
#endif
#ifdef CONFIGURATION_Release
    [Appsee start:@"5c4b174cbb744f769fcb10bf7346b62a"];
#endif
    */
    
    
    // General application UI look and feel
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"NavigationBackground"] forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    //Heap
    [Heap setAppId:@"3304096389"];
#ifdef DEBUG
    [Heap enableVisualizer];
#endif
    
    //Set the first run date
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"firstRun"]) {
        [defaults setBool:YES forKey:@"firstRun"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    Ubertersters SDK initialization
//    [[Ubertesters shared] initialize];
    
    
    // Initialize Intercom
    [Intercom setApiKey:@"ios_sdk-cf20a5d95aba9611f61319d228257299922c29ac" forAppId:@"fd6tbtjb"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    [[PFFacebookUtils session] close];
}

/*
 - (void)initializeHockeyKit {
 #ifdef CONFIGURATION_Debug
 [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"dd2d58551c66e9625c104af5e2e43abb"];
 #endif
 #ifdef CONFIGURATION_Adhoc
 [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"dd2d58551c66e9625c104af5e2e43abb"];
 #endif
 #ifdef CONFIGURATION_Release
 [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"f4d20aa7968d821b3a08c3659936b047"];
 #endif
 
 [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeHockeyAppEmail];
 
 // Enable debugging for the Debug configuration
 #ifdef CONFIGURATION_Debug
 [BITHockeyManager sharedHockeyManager].debugLogEnabled = YES;
 #endif
 
 [[BITHockeyManager sharedHockeyManager] startManager];
 
 // If this is an adhoc build, authenticate the user
 #ifdef CONFIGURATION_Adhoc
 [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
 #endif
 
 }
 */

- (void)initializeHelpShift
{
    [Helpshift installForApiKey:@"2720aaf22e9903134c6ff22bc9498263" domainName:@"giusto.helpshift.com" appID:@"giusto_platform_20141031192833465-13599d8ba5e7f63"];
}

/*
 #pragma mark - BITCrashManagerDelegate Methods
 
 - (void)crashManagerWillCancelSendingCrashReport:(BITCrashManager *)crashManager
 {
 if ([self didCrashInLastSessionOnStartup]) {
 [self setupApplication];
 }
 }
 
 
 - (void)crashManager:(BITCrashManager *)crashManager didFailWithError:(NSError *)error
 {
 if ([self didCrashInLastSessionOnStartup]) {
 [self setupApplication];
 }
 }
 
 
 - (void)crashManagerDidFinishSendingCrashReport:(BITCrashManager *)crashManager
 {
 if ([self didCrashInLastSessionOnStartup]) {
 [self setupApplication];
 }
 }
 
 
 - (void)checkForRecentCrashes
 {
 if ([self didCrashInLastSessionOnStartup]) {
 // TODO: We need to display an intermediate screen while we are waiting for 'startup' crashes to upload to hockey
 }
 }
 
 
 - (BOOL)didCrashInLastSessionOnStartup
 {
 return ([[BITHockeyManager sharedHockeyManager].crashManager didCrashInLastSession] &&
 [[BITHockeyManager sharedHockeyManager].crashManager timeintervalCrashInLastSessionOccured] < 5);
 }
 */



@end
