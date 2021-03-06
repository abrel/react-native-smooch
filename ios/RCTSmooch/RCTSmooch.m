#import "RCTSmooch.h"

@implementation SmoochManager

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(init:(NSString*)appId:(RCTResponseSenderBlock)callback) {
  NSLog(@"Init Smooch");
  [Smooch destroy];
  [Smooch initWithSettings:[SKTSettings settingsWithAppId:appId] completionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
    [Smooch conversation].delegate = self;
    callback(@[]);
  }];
};

RCT_EXPORT_METHOD(show) {
  NSLog(@"Smooch Show");

  dispatch_async(dispatch_get_main_queue(), ^{
    [Smooch show];
  });
};

RCT_EXPORT_METHOD(login:(NSString*)userId jwt:(NSString*)jwt resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch Login");

  dispatch_async(dispatch_get_main_queue(), ^{
      [Smooch login:userId jwt:jwt completionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
          if (error) {
              reject(
                 userInfo[SKTErrorCodeIdentifier],
                 userInfo[SKTErrorDescriptionIdentifier],
                 error);
          }
          else {
              resolve(userInfo);
          }
      }];
  });
};

RCT_EXPORT_METHOD(logout:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch Logout");

  dispatch_async(dispatch_get_main_queue(), ^{
      [Smooch logoutWithCompletionHandler:^(NSError * _Nullable error, NSDictionary * _Nullable userInfo) {
          if (error) {
              reject(
                     userInfo[SKTErrorCodeIdentifier],
                     userInfo[SKTErrorDescriptionIdentifier],
                     error);
          }
          else {
              resolve(userInfo);
          }
      }];
  });
};


RCT_EXPORT_METHOD(setUserProperties:(NSDictionary*)options) {
  NSLog(@"Smooch setUserProperties with %@", options);

  [[SKTUser currentUser] addProperties:options];
};

RCT_EXPORT_METHOD(getUserId:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSLog(@"Smooch getUserId");

  resolve([SKTUser currentUser].userId);
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
    if (!message.text) {
        // do not touch photos
        return message;
    }

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
