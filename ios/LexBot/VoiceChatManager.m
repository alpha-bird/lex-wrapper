//
//  VoiceChatManager.m
//  LexBot
//
//  Created by Alpha on 12/16/17.
//  Copyright © 2017 Facebook. All rights reserved.
//
#import "VoiceChatManager.h"
#import <AWSCore/AWSCore.h>
#import <AWSLex/AWSLex.h>
#import <AWSLex/AWSLexVoiceButton.h>

static NSString *VoiceButtonUserAgent = @"LexVoiceButton";

@interface AWSLexInteractionKit()

@property (nonatomic, readonly) AWSServiceConfiguration *configuration;

@end

@interface VoiceChatManager () <AWSLexInteractionDelegate, AWSLexMicrophoneDelegate, AWSLexAudioPlayerDelegate>
  @property (nonatomic, strong) AWSLexInteractionKit *interactionKit;
  @property (nonatomic, assign) double voiceLevel;
@end

@implementation VoiceChatManager {
  BOOL isListening;
  BOOL canListen;
  BOOL isAnimating;
  CAMediaTimingFunction *timingFunction;
  BOOL errorFired;
  RCTResponseSenderBlock startedCallBack;
  RCTResponseSenderBlock responseCallBack;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(startVoiceChat:(RCTResponseSenderBlock)callback) {
  responseCallBack = callback;
  [self startMonitoring:0];
}

RCT_EXPORT_METHOD(setStartingCallBack:(RCTResponseSenderBlock)callback) {
  startedCallBack = callback;
}

RCT_EXPORT_METHOD(stopChatting) {
  [self stopProgress];
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
  if(!newSuperview) {
    isListening = NO;
    [self stopProgress];
    [self stopDisplay];
    [self removeDelegates];
    [self.interactionKit cancel];
  } else {
    [self setDelegates];
  }
}

- (void)startProgress{
  if(!isAnimating){
    isAnimating = YES;
    CABasicAnimation *rotationAnimation = [CABasicAnimation
                                           animationWithKeyPath:@"transform.rotation.z"];
    [rotationAnimation setFromValue:0];
    [rotationAnimation setToValue:@(2*M_PI)];
    [rotationAnimation setDuration:1.0f];
    [rotationAnimation setRepeatCount:INFINITY];
  }
}

- (void)stopProgress{
  if (isAnimating) {
    isAnimating = NO;
    self.voiceLevel = 0;
  }
}

- (void)setDelegates{
  self.interactionKit.audioPlayerDelegate = self;
  self.interactionKit.microphoneDelegate = self;
  self.interactionKit.interactionDelegate = self;
}

- (void) removeDelegates {
  self.interactionKit.audioPlayerDelegate = nil;
  self.interactionKit.microphoneDelegate = nil;
  self.interactionKit.interactionDelegate = nil;
}

- (void)startMonitoring:(id)sender{
  
  if(!self.interactionKit){
    self.interactionKit = [AWSLexInteractionKit interactionKitForKey:AWSLexVoiceButtonKey];
    if(!self.interactionKit){
      @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                     reason:[NSString stringWithFormat:@"Cannot find interactionKit with key %@", AWSLexVoiceButtonKey ]
                                   userInfo:nil];
    }
    [self.interactionKit.configuration addUserAgentProductToken:VoiceButtonUserAgent];
    [self setDelegates];
  }
  
  NSError *audioSessionError;
  AWSLexAudioSession *session = [AWSLexAudioSession sharedInstance];
  [session setPlayAndRecordCategory:&audioSessionError];
  
  if(audioSessionError){
    [self handleError:audioSessionError];
    return;
  }
  
  [session requestRecordPermission:^(BOOL granted) {
    canListen = granted;
    if(granted) {
      NSLog(@"LISTENING STARTED");
      startedCallBack(@[@"started"]);
      [self startListening];
    } else {
      NSLog(@"PERMISSION DEINED");
      NSError *permissionDeniedError = [[NSError alloc]initWithDomain:AWSLexVoiceButtonErrorDomain code:AWSLexVoiceButtonErrorCodeAudioRecordingPermisionDenied userInfo:nil];
      [self handleError:permissionDeniedError];
    }
  }];
}

- (void)handleError:(NSError *)error{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate voiceButton:self onError:error];
  });
}

- (void)startListening{
  if(!isListening && canListen){
    [self.interactionKit audioInAudioOut];
  }
}

