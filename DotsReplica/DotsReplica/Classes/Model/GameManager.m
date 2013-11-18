//
//  GameManager.m
//  ConnectDots
//
//  Created by mihaiserban on 9/12/13.
//  Copyright (c) 2013 ProtonicService. All rights reserved.
//

#import "GameManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AVFoundation/AVFoundation.h"

@interface GameManager ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end
@implementation GameManager

+ (id)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(id)init
{
    if (self == [super init]) {

    }
    return self;
}

#pragma mark - Sounds

-(void)playBackgroundMusic
{
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"Samantha Foster - Wild Acorns" ofType:@"mp3"];
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundFileURL error:nil];
    _audioPlayer.numberOfLoops = -1; //infinite
    
    [_audioPlayer play];
}

-(void)playDropSound
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"water-droplet-1" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}
-(void) playSound {
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"water-droplet-1" ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
}

@end
