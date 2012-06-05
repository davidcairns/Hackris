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
#import "SPGamePlayer.h"

@interface SPViewController ()
@property(nonatomic, strong)SPGameController *gameController;
@property(nonatomic, readonly)dispatch_source_t gameUpdateTimerSource;

@property(nonatomic, strong)SPGamePlayer *gamePlayer;

// Interaction
@property(nonatomic, strong)UITouch *trackingTouch;
@end

@implementation SPViewController
@synthesize gameController = _gameController;
@synthesize gameUpdateTimerSource = _gameUpdateTimerSource;
@synthesize gamePlayer = _gamePlayer;
@synthesize trackingTouch = _trackingTouch;

- (void)_SPViewController_commonInit {
	// Create our game object.
	self.gameController = [[SPGameController alloc] init];
	
	// Create our game player.
	self.gamePlayer = [[SPGamePlayer alloc] init];
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
//	const uint64_t gameUpdateTimerInterval = NSEC_PER_SEC / 10;	// 10fps
	const uint64_t gameUpdateTimerInterval = NSEC_PER_SEC / 40;	// 40fps
	dispatch_source_set_timer(self.gameUpdateTimerSource, dispatch_time(DISPATCH_TIME_NOW, 0), gameUpdateTimerInterval, 0);
	
	__block NSTimeInterval lastUpdateTimestamp = 0.0;
	__block NSTimeInterval lastMoveTimestamp = 0.0;
	const NSTimeInterval moveInterval = 1.0 / 10.0;
	dispatch_source_set_event_handler(self.gameUpdateTimerSource, ^ {
		// Determine how much time has elapsed since the last game update.
		const NSTimeInterval currentTimestamp = [NSDate timeIntervalSinceReferenceDate];
		const NSTimeInterval timeDelta = (0 == lastUpdateTimestamp ? 0 : currentTimestamp - lastUpdateTimestamp);
		lastUpdateTimestamp = currentTimestamp;
		
		if(currentTimestamp - lastMoveTimestamp >= moveInterval) {
			// Allow our player object to act.
			[self.gamePlayer makeMoveInGame:self.gameController];
			lastMoveTimestamp += moveInterval;
		}
		
		// Update the game.
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
	return (UIInterfaceOrientationPortrait == interfaceOrientation);
}


#pragma mark - Touch Handling
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	// If this isn't an interesting call to -touchesBegan, just bail.
	if(!self.trackingTouch && touches.count > 1) {
		return;
	}
	
	// Hold on to the touch.
	self.trackingTouch = [touches anyObject];
	
	const CGPoint touchLocation = [self.trackingTouch locationInView:self.trackingTouch.view];
	[self.gameController grabBlocksNearestTouchLocation:touchLocation];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	// If none of these touches are our tracking touch, just bail.
	if(![touches containsObject:self.trackingTouch]) {
		return;
	}
	
	// Update the position of the blocks we're currently moving around.
	const CGPoint touchLocation = [self.trackingTouch locationInView:self.trackingTouch.view];
	[self.gameController moveGrabbedBlocksToTouchLocation:touchLocation];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// If none of these touches are our tracking touch, just bail.
	if(![touches containsObject:self.trackingTouch]) {
		return;
	}
	
	// Drop the blocks we're currently moving around.
	const CGPoint dropLocation = [self.trackingTouch locationInView:self.trackingTouch.view];
	[self.gameController dropGrabbedBlocksAtTouchLocation:dropLocation];
	
	// Clear our tracking touch and game blocks.
	self.trackingTouch = nil;
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	// If none of these touches are our tracking touch, just bail.
	if(![touches containsObject:self.trackingTouch]) {
		return;
	}
	
	// Drop the blocks we're currently moving back to their original locations.
	const CGPoint dropLocation = [self.trackingTouch locationInView:self.trackingTouch.view];
	[self.gameController dropGrabbedBlocksAtTouchLocation:dropLocation];
	
	// Clear our tracking touch and game blocks.
	self.trackingTouch = nil;
}


#pragma mark 
- (void)resetGame {
	// Reset our game's state.
	[self.gameController resetGame];
}

@end
