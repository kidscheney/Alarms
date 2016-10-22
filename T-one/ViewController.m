//
//  ViewController.m
//  T-one
//
//  Created by Cheney on 9/13/15.
//  Copyright (c) 2015 Cheney. All rights reserved.
//
#import "ViewController.h"
#define myRecorderfile @"//myRecord.caf"

typedef NS_ENUM ( NSInteger,OptionType ) {
    defaultValue = 1,
    customValue = 2,
};

@interface ViewController () <UIAlertViewDelegate,UITextFieldDelegate,PassValueDelegate>
@property NSInteger hours;
@property NSInteger min;

///////////////////////
@property NSInteger h;
@property NSInteger m;
@property NSInteger s;


/////////////////////
@property UITextField *Text_M;
@property UITextField *Text_H;

@property UIButton *Button_save;
@property UIButton *Button_begin;
@property UIButton *Button_stop;
@property UIButton *Button_setting;

@property BOOL haveSaved;
@property BOOL haveBegined;

@property NSTimer* myTimer;
@property NSInteger totalSeconds;

@property UILabel * Label_hours;
@property UILabel * Label_minutes;
@property UILabel * Label_seconds;

@property AVAudioPlayer * myPlayer;
@property AVAudioPlayer * recorderFilePlayer;
@property AVAudioSession * audioSession;

@property SecondViewController * SettingVC;

@property NSInteger optionV;

@property NSURL * defaultAlarmsURL;
@property NSURL * recorderURL;//from delegate for the first time record
@property NSURL * recorderFileUrl;//default path same with recorder

@property CGPoint boundP;
@property CGSize boundS;

//alert view controller
@property UIAlertController * alertV1;
@property UIAlertController * alertV2;
@property UIAlertController * alertV3;
@property UIAlertController * alertV4;
@property UIAlertController * alertV5;
@property UIAlertController * alertV6;
@property UIAlertController * alertV7;

////////////////////
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self Initial];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
 //   [self.myTimer invalidate];
  //  self.myTimer = nil;
}

