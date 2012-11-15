//
//  AppDelegate.h
//  TransmissionMagnet
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSURLConnectionDelegate>

@property NSString *sessionID;
@property NSURLConnection *connection;
@property NSMutableURLRequest *request;

@end
