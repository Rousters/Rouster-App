//
//  NetworkController.m
//  Rouster
//
//  Created by Eric Mentele on 2/25/15.
//  Copyright (c) 2015 Eric Mentele. All rights reserved.
//

#import "NetworkController.h"

@interface NetworkController ()


//@property (weak,nonatomic)NSString *deviceId;

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
  
  NSMutableString *tempId = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUUID"];
  if (tempId == nil) {
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    
    tempId = [NSMutableString stringWithFormat:@"%@", uuidStr];
    [[NSUserDefaults standardUserDefaults] setObject:tempId forKey:@"deviceUUID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}


-(void)createUser {
  
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
        NSLog(@"could not connect %@",error.description);
              } else {

        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode            = httpResponse.statusCode;
        NSLog(@"the status code for post was %lu", statusCode);
        NSLog(@"the response was %@", httpResponse.description);
        switch (statusCode) {
            
          case 200 ... 299: {
           
            if (data != nil) {
              
              //NSDictionary *jsonDict = [[NSDictionary alloc]init];
              NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSString *token = jsonDict[@"eat"];
              [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
              [[NSUserDefaults standardUserDefaults] synchronize];
            }
            break;
          }//case 200..299
          default:
            NSLog(@"%ld",(long)statusCode);
            break;
        }//switch
      }//if else
    }];//data task
    [dataTask resume];
  }//if local token
}//create user



-(void)alarmSet:(NSString*)alarmTime {
  
  
  NSString *localToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
  if (localToken != nil) {
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUUID"];
    
    NSDictionary *userDict = @{@"id":userId,@"time":alarmTime};
    //NSLog(@"%@", userString);
  
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&error];
    
    if (jsonData) {
      
      NSLog(@"user dictionary = %@", jsonData.description);
      
    } else {
      NSLog(@"Unable to serialize the data %@: %@", userDict, error);
    }
    
    NSString *urlString             = @"http://rouster.herokuapp.com/create_alarm";
    NSURL *url                      = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request    = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
    [request setValue:localToken forHTTPHeaderField:@"eat"];
    
    [request setHTTPBody:jsonData];
    
    NSURLSession *session           = [NSURLSession sharedSession];
    
    NSURLSessionTask *dataTask      = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      
      if (error) {
        NSLog(@"could not connet %@",error.description);
      } else {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSInteger statusCode            = httpResponse.statusCode;
        NSLog(@"the status code for post was %lu", statusCode);
        NSLog(@"the response was %@", httpResponse.description);
        switch (statusCode) {
            
          case 200 ... 299: {
            
            if (data != nil) {
              
              NSLog(@"%@",data.description);
            }
            break;
          }//case 200..299
          default:
            NSLog(@"%ld",(long)statusCode);
            break;
        }//switch
      }//if else
    }];//data task
    [dataTask resume];
  }//if token nil
}//alarmSet



-(void)alarmConfirmed:(NSString *)wakeTime {
  
  
  NSString *localToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
  if (localToken != nil) {
  
  NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceUUID"];
  
  NSDictionary *userDict = @{@"id":userId,@"wakeTime":wakeTime};
  //NSLog(@"%@", userString);
  
  NSError *error = nil;
  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict options:0 error:&error];
  
  if (jsonData) {
    
    NSLog(@"user dictionary = %@", jsonData.description);
    
  } else {
    NSLog(@"Unable to serialize the data %@: %@", userDict, error);
  }
  
  NSString *urlString             = @"http://rouster.herokuapp.com/check_alarm";
  NSURL *url                      = [NSURL URLWithString:urlString];
  
  NSMutableURLRequest *request    = [[NSMutableURLRequest alloc] initWithURL:url];
  [request setHTTPMethod:@"PATCH"];
  [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:localToken forHTTPHeaderField:@"eat"];
  [request setHTTPBody:jsonData];
  
  
  NSURLSession *session           = [NSURLSession sharedSession];
  
  NSURLSessionTask *dataTask      = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    if (error) {
      NSLog(@"could not connet %@",error.description);
    } else {
      
      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
      NSInteger statusCode            = httpResponse.statusCode;
      NSLog(@"the status code for post was %lu", statusCode);
      NSLog(@"the response was %@", httpResponse.description);
      switch (statusCode) {
          
        case 200 ... 299: {
          
          if (data != nil) {
            
            NSLog(@"%@",data.description);
          }
          break;
        }//case 200..299
        default:
          NSLog(@"%ld",(long)statusCode);
          break;
      }//switch
    }//if else
  }];//data task
  [dataTask resume];
  }//if token nil
}//alarm confirmed

@end
