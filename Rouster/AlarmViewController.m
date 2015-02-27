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
@property (strong, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic  ) IBOutlet UILabel         *commitmentLabel;
@property (strong, nonatomic) SoundController * soundController;
@property (weak, nonatomic  ) NSDate          * alarmTime;
@property (weak, nonatomic)   NSDate          * lastAlarm;
@property (weak, nonatomic  ) NSTimer         * checkTime;
@property (weak, nonatomic  ) NSTimer         * checkSteps;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) NSInteger globalSteps;

@end

@implementation AlarmViewController
{
   DTStepModelController *_stepModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.stepsLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.commitmentLabel setFont:[UIFont boldSystemFontOfSize:24]];
    
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Clock.png"]]];
    
    
    [self.timePicker setMinimumDate:[NSDate date]];
    //MARK - ALL PEDOMETER MAGIC
    _stepModel = [[DTStepModelController alloc] init];
    
    [_stepModel addObserver:self forKeyPath:@"stepsToday"
                    options:NSKeyValueObservingOptionNew context:NULL];
    
    [self _updateSteps:_stepModel.stepsToday];
  
  [[NetworkController sharedService]getUUID];
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
  
    
    if (self.globalSteps >= 15) {
      
      
      
      self.globalSteps = 0;
      self.stepsLabel.text = [NSString stringWithFormat:@"%ld",
                              (long)self.globalSteps];
      [self.checkSteps invalidate];
      [stepsCheck invalidate];
        NSLog(@"I have moved over 15 steps");
      [self.soundController stopSound];
      
      
        UIAlertController* alertSteps = [UIAlertController alertControllerWithTitle:@"Roust!"
                                                                       message:@"Congratulations you have moved over 15 steps.  Enjoy your day"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"Good Bye" style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action) {
                                                            
                                                            //[self.soundController stopSound];
                                                          self.globalSteps = 0;
                                                          NSDate *dateToConvertForDB = [NSDate date];
                                                          NSString *dateForDB = [NSString stringWithFormat:@"%.0f", [dateToConvertForDB timeIntervalSince1970]];
                                                          [[NetworkController sharedService]alarmConfirmed:dateForDB];
                                                          [self dismissViewControllerAnimated:alertSteps completion:nil];
                                                        }];
        
        [alertSteps addAction:confirm];
      
        [self presentViewController:alertSteps animated:YES completion:nil];
      
      
     
      
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
                                                   
                                                   [self dismissViewControllerAnimated:alert completion:nil];
                                                 }];

    [alert addAction:confirm];
    
    
    
  
  NSLog(@"Checking time");
  if ([NSDate date] >= self.alarmTime) {
    [self.checkTime invalidate];
    [timeCheck invalidate];
    //[self.soundController playSound];
    NSLog(@"WAKE UP!!!!!!!");
    [self presentViewController:alert animated:YES completion:nil];
      
      self.checkSteps = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkSteps:) userInfo:nil repeats:true];
      [self.soundController playSound];
      
  }//if time
}//trigger alarm


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
                                                        green:0
                                                         blue:5
                                                        alpha:3];
            
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
