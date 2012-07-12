//
//  SPGameBoardDescription.m
//  Hackris
//
//  Created by David Cairns on 6/1/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPHackrisGameBoardDescription.h"
#import <QuartzCore/QuartzCore.h>
#import "SPHackrisGameController+SPGameBoardAccess.h"
#import "SPBlockSize.h"

@interface SPHackrisGameBoardDescription ()
@property(nonatomic, readonly)BOOL *blockExistenceArray;
@end

@implementation SPHackrisGameBoardDescription
@synthesize gridNumRows = _gridNumRows;
@synthesize gridNumColumns = _gridNumColumns;
@synthesize blockExistenceArray = _blockExistenceArray;

- (id)initWithGridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns {
	if((self = [super init])) {
		_gridNumRows = gridNumRows;
		_gridNumColumns = gridNumColumns;
		
		// Allocate our block-existence array.
		const size_t blockExistenceArraySize = gridNumRows * gridNumColumns * sizeof(BOOL);
		_blockExistenceArray = (BOOL *)malloc(blockExistenceArraySize);
		memset(self.blockExistenceArray, 0, blockExistenceArraySize);
	}
	return self;
}
- (id)initWithBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns {
	if((self = [self initWithGridNumRows:gridNumRows gridNumColumns:gridNumColumns])) {
		// Populate our block-existence array.
		for(NSInteger rowIndex = 0; rowIndex < gridNumRows; rowIndex++) {
			for(NSInteger columnIndex = 0; columnIndex < gridNumColumns; columnIndex++) {
				const NSInteger idx = rowIndex * gridNumColumns + columnIndex;
				self.blockExistenceArray[idx] = (nil != [[self class] _blockAtRow:rowIndex column:columnIndex inGroup:gameBlocks]);
			}
		}
	}
	return self;
}
- (void)dealloc {
	if(_blockExistenceArray) {
		free(_blockExistenceArray);
		_blockExistenceArray = NULL;
	}
}

+ (CALayer *)_blockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex inGroup:(NSSet *)blocks {
	const CGPoint location = CGPointMake(0.5f * SPBlockSize + SPBlockSize * columnIndex, 0.5f * SPBlockSize + SPBlockSize * rowIndex);
	for(CALayer *block in blocks) {
		const CGFloat xDiff = block.position.x - location.x;
		const CGFloat yDiff = block.position.y - location.y;
		if(sqrtf(xDiff * xDiff + yDiff * yDiff) < 0.01f) {
			return block;
		}
	}
	return nil;
}

+ (SPHackrisGameBoardDescription *)gameBoardDescriptionForBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns {
	return [[SPHackrisGameBoardDescription alloc] initWithBlocks:gameBlocks gridNumRows:gridNumRows gridNumColumns:gridNumColumns];
}
- (SPHackrisGameBoardDescription *)gameBoardDescriptionByAddingPiece:(SPHackrisGamePiece *)gamePiece toLeftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation {
	SPHackrisGameBoardDescription *boardDescription = [[SPHackrisGameBoardDescription alloc] initWithGridNumRows:self.gridNumRows gridNumColumns:self.gridNumColumns];
	
	BOOL *existenceMappingForPiece = [[self class] _existenceMappingForPiece:gamePiece gridNumRows:boardDescription.gridNumRows gridNumColumns:boardDescription.gridNumColumns leftEdgeColumn:leftEdgeColumn depth:depth orientation:orientation];
	
	// Populate our block-existence array.
	for(NSInteger rowIndex = 0; rowIndex < boardDescription.gridNumRows; rowIndex++) {
		for(NSInteger columnIndex = 0; columnIndex < boardDescription.gridNumColumns; columnIndex++) {
			const NSInteger idx = rowIndex * boardDescription.gridNumColumns + columnIndex;
			boardDescription.blockExistenceArray[idx] = (self.blockExistenceArray[idx] || existenceMappingForPiece[idx]);
		}
	}
	free(existenceMappingForPiece);
	
	return boardDescription;
}
+ (BOOL *)_existenceMappingForPiece:(SPHackrisGamePiece *)gamePiece gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns leftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation {
	// Get the relative blocks locations for this piece type and orientation.
	NSArray *relativeBlockLocations = [SPHackrisGamePiece relativeBlockLocationsForPieceType:gamePiece.gamePieceType orientation:orientation];
	
	// Get the column offset for this piece such that it has the given left-edge column.
	__block NSInteger pieceColumnOffset = 0;
	__block NSInteger pieceBottomRowOffset = 0;
	[relativeBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint relativeLocation = [(NSValue *)obj CGPointValue];
		const NSInteger columnOffsetForBlock = relativeLocation.x / SPBlockSize;
		pieceColumnOffset = MIN(pieceColumnOffset, columnOffsetForBlock);
		const NSInteger rowOffsetForBlock = relativeLocation.y / SPBlockSize;
		pieceBottomRowOffset = MAX(pieceBottomRowOffset, rowOffsetForBlock);
	}];
	
	// Get the block locations for the given piece / left edge / depth / orientation.
	NSMutableArray *absoluteBlockLocations = [NSMutableArray array];
	[relativeBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint relativeLocation = [(NSValue *)obj CGPointValue];
		const CGPoint absoluteLocation = CGPointMake(relativeLocation.x + SPBlockSize * (CGFloat)(leftEdgeColumn - pieceColumnOffset) + 0.5f * SPBlockSize, relativeLocation.y + SPBlockSize * (CGFloat)(depth - pieceBottomRowOffset) + 0.5f * SPBlockSize);
		[absoluteBlockLocations addObject:[NSValue valueWithCGPoint:absoluteLocation]];
	}];
	
	const size_t blockExistenceArraySize = gridNumRows * gridNumColumns * sizeof(BOOL);
	BOOL *existenceMap = (BOOL *)malloc(blockExistenceArraySize);
	memset(existenceMap, 0, blockExistenceArraySize);
	
	// Add blocks for the block locations to the game blocks set and return it.
	[absoluteBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint location = [(NSValue *)obj CGPointValue];
		const NSInteger pieceBlockColumn = MAX(0, MIN((location.x - 0.5f * SPBlockSize) / SPBlockSize, gridNumColumns - 1));
		const NSInteger pieceBlockRow = MAX(0, MIN((location.y - 0.5f * SPBlockSize) / SPBlockSize, gridNumRows - 1));
		const NSInteger existenceMapIndex = pieceBlockRow * gridNumColumns + pieceBlockColumn;
		existenceMap[existenceMapIndex] = YES;
	}];
	
	return existenceMap;
}


