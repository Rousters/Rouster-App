//
//  NetworkController.h
//  Rouster
//
//  Created by Eric Mentele on 2/25/15.
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


#import <UIKit/UIKit.h>

@interface NetworkController : NSObject

+(id)sharedService;
- (void)getUUID;
-(void)createUser;
-(void)alarmSet:(NSString*)alarmTime;
-(void)alarmConfirmed:(NSString *)alarmTime;
-(void)getScore:(void (^)(NSNumber *score, NSString *error))completionHandler;

@end
