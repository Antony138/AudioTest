//
//  ViewController.m
//  AudioTest20151026
//
//  Created by YuHeng_Antony on 10/26/15.
//  Copyright © 2015 Homni Electron Inc. All rights reserved.
//

#import "ViewController.h"

@import AVFoundation;

@interface ViewController ()
{
    AVAudioEngine *_testEngine;
    AVAudioPlayerNode *_marimbaPlayer;
    AVAudioPCMBuffer *_marimbaLoopBuffer;
    AVAudioUnitDelay    *_delay;
    
    AVAudioPlayerNode   *_mixerOutputFilePlayer;
}

@property (nonatomic, readonly) BOOL marimbaPlayerIsPlaying;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _marimbaPlayer = [[AVAudioPlayerNode alloc] init];
    _testEngine = [[AVAudioEngine alloc] init];
    _delay = [[AVAudioUnitDelay alloc] init];
    _mixerOutputFilePlayer = [[AVAudioPlayerNode alloc] init];
    [_testEngine attachNode:_marimbaPlayer];
    [_testEngine attachNode:_delay];
    [_testEngine attachNode:_mixerOutputFilePlayer];
    
    
    NSError *error;
    NSURL *marimbaLoopURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"marimbaLoop" ofType:@"caf"]];
    AVAudioFile *marimbaLoopFile = [[AVAudioFile alloc] initForReading:marimbaLoopURL error:&error];
    _marimbaLoopBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[marimbaLoopFile processingFormat] frameCapacity:(AVAudioFrameCount)[marimbaLoopFile length]];
    NSAssert([marimbaLoopFile readIntoBuffer:_marimbaLoopBuffer error:&error], @"couldn't read marimbaLoopFile into buffer, %@", [error localizedDescription]);
    
    
    // make engine connections
    [self makeEngineConnections];
    
}

- (BOOL)marimbaPlayerIsPlaying {
    return _marimbaPlayer.isPlaying;
}

- (void)startEngine {
    if (!_testEngine.isRunning) {
        NSError *error;
        NSAssert([_testEngine startAndReturnError:&error], @"couldn't start engine, %@", [error localizedDescription]);
    }
}

- (void)makeEngineConnections
{
    // get the engine's optional singleton main mixer node
    AVAudioMixerNode *mainMixer = [_testEngine mainMixerNode];
    
    // establish a connection between nodes
    
    // marimba player -> delay -> main mixer
    [_testEngine connect: _marimbaPlayer to:_delay format:_marimbaLoopBuffer.format];
    [_testEngine connect:_delay to:mainMixer format:_marimbaLoopBuffer.format];
    
    // node tap player
    [_testEngine connect:_mixerOutputFilePlayer to:mainMixer format:[mainMixer outputFormatForBus:0]];
}


- (IBAction)togglePlayMarimba:(UIButton *)sender {
    if (!self.marimbaPlayerIsPlaying) {
        [self startEngine];
        [_marimbaPlayer scheduleBuffer:_marimbaLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        [_marimbaPlayer play];
    } else {
        [_marimbaPlayer stop];
    }
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
