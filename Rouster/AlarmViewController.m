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

@interface AlarmViewController () 

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UILabel *commitmentLabel;
@property (weak, nonatomic) NSDate *alarmTime;
@property (weak, nonatomic) NSTimer *checkTime;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (nonatomic) NSInteger stepsToday;

@end

@implementation AlarmViewController
{
    PedometerController *_stepModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
  self.soundController = [[SoundController alloc]init];
    _stepModel = [[PedometerController alloc] init];
    
    [_stepModel addObserver:self forKeyPath:@"stepsToday" options:NSKeyValueObservingOptionNew context:NULL];
    
    [self _updateSteps:_stepModel.stepsToday];
    
    // Do any additional setup after loading the view.
  //Set time pickers default time position to the last selected time or the current time.
  self.alarmTime = [[NSUserDefaults standardUserDefaults]
                          objectForKey:@"alarmTime"];
  if (self.alarmTime != nil) {
    
  self.timePicker.date =  self.alarmTime;
  } else {
    
    self.timePicker.date = [NSDate date];
  }//if else
  
}//viewDidLoad



#pragma mark - Set Alarm
- (IBAction)commitTime:(id)sender {
  
  //Format selected time to display to user  and set label text to it.
  NSDateFormatter *timeFormat = [[NSDateFormatter alloc]init];
  timeFormat.timeZone = [NSTimeZone defaultTimeZone];
  timeFormat.timeStyle = NSDateFormatterShortStyle;
  NSString *time = [timeFormat stringFromDate:self.timePicker.date];
  NSString *committed = @"Committed to: ";
  NSString *timeCommit = [committed stringByAppendingString:time];
  self.commitmentLabel.text = timeCommit;
  //Save selected time.
  self.alarmTime = [[NSUserDefaults standardUserDefaults]
                    objectForKey:@"alarmTime"];
  [[NSUserDefaults standardUserDefaults] setObject:self.timePicker.date forKey:@"alarmTime"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  self.checkTime = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(triggerAlarm:) userInfo:nil repeats:true];
  NSLog(@"%@", self.alarmTime);
  
  //Test audio player:
  
}//commitTime


#pragma mark - Trigger Alarm
//Check for match every 60 seconds. Fire alarm when match exists.
-(void) triggerAlarm:(NSTimer *)timeCheck {
  
  NSDate *currentTime = [NSDate date];
  NSLog(@"checking for time");

  if (currentTime >= self.alarmTime) {
    
    [self.soundController playSound];
    NSLog(@"WAKE UP!!!!!!!");
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
