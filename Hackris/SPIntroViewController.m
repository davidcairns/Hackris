//
//  SPIntroViewController.m
//  Hackris
//
//  Created by David Cairns on 6/4/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPIntroViewController.h"

@implementation SPIntroViewController
@synthesize gameViewController = _gameViewController;

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (UIInterfaceOrientationPortrait == interfaceOrientation);
}


#pragma mark 
- (IBAction)continueButtonTapped:(id)sender {
	self.gameViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
	[self presentViewController:self.gameViewController animated:YES completion:nil];
}

@end
