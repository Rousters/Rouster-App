//
//  AlarmViewController.m
//  Rouster
//
//  Created by Eric Mentele on 2/23/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "AlarmViewController.h"
#import "SoundController.h"
#import <CoreLocation/CoreLocation.h>
#import "DTStepModelController.h"
#import "NetworkController.h"


@interface AlarmViewController () <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic  ) IBOutlet UIDatePicker    *timePicker;
@property (weak, nonatomic  ) IBOutlet UILabel         *commitmentLabel;
@property (strong, nonatomic) SoundController * soundController;
@property (weak, nonatomic  ) NSDate          * alarmTime;
@property (weak, nonatomic)   NSDate          * lastAlarm;
@property (weak, nonatomic  ) NSTimer         * checkTime;
@property (weak, nonatomic  ) NSTimer         * checkSteps;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) NSInteger globalSteps;

- (NSTimeInterval)timeIntervalSince1970;
@end

@implementation AlarmViewController
{
   DTStepModelController *_stepModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //MARK - ALL PEDOMETER MAGIC
    _stepModel = [[DTStepModelController alloc] init];
    
    [_stepModel addObserver:self forKeyPath:@"stepsToday"
                    options:NSKeyValueObservingOptionNew context:NULL];
    
    [self _updateSteps:_stepModel.stepsToday];
  
  [[NetworkController sharedService]createUser];
  
  self.soundController = [[SoundController alloc]init];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
    
    // Do any additional setup after loading the view.
  //Set time pickers default time position to the last selected time or the current time.
  self.lastAlarm = [[NSUserDefaults standardUserDefaults]
                          objectForKey:@"lastAlarm"];
  if (self.lastAlarm != nil) {

  self.timePicker.date = self.lastAlarm;
  } else {

  self.timePicker.date = [NSDate date];
  }//if else
}//viewDidLoad

- (void)dealloc
{
    [_stepModel removeObserver:self forKeyPath:@"stepsToday"];
}



#pragma mark - Set Alarm
- (IBAction)commitTime:(id)sender {
  
  //Format selected time to display to user  and set label text to it.
  NSDateFormatter *timeFormat = [[NSDateFormatter alloc]init];
  timeFormat.timeZone         = [NSTimeZone defaultTimeZone];
  timeFormat.timeStyle        = NSDateFormatterShortStyle;
  NSString *time              = [timeFormat stringFromDate:self.timePicker.date];
  NSString *committed         = @"Committed to: ";
  NSString *timeCommit        = [committed stringByAppendingString:time];
  self.commitmentLabel.text   = timeCommit;
  //Clear last allarm
  //[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"lastAlarm"];
  //Save selected time.
  [[NSUserDefaults standardUserDefaults] setObject:self.timePicker.date forKey:@"lastAlarm"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  self.lastAlarm = [[NSUserDefaults standardUserDefaults]objectForKey:@"alarmTime"];
  self.alarmTime = self.timePicker.date;
  self.checkTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(triggerAlarm:) userInfo:nil repeats:true];
  NSLog(@"%@", self.alarmTime);
  
  NSDate *dateToConvertForDB = self.timePicker.date;
  NSString *dateForDB = [NSString stringWithFormat:@"%.0f", [dateToConvertForDB timeIntervalSince1970]];
  
  [[NetworkController sharedService]alarmSet:dateForDB];
    
  
}//commitTime

-(void) checkSteps:(NSTimer *)stepsCheck {
    [self.soundController playSound];
    
    if (self.globalSteps >= 30) {
        NSLog(@"I have moved over 30 steps");
        [self.soundController stopSound];
        [self.checkTime invalidate];
        
        UIAlertController* alertSteps = [UIAlertController alertControllerWithTitle:@"Roust!"
                                                                       message:@"Congratulations you have moved over 30 steps.  Enjoy your day"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"Good Bye" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            
                                                            //[self.soundController stopSound];
                                                    [self.checkSteps invalidate];
                                                            
                                                        }];
        
        [alertSteps addAction:confirm];
        [self presentViewController:alertSteps animated:YES completion:nil];
        //[self.checkSteps invalidate];

    }
 
}

#pragma mark - Trigger Alarm
//Check for match every 60 seconds. Fire alarm when match exists.
-(void) triggerAlarm:(NSTimer *)timeCheck {
    
    
  
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Roust!"
                                                                 message:@"Welcome to your future. Walk away 30 steps from your location to confirm alarm. We are watching so don't go back to bed"
                                                          preferredStyle:UIAlertControllerStyleAlert];
    
 
  
  UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self.checkTime invalidate];
                                                     
                                                 }];

    [alert addAction:confirm];
    
    
    
  
  NSLog(@"Checking time");
  if ([NSDate date] >= self.alarmTime) {
    
    //[self.soundController playSound];
    NSLog(@"WAKE UP!!!!!!!");
    [self presentViewController:alert animated:YES completion:nil];
      
      self.checkSteps = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkSteps:) userInfo:nil repeats:true];
      
      
  } 
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
  
}//didRecieveMemoryWarning

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Pedometer Section

- (void)_updateSteps:(NSInteger)steps
{
    // force main queue for UIKit
    dispatch_async(dispatch_get_main_queue(), ^{
        if (steps>=0)
        {
            self.globalSteps = steps;
            self.stepsLabel.text = [NSString stringWithFormat:@"%ld",
                                    (long)self.globalSteps];
            self.stepsLabel.textColor = [UIColor colorWithRed:0
                                                        green:0.8
                                                         blue:0
                                                        alpha:1];
            
        }
        else
        {
            self.stepsLabel.text = @"Not available";
            self.stepsLabel.textColor = [UIColor redColor];
        }
    });

}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self _updateSteps:_stepModel.stepsToday];
}




@end
