//
//  SecondViewController.h
//  T-one
//
//  Created by Cheney on 10/25/15.
//  Copyright © 2015 Cheney. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecordViewController.h"

@protocol PassValueDelegate

- (void)passValue:(NSInteger) value;
- (void)passURLAgency: (NSURL*) url;

@end


@interface SecondViewController : UIViewController

@property id <PassValueDelegate> delegate;

@end
