/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <AWSCore/AWSCore.h>
#import <AWSLex/AWSLex.h>
#import "Constants.h"

static NSString *AWSLexVoiceButtonIdentifierKey = @"AWSLexVoiceButton";
static NSString *AWSLexChatConfigIdentifierKey = @"chatConfig";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc]
                                                        initWithRegionType:CognitoRegionType
                                                        identityPoolId:CognitoIdentityPoolId];
  
  AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:LexRegionType credentialsProvider:credentialsProvider];
  
  [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
  
  AWSLexInteractionKitConfig *config = [AWSLexInteractionKitConfig defaultInteractionKitConfigWithBotName:BotName botAlias:BotAlias];
  
  [AWSLexInteractionKit registerInteractionKitWithServiceConfiguration:configuration interactionKitConfiguration:config forKey:AWSLexVoiceButtonIdentifierKey];
  
  AWSLexInteractionKitConfig *chatConfig = [AWSLexInteractionKitConfig defaultInteractionKitConfigWithBotName:BotName botAlias:BotAlias];
  chatConfig.autoPlayback = NO;
  [AWSLexInteractionKit registerInteractionKitWithServiceConfiguration:configuration interactionKitConfiguration:chatConfig forKey:AWSLexChatConfigIdentifierKey];
  
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"LexBot"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  self.window.rootViewController = rootViewController;
  [self.window makeKeyAndVisible];
  return YES;
}

@end
