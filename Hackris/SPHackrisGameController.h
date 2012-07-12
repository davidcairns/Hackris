//
//  SPHackrisGameController.h
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SPHackrisGamePiece.h"
#import "SPHackrisGameBoardDescription.h"

@interface SPHackrisGameController : NSObject

- (void)resetGame;

// Game Rules
@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;
// How often e.g. the piece drops:
@property(nonatomic, readonly)NSTimeInterval gameStepInterval;
//// How often the (computer) 'player' can issue game actions:
//@property(nonatomic, readonly)NSTimeInterval gameActionInterval;


// Game State
@property(nonatomic, strong, readonly)SPHackrisGamePiece *currentlyDroppingPiece;
- (SPHackrisGameBoardDescription *)descriptionOfCurrentBoard;
- (SPHackrisGameBoardDescription *)descriptionOfCurrentBoardSansPiece:(SPHackrisGamePiece *)piece;

// Interface
@property(nonatomic, strong, readonly)CALayer *gameContainerLayer;

// Updating game state
- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta;

// Interaction
- (void)grabBlocksNearestTouchLocation:(CGPoint)touchLocation;
- (void)moveGrabbedBlocksToTouchLocation:(CGPoint)touchLocation;
- (void)dropGrabbedBlocksAtTouchLocation:(CGPoint)touchLocation;

@end
