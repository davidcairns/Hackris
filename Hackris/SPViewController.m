//
//  SPViewController.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SPGameController.h"

@interface SPViewController ()
@property(nonatomic, strong)SPGameController *gameController;
@property(nonatomic, readonly)dispatch_source_t gameUpdateTimerSource;
@end

@implementation SPViewController
@synthesize gameController = _gameController;
@synthesize gameUpdateTimerSource = _gameUpdateTimerSource;

- (void)_SPViewController_commonInit {
	// Create our game object.
	self.gameController = [[SPGameController alloc] init];
}
- (id)init {
	if((self = [super init])) {
		[self _SPViewController_commonInit];
	}
	return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super initWithCoder:aDecoder])) {
		[self _SPViewController_commonInit];
	}
	return self;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self _SPViewController_commonInit];
	}
	return self;
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Add our game controller's container layer.
	[self.view.layer addSublayer:self.gameController.gameContainerLayer];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	self.gameController.gameContainerLayer.frame = self.view.layer.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	// Create and start our game update timer source.
	_gameUpdateTimerSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
	const uint64_t gameUpdateTimerInterval = NSEC_PER_SEC / 10;	// 10fps
	dispatch_source_set_timer(self.gameUpdateTimerSource, dispatch_time(DISPATCH_TIME_NOW, 0), gameUpdateTimerInterval, 0);
	
	__block NSTimeInterval lastUpdateTimestamp = 0;
	dispatch_source_set_event_handler(self.gameUpdateTimerSource, ^ {
		const NSTimeInterval currentTimestamp = [NSDate timeIntervalSinceReferenceDate];
		const NSTimeInterval timeDelta = (0 == lastUpdateTimestamp ? 0 : currentTimestamp - lastUpdateTimestamp);
		lastUpdateTimestamp = currentTimestamp;
		[self.gameController updateWithTimeDelta:timeDelta];
	});
	dispatch_source_set_cancel_handler(self.gameUpdateTimerSource, ^ {
		dispatch_release(_gameUpdateTimerSource);
		_gameUpdateTimerSource = NULL;
	});
	dispatch_resume(self.gameUpdateTimerSource);
}
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	
	// Cancel our game update timer.
	dispatch_source_cancel(self.gameUpdateTimerSource);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

@end
