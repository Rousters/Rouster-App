//
//  AlarmViewController.m
//  Rouster
//
//  Created by Eric Mentele on 2/23/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "AlarmViewController.h"

@interface AlarmViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UILabel *commitmentLabel;

@end

@implementation AlarmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  //Set time pickers default time position to the last selected time or the current time.
  NSDate *lastAlarm = [[NSUserDefaults standardUserDefaults]
                          objectForKey:@"alarmTime"];
  if (lastAlarm != nil) {
    
  self.timePicker.date =  lastAlarm;
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
  [[NSUserDefaults standardUserDefaults] setObject:self.timePicker.date forKey:@"alarmTime"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
}//commitTime



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

@end
