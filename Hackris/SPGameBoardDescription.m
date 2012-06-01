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

@property(nonatomic, readonly)BOOL *blockExistenceArray;
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
		_blockExistenceArray = (BOOL *)malloc(blockExistenceArraySize);
		memset(_blockExistenceArray, 0, blockExistenceArraySize);
		for(NSInteger rowIndex = 0; rowIndex < gridNumRows; rowIndex++) {
			for(NSInteger columnIndex = 0; columnIndex < gridNumColumns; columnIndex++) {
				NSInteger idx = rowIndex * gridNumColumns + columnIndex;
				_blockExistenceArray[idx] = (nil != [[self class] _blockAtRow:rowIndex column:columnIndex inGroup:gameBlocks]);
			}
		}
	}
	return self;
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


- (BOOL)hasBlockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	return self.blockExistenceArray[rowIndex * self.gridNumColumns + columnIndex];
}

@end