- (BOOL)hasBlockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	if(rowIndex < 0 || rowIndex >= self.gridNumRows || columnIndex < 0 || columnIndex >= self.gridNumColumns) {
		return NO;
	}
	
	return self.blockExistenceArray[rowIndex * self.gridNumColumns + columnIndex];
}


- (NSString *)description {
	NSMutableString *string = [NSMutableString stringWithString:@"\n"];
	
	// Add the top border.
	for(NSInteger columnIndex = 0; columnIndex < self.gridNumColumns; columnIndex++) {
		[string appendString:@"="];
	}
	[string appendString:@"\n"];
	
	// Print each row.
	for(NSInteger rowIndex = 0; rowIndex < self.gridNumRows; rowIndex++) {
		for(NSInteger columnIndex = 0; columnIndex < self.gridNumColumns; columnIndex++) {
			// If this (row, column) contains a block, append an 'X'.
			if([self hasBlockAtRow:rowIndex column:columnIndex]) {
				[string appendString:@"X"];
			}
			// Otherwise, append a space.
			else {
				[string appendString:@" "];
			}
		}
		[string appendString:@"\n"];
	}
	
	// Add the bottom border.
	for(NSInteger columnIndex = 0; columnIndex < self.gridNumColumns; columnIndex++) {
		[string appendString:@"="];
	}
	
	return string;
}


- (NSInteger)fallDepthForPiece:(SPHackrisGamePiece *)piece leftEdgeColumn:(NSInteger)leftEdgeColumn orientation:(SPGamePieceRotation)orientation {
	// Get the arrangement of this piece's blocks for this orientation.
	NSArray *relativeBlockLocations = [SPHackrisGamePiece relativeBlockLocationsForPieceType:piece.gamePieceType orientation:orientation];
	
	// Determine how far we have to offset the whole piece based on this orientation (such that its left edge falls in the column specified).
	__block NSInteger pieceColumnOffset = 0;
	__block NSInteger pieceBottomRowOffset = 0;
	[relativeBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint relativeLocation = [(NSValue *)obj CGPointValue];
		const NSInteger columnOffsetForBlock = relativeLocation.x / SPBlockSize;
		pieceColumnOffset = MIN(pieceColumnOffset, columnOffsetForBlock);
		const NSInteger rowOffsetForBlock = relativeLocation.y / SPBlockSize;
		pieceBottomRowOffset = MAX(pieceBottomRowOffset, rowOffsetForBlock);
	}];
	
	__block NSInteger depth = -1;
	while(depth < self.gridNumRows) {
		depth++;
		
		// Determine the piece's absolute block locations given this depth.
		NSMutableArray *locations = [NSMutableArray array];
		for(NSValue *relativeLocationValue in relativeBlockLocations) {
			const CGPoint relativeLocation = [relativeLocationValue CGPointValue];
			const CGPoint absoluteLocation = CGPointMake(relativeLocation.x + SPBlockSize * (CGFloat)(leftEdgeColumn - pieceColumnOffset) + 0.5f * SPBlockSize, relativeLocation.y + SPBlockSize * (CGFloat)depth + 0.5f * SPBlockSize);
			[locations addObject:[NSValue valueWithCGPoint:absoluteLocation]];
		}
		
		__block BOOL hasHit = NO;
		for(NSValue *locationValue in locations) {
			const CGPoint location = [locationValue CGPointValue];
			const NSInteger rowIndex = (location.y - 0.5f * SPBlockSize) / SPBlockSize;
			const NSInteger columnIndex = (location.x - 0.5f * SPBlockSize) / SPBlockSize;
			
			// If the location is off the top of the screen, skip this iteration.
			if(rowIndex >= self.gridNumRows) {
				continue;
			}
			
			// If the location is off the side of the screen or if there is a collision, stop trying to drop the piece.
			if(columnIndex < 0 || columnIndex >= self.gridNumColumns || [self hasBlockAtRow:rowIndex column:columnIndex]) {
				depth -= 1;
				hasHit = YES;
				break;
			}
		}
		if(hasHit) {
			break;
		}
	}
	
	return depth > 0 ? MIN(depth + pieceBottomRowOffset, self.gridNumRows - 1): 0;
}

@end
