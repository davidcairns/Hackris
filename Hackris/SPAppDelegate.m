//
//  SPAppDelegate.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPAppDelegate.h"
#import "SPViewController.h"

@implementation SPAppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Create our window.
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Create our main view controller and add it to our window.
	self.viewController = [[SPViewController alloc] initWithNibName:@"SPViewController" bundle:nil];
	self.window.rootViewController = self.viewController;
	
	// TODO: Implement intro screen.
	
	// Tell the window to display.
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self.viewController resetGame];
}

@end
