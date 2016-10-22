//
//  RecordViewController.m
//  T-one
//
//  Created by Cheney on 11/8/15.
//  Copyright © 2015 Cheney. All rights reserved.
//

#import "RecordViewController.h"
#import <AVFoundation/AVFoundation.h>
#define myRecorderfile @"//myRecord.caf"


@interface RecordViewController () <AVAudioRecorderDelegate>

///button
@property UIButton * Button_Back;
@property UIButton * Button_Record;
@property UIButton * Button_Stop;
@property UIButton * Button_Play;

/////recorder and player
@property AVAudioRecorder * myRecorder;
@property AVAudioPlayer * myPlayer;
@property AVAudioSession * mySession;

//////progress
@property UIProgressView * recordProgressV;
@property NSTimer * myTimer;
@property float progress;

@property CGPoint boundP;
@property CGSize boundS;

//////url
@property NSURL *recorderFileUrl;

///alert
@property UIAlertController * alertV1;
@property UIAlertController * alertV2;
@property UIAlertController * alertV3;

@end

@implementation RecordViewController
@synthesize delegate = _delegate;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initial];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/////init
- (void) initial {
    //backbround color
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //size and point of bound
    self.boundP = [[UIScreen mainScreen] bounds].origin;
    self.boundS = [[UIScreen mainScreen] bounds].size;
    
    //button
    UIButton* Btn_back = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-53/2,(_boundS.height/20)*4,53,30)];
    Btn_back.backgroundColor = [UIColor lightGrayColor];
    [Btn_back setTitle:@"back" forState:UIControlStateNormal];
    [Btn_back setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_back setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_back addTarget:self action:@selector(clickBtn_Back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_back];
    self.Button_Back = Btn_back;  
    
    UIButton * Btn_Record = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-53/2-3-53, (_boundS.height/20)*3, 53, 30)];
    Btn_Record.backgroundColor = [UIColor lightGrayColor];
    [Btn_Record setTitle:@"start" forState:UIControlStateNormal];
    [Btn_Record setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Record setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Record addTarget:self action:@selector(clickBtn_Record) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Record];
    self.Button_Record = Btn_Record;
    
    UIButton * Btn_Stop = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-53/2, (_boundS.height/20)*3, 53, 30)];
    Btn_Stop.backgroundColor = [UIColor lightGrayColor];
    Btn_Stop.contentMode = UIViewContentModeCenter;
    [Btn_Stop setTitle:@"stop" forState:UIControlStateNormal];
    [Btn_Stop setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Stop setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Stop addTarget:self action:@selector(clickBtn_Stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Stop];
    self.Button_Stop = Btn_Stop;
    
    UIButton * Btn_Play = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2+53/2+3, (_boundS.height/20)*3, 53, 30)];
    Btn_Play.backgroundColor = [UIColor lightGrayColor];
    [Btn_Play setTitle:@"play" forState:UIControlStateNormal];
    [Btn_Play setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Play setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Play addTarget:self action:@selector(clickBtn_Play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Play];
    self.Button_Play = Btn_Play;
    
    ////timer
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(timer) userInfo:nil repeats:YES];
    timer.fireDate = [NSDate distantFuture];
    self.myTimer = timer;
    
    //progress view
    UIProgressView * progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(_boundS.width/2-154/2, (_boundS.height/20)*2, 154, 0)];
    progressV.progressTintColor = [UIColor greenColor];
    progressV.trackTintColor = [UIColor whiteColor];
    progressV.progress = 0;
    self.progress = 0;
    [self.view addSubview:progressV];
    self.recordProgressV = progressV;
    
    ///////AVsession
    NSError * sessionError = nil;
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&sessionError];
    [session setActive:YES error:nil];
    self.mySession = session;
    
    if ( !session ) {
        NSLog(@"Session error : %@",sessionError.localizedDescription);
    }
    
    //record and play url
    NSString * urlString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlString = [urlString stringByAppendingString:myRecorderfile];
    NSLog(@"Recorder file path : %@",urlString);
    NSURL * url = [NSURL fileURLWithPath:urlString];
    self.recorderFileUrl = url;
    
    //player and recorder init
    self.myRecorder = [self RecorderInit];
    self.myPlayer = [self PlayerInit];
}