- (void)Initial {
    //
    self.optionV = defaultValue;
    self.boundP = [[UIScreen mainScreen] bounds].origin;
    self.boundS = [[UIScreen mainScreen] bounds].size;
    
    //Setting controller
    SecondViewController * setVC = [[SecondViewController alloc] init];
    setVC.delegate = self;
    self.SettingVC = setVC;
    
    //
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //Timer
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timer) userInfo:nil repeats:YES];
    [timer setFireDate:[NSDate distantFuture]];//turn off the timer as init
    self.myTimer = timer;
    
    //save first ,then begin---- //// begin first,then stop
    self.haveSaved = NO;
    self.haveBegined = NO;
    
    ///////////audio player
    //default file player
    NSString * string = [[NSBundle mainBundle] pathForResource:@"Alarms" ofType:@"mp3"];
    NSURL * nsurl = [NSURL fileURLWithPath:string];
    self.defaultAlarmsURL = nsurl;
    AVAudioPlayer* player1  = [[AVAudioPlayer alloc] initWithContentsOfURL:nsurl error:nil];
    player1.numberOfLoops = -1;//inifite loops
    self.myPlayer = player1;
    
    //record and play url
    NSString * urlString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    urlString = [urlString stringByAppendingString:myRecorderfile];
    NSLog(@"Recorder file path : %@",urlString);
    NSURL * url = [NSURL fileURLWithPath:urlString];
    self.recorderFileUrl = url;
    //recorder file player
    
    AVAudioPlayer * player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorderFileUrl error:nil];
    player2.numberOfLoops = -1;
    self.recorderFilePlayer = player2;

    
    ////////////////////////
    UILabel * label1 = [[UILabel alloc] initWithFrame:CGRectMake(_boundS.width/2-30/2-3-30, (_boundS.height/20)*4+5+15, 30, 30)];
    label1.text = @"00:";
    label1.textColor = [UIColor blackColor];
    label1.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview: label1];
    self.Label_hours = label1;
    
    UILabel * label2 = [[UILabel alloc] initWithFrame:CGRectMake(_boundS.width/2-30/2, (_boundS.height/20)*4+5+15, 30, 30)];
    label2.text = @"00:";
    label2.textColor = [UIColor blackColor];
    label2.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview: label2];
    self.Label_minutes = label2;
    
    UILabel * label3 = [[UILabel alloc] initWithFrame:CGRectMake(_boundS.width/2+30/2+3, (_boundS.height/20)*4+5+15, 30, 30)];
    label3.text = @"00";
    label3.textColor = [UIColor blackColor];
    label3.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview: label3];
    self.Label_seconds = label3;


    
    ///////////////////////////
    UITextField* Text_1 = [[UITextField alloc] initWithFrame:CGRectMake(_boundS.width/2-105/2, (_boundS.height/20)*2+5+5, 105, 30)];
    Text_1.placeholder = @"Miniutes";
    [Text_1 setBorderStyle:UITextBorderStyleRoundedRect];
    Text_1.backgroundColor = [UIColor whiteColor];
    [Text_1 setKeyboardType:UIKeyboardTypeNumberPad];
    Text_1.delegate = self;
    [self.view addSubview:Text_1];
    self.Text_M = Text_1;
    
    UITextField* Text_2 = [[UITextField alloc] initWithFrame:CGRectMake(_boundS.width/2-105/2, (_boundS.height/20), 105, 30)];
    Text_2.placeholder = @"Hours";
    Text_2.borderStyle = UITextBorderStyleRoundedRect;
    Text_2.backgroundColor = [UIColor whiteColor];
    [Text_2 setKeyboardType:UIKeyboardTypeNumberPad];
    Text_2.delegate = self;
    [self.view addSubview:Text_2];
    self.Text_H = Text_2;
    
    UIButton * Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    Btn.frame = CGRectMake(_boundS.width/2-46/2-3-46, (_boundS.height/20)*3+10+10, 46, 30);
    Btn.backgroundColor = [UIColor lightGrayColor];
    
    [Btn setTitle:@"save" forState:UIControlStateNormal];
    [Btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn addTarget:self action:@selector(clickBtn_Save) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn];
    self.Button_save = Btn;
    
    UIButton * Btn_Begin = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-46/2, (_boundS.height/20)*3+10+10, 46, 30)];
    Btn_Begin.backgroundColor = [UIColor lightGrayColor];
    [Btn_Begin setTitle:@"begin" forState:UIControlStateNormal];
    [Btn_Begin setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Begin setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Begin addTarget:self action:@selector(clickBtn_Begin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Begin];
    self.Button_begin = Btn_Begin;
    
    UIButton *Btn_Stop = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2+46/2+3, (_boundS.height/20)*3+10+10, 46, 30)];
    Btn_Stop.backgroundColor = [UIColor lightGrayColor];
    [Btn_Stop setTitle:@"stop" forState:UIControlStateNormal];
    [Btn_Stop setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Stop setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Stop addTarget:self action:@selector(clickBtn_Stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Stop];
    self.Button_stop = Btn_Stop;
    
    UIButton *Btn_Set = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-56/2,(_boundS.height/20)*5+20,56,30)];
    Btn_Set.backgroundColor = [UIColor lightGrayColor];
    [Btn_Set setTitle:@"setting" forState:UIControlStateNormal];
    [Btn_Set setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Set setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Set addTarget:self action:@selector(clickBtn_Setting) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Set];
    self.Button_setting = Btn_Set;
    
    //audio ssesion
    AVAudioSession *Session=[AVAudioSession sharedInstance];
   // [Session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [Session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [Session setActive:YES error:nil];
    self.audioSession = Session;
    
    }


