//
//  RSCDNContainer.m
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/27/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSCDNContainer.h"
#import "RSStorageObject.h"
#import "RSClient.h"

#define $S(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]

@implementation RSCDNContainer

@synthesize name, cdn_enabled, ttl, log_retention, cdn_uri, cdn_ssl_uri, cdn_streaming_uri, metadata, publicURL;

- (id)init {
    self = [super init];
    if (self) {
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSURLRequest *)purgeCDNObjectRequest:(RSStorageObject *)object {
    
    NSURL *url = [NSURL URLWithString:$S(@"%@/%@/%@", self.publicURL, self.name, object.name)];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request addValue:self.client.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return (NSURLRequest*)request;
}

- (NSURLRequest *)purgeCDNObjectRequest:(RSStorageObject *)object emailAddresses:(NSArray *)emailAddresses {
    
    NSURL *url = [NSURL URLWithString:$S(@"%@/%@/%@", self.publicURL, self.name, object.name)];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request addValue:self.client.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[emailAddresses componentsJoinedByString:@", "] forHTTPHeaderField:@"X-Purge-Email"];
    return (NSURLRequest*)request;
}

- (void)purgeCDNObject:(RSStorageObject *)object success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client _sendAsynchronousRequest:@selector(purgeCDNObjectRequest:) object:object sender:self successHandler:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        if (successHandler) {
            successHandler();        
        }
    } failureHandler:failureHandler];
    
}

@end
