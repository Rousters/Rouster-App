//
//  SoundController.m
//  Rouster
//
//  Created by Eric Mentele on 2/24/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//Inspired in part by http://www.raywenderlich.com/69369/audio-tutorial-ios-playing-audio-programatically-2014-edition

#import "SoundController.h"
@import AVFoundation;

@interface SoundController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (assign) BOOL alarmPlaying;
@property (assign) BOOL alarmInterrupted;

@end


@implementation SoundController

- (instancetype)init {
  self = [super init];
  
  if (self) {
    
    [self configureAudioSession];
    [self configureAudioPlayer];
  }
  return self;
}

#pragma mark - Config
- (void)configureAudioSession {
  
  self.audioSession = [AVAudioSession sharedInstance];
  
  NSError *setCategoryError = nil;
  [self.audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
  if (setCategoryError) {
    NSLog(@"There was an error setting the category to playback");
  }//if error
}//configure audio session


-(void)configureAudioPlayer {
  
  NSString *alienSirenPath = [[NSBundle mainBundle] pathForResource:@"Alien_Siren" ofType:@"mp3"];
  NSURL *alienSirenURL = [NSURL fileURLWithPath:alienSirenPath];
  self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:alienSirenURL error:nil];
  self.audioPlayer.delegate = self;
}


#pragma mark - Methods
-(void)playSound {
  [self.audioPlayer play];
  self.audioPlayer.numberOfLoops = -1;
}//play sound

-(void)stopSound {
  [self.audioPlayer stop];
  [self.audioPlayer setCurrentTime:0];
    NSLog(@"I have stopped sound");
  //[self.audioSession setActive:NO error:nil];
}
@end
