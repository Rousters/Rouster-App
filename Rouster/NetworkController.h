//
//  NetworkController.h
//  Rouster
//
//  Created by Eric Mentele on 2/25/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkController : NSObject

+(id)sharedService;
- (void)getUUID;
-(void)createUser:(void (^)(NSString *token, NSString *error))completionHandler;
@end
