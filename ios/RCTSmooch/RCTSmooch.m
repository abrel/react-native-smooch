#import "RCTSmooch.h"

@implementation SmoochManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(init:(NSString*)appToken:(RCTResponseSenderBlock)callback) {
  NSLog(@"Init Smooch");

  [Smooch initWithSettings: [SKTSettings settingsWithAppToken:appToken]];
  [Smooch conversation].delegate = self;
  callback(@[]);
};

RCT_EXPORT_METHOD(show) {
  NSLog(@"Smooch Show");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch show];
  });
};

RCT_EXPORT_METHOD(login:(NSString*)userId jwt:(NSString*)jwt) {
  NSLog(@"Smooch Login");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch login:userId jwt:jwt];
  });
};

RCT_EXPORT_METHOD(logout) {
  NSLog(@"Smooch Logout");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch logout];
  });
};


RCT_EXPORT_METHOD(setUserProperties:(NSDictionary*)options) {
  NSLog(@"Smooch setUserProperties with %@", options);

  [[SKTUser currentUser] addProperties:options];
};

RCT_EXPORT_METHOD(track:(NSString*)eventName) {
  NSLog(@"Smooch track with %@", eventName);

  [Smooch track:eventName];
};

RCT_REMAP_METHOD(getUnreadCount,
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch getUnreadCount");

  long unreadCount = [Smooch conversation].unreadCount;
  resolve(@(unreadCount));
};

RCT_EXPORT_METHOD(setFirstName:(NSString*)firstName) {
  NSLog(@"Smooch setFirstName");

  [SKTUser currentUser].firstName = firstName;
};

RCT_EXPORT_METHOD(setLastName:(NSString*)lastName) {
  NSLog(@"Smooch setLastName");

  [SKTUser currentUser].lastName = lastName;
};

RCT_EXPORT_METHOD(setEmail:(NSString*)email) {
  NSLog(@"Smooch setEmail");

  [SKTUser currentUser].email = email;
};


RCT_EXPORT_METHOD(setSignedUpAt:(NSDate*)date) {
  NSLog(@"Smooch setSignedUpAt");

  [SKTUser currentUser].signedUpAt = date;
};

RCT_EXPORT_METHOD(sendMessage:(NSString*)message) {
    NSLog(@"Smooch sendMessage");

    [[Smooch conversation] sendMessage:[[SKTMessage alloc] initWithText:message]];
};

-(nullable SKTMessage *)conversation:(SKTConversation*)conversation willDisplayMessage:(SKTMessage *)message {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern:@"^@@@"
                                  options:0
                                  error:&error];

    NSUInteger numberOfMatches = [regex
                                  numberOfMatchesInString:message.text
                                  options:0
                                  range:NSMakeRange(0, [message.text length])];

    if (numberOfMatches > 0) {
        return nil;
    } else {
        return message;
    }
};

@end
