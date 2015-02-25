//
//  PedometerController.m
//  Rouster
//
//  Created by Rodrigo Carballo on 2/24/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "PedometerController.h"
@import CoreMotion;


@interface PedometerController ()

@property (assign) NSInteger stepsToday;

@end

@implementation PedometerController

CMPedometer *_stepCounter;
NSInteger _stepsToday;
NSInteger _stepsAtBeginOfLiveCounting;
BOOL _isLiveCounting;
NSOperationQueue *_stepQueue;

- (instancetype)initWithDateRangeStartingFrom:(NSDate *)startDate to:(NSDate *)endDate isToday:(BOOL)today
{
    self = [super init];
    
    if (self)
    {
        _stepCounter = [[CMPedometer alloc] init];
        _startDate = startDate;
        _endDate = endDate;
        _isToday = today;
        //self.stepsToday = -1;
        
        NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
        
        // subscribe to relevant notifications
//        [noteCenter addObserver:self selector:@selector(timeChangedSignificantly:) name:UIApplicationSignificantTimeChangeNotification object:nil];
        [noteCenter addObserver:self selector:@selector(willEnterForeground:)
                           name:UIApplicationWillEnterForegroundNotification
                         object:nil];
        [noteCenter addObserver:self selector:@selector(didEnterBackground:)
                           name:UIApplicationDidEnterBackgroundNotification
                         object:nil];
        
        // queue for step count updating
        _stepQueue = [[NSOperationQueue alloc] init];
        _stepQueue.maxConcurrentOperationCount = 1;
        
        // start counting
        [self _updateStepsTodayFromHistoryLive:YES];
    }
    
    return self;
}

- (void)dealloc
{
    // remove notification subscriptions
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


// queries the CMStepCounter history from midnight until now
- (void)_updateStepsTodayFromHistoryLive:(BOOL)startLiveCounting
{
    if (![CMStepCounter isStepCountingAvailable])
    {
        NSLog(@"Step counting not available on this device");
        
        //self.stepsToday = -1 as NSNumber;
        return;
    }
    
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *threeHoursFromNow;
    threeHoursFromNow = [calendar dateByAddingUnit:NSCalendarUnitHour
                                             value:3
                                            toDate:[NSDate date]
                                           options:kNilOptions];
  
   
   [ _stepCounter queryPedometerDataFromDate:now toDate:threeHoursFromNow withHandler:^(CMPedometerData *pedometerData, NSError *error) {
       
       if (error) {
           NSLog(@"Errors have occured");
       }
       else {
           NSNumber *myNum = [NSNumber numberWithInteger:self.stepsToday];
           myNum = pedometerData.numberOfSteps;
           
           if (startLiveCounting) {
               [self _startLiveCounting];
           }
           
       }
   }];
    
    
//    NSDate *beginOfDay = [calendar dateFromComponents:components];
    //NSdate *beginOfWakeUp =
    
//    [_stepCounter queryPedometerDataFromDate:beginOfDay
//                                          to:now
//                                 withHandler:^(NSInteger numberOfSteps, NSError *error) {
//                                     
//                                     if (error)
//                                     {
//                                         // note: CMErrorDomain, code 105 means not authorized
//                                         NSLog(@"%@", [error localizedDescription]);
//                                         self.stepsToday = -1;
//                                     }
//                                     else
//                                     {
//                                         self.stepsToday = numberOfSteps;
//                                         
//                                         if (startLiveCounting)
//                                         {
//                                             [self _startLiveCounting];
//                                         }
//                                     }
//                                 }];
}

- (void)_startLiveCounting
{
    if (_isLiveCounting)
    {
        return;
    }
    _isLiveCounting = YES;
    //_stepsAtBeginOfLiveCounting = self.stepsToday;
    _stepsAtBeginOfLiveCounting = 0;
//    [_stepCounter startStepCountingUpdatesToQueue:_stepQueue
//                                         updateOn:1
//                                      withHandler:^(NSInteger numberOfSteps, NSDate *timestamp, NSError *error) {
//                                          self.stepsToday = _stepsAtBeginOfLiveCounting
//                                          + numberOfSteps;
//                                      }];
    
    NSDate *now = [NSDate date];
    
    [_stepCounter startPedometerUpdatesFromDate:now withHandler:^(CMPedometerData *pedometerData, NSError *error) {
        
        NSInteger pedometerNumberSteps = [pedometerData.numberOfSteps integerValue];

        self.stepsToday = _stepsAtBeginOfLiveCounting + pedometerNumberSteps;
    }];
    
    NSLog(@"Started live step counting");
}

- (void)_stopLiveCounting
{
    if (!_isLiveCounting)
    {
        return;
    }
    
//    [_stepCounter stopStepCountingUpdates];
//    _isLiveCounting = NO;
    
    NSLog(@"Stopped live step counting");
}



#pragma mark - Notifications

- (void)timeChangedSignificantly:(NSNotification *)notification
{
    [self _stopLiveCounting];
    
    [self _updateStepsTodayFromHistoryLive:YES];
}

- (void)willEnterForeground:(NSNotification *)notification
{
    [self _updateStepsTodayFromHistoryLive:YES];
}

- (void)didEnterBackground:(NSNotification *)notification
{
    [self _stopLiveCounting];
}

@end