/////////Recorder and Player init/////////
- (AVAudioRecorder *) RecorderInit {
    ///////AVRecorder
    NSError * recorderError = nil;//error return
    
    //settings
    NSMutableDictionary * settings = [NSMutableDictionary dictionary];
    [settings setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [settings setObject:@(8000) forKey:AVSampleRateKey];
    [settings setObject:@(1) forKey:AVChannelLayoutKey];
    [settings setObject:@(16) forKey:AVLinearPCMBitDepthKey];
    [settings setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    //recorder
    AVAudioRecorder * recorder = [[AVAudioRecorder alloc] initWithURL:self.recorderFileUrl settings:settings error:&recorderError];
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
        //output error
    if ( !recorder ) {
        NSLog(@"AVAudioRecorder error : %@",recorderError.localizedDescription);
    }
    
    return recorder;
}

- (AVAudioPlayer *) PlayerInit {
    ////////////AVPlayer
    //error player
    NSError * playerError = nil;
    //player
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorderFileUrl error:&playerError];
    player.numberOfLoops = -1;
    [player prepareToPlay];
    player.meteringEnabled = YES;
    //output error
    if ( !player ) {
        NSLog(@"AVAudioPlayerInRecordVC error : %@",playerError.localizedDescription);
    }
    
    return player;
}

///////click Button///////
- (void) clickBtn_Back {
    if ( [_myRecorder isRecording] || [_myPlayer isPlaying] ) {
//        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please stop recording or playing!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alert show];
        if ( !self.alertV1 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please stop recording or playing!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV1 = alertV;
        }
        
        [self presentViewController:self.alertV1 animated:YES completion:nil];         
    }
    else if ( ![_myRecorder isRecording] && ![_myPlayer isPlaying] ){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) clickBtn_Record {
    
    if ( [_myPlayer isPlaying] || [_myRecorder isRecording] ) {
//        UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please stop recording or playing first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertV show];
        if ( !self.alertV2 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please stop recording or playing first!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV2 = alertV;
        }
        [self presentViewController:self.alertV2 animated:YES completion:nil];
    }
    
    if ( ![_myRecorder isRecording] && ![_myPlayer isPlaying] ) {
        //can be recorded
        AVAudioSession * ssession = [AVAudioSession sharedInstance];
        [ssession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [ssession setActive:YES error:nil];
        
        _myTimer.fireDate = [NSDate distantPast];//begin timer
        [_myRecorder prepareToRecord];
        BOOL recState = [_myRecorder record];//begin record
        NSLog(@"recording");
        NSLog(@"RECORDING? : %d",[_myRecorder isRecording]);
        NSLog(@"PLAYING? : %d",[_myPlayer isPlaying]);
        NSLog(@"recState : %d",recState);
    }

}

- (void) clickBtn_Stop {
    [self.myRecorder stop];//stop record
    [self.myPlayer stop];//stop play
    self.recordProgressV.progress = 0;//reset progress
    _myTimer.fireDate = [NSDate distantFuture];//close timer
    NSLog(@"record or play stopped");
    
    //pass the path
    [self.delegate passPath:self.recorderFileUrl];//Pass the recorder file path
}

- (void) clickBtn_Play {

    if ( [_myRecorder isRecording] || [_myPlayer isPlaying] ) {
//        UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please stop recording or playing first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertV show];
        
        if ( !self.alertV3 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please stop recording or playing first!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV3 = alertV;
        }
        [self presentViewController:self.alertV3 animated:YES completion:nil];
    }
    
    if ( ![_myPlayer isPlaying] && ![_myRecorder isRecording] ) {
        //make the play back sound louder
        AVAudioSession * ssession = [AVAudioSession sharedInstance];
        [ssession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [ssession setActive:YES error:nil];
        
        self.myTimer.fireDate = [NSDate distantPast];//begin timer
        
        [_myPlayer stop];//stop first then can play with beginning
        [_myPlayer prepareToPlay];
        bool playState = [_myPlayer play];
        NSLog(@"record playing");
        NSLog(@"RECORDING? : %d",[_myRecorder isRecording]);
        NSLog(@"PLAYING? : %d",[_myPlayer isPlaying]);
        NSLog(@"playSate : %d",playState);
    }
}

///////timer/////
- (void) timer {
    if ( [_myRecorder isRecording] ) {
        [self.myRecorder updateMeters];
        float power1 = [self.myRecorder averagePowerForChannel:0];
        self.progress= ((power1+160.0)/160.0);//(1.0/160.0)*(power+160.0);
        [self.recordProgressV setProgress:_progress animated:YES];
        NSLog(@"power: %f",power1);
    }
    if ( [_myPlayer isPlaying] ) {
        [self.myPlayer updateMeters];
        float power2 = [self.myPlayer averagePowerForChannel:0];
        self.progress = ((power2+160.0)/160.0);
        [self.recordProgressV setProgress:_progress animated:YES];
        NSLog(@"power: %f",power2);
    }
    NSLog(@"timering........");
}

////recoder delegate
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    if ( ![_myRecorder isRecording] ) {
        NSLog(@"Record did finish!");
    }
}

- (void) audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error {
    NSLog(@"Record decode error : %@",error.localizedDescription);
}

@end
