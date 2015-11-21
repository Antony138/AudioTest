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
    AVAudioPlayerNode *_firstSongPlayer;
    AVAudioPCMBuffer *_firstSongLoopBuffer;
    
    AVAudioPlayerNode *_secondSongPlayer;
    AVAudioPCMBuffer *_secondSongLoopBuffer;
    
    // 第三个buffer(用于测试)
    AVAudioPCMBuffer *_thirdBuffer;
    
    AVAudioPlayerNode   *_mixerOutputFilePlayer;
}

@property (nonatomic, readonly) BOOL marimbaPlayerIsPlaying;

// 第一首歌的按钮
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@property (strong, nonatomic) UIAlertView *nonSelectedSoundtrackAlertView;

// 第二首歌的按钮
@property (weak, nonatomic) IBOutlet UIButton *secondPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *secondLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *secondRightButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _firstSongPlayer = [[AVAudioPlayerNode alloc] init];
    _secondSongPlayer = [[AVAudioPlayerNode alloc] init];
    
    _testEngine = [[AVAudioEngine alloc] init];
    _mixerOutputFilePlayer = [[AVAudioPlayerNode alloc] init];
    [_testEngine attachNode:_firstSongPlayer];
    [_testEngine attachNode:_secondSongPlayer];
    [_testEngine attachNode:_mixerOutputFilePlayer];
    
    
    // 创建播放的buffer
    NSError *error;
    NSURL *marimbaLoopURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"leftRightTest" ofType:@"mp3"]];
    AVAudioFile *marimbaLoopFile = [[AVAudioFile alloc] initForReading:marimbaLoopURL error:&error];
    _firstSongLoopBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[marimbaLoopFile processingFormat] frameCapacity:(AVAudioFrameCount)[marimbaLoopFile length]];
    NSAssert([marimbaLoopFile readIntoBuffer:_firstSongLoopBuffer error:&error], @"couldn't read marimbaLoopFile into buffer, %@", [error localizedDescription]);
    
    NSURL *drumLoopURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"leftRightTest2" ofType:@"mp3"]];
    AVAudioFile *drumLoopFile = [[AVAudioFile alloc] initForReading:drumLoopURL error:&error];
    _secondSongLoopBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[drumLoopFile processingFormat] frameCapacity:(AVAudioFrameCount)[drumLoopFile length]];
    [drumLoopFile readIntoBuffer:_secondSongLoopBuffer error:&error];
    
//    NSURL *thirdBufferURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"勇气" ofType:@"mp3"]];
//    AVAudioFile *thirdBufferFile = [[AVAudioFile alloc] initForReading:thirdBufferURL error:&error];
//    _thirdBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:[thirdBufferFile processingFormat] frameCapacity:(AVAudioFrameCount)[thirdBufferFile length]];
//    [thirdBufferFile readIntoBuffer:_thirdBuffer error:&error];
    
    
    // make engine connections
    [self makeEngineConnections];
    
}

- (BOOL)firstSongPlayerIsPlaying {
    return _firstSongPlayer.isPlaying;
}

- (void)makeEngineConnections
{
    // get the engine's optional singleton main mixer node
    AVAudioMixerNode *mainMixer = [_testEngine mainMixerNode];
    
    // establish a connection between nodes
    [_testEngine connect:_firstSongPlayer to:mainMixer format:_firstSongLoopBuffer.format];
    
    [_testEngine connect:_secondSongPlayer to:mainMixer format:_secondSongLoopBuffer.format];
    
    // node tap player(监视器?)
//    [_testEngine connect:_mixerOutputFilePlayer to:mainMixer format:[mainMixer outputFormatForBus:0]];
}

- (void)startEngine {
    if (!_testEngine.isRunning) {
        NSError *error;
        NSAssert([_testEngine startAndReturnError:&error], @"couldn't start engine, %@", [error localizedDescription]);
    }
}

