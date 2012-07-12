//
//  SPIntroViewController.h
//  Hackris
//
//  Created by David Cairns on 6/4/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPHackrisViewController.h"

@interface SPIntroViewController : UIViewController

@property(nonatomic, strong)IBOutlet SPHackrisViewController *gameViewController;

- (IBAction)continueButtonTapped:(id)sender;

@end
