//
//  AlarmViewController.m
//  Rouster
//
//  Created by Eric Mentele on 2/23/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "AlarmViewController.h"
#import "PedometerController.h"
#import "SoundController.h"
#import "NetworkController.h"
@interface AlarmViewController () 

@property (weak, nonatomic  ) IBOutlet UIDatePicker    *timePicker;
@property (weak, nonatomic  ) IBOutlet UILabel         *commitmentLabel;
@property (weak, nonatomic  ) IBOutlet UILabel         *stepsLabel;
@property (strong, nonatomic) SoundController * soundController;
@property (weak, nonatomic  ) NSDate          * alarmTime;
@property (weak, nonatomic)   NSDate          * lastAlarm;
@property (weak, nonatomic  ) NSTimer         * checkTime;

@end

@implementation AlarmViewController
{
    PedometerController *_stepModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
  [[NetworkController sharedService]createUser:^(NSString *token, NSString *error) {
    
  
    //[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"%@",token);
  }];
  
  self.soundController = [[SoundController alloc]init];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    _stepModel = [[PedometerController alloc] init];
    
    [_stepModel addObserver:self forKeyPath:@"stepsToday" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self _updateSteps:_stepModel.stepsToday];
    
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
  
}//commitTime


#pragma mark - Trigger Alarm
//Check for match every 60 seconds. Fire alarm when match exists.
-(void) triggerAlarm:(NSTimer *)timeCheck {
  
  UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Roust!"
                                                                 message:@"Welcome to your future. Walk away from bed to confirm alarm. We are watching so don't go back to bed"
                                                          preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction* confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                   
                                                   [self.soundController stopSound];
                                                   [self.checkTime invalidate];
                                                   [timeCheck invalidate];
                                                 }];
  [alert addAction:confirm];
  
  NSLog(@"Checking time");
  if ([NSDate date] >= self.alarmTime) {
    
    [self.soundController playSound];
    NSLog(@"WAKE UP!!!!!!!");
    [self presentViewController:alert animated:YES completion:nil];
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
            self.stepsLabel.text = [NSString stringWithFormat:@"%ld",
                                    (long)steps];
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

- (void)dealloc
{
    [_stepModel removeObserver:self forKeyPath:@"stepsToday"];
}

#pragma mark - Notifications

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self _updateSteps:_stepModel.stepsToday];
}



@end
