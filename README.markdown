# The Rackspace Cloud Files SDK for iOS

## Overview

The Rackspace Cloud Files SDK for iOS is a simple library that helps you communicate with the Rackspace Cloud Files API.  You can use this library to upload files, download files, and control metadata and CDN settings in a Rackspace Cloud account.

This library is designed for ARC-enabled projects and uses Foundation classes for HTTP communication and JSON parsing, so no third party dependencies need to be added to your Xcode project.

All API operations have two callback block arguments to allow you to handle success and failure conditions.  If you want to have more control over how you handle HTTP, or if you are using a third party HTTP library such as AFNetworking, you can also access getters for all of the NSURLRequests that the SDK uses.

## Installation

### Installing the Library

There are two ways to install the library:

- Add Source Code to your Xcode Project
- Link to a Static Library

#### Add Source Code to your Xcode Project

Open the Source folder and drag all files into your project.  If you plan on using this library in multiple Xcode projects, you may want to choose not to copy the actual files into your project, and instead refer to them from a single location.

#### Link to a Static Library

To use a static library, open the RackspaceCloudFiles project in Xcode and build the project.  Then, in the Groups and Files pane, expand the Products group and you will see libRackspaceCloudFiles.a.  You can link to this file in the Build Phases tab of your Xcode project settings.

### Installing the Documentation

To install the documentation, go into Xcode Preferences, and choose the Downloads tab.  From there, choose Documentation on the segmented control and press the + button on the bottom left of the window.  For the feed URL, enter the following:

http://overhrd.com/rackspace/com.rackspace.Rackspace-Cloud-Files.atom

## Classes

There are four main classes that you can use to communicate with Cloud Files.

#### RSClient

The RSClient class is the root class for this SDK.  You use it to authenticate with your account and work with containers and CDN containers.  You must have a RSClient object available in your code to use the other classes.

You can create a RSClient object with a single line of code:

```Objective-C
RSClient *client = [[RSClient alloc] initWithProvider:RSProviderTypeRackspaceUS username:@"my username" apiKey:@"secret"];
```

Your username is the username you use to login to http://manage.rackspacecloud.com, and your API Key is available in the My Account section of http://manage.rackspacecloud.com.  If you are a UK user, pass RSProviderTypeRackspaceUK to the provider argument in the constructor.  If you are using OpenStack Swift, you can create a RSClient object like this:

```Objective-C
NSURL *url = [NSURL URLWithString:@"https://api.myopenstackdomain.com/"];
RSClient *client = [[RSClient alloc] initWithAuthURL:url username:@"my username" apiKey:@"secret"];
```

Once you have created your object, you can optionally authenticate before performing any operations.  If you do not authenticate, the client will authenticate for you before performing any other API operations.

```Objective-C
[client authenticate:^{

  // authentication was successful

} failure:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {

  // authentication failed.  you can inspect the response, data, and error
  // objects to determine why.



Formal documentation on how to use is coming soon, but for now look at the
unit tests. They are the best code samples right now; also don't call any
functions directly that start with an underscore - a convention from the original days of C/C++ and MFC usage Windows. Those functions are subject to change as needed and without notice. 

