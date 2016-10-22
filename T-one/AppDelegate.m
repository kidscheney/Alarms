//
//  AppDelegate.m
//  T-one
//
//  Created by Cheney on 9/13/15.
//  Copyright (c) 2015 Cheney. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

@interface AppDelegate ()
@property AVAudioPlayer * myPlayer;
@property NSTimer * myTimer;
@property NSInteger count;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
     //Override point for customization after application launch.
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self.window makeKeyAndVisible];
//    self.window.rootViewController = [[ViewController alloc] init];
    
    //bounds
    NSLog(@"Bound : %f,%f,%f,%f",[[UIScreen mainScreen] bounds].origin.x,[[UIScreen mainScreen] bounds].origin.y,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height);
    
//    //frame
//    CGPoint framePoint = [[UIScreen mainScreen] applicationFrame].origin;
//    CGSize  frameSize = [[UIScreen mainScreen] applicationFrame].size;
//    NSLog(@"Frame : %f,%f,%f,%f",framePoint.x,framePoint.y,frameSize.width,frameSize.height);
    
    NSLog(@"=========================");
    
    //init
    self.count = 60;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"will resign active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"did enter background");
    
    //need to play it here also when go to background,if not ,there is no sound out even the timer done while in background
    //
    AVAudioSession * sse = [AVAudioSession sharedInstance];
    [sse setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [sse setActive:YES error:nil];

    if ( !_myPlayer ) {
        self.myPlayer = [self playerInit];
    }
    self.myPlayer.volume = 0;
    [_myPlayer play];
    NSLog(@"background playing in app delegate : %d",[self.myPlayer isPlaying]);
    
//    if ( !_myTimer ) {
//        self.myTimer = [self timerInit];//for prevent the playing stopped as launch other music player
//    }
//    self.myTimer.fireDate = [NSDate distantPast];//begin timer
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"will enter foreground");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"did become active");
//    self.myTimer.fireDate = [NSDate distantFuture];//close the timer when in active
    [self.myPlayer stop];//stop the playing when in active
    NSLog(@"background playing in app delegate : %d",[self.myPlayer isPlaying]);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

////////player init and timer init
-(AVAudioPlayer * ) playerInit {
    NSString * path = [[NSBundle mainBundle] pathForResource:@"Alarms" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAudioPlayer * player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.numberOfLoops = -1;
    return player;
}

-(NSTimer * ) timerInit {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timer) userInfo:nil repeats:YES];
    timer.fireDate = [NSDate distantFuture];
    return timer;
}

////////timer
- (void) timer {
    NSLog(@"background timer: %ld",(long)_count--);
    if ( _count == 0 ) {
        _count = 60;
    }
    self.myPlayer.volume = 0;
    [_myPlayer play];
}

@end
