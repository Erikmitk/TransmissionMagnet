//
//  AppDelegate.m
//  TransmissionMagnet
//

#import "AppDelegate.h"

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];

    _sessionID = nil;

    [self prepareRequest];

}

- (void)prepareRequest
{
    _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:9091/transmission/rpc"]];
    [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [_request setHTTPMethod:@"POST"];
}

#pragma mark URL Event Handling

- (void)handleURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent
{
    [self prepareRequestData:event];
    [self setSessionIDandConnect];

}

- (void)prepareRequestData:(NSAppleEventDescriptor *)event
{
    NSString* magnetlink = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSString *bodyData = [[NSString alloc] initWithFormat:@"{\"method\":\"torrent-add\",\"arguments\":{\"paused\":\"false\",\"filename\":\"%@\"}}", magnetlink];
    [_request setHTTPBody:[NSData dataWithBytes:[bodyData UTF8String] length:[bodyData length]]];
}

- (void)setSessionIDandConnect
{
    [_request setValue:_sessionID forHTTPHeaderField:@"X-Transmission-Session-Id"];
    _connection = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(_sessionID == nil) {
        NSMutableString *session = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:@".*<code>X-Transmission-Session-Id: |</code>.*"
                                                                                            options:0
                                                                                              error:nil];

        _sessionID =  [[[NSMutableString alloc] initWithString:[regularExpression stringByReplacingMatchesInString:session
                                                                                                           options:0
                                                                                                             range:NSMakeRange(0, [session length])
                                                                                                      withTemplate:@""]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

       [self setSessionIDandConnect];

    }else{
        _sessionID = nil;
    }
}

#pragma mark NSApplicationDelegate

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    return NSTerminateNow;
}


@end
