//
//  SPGameBoardDescription.m
//  Hackris
//
//  Created by David Cairns on 6/1/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameBoardDescription.h"
#import <QuartzCore/QuartzCore.h>
#import "SPGameController+SPGameBoardAccess.h"
#import "SPBlockSize.h"

@interface SPGameBoardDescription ()
@property(nonatomic, assign)NSInteger gridNumRows;
@property(nonatomic, assign)NSInteger gridNumColumns;

@property(nonatomic, assign)BOOL *blockExistenceArray;
@end

@implementation SPGameBoardDescription
@synthesize gridNumRows = _gridNumRows;
@synthesize gridNumColumns = _gridNumColumns;
@synthesize blockExistenceArray = _blockExistenceArray;

- (id)initWithBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns {
	if((self = [super init])) {
		self.gridNumRows = gridNumRows;
		self.gridNumColumns = gridNumColumns;
		
		// Populate our block-existence array.
		const size_t blockExistenceArraySize = gridNumRows * gridNumColumns * sizeof(BOOL);
		self.blockExistenceArray = (BOOL *)malloc(blockExistenceArraySize);
		memset(self.blockExistenceArray, 0, blockExistenceArraySize);
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
	free(_blockExistenceArray);
	_blockExistenceArray = NULL;
}

+ (CALayer *)_blockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex inGroup:(NSSet *)blocks {
	const CGPoint location = CGPointMake(1.5f * SPBlockSize * columnIndex, 1.5f * SPBlockSize * rowIndex);
	for(CALayer *block in blocks) {
		const CGFloat xDiff = block.position.x - location.x;
		const CGFloat yDiff = block.position.y - location.y;
		if(sqrtf(xDiff * xDiff + yDiff * yDiff) < 0.01f) {
			return block;
		}
	}
	return nil;
}

+ (SPGameBoardDescription *)gameBoardDescriptionForBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns {
	return [[SPGameBoardDescription alloc] initWithBlocks:gameBlocks gridNumRows:gridNumRows gridNumColumns:gridNumColumns];
}
- (SPGameBoardDescription *)gameBoardDescriptionByAddingPiece:(SPGamePiece *)gamePiece toLeftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation {
	SPGameBoardDescription *boardDescription = [[SPGameBoardDescription alloc] init];
	
	boardDescription.gridNumRows = self.gridNumRows;
	boardDescription.gridNumColumns = self.gridNumColumns;
	
	BOOL *existenceMappingForPiece = [[self class] _existenceMappingForPiece:gamePiece gridNumRows:boardDescription.gridNumRows gridNumColumns:boardDescription.gridNumColumns leftEdgeColumn:leftEdgeColumn depth:depth orientation:orientation];
	
	// Populate our block-existence array.
	const size_t blockExistenceArraySize = boardDescription.gridNumRows * boardDescription.gridNumColumns;
	boardDescription.blockExistenceArray = (BOOL *)malloc(blockExistenceArraySize);
	memset(boardDescription.blockExistenceArray, 0, blockExistenceArraySize);
	for(NSInteger rowIndex = 0; rowIndex < boardDescription.gridNumRows; rowIndex++) {
		for(NSInteger columnIndex = 0; columnIndex < boardDescription.gridNumColumns; columnIndex++) {
			const NSInteger idx = rowIndex * boardDescription.gridNumColumns + columnIndex;
			
			const BOOL pieceFillsSpace = existenceMappingForPiece[idx];
			
			boardDescription.blockExistenceArray[idx] = (self.blockExistenceArray[idx] || pieceFillsSpace);
		}
	}
	
	free(existenceMappingForPiece);
	return boardDescription;
}
+ (BOOL *)_existenceMappingForPiece:(SPGamePiece *)gamePiece gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns leftEdgeColumn:(NSInteger)leftEdgeColumn depth:(NSInteger)depth orientation:(SPGamePieceRotation)orientation {
	// Get the relative blocks locations for this piece type and orientation.
	NSArray *relativeBlockLocations = [SPGamePiece relativeBlockLocationsForPieceType:gamePiece.gamePieceType orientation:orientation];
	
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
	
	const size_t blockExistenceArraySize = gridNumRows * gridNumColumns;
	BOOL *existenceMap = (BOOL *)malloc(blockExistenceArraySize);
	
	// Add blocks for the block locations to the game blocks set and return it.
	[absoluteBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *pieceBlock = [CALayer layer];
		const NSInteger pieceBlockColumn = (pieceBlock.position.x - 0.5f * SPBlockSize) / SPBlockSize;
		const NSInteger pieceBlockRow = (pieceBlock.position.y - 0.5f * SPBlockSize) / SPBlockSize;
		const NSInteger existenceMapIndex = pieceBlockRow * gridNumColumns + pieceBlockColumn;
		existenceMap[existenceMapIndex] = YES;
	}];
	
	return existenceMap;
}


- (BOOL)hasBlockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	return self.blockExistenceArray[rowIndex * self.gridNumColumns + columnIndex];
}

@end