- (IBAction)togglePlayFirstSong:(UIButton *)sender {
    if (!_leftButton.selected && !_rightButton.selected) {
        if (!_nonSelectedSoundtrackAlertView) {
            _nonSelectedSoundtrackAlertView = [[UIAlertView alloc] initWithTitle:@"NOTE" message:@"Please select Soundtrack First." delegate:sender cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        [_nonSelectedSoundtrackAlertView show];
        return;
    }
    
    sender.selected = !sender.selected;

//    _marimbaPlayer.pan = 1;
    if (!self.firstSongPlayerIsPlaying) {
        
        [self startEngine];
        
        // 播放文件(AVAudioFile)，只能播放一次，
//        NSError *error;
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"遇见" ofType:@"mp3"];
//        NSURL *marimbaLoopURL = [NSURL fileURLWithPath:path];
//        AVAudioFile *marimbaLoopFile = [[AVAudioFile alloc] initForReading:marimbaLoopURL error:&error];
//        [_marimbaPlayer scheduleFile:marimbaLoopFile atTime:nil completionHandler:nil];
 

        // Loop single buffer
        // 播放buffer，options参数选AVAudioPlayerNodeBufferLoops，实现buffer循环播放
//        [_marimbaPlayer scheduleBuffer:_marimbaLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];

        // 设置播放时间:5秒后播放
//        double sampleRate = _marimbaLoopBuffer.format.sampleRate;
//        double sampleTime = sampleRate * 5.0;
//        AVAudioTime *futureTime = [AVAudioTime timeWithSampleTime:sampleTime atRate:sampleRate];
//        [_marimbaPlayer scheduleBuffer:_marimbaLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        
        
        // 播放两个buffer,
        // 播放两个buffer，通过设置不同的options，控制buffer的播放方式(1、是否循环；2、是否打断前面的buffer(循环))。
        // 1、(Append new buffer)两个options参数设置为nil，两个buffer默认按顺序前后播放
        // 2、(Interrupt with new buffer)第二个bufferoptions参数设置为AVAudioPlayerNodeBufferInterrupts，会打断前面播放的buffer，直接播放新buffer
        // ( Interrupt looping buffer after current loop finishes)AVAudioPlayerNodeBufferInterruptsAtLoop:等前面循环的buffer完整播完后，再打断，播放新buffer(测试过，好像不起作用)
        [_firstSongPlayer scheduleBuffer:_firstSongLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
//        [_marimbaPlayer scheduleBuffer:_drumLoopBuffer atTime:nil options:nil completionHandler:nil];
        
        
//        [_marimbaPlayer scheduleBuffer:_thirdBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];

        [_firstSongPlayer play];
        
    } else {
        [_firstSongPlayer stop];
        _leftButton.selected = NO;
        _rightButton.selected = NO;
    }
}

#pragma mark - 第一首歌左右声道切换
// -1为左声道;1为右声道
- (IBAction)leftButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        // 左声道选择状态:1、如果右声道有选择，就设置立体声;2、如果右声道没有选择，就设置左声道
        if (_rightButton.selected) {
            _firstSongPlayer.pan = 0;
        } else {
            _firstSongPlayer.pan = -1;
        }
    } else {
        // 左声道非选择状态:1、如果右声道有选择，就设置右声道;2、如果右声道没有选择，关闭声音
        if (_rightButton.selected) {
            _firstSongPlayer.pan = 1;
        } else {
            // 停止播放
            [_firstSongPlayer stop];
            _playButton.selected = NO;
        }
    }
}

- (IBAction)rightButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        if (_leftButton.selected) {
            _firstSongPlayer.pan = 0;
        } else {
            _firstSongPlayer.pan = 1;
        }
    } else {
        if (_leftButton.selected) {
            _firstSongPlayer.pan = -1;
        } else {
            // 停止播放
            [_firstSongPlayer stop];
            _playButton.selected = NO;
        }
    }
}

#pragma mark - 第二首歌左右声道切换
- (BOOL)secondSongPlayerIsPlaying {
    return _secondSongPlayer.isPlaying;
}

- (IBAction)togglePlaySecondSong:(UIButton *)sender {
    if (!_secondLeftButton.selected && !_secondRightButton.selected) {
        if (!_nonSelectedSoundtrackAlertView) {
            _nonSelectedSoundtrackAlertView = [[UIAlertView alloc] initWithTitle:@"NOTE" message:@"Please select Soundtrack First/请先选择声道." delegate:sender cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        }
        [_nonSelectedSoundtrackAlertView show];
        return;
    }
    
    sender.selected = !sender.selected;
    
    
    if (!self.secondSongPlayerIsPlaying) {
        [self startEngine];
        [_secondSongPlayer scheduleBuffer:_secondSongLoopBuffer atTime:nil options:AVAudioPlayerNodeBufferLoops completionHandler:nil];
        
        
        [_secondSongPlayer play];
    } else {
        [_secondSongPlayer stop];
        _secondLeftButton.selected = NO;
        _secondRightButton.selected = NO;
    }
}

- (IBAction)secondLeftButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        // 左声道选择状态:1、如果右声道有选择，就设置立体声;2、如果右声道没有选择，就设置左声道
        if (_secondRightButton.selected) {
            _secondSongPlayer.pan = 0;
        } else {
            _secondSongPlayer.pan = -1;
        }
    } else {
        // 左声道非选择状态:1、如果右声道有选择，就设置右声道;2、如果右声道没有选择，关闭声音
        if (_secondRightButton.selected) {
            _secondSongPlayer.pan = 1;
        } else {
            // 停止播放
            [_secondSongPlayer stop];
            _secondPlayButton.selected = NO;
        }
    }
}

- (IBAction)secondRightButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (sender.selected) {
        if (_secondLeftButton.selected) {
            _secondSongPlayer.pan = 0;
        } else {
            _secondSongPlayer.pan = 1;
        }
    } else {
        if (_secondLeftButton.selected) {
            _secondSongPlayer.pan = -1;
        } else {
            // 停止播放
            [_secondSongPlayer stop];
            _secondPlayButton.selected = NO;
        }
    }
}

@end
