//
//  SPIntroViewController.h
//  Hackris
//
//  Created by David Cairns on 6/4/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPViewController.h"

@interface SPIntroViewController : UIViewController

@property(nonatomic, strong)IBOutlet SPViewController *gameViewController;

- (IBAction)continueButtonTapped:(id)sender;

@end
