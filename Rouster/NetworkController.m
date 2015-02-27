//
//  NetworkController.m
//  Rouster
//
//  Created by Eric Mentele on 2/25/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "NetworkController.h"

@interface NetworkController ()


@property (weak,nonatomic)NSString *deviceId;

@end

@implementation NetworkController

+(id)sharedService {
  
  static NetworkController *mySharedService;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    
    mySharedService                 = [[NetworkController alloc] init];
  });//dispatch once
  return mySharedService;
}//shared service singleton


- (void)getUUID {
  
  NSString *id = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUUID"];
  if (id == nil) {
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    
    id = [NSString stringWithFormat:@"%@", uuidStr];
    [[NSUserDefaults standardUserDefaults] setObject:id forKey:@"deviceUUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}


-(void)createUser:(void (^)(NSString *token, NSString *error))completionHandler {
  
  NSString *localToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
  if (localToken == nil) {
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUUID"];

    NSDictionary *userDict = @{@"id":userId};
    //NSLog(@"%@", userString);
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&error];

    if (jsonData) {
      
          NSLog(@"user dictionary = %@", jsonData.description);
      
    } else {
      NSLog(@"Unable to serialize the data %@: %@", userDict, error);
    }
    
    NSString *urlString             = @"http://rouster.herokuapp.com/create_user";
    NSURL *url                      = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request    = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:jsonData];

    NSURLSession *session           = [NSURLSession sharedSession];
    
    NSURLSessionTask *dataTask      = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      
      if (error) {
        NSLog(@"could not connet %@",error.description);
        completionHandler(nil,@"Could not connect because %@");
      } else {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode            = httpResponse.statusCode;
        NSLog(@"the status code for post was %lu", statusCode);
        NSLog(@"the responce was %@", httpResponse.description);
        switch (statusCode) {
            
          case 200 ... 299: {
           
//           NSLog(@"the status code was %ld",(long)statusCode);
//            
            //NSData* tokenData = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
//            NSLog(@"%@",tokenDict);
            break;
          }//case 200..299
          default:
            NSLog(@"%ld",(long)statusCode);
            break;
        }//switch
      }//if else
    }];//data task
    [dataTask resume];
//
  }
  
  
}

@end
