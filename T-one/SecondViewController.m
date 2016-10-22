//
//  SecondViewController.m
//  T-one
//
//  Created by Cheney on 10/25/15.
//  Copyright © 2015 Cheney. All rights reserved.
//

#import "SecondViewController.h"
//////ENUM for option value
typedef NS_ENUM ( NSInteger,OptionType ) {
    defaultValue = 1,
    customValue = 2,
};

//////delegate for pass value from secondviewcontroller to first view controller

@interface SecondViewController () <RecordFilePathPassDelegate>

@property UIButton * Button_Back;
@property UIButton * Button_Option;
@property UIButton * BUtton_Record;

@property UIAlertController * alertC_Option;

@property NSInteger optionValue;
@property RecordViewController * RecordVC;

@property NSURL * recURL;

@property CGPoint boundP;
@property CGSize boundS;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initial];
}

//////////////init///////////
- (void) initial {
        
    //optionValue default is 1,custom is 2
    self.optionValue = defaultValue;
    self.boundP = [[UIScreen mainScreen] bounds].origin;
    self.boundS = [[UIScreen mainScreen] bounds].size;
    
    //set background color
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    //button
    UIButton* Btn_back = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-53/2,(_boundS.height/20)*3,53,30)];
    Btn_back.backgroundColor = [UIColor lightGrayColor];
    [Btn_back setTitle:@"back" forState:UIControlStateNormal];
    [Btn_back setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_back setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_back addTarget:self action:@selector(clickBtn_Back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_back];
    self.Button_Back = Btn_back;
    
    UIButton * Btn_Option = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2-3-53, (_boundS.height/20)*2, 53, 30)];
    Btn_Option.backgroundColor = [UIColor lightGrayColor];
    [Btn_Option setTitle:@"option" forState:UIControlStateNormal];
    [Btn_Option setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Option setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Option addTarget:self action:@selector(clickBtn_Option) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Option];
    self.Button_Option = Btn_Option;
    
    UIButton* Btn_Record = [[UIButton alloc] initWithFrame:CGRectMake(_boundS.width/2+3, (_boundS.height/20)*2, 53, 30)];
    Btn_Record.backgroundColor = [UIColor lightGrayColor];
    [Btn_Record setTitle:@"record" forState:UIControlStateNormal];
    [Btn_Record setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [Btn_Record setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [Btn_Record addTarget:self action:@selector(clickBtn_Record) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:Btn_Record];
    self.BUtton_Record = Btn_Record;
    
    //alert controller
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Option" message:@"Choose the alarm" preferredStyle:UIAlertControllerStyleActionSheet];
    self.alertC_Option = alertC;
    
    UIAlertAction * cancelAlert = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction * defaultAlert = [UIAlertAction actionWithTitle:@"default" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self defaultOption];
    }];
    UIAlertAction * customAlert = [UIAlertAction actionWithTitle:@"custom" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self customOption];
    }];
    
    [alertC addAction:cancelAlert];
    [alertC addAction:defaultAlert];
    [alertC addAction:customAlert];
    
    //////Record view controller
    RecordViewController *RecordViewC = [[RecordViewController alloc] init];
    RecordViewC.delegate = self;
    self.RecordVC = RecordViewC;
    
}

///////////////button click/////////////
- (void) clickBtn_Back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) clickBtn_Option {
    [self presentViewController:self.alertC_Option animated:YES completion:nil];
}

- (void) clickBtn_Record {
    [self presentViewController:self.RecordVC animated:YES completion:nil];
}

///////////////action sheet option method/////////
- (void) defaultOption {
    self.optionValue = defaultValue;
    [_delegate passValue:_optionValue];
    //NSLog(@"optionValue : %ld",_optionValue);
}

- (void) customOption {
    self.optionValue = customValue;
    [_delegate passValue:_optionValue];
    //NSLog(@"optionValue : %ld",_optionValue);
}

///////////recorder VC delegate ////////
- (void) passPath:(NSURL *)url {
    self.recURL = url;
    [_delegate passURLAgency:self.recURL];
}

@end
