//
//  VoiceChatManager.h
//  LexBot
//
//  Created by Alpha on 12/16/17.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import <AWSLex/AWSLex.h>

@interface VoiceChatManager : NSObject <RCTBridgeModule>
  @property (weak, nonatomic) AWSLexVoiceButton *voiceButton;
  @property (nonatomic, weak) id<AWSLexVoiceButtonDelegate> delegate;
@end

