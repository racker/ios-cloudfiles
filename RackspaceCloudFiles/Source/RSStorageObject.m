//
//  RSStorageObject.m
//  CloudFilesSDKDemo
//
//  Created by Mike Mayo on 10/27/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RSStorageObject.h"
#import "RSClient.h"

#define $S(format, ...) [NSString stringWithFormat:format, ## __VA_ARGS__]

@implementation RSStorageObject

@synthesize name, hash, bytes, content_type, last_modified, metadata, etag, data;
@synthesize publicURL, parentContainerName;

- (id)init {
    self = [super init];
    if (self) {
        self.metadata = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSDate *)last_modified_date {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'H:mm:ss.SSSSSS"];
	return [dateFormatter dateFromString:self.last_modified];
}

- (NSURLRequest *)getObjectDataRequest {
    NSURL *url = [NSURL URLWithString:$S(@"%@/%@/%@", self.publicURL, self.parentContainerName, self.name)];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:self.client.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return (NSURLRequest*)request;
}

- (void)getObjectData:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(getObjectDataRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *responseData, NSError *error) {

        self.etag = [[response allHeaderFields] valueForKey:@"ETag"];
        self.data = responseData;

        if (successHandler) {
            successHandler();
        }
        
    } failureHandler:failureHandler];
}

- (void)writeObjectDataToFile:(NSString *)path atomically:(BOOL)atomically success:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {

    [self.client sendAsynchronousRequest:@selector(getObjectDataRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *responseData, NSError *error) {

        self.etag = [[response allHeaderFields] valueForKey:@"ETag"];
        [responseData writeToFile:path atomically:atomically];

        if (successHandler) {
            successHandler();
        }
        
    } failureHandler:failureHandler];    
    
}

- (NSURLRequest *)getObjectMetadataRequest {
    NSURL *url = [NSURL URLWithString:$S(@"%@/%@/%@", self.publicURL, self.parentContainerName, self.name)];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request addValue:self.client.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    return (NSURLRequest*)request;
}

- (void)getMetadata:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(getObjectMetadataRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *responseData, NSError *error) {
        
        NSDictionary *headers = [response allHeaderFields];
        self.etag = [headers valueForKey:@"ETag"];
        self.content_type = [headers valueForKey:@"Content-Type"];

        for (NSString *key in headers) {
            if ([key hasPrefix:@"X-Object-Meta-"]) {
                [self.metadata setValue:[headers valueForKey:key] forKey:[key substringFromIndex:14]];
            }
            
        }

        if (successHandler) {
            successHandler();
        }
        
    } failureHandler:failureHandler];    
    
}

- (NSURLRequest *)updateMetadataRequest {
    NSURL *url = [NSURL URLWithString:$S(@"%@/%@/%@", self.publicURL, self.parentContainerName, self.name)];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request addValue:self.client.authToken forHTTPHeaderField:@"X-Auth-Token"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    for (NSString *key in self.metadata)
        [request addValue:[self.metadata valueForKey:key] forHTTPHeaderField:$S(@"X-Object-Meta-%@", key)];
    
    return request;
}

- (void)updateMetadata:(void (^)())successHandler failure:(void (^)(NSHTTPURLResponse*, NSData*, NSError*))failureHandler {
    
    [self.client sendAsynchronousRequest:@selector(updateMetadataRequest) sender:self successHandler:^(NSHTTPURLResponse *response, NSData *responseData, NSError *error) {
        if (successHandler) {
            successHandler();
        }
    } failureHandler:failureHandler];    

}


@end
