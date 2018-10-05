//
//  LexBotManager.m
//  LexBot
//
//  Created by Alpha on 12/15/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LexBotManager.h"
#import <React/RCTConvert.h>
#import <AWSLex/AWSLex.h>
#import <AWSCore/AWSCore.h>

#define HEIGHT 100;
#define CLIENT_SENDER_ID @"client"
#define SERVER_SENDER_ID @"server"
#define CONFIG_KEY @"chatConfig"

@interface LexBotManager() <AWSLexMicrophoneDelegate, AWSLexInteractionDelegate>
  @property (nonatomic, strong) AWSLexInteractionKit *interactionKit;
@end

@implementation LexBotManager{
  AWSTaskCompletionSource *textModeSwitchingCompletion;
  RCTResponseSenderBlock responseCallBack;
}
  
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(initAWSLexKit) {
  self.interactionKit = [AWSLexInteractionKit interactionKitForKey:CONFIG_KEY];
  self.interactionKit.interactionDelegate = self;
  self.interactionKit.microphoneDelegate = self;
}

RCT_EXPORT_METHOD(sendToServer:(NSString *)text callback:(RCTResponseSenderBlock)callback) {
  NSLog(@"SEND TO SERVER");
  responseCallBack = callback;
  if(textModeSwitchingCompletion){
    [textModeSwitchingCompletion setResult:text];
    textModeSwitchingCompletion = nil;
  }else{
    [self.interactionKit textInTextOut:text];
  }
}

- (void)interactionKit:(nonnull AWSLexInteractionKit *)interactionKit onError:(nonnull NSError *)error {
    NSLog(@"error occured %@", error);
}

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit
  switchModeInput:(AWSLexSwitchModeInput *)switchModeInput
  completionSource:(AWSTaskCompletionSource<AWSLexSwitchModeResponse *> *)completionSource{
    responseCallBack(@[switchModeInput.outputText]);
  
    NSLog(@"%@", switchModeInput.outputText);
    //this can expand to take input from user.
    AWSLexSwitchModeResponse *switchModeResponse = [AWSLexSwitchModeResponse new];
    [switchModeResponse setInteractionMode:AWSLexInteractionModeText];
    [switchModeResponse setSessionAttributes:switchModeInput.sessionAttributes];
    [completionSource setResult:switchModeResponse];
}
/*
 * Sent to delegate when the Switch mode requires a user to input a text. You should set the completion source result to the string that you get from the user. This ensures that the session attribute information is carried over from the previous request to the next one.
 */
- (void)interactionKitContinueWithText:(AWSLexInteractionKit *)interactionKit
                      completionSource:(AWSTaskCompletionSource<NSString *> *)completionSource{
  textModeSwitchingCompletion = completionSource;
}

@end