///////////////////////////*Button click*///////////
- (void)clickBtn_Save {
    //init
    self.haveSaved = YES;
    self.hours = [self.Text_H.text intValue];
    self.min = [self.Text_M.text intValue];
    [self.myTimer setFireDate:[NSDate distantFuture]];//Stop timer
    
    //hours and minutes must in normal
    if ( [self.Text_M.text intValue] <0 || [self.Text_M.text intValue] >59  || [self.Text_H.text intValue] >23 || [self.Text_H.text intValue] <0) {
//        UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Please input 0-23 for Hours and input 0-59 for Minutes!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertV show];
        if ( !self.alertV1 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please input 0-23 for Hours and input 0-59 for Minutes!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV1 = alertV;

        }
        [self presentViewController:self.alertV1 animated:YES completion:nil];
        
        self.haveSaved = NO;
        _hours = 0;
        _min = 0;
    }
    //can not begin from 0
    if ( [self.Text_H.text intValue] == 0 &&  [self.Text_M.text intValue] == 0 ) {
//        UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"The timer can not begin from 0 and please input the integer!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertV show];
        if ( !self.alertV2 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"The timer can not begin from 0 and please input the integer!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV2 = alertV;
        }
        [self presentViewController:self.alertV2 animated:YES completion:nil];
        
        self.haveSaved = NO;
        _hours = 0;
        _min = 0;
    }
    //check if only input with number
    NSInteger hours_length = [self.Text_H.text length];
    NSInteger minutes_length = [self.Text_M.text length];
    NSLog(@"hours length : %ld",(long)hours_length);
    NSLog(@"minutes length : %ld",(long)minutes_length);
    for (NSInteger i = 0; i < hours_length; i++) {
        int hour_char = [self.Text_H.text characterAtIndex:i];
        if ( hour_char < 48 || hour_char >57 ) {
//            UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please input numbers!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertV show];
            if ( !self.alertV3 ) {
                UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please input numbers!"  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertV addAction:alertAction];
                self.alertV3 = alertV;
            }
            
            [self presentViewController:self.alertV3 animated:YES completion:nil];
            
            i = hours_length;
            //set can not be saved
            self.haveSaved = NO;
            _hours = 0;
            _min = 0;
        }
    }
    
    for (NSInteger i = 0; i < minutes_length; i++) {
        int minute_char = [self.Text_M.text characterAtIndex:i];
        if ( minute_char < 48 || minute_char >57 ) {
//            UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please input numbers!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertV show];
            if ( !self.alertV4 ) {
                UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please input numbers!"  preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertV addAction:alertAction];
                self.alertV4 = alertV;
            }
            
            [self presentViewController:self.alertV4 animated:YES completion:nil];
            
            
            i = minutes_length;
            //set can not be saved
            self.haveSaved = NO;
            _hours = 0;
            _min = 0;
        }
    }
    
    //total seconds
    self.totalSeconds = ( _hours * 3600 + _min * 60 ) ;
    NSLog(@"H:M = %ld:%ld -- %ld",(long)_hours,(long)_min,(long)_totalSeconds);
}

- (void) clickBtn_Begin {
    self.haveBegined = YES;
    
    if ( self.haveSaved == NO ) {
//        UIAlertView * alerV = [[UIAlertView alloc] initWithTitle:@"Atention" message:@"Please save the time point first!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alerV show];
        if ( !self.alertV5 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please save the time point first!"  preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV5 = alertV;
        }
        
        [self presentViewController:self.alertV5 animated:YES completion:nil];

        
        self.haveBegined = NO;
    }
    else {
        self.haveSaved = NO;
        [_myTimer setFireDate:[NSDate distantPast]];//begin timer
        NSLog(@"timer begin..");
        
        //playing while in background
        self.myPlayer.volume = 0;
        [self.recorderFilePlayer stop];
        [self.myPlayer stop];
        [self.myPlayer play];
        
    }
    
    //close key board
    [self.Text_H resignFirstResponder];
    [self.Text_M resignFirstResponder];
    
}

- (void) clickBtn_Stop {
    if ( self.haveBegined == YES ) {
        [_myTimer setFireDate:[NSDate distantFuture]];//stop timer
    
        self.Label_hours.text = [NSString stringWithFormat:@"00:"];
        self.Label_minutes.text = [NSString stringWithFormat:@"00:"];
        self.Label_seconds.text = [NSString stringWithFormat:@"00"];
    
        _Text_H.text = 0;
        _Text_M.text = 0;
    
        NSLog(@"Ring...Stop");
        
        //stop the background player
        [self.myPlayer stop];
        [self.recorderFilePlayer stop];
        
    }else if ( self.haveBegined == NO ) {
//        UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"Attention" message:@"Please begin the timer first then can stop it!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [alertV show];
        if ( !self.alertV6 ) {
            UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Please begin the timer first then can stop it!" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
            [alertV addAction:alertAction];
            self.alertV6 = alertV;
        }
        
        [self presentViewController:self.alertV6 animated:YES completion:nil];
    }
    self.haveBegined = NO;
}

//////////////////////////////////

- (void) clickBtn_Setting {
    [self presentViewController:self.SettingVC animated:YES completion:nil];
}

