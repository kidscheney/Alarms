//
//  RecordViewController.h
//  T-one
//
//  Created by Cheney on 11/8/15.
//  Copyright © 2015 Cheney. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordFilePathPassDelegate

- (void) passPath:(NSURL*) url;
@end


@interface RecordViewController : UIViewController

@property id <RecordFilePathPassDelegate> delegate;

@end

