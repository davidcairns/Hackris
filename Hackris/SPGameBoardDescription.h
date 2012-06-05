//
//  SPGameBoardDescription.h
//  Hackris
//
//  Created by David Cairns on 6/1/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGamePiece.h"

@interface SPGameBoardDescription : NSObject

+ (SPGameBoardDescription *)gameBoardDescriptionForBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns;
- (SPGameBoardDescription *)gameBoardDescriptionByAddingPiece:(SPGamePiece *)gamePiece toLeftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation;

@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;

- (BOOL)hasBlockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

- (NSInteger)fallDepthForPiece:(SPGamePiece *)piece leftEdgeColumn:(NSInteger)leftEdgeColumn orientation:(SPGamePieceRotation)orientation;

@end
