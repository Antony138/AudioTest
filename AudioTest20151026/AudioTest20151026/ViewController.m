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
    
    AVAudioPlayerNode   *_mixerOutputFilePlayer;
}

@property (nonatomic, readonly) BOOL marimbaPlayerIsPlaying;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _marimbaPlayer = [[AVAudioPlayerNode alloc] init];
    _testEngine = [[AVAudioEngine alloc] init];
    _mixerOutputFilePlayer = [[AVAudioPlayerNode alloc] init];
    [_testEngine attachNode:_marimbaPlayer];
    [_testEngine attachNode:_mixerOutputFilePlayer];
    
    
    // 创建播放的buffer
    NSError *error;
    NSURL *marimbaLoopURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"遇见" ofType:@"mp3"]];
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
    [_testEngine connect:_marimbaPlayer to:mainMixer format:_marimbaLoopBuffer.format];
    
    // node tap player(监视器?)
//    [_testEngine connect:_mixerOutputFilePlayer to:mainMixer format:[mainMixer outputFormatForBus:0]];
}

- (IBAction)togglePlayMarimba:(UIButton *)sender {
    if (!self.marimbaPlayerIsPlaying) {
        [self startEngine];
        
        // 播放文件(AVAudioFile)，只能播放一次，
//        NSError *error;
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"遇见" ofType:@"mp3"];
//        NSURL *marimbaLoopURL = [NSURL fileURLWithPath:path];
//        AVAudioFile *marimbaLoopFile = [[AVAudioFile alloc] initForReading:marimbaLoopURL error:&error];
//        [_marimbaPlayer scheduleFile:marimbaLoopFile atTime:nil completionHandler:nil];
 

        
        // 播放buffer，可实现循环重复播放
        [_marimbaPlayer scheduleBuffer:_marimbaLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        
        // 设置5秒后播放
//        double sampleRate = _marimbaLoopBuffer.format.sampleRate;
//        double sampleTime = sampleRate * 5.0;
//        AVAudioTime *futureTime = [AVAudioTime timeWithSampleTime:sampleTime atRate:sampleRate];
//        [_marimbaPlayer scheduleBuffer:_marimbaLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        
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
