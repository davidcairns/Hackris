//
//  SPAppDelegate.h
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPHackrisViewController;

@interface SPAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic)UIWindow *window;
@property(strong, nonatomic)SPHackrisViewController *viewController;

@end
