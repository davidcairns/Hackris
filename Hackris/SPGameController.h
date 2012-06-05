//
//  SPGameController.h
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SPGamePiece.h"
#import "SPGameBoardDescription.h"

@interface SPGameController : NSObject

- (void)resetGame;

// Game Rules
@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;
// How often e.g. the piece drops:
@property(nonatomic, readonly)NSTimeInterval gameStepInterval;
//// How often the (computer) 'player' can issue game actions:
//@property(nonatomic, readonly)NSTimeInterval gameActionInterval;


// Game State
@property(nonatomic, strong, readonly)SPGamePiece *currentlyDroppingPiece;
- (SPGameBoardDescription *)descriptionOfCurrentBoard;
- (SPGameBoardDescription *)descriptionOfCurrentBoardSansPiece:(SPGamePiece *)piece;

// Interface
@property(nonatomic, strong, readonly)CALayer *gameContainerLayer;

// Updating game state
- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta;

// Interaction
- (void)grabBlocksNearestTouchLocation:(CGPoint)touchLocation;
- (void)moveGrabbedBlocksToTouchLocation:(CGPoint)touchLocation;
- (void)dropGrabbedBlocksAtTouchLocation:(CGPoint)touchLocation;

@end
