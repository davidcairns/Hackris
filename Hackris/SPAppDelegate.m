//
//  SPAppDelegate.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPAppDelegate.h"
#import "SPIntroViewController.h"
#import "SPViewController.h"

@implementation SPAppDelegate
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Create our window.
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Create our intro view controller.
	SPIntroViewController *introViewController = [[SPIntroViewController alloc] initWithNibName:@"SPIntroViewController" bundle:nil];
	
	// Add the intro view controller to our window.
	self.window.rootViewController = introViewController;
	
	// Tell the window to display.
	[self.window makeKeyAndVisible];
	
	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[self.viewController resetGame];
}

@end
