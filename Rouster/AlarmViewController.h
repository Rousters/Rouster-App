//
//  AlarmViewController.h
//  Rouster
//
//  Created by Eric Mentele on 2/23/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmViewController : UIViewController

-(void) triggerAlarm:(NSTimer*)timeCheck;
-(void) checkSteps:(NSTimer *)stepsCheck;
@end
