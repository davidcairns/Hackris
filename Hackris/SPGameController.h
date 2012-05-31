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

@interface SPGameController : NSObject

// Game Rules
@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;
// How often e.g. the piece drops:
@property(nonatomic, readonly)NSTimeInterval gameStepInterval;
// How often the (computer) 'player' can issue game actions:
@property(nonatomic, readonly)NSTimeInterval gameActionInterval;


// Game State
@property(nonatomic, strong, readonly)SPGamePiece *currentlyDroppingPiece;
- (NSInteger)fallDepthForPiece:(SPGamePiece *)piece leftEdgeColumn:(NSInteger)leftEdgeColumn orientation:(SPGamePieceRotation)orientation;
- (NSSet *)gameBlocksAfterMovingPiece:(SPGamePiece *)gamePiece toLeftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation;

// Interface
@property(nonatomic, strong, readonly)CALayer *gameContainerLayer;

// Updating game state
- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta;

// Interaction
#if 1
- (void)grabBlocksNearestTouchLocation:(CGPoint)touchLocation;
#else
- (NSSet *)grabBlocksNearestTouchLocation:(CGPoint)touchLocation;
#endif
- (void)moveGrabbedBlocksToTouchLocation:(CGPoint)touchLocation;
- (void)dropGrabbedBlocksAtTouchLocation:(CGPoint)touchLocation;

@end
