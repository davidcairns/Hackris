//
//  SPGameBoardDescription.h
//  Hackris
//
//  Created by David Cairns on 6/1/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPHackrisGamePiece.h"

@interface SPHackrisGameBoardDescription : NSObject

+ (SPHackrisGameBoardDescription *)gameBoardDescriptionForBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns;
- (SPHackrisGameBoardDescription *)gameBoardDescriptionByAddingPiece:(SPHackrisGamePiece *)gamePiece toLeftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation;

@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;

- (BOOL)hasBlockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

- (NSInteger)fallDepthForPiece:(SPHackrisGamePiece *)piece leftEdgeColumn:(NSInteger)leftEdgeColumn orientation:(SPGamePieceRotation)orientation;

@end