- (void)startDisplay{
  
}

-(void)stopDisplay{
 
}

#pragma mark - AWSLexMicrophoneDelegate

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit onSoundLevelChanged:(double)soundLevel{
  self.voiceLevel = soundLevel;
}

- (void)interactionKitOnRecordingStart:(AWSLexInteractionKit *)interactionKit {
  // Voice recording is about to start.
  isListening = YES;
  [self startDisplay];
}

#pragma mark -

#pragma mark - AWSLexInteractionKitDelegate

- (void)interactionKitOnRecordingEnd:(AWSLexInteractionKit *)interactionKit audioStream:(nonnull NSData *)audioStream contentType:(nonnull NSString *)contentType{
  isListening = NO;
  [self stopDisplay];
  [self startProgress];
}

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit onError:(NSError *)error{
  dispatch_async(dispatch_get_main_queue(), ^{
    isAnimating = YES;//fake animation so that next step succeeds
    isListening = NO;
    [self stopProgress];
    
    NSDictionary *userInfo;
    // If AWSLexInteractionKitErrorCodeDialogFailed is encountered, audio would be playing.
    // for the rest of errors, we would want to use microphone color.
    if ([error.domain isEqualToString:AWSLexInteractionKitErrorDomain]
        && error.code == AWSLexInteractionKitErrorCodeDialogFailed) {
     
    } else {
      
    }
    
    //start a timer for a few secs to display error code to reset the error mode.
    [NSTimer scheduledTimerWithTimeInterval:1.5f
                                     target:self
                                   selector:@selector(resetError:)
                                   userInfo:userInfo
                                    repeats:NO];
  });
  
  if(self.delegate && [self.delegate respondsToSelector:@selector(voiceButton:onError:)]){
    [self.delegate voiceButton:self onError:error];
  }
}

- (void)resetError:(NSTimer *)timer {
  
}

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit
       switchModeInput:(AWSLexSwitchModeInput *)switchModeInput
      completionSource:(AWSTaskCompletionSource<AWSLexSwitchModeResponse *> *)completionSource{
  
  dispatch_async(dispatch_get_main_queue(), ^{
    [self stopProgress];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(voiceButton:onResponse:)]){
      /*
      AWSLexVoiceButtonResponse *response = [[AWSLexVoiceButtonResponse alloc] initWithOutputText:switchModeInput.outputText
                                                                                           intent:switchModeInput.intent
                                                                                sessionAttributes:switchModeInput.sessionAttributes
                                                                                     slotToElicit:switchModeInput.elicitSlot
                                                                                            slots:switchModeInput.slots
                                                                                      dialogState:switchModeInput.dialogState
                                                                                      audioStream:switchModeInput.audioStream
                                                                                 audioContentType:switchModeInput.audioContentType
                                                                                  inputTranscript:switchModeInput.inputTranscript];
      [self.delegate voiceButton:self onResponse:response];
       */
      
    }
  });
  
  NSLog(@"%@" , switchModeInput.inputTranscript);
  NSLog(@"%@" , switchModeInput.outputText);
  
  responseCallBack(@[switchModeInput.inputTranscript, switchModeInput.outputText]);
  
  AWSLexSwitchModeResponse *switchModeResponse = [AWSLexSwitchModeResponse new];
  [switchModeResponse setInteractionMode:AWSLexInteractionModeSpeech];
  [switchModeResponse setSessionAttributes:switchModeResponse.sessionAttributes];
  [completionSource setResult:switchModeResponse];
}

- (void)interactionKit:(AWSLexInteractionKit *)interactionKit onDialogReadyForFulfillmentForIntent:(nonnull NSString *)intentName slots:(nonnull NSDictionary *)slots{
  if(self.delegate && [self.delegate respondsToSelector:@selector(voiceButtononReadyToFullFill:withSlots:)]){
    [self.delegate voiceButtononReadyToFullFill:self withSlots:slots];
  }
}

#pragma mark -

#pragma mark - AWSLexAudioPlaybackDelegate

- (void)interactionKitOnAudioPlaybackStarted:(AWSLexInteractionKit *)interactionKit {
  // Lex is about to talk. Switch listen image in order to provide clear visual indication that you need to listen.

}

- (void)interactionKitOnAudioPlaybackFinished:(AWSLexInteractionKit *)interactionKit {
  // Lex finished talking. Switch to microphone image.

}

#pragma mark -

@end

