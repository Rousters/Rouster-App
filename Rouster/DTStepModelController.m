//
//  DTStepModelController.m
//  Rouster
//
//  Created by Rodrigo Carballo on 2/26/15.
//  Copyright (c) 2015 Rodrigo Carballo & Eric Mentele. All rights reserved.

/*
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "DTStepModelController.h"
#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>

@interface DTStepModelController ()

@property (assign) NSInteger stepsToday;

@end

@implementation DTStepModelController
{
    CMStepCounter *_stepCounter;
    NSInteger _stepsToday;
    NSInteger _stepsAtBeginOfLiveCounting;
    BOOL _isLiveCounting;
    NSOperationQueue *_stepQueue;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
    _stepCounter = [[CMStepCounter alloc] init];
    self.stepsToday = -1;
    
     NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
        
        // subscribe to relevant notifications
        [noteCenter addObserver:self selector:@selector(timeChangedSignificantly:)
                           name:UIApplicationSignificantTimeChangeNotification object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// queries the CMStepCounter history from midnight until now
- (void)_updateStepsTodayFromHistoryLive:(BOOL)startLiveCounting
{
    if (![CMStepCounter isStepCountingAvailable])
    {
        NSLog(@"Step counting not available on this device");
        
        self.stepsToday = -1;
        return;
    }
    
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit
                                    | NSMonthCalendarUnit
                                    | NSDayCalendarUnit
                                               fromDate:now];
    
    NSDate *beginOfDay = [calendar dateFromComponents:components];
    
    [_stepCounter queryStepCountStartingFrom:beginOfDay
                                          to:now
                                     toQueue:_stepQueue
                                 withHandler:^(NSInteger numberOfSteps,
                                               NSError *error) {
                                     
                                     if (error)
                                     {
                                         // note: CMErrorDomain, code 105 means not authorized
                                         NSLog(@"%@", [error localizedDescription]);
                                         self.stepsToday = -1;
                                     }
                                     else
                                     {
                                         self.stepsToday = numberOfSteps;
                                         
                                         if (startLiveCounting)
                                         {
                                             [self _startLiveCounting];
                                         }
                                     }
                                 }];
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
    [_stepCounter startStepCountingUpdatesToQueue:_stepQueue
                                         updateOn:1
                                      withHandler:^(NSInteger numberOfSteps,
                                                    NSDate *timestamp,
                                                    NSError *error) {
                                          self.stepsToday = _stepsAtBeginOfLiveCounting
                                          + numberOfSteps;
                                      }];
    
    NSLog(@"Started live step counting");
}

- (void)_stopLiveCounting
{
    if (!_isLiveCounting)
    {
        return;
    }
    
    [_stepCounter stopStepCountingUpdates];
    _isLiveCounting = NO;
    
    NSLog(@"Stopped live step counting");
}

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
