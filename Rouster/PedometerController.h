//
//  PedometerController.h
//  Rouster
//
//  Created by Rodrigo Carballo on 2/24/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PedometerController : NSObject

@property (readonly, nonatomic) NSDate *startDate;
@property (readonly, nonatomic) NSDate *endDate;
@property (readonly, nonatomic) BOOL isToday;
@property (nonatomic) NSInteger stepsToday;

@end
