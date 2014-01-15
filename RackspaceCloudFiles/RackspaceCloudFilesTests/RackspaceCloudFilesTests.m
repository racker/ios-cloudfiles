//
//  RackspaceCloudFilesTests.m
//  RackspaceCloudFilesTests
//
//  Created by Mike Mayo on 11/1/11.
//  Copyright (c) 2011 Rackspace. All rights reserved.
//

#import "RackspaceCloudFilesTests.h"
#import "RSClient.h"

@implementation RackspaceCloudFilesTests

//@synthesize client, container, object, waiting, timeoutFailureString;

#pragma mark - Utilities

- (void)waitForTestCompletion {
	NSTimeInterval startTime = [[NSDate date] timeIntervalSinceReferenceDate];
	while (self.waiting) {		
		[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		// Don't let the download take longer than we're allowed
		NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceReferenceDate] - startTime;
		if (elapsedTime > (30.0)) {
			NSString* failContext = [self timeoutFailureString];
			if (failContext == nil) {
				failContext = @"Timed out trying to perform test.";
			}
			NSString* testFailString = [NSString stringWithFormat:@"%@ %@", failContext, @"DCJ - Get more info about the running test in here?"];
            STFail(testFailString);
			self.waiting = NO;
			break;
		}
	}
}

- (void)resetWaiting {
    self.waiting = YES;
}


- (void)stopWaiting {
    self.waiting = NO;
}

- (void)createContainer {
    [self resetWaiting];
    RSContainer *c = [[RSContainer alloc] init];
    c.name = @"RSCloudFilesSDK-Test";
    [self.client createContainer:c region:@"SYD" success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"(setup)createContainer failed.");
    }];
    [self waitForTestCompletion];
}

- (void)loadContainer {
    [self resetWaiting];
    void(^mycallback)(NSMutableArray*, NSArray*) = ^(NSMutableArray* errors, NSArray* containers)
    {
        for (RSContainer *c in containers)
            if ([c.name isEqualToString:@"RSCloudFilesSDK-Test"]) {
                self.container = c;
                break;
            }
        if(!self.container)
            [self createContainer];
        [self stopWaiting];
    };
    [self.client getContainersForAllRegions:mycallback];
    [self waitForTestCompletion];
}


- (void)createObject {
    RSStorageObject *o = [[RSStorageObject alloc] init];
    o.name = @"test.txt";
    o.content_type = @"text/plain";    
    o.data = [@"This is a test." dataUsingEncoding:NSUTF8StringEncoding];
    [self resetWaiting];
    [self.container uploadObject:o success:^{
        self.object = o;
        self.object.parentContainerName = self.container.name;
        self.object.publicURL = self.container.publicURL;
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Create object failed.");
    }];
    [self waitForTestCompletion];
    
}

- (void)deleteObject:(void (^)())successHandler {
    
    [self.container deleteObject:self.object success:^{
        successHandler();
    }failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"delete object failed");
    }];    
    
}


#pragma mark - Test Setup

// setUp and tearDown are called with each individual test

- (void)setUp {
        
    [super setUp];    
    
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"RackspaceCloudFilesTests" ofType:@"plist"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSURL *url = [NSURL URLWithString:[settings valueForKey:@"auth_url"]];
    NSString *username = [settings valueForKey:@"username"];
    NSString *apiKey = [settings valueForKey:@"api_key"];
    if(!self.client)
    {
        [self resetWaiting];
        self.client = [[RSClient alloc] initWithAuthURL:url username:username apiKey:apiKey];
        [self.client authenticate:^{
            [self stopWaiting];
            STAssertNotNil(self.client.authToken, @"Client should have an auth token");
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            [self stopWaiting];
            STFail(@"Authentication failed.");
        }];
        [self waitForTestCompletion];
        [self createContainer];
        [self loadContainer];
        [self createObject];
    }
    [self resetWaiting];
}

- (void)tearDown {

    [super tearDown];
}

#pragma mark - Tests

- (void)testCreateContainer {
    RSContainer *c = [[RSContainer alloc] init];
    c.name = @"RSCloudFilesSDK-Test";
    [self.client createContainer:c region:@"SYD" success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Create container failed.");
    }];
    [self waitForTestCompletion];
}


