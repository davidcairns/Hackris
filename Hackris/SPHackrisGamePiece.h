//
//  SPGamePiece.h
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SPHackrisGameAction.h"

typedef enum {
	SPGamePieceTypeStraight = 0, 
	SPGamePieceTypeLeftL, 
	SPGamePieceTypeRightL, 
	SPGamePieceTypeT, 
	SPGamePieceTypeSquare, 
	SPGamePieceNumTypes, 
} SPGamePieceType;


typedef enum {
	SPGamePieceRotationNone = 0, 
	SPGamePieceRotationClockwise, 
	SPGamePieceRotationUpsideDown, 
	SPGamePieceRotationCounterClockwise, 
	SPGamePieceRotationNumAngles, 
} SPGamePieceRotation;


@interface SPHackrisGamePiece : NSObject

- (id)initWithGamePieceType:(SPGamePieceType)gamePieceType;
@property(nonatomic, readonly)SPGamePieceType gamePieceType;

@property(nonatomic, strong, readonly)NSArray *componentBlocks;
- (NSInteger)leftEdgeColumn;

+ (NSArray *)relativeBlockLocationsForPieceType:(SPGamePieceType)pieceType orientation:(SPGamePieceRotation)orientation;
- (NSArray *)blockLocationsAfterApplyingAction:(SPHackrisGameAction *)action;

// Mutable state.
@property(nonatomic, assign)SPGamePieceRotation rotation;

- (NSInteger)numBlocksHigh;
- (NSInteger)numBlocksWide;

@end