///////////////////////////*timer begin*///////////


- (void) timer {
        if ( _totalSeconds != 0 ) {
            NSLog(@"RemainTime...%7.f",[[UIApplication sharedApplication] backgroundTimeRemaining]);//remain time
            NSLog(@"Ring...%ld",(long)_totalSeconds);
            _totalSeconds = _totalSeconds - 1;
            [self timeCount];
            
        } else if ( _totalSeconds == 0 ) {
            [_myTimer setFireDate:[NSDate distantFuture]]; // end timer
            NSLog(@"Ring...0");
            NSLog(@"Ring...end..");
            [self timeCount];
            
            //play alarms and infinite playing until close the alert
            [self stopPlayAlarms];
            [self playAlarms];
//            UIAlertView * alertV = [[UIAlertView alloc] initWithTitle:@"" message:@"Timer Done" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//            [alertV show];
            if ( !self.alertV7 ) {
                UIAlertController * alertV = [UIAlertController alertControllerWithTitle:@"Attention" message:@"Timer Done" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction * alertAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self timerDoneAction];//when click the ok
                }];
                [alertV addAction:alertAction];
                
                self.alertV7 = alertV;
            }
            
            [self presentViewController:self.alertV7 animated:YES completion:nil];
        }
}

////////////////touch the screen then close the key board/////////
- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    UIView *view = touch.view;
    if ( view == self.view ) {
        [self.Text_H resignFirstResponder];
        [self.Text_M resignFirstResponder];
    }
}

/////////////////time counting///////////////////////////////////////
- (void) timeCount {
    _h = _totalSeconds/3600;
    _m = _totalSeconds%3600/60;
    _s = _totalSeconds%3600%60;
    
    self.Label_hours.text = [NSString stringWithFormat:@"%ld:",(long)_h];
    self.Label_minutes.text = [NSString stringWithFormat:@"%ld:",(long)_m];
    self.Label_seconds.text = [NSString stringWithFormat:@"%ld",(long)_s];

    //if the time<10,add a 0 to show well like 00:
    if ( _h < 10 ) {
        self.Label_hours.text = [NSString stringWithFormat:@"0%ld:",(long)_h];
    }
    
    if ( _m < 10 ) {
        self.Label_minutes.text = [NSString stringWithFormat:@"0%ld:",(long)_m];
    }
    
    if ( _s < 10 ) {
        self.Label_seconds.text = [NSString stringWithFormat:@"0%ld",(long)_s];
    }
}

/////////////////player method///////////////////////////////////////
- (void) playAlarms {
    if ( self.optionV == 1 ) {
        _myPlayer.volume = 1;
        [_myPlayer setCurrentTime:0];
        [_myPlayer play];
    }
    else if ( self.optionV == 2 ) {
        _recorderFilePlayer.volume = 1;
        [_recorderFilePlayer setCurrentTime:0];
        [_myPlayer stop];//stop the background playing
        [_recorderFilePlayer play];
    }
    else {
        NSLog(@"player begin error,because optionV is not default or custom");
        NSLog(@"optionV value : %ld",(long)self.optionV);
    }
}

- (void) stopPlayAlarms {
    if ( self.optionV == 1 ) {
        [_myPlayer stop];
    }
    else if ( self.optionV == 2 ) {
        [_recorderFilePlayer stop];
    }
    else {
        NSLog(@"player stop error,because optionV is not default or custom");
        NSLog(@"optionV value : %ld",(long)self.optionV);
    }
}

/////////////////play alert delegate //////////////////////////////
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndexal {
//    if ( buttonIndexal == 0 ) {
//        [self stopPlayAlarms];
//    }
//} // do not use this any more later than ios 9.0

- (void) timerDoneAction {
    [self stopPlayAlarms];
}

////////////pass value delegate from second VC////////////
- (void) passValue:(NSInteger)value {
    self.optionV = value;
    NSLog(@"optionValue : %ld",(long)_optionV);
}

- (void) passURLAgency:(NSURL *)url {
    self.recorderURL = url;
    
    //recorder file player
    if ( !self.recorderFilePlayer ) {
        AVAudioPlayer * player2 = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorderURL error:nil];
        player2.numberOfLoops = -1;
        self.recorderFilePlayer = player2;
    }
    
}

@end
