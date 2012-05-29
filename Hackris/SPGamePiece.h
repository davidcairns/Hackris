//
//  SPGamePiece.h
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

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


@interface SPGamePiece : NSObject

- (id)initWithGamePieceType:(SPGamePieceType)gamePieceType;

@property(nonatomic, strong, readonly)NSArray *componentBlocks;

// Mutable state.
- (SPGamePieceRotation)rotation;
- (void)rotate;

- (NSInteger)numBlocksHigh;
- (NSInteger)numBlocksWide;

@end
