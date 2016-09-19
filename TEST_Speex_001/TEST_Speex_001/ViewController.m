//
//  ViewController.m
//  TEST_Speex_001
//
//  Created by cai xuejun on 12-9-3.
//  Copyright (c) 2012年 caixuejun. All rights reserved.
//

#import "ViewController.h"
#import "SpeexCodec.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize PCMFilePath = _PCMFilePath;
@synthesize audioPlayer = _audioPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"caf"];
    NSData *PCMData = [NSData dataWithContentsOfFile:filePath];
//    NSLog(@"---------%d", [PCMData length]);
    
    NSData *SpeexData = EncodeWAVEToSpeex(PCMData, 1, 16);
//    NSLog(@"---------%d", [SpeexData length]);
    SpeexHeader *header = (SpeexHeader *)[SpeexData bytes];
    CalculatePlayTime(SpeexData, header->reserved1);
    
    NSData *NewPCMData = DecodeSpeexToWAVE(SpeexData);
    self.PCMFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]];
    [NewPCMData writeToFile:self.PCMFilePath atomically:YES];
}

- (IBAction)play:(id)sender {
    NSError *error;
    NSData *PCMData = [NSData dataWithContentsOfFile:self.PCMFilePath];
    self.audioPlayer = [[[AVAudioPlayer alloc] initWithData:PCMData error:&error] autorelease];
    if (!self.audioPlayer) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    self.audioPlayer.delegate = self; // 设置代理
    self.audioPlayer.numberOfLoops = 0;// 不循环播放
    [self.audioPlayer prepareToPlay];// 准备播放
    [self.audioPlayer play];// 开始播放
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)dealloc
{
    [_PCMFilePath release], _PCMFilePath = nil;
    [_audioPlayer release], _audioPlayer = nil;
    [super dealloc];
}

@end
