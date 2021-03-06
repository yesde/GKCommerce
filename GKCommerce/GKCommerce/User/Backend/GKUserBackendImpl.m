//
//  GKUserBackendImpl.m
//  GKCommerce
//
//  Created by 小悟空 on 1/15/15.
//  Copyright (c) 2015 GKCommerce. All rights reserved.
//

#import "GKUserBackendImpl.h"

@implementation GKUserBackendImpl

- (id)init
{
    self = [super init];
    if (self) {
        self.assembler = [[GKUserAssembler alloc] init];
    }
    return self;
}

- (RACSignal *)requestAuthenticate:(UserAuthenticationModel *)user
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"grant_type"]       = @"password";
    parameters[@"username"]         = user.username;
    parameters[@"password"]         = user.password;
    parameters[@"client_id"]        = @"swagger";
    parameters[@"client_secret"]    = @"swagger";
  
  // TODO: 格式化
    @weakify(self)
    return
    [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        [self.manager
         POST:self.config.OAuthAccessTokenURL
         parameters:parameters
         success:^(AFHTTPRequestOperation *operation,
                   id responseObject) {
           DDLogVerbose(@"did request authenticate success.");
             [subscriber sendNext:
              [self.assembler accessTokenWithAuthenticate:responseObject]];
         } failure:^(AFHTTPRequestOperation *operation,
                     NSError *error) {
           DDLogError(@"%@", error.localizedDescription);
             [subscriber sendError:error];
           [subscriber sendCompleted];
         }];
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
}

- (RACSignal *)requestUser:(GKUserAccessToken *)accessToken
{
  NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
  parameters[@"access_token"] = accessToken.accessToken;
  @weakify(self)
  return
  [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
    @strongify(self)
    [self.manager
     GET:[NSString stringWithFormat:@"%@/user/1", self.config.backendURL]
     parameters:parameters
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
       [subscriber sendNext:[self.assembler user:responseObject]];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       DDLogError(operation.responseString);
       [subscriber sendError:error];
     }];
        
    return [RACDisposable disposableWithBlock:^{ }];
  }];
}
@end
