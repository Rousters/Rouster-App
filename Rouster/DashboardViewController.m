//
//  DashboardViewController.m
//  Rouster
//
//  Created by Eric Mentele on 2/23/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "DashboardViewController.h"
#import "NetworkController.h"

@interface DashboardViewController ()
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@end

@implementation DashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [[NetworkController sharedService]getScore:^(NSNumber *score, NSString *error) {
    
    //double myscore = [score doubleValue];
    self.scoreLabel.text = [NSString stringWithFormat: @"%@%%", score];
    
  }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