- (void)testGetAccountMetadata {
    [self.client getAccountMetadata:^{
        [self stopWaiting];
        STAssertTrue(self.client.containerCount > 0,@"At least 1 container" );
        STAssertTrue(self.client.totalBytesUsed > 0,@"Some bytes are used." );
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get Account Metadata failed.");
    }];
    [self waitForTestCompletion];
}

- (void)testGetContainers {
    void(^mycallback)(NSMutableArray*, NSArray*) = ^(NSMutableArray* errors, NSArray* containers)
    {
     [self stopWaiting];
      STAssertFalse([containers count] == 0, @"At least one container should be found");
      STAssertTrue([errors count] == 0, @"No errors in the errors array");
    };
    [self.client getContainersForAllRegions:mycallback];
    [self waitForTestCompletion];
}

- (void)testGetCDNContainers {
    void(^mycallback)(NSMutableArray*, NSArray*) = ^(NSMutableArray* errors, NSArray* containers)
    {
        [self stopWaiting];
        STAssertTrue([containers count] > 0, @"At least one container should be found");
        STAssertTrue([errors count] == 0, @"No errors in the errors array");
    };
    [self.client getCDNContainersForAllRegions:mycallback];//---Note, in general you shouldn't use this.
    [self waitForTestCompletion];
}

- (void)testGetContainerMetadata {
    RSContainer *c = [[RSContainer alloc] init];
    c.name = @"RSCloudFilesSDK-Test";

    [self.client getContainerMetadata:c region:@"SYD" success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get container metadata failed.");            
    }];
    [self waitForTestCompletion];
}

- (void)testEnableCDNforContainer {
    RSContainer *c = [[RSContainer alloc] init];
    c.name = @"RSCloudFilesSDK-Test";
    
    [self.client cdnEnableContainer:c region:@"SYD" success:^(RSCDNContainer *cdnContainer) {
       [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"CDN enable container failed.");
    }];
   [self waitForTestCompletion];
}


- (void)testGetObjects {
    [self.container getObjects:^(NSArray *objects, NSError *jsonError) {
        
        [self stopWaiting];
        STAssertNotNil(objects, @"getObjects should return an array");
        STAssertNil(jsonError, @"getObjects should not return a JSON error");
        
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Get objects failed");
    }];
   [self waitForTestCompletion];
}


- (void)testGetObjectData {
    
    self.object.data = nil; // clear out the data to make sure we're getting it from the API
    
    [self.object getObjectData:^{
        [self stopWaiting];
        STAssertNotNil(self.object.data, @"object data should not be nil");
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"get object data failed");
    }];
   [self waitForTestCompletion];
}

- (void)testGetObjectMetadata {
    self.object.metadata = [[NSMutableDictionary alloc] initWithCapacity:1];
    [self.object.metadata setValue:@"Mike" forKey:@"Name"];
    
    [self.object updateMetadata:^{
        // let's clear it out, and then get it to make sure it comes back from the API                
        [self.object.metadata removeAllObjects];
        [self.object getMetadata:^{
            [self stopWaiting];
            STAssertEqualObjects([self.object.metadata valueForKey:@"Name"], @"Mike", @"Object metadata should be set");
        } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
            [self stopWaiting];
            STFail(@"get object metadata failed");
        }];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"update object metadata failed: %i", [response statusCode]);
    }];
   [self waitForTestCompletion];
}

- (void)testUpdateObjectMetadata {
    
    [self.object.metadata setValue:@"Mike" forKey:@"Name"];
    
    [self.object updateMetadata:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"update object metadata failed");
    }];
   [self waitForTestCompletion];
}

-(void)testUpdateCDNContainer {
    
    [self.client updateCDNContainer:(RSCDNContainer*)self.container success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Update CDN container failed.");
    }];
    [self waitForTestCompletion];
}

- (void)testZDelete_Object_and_Container {// "Z" because I need this test to run last.
    [self.container deleteObject:self.object success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Delete object failed.");
    }];
    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
    
    [self.client deleteContainer:self.container success:^{
        [self stopWaiting];
    } failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        [self stopWaiting];
        STFail(@"Delete container failed.");
    }];
    [self waitForTestCompletion];
}

@end
