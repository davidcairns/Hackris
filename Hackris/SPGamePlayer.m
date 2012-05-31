//
//  SPGamePlayer.m
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGamePlayer.h"
#import "SPGameController+SPGameInteraction.h"
#import "SPGameAction.h"
#import "SPGamePiece.h"

@interface SPSolution : NSObject
@property(nonatomic, assign)NSInteger leftEdgeColumn;
@property(nonatomic, assign)NSInteger bottomEdgeRow;
@property(nonatomic, assign)SPGamePieceRotation orientation;
@end
@implementation SPSolution
@synthesize leftEdgeColumn = _leftEdgeColumn;
@synthesize bottomEdgeRow = _bottomEdgeRow;
@synthesize orientation = _orientation;
- (NSString *)description {
	return [NSString stringWithFormat:@"<%@%p -- left edge column: %i, bottom edge row: %i, orientation: %i >", [self class], self, self.leftEdgeColumn, self.bottomEdgeRow, self.orientation];
}
@end


@implementation SPGamePlayer

- (NSArray *)_possibleSolutionsForPiece:(SPGamePiece *)currentlyDroppingPiece gameController:(SPGameController *)gameController {
	// For each column...
	NSMutableArray *solutions = [NSMutableArray array];
	for(NSInteger columnOffset = 0; columnOffset < gameController.gridNumColumns; columnOffset++) {
		// Generate each valid solution in which the piece's left edge is in this column.
		for(SPGamePieceRotation orientation = 0; orientation < SPGamePieceRotationNumAngles; orientation++) {
			// Determine the depth to which this block would fall (in rows, from the top).
			const NSInteger fallDepth = [gameController fallDepthForPiece:currentlyDroppingPiece leftEdgeColumn:columnOffset orientation:orientation];
			
			// If the piece will fall at all, save this solution.
			if(fallDepth > 0) {
				SPSolution *solution = [[SPSolution alloc] init];
				solution.leftEdgeColumn = columnOffset;
				solution.orientation = orientation;
				solution.bottomEdgeRow = fallDepth;
				[solutions addObject:solution];
			}
		}
	}
	
	return solutions;
}
#if 1
#else
- (NSArray *)_culledSolutions:(NSArray *)solutions forGame:(SPGameController *)gameController {
	NSMutableArray *reachableSolutions = [NSMutableArray array];
	[solutions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		// Determine if this solution is reachable.
		SPSolution *solution = (SPSolution *)obj;
		
		// TODO: Determine how many moves away the solution is.
		
		// TODO: Determine how many game steps until the block
		
		if(1) {
			[reachableSolutions addObject:solution];
		}
	}];
	return reachableSolutions;
}
#endif
- (CGPoint)_locationForRow:(NSInteger)rowIndex column:(NSInteger)columnIndex {
	return CGPointMake(columnIndex * 20.0f + 10.0f, rowIndex * 20.0f + 10.0f);
}
- (CALayer *)_blockAtLocation:(CGPoint)location inGroup:(NSSet *)blocks {
	for(CALayer *block in blocks) {
		const CGFloat xDiff = block.position.x - location.x;
		const CGFloat yDiff = block.position.y - location.y;
		if(sqrtf(xDiff * xDiff + yDiff * yDiff) < 0.01f) {
			return block;
		}
	}
	return nil;
}
- (CGFloat)_holeScoreForGameBoardBlocks:(NSSet *)gameBoardBlocks inGame:(SPGameController *)gameController {
	// NOTE: How this algorithm calculates the score:
	//			• 1.0 for a space surrounded on all sides
	//			• 0.75 for a space surrounded on all sides but one
	//			• 0.5 for a space surrounded on all sides but two
	//			* A “bonus” of 0.1, if there's a block above at all
	const CGFloat kTotallySurroundedScore = 1.0f;
	const CGFloat kMostlySurroundedScore = 0.75f;
	const CGFloat kPartiallySurroundedScore = 0.5f;
	const CGFloat kBlockAboveBonus = 0.1f;
	
	// Find the number of holes (open spaces surrounded by four blocks).
	CGFloat holeScore = 0.0f;
	for(NSInteger rowIndex = 0; rowIndex < gameController.gridNumRows; rowIndex++) {
		for(NSInteger columnIndex = 0; columnIndex < gameController.gridNumColumns; columnIndex++) {
			// Get the location for this (row, column).
			const CGPoint location = [self _locationForRow:rowIndex column:columnIndex];
			
			// If this space contains a block, bail this iteration.
			if([self _blockAtLocation:location inGroup:gameBoardBlocks]) {
				continue;
			}
			
			// Check for spaces surrounded on all sides.
			const BOOL isOnBottomEdge = (gameController.gridNumRows - 1 == rowIndex);
			const BOOL isOnLeftEdge = (0 == columnIndex);
			const BOOL isOnRightEdge = (gameController.gridNumColumns - 1 == columnIndex);
			const BOOL isOnBottomLeftCorner = isOnBottomEdge && isOnLeftEdge;
			const BOOL isOnBottomRightCorner = isOnBottomEdge && isOnRightEdge;
			CALayer *blockAbove = [self _blockAtLocation:[self _locationForRow:rowIndex - 1 column:columnIndex] inGroup:gameBoardBlocks];
			CALayer *blockBelow = [self _blockAtLocation:[self _locationForRow:rowIndex + 1 column:columnIndex] inGroup:gameBoardBlocks];
			CALayer *blockLeft = [self _blockAtLocation:[self _locationForRow:rowIndex column:columnIndex - 1] inGroup:gameBoardBlocks];
			CALayer *blockRight = [self _blockAtLocation:[self _locationForRow:rowIndex column:columnIndex + 1] inGroup:gameBoardBlocks];
			// Check for the bottom-left corner.
			if(isOnBottomLeftCorner && blockAbove && blockRight) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for the bottom-right corner.
			else if(isOnBottomRightCorner && blockAbove && blockLeft) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces at the bottom edge.
			else if(isOnBottomEdge && blockAbove && blockLeft && blockRight) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces on the left edge.
			else if(isOnLeftEdge && blockAbove && blockBelow && blockRight) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces on the right edge.
			else if(isOnRightEdge && blockAbove && blockBelow && blockLeft) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces in the middle.
			else if(blockAbove && blockBelow && blockLeft && blockRight) {
				holeScore += kTotallySurroundedScore;
			}
			
			// Check for spaces surrounded on all sides but one.
			// Bottom-left corner.
			else if(isOnBottomLeftCorner && (blockAbove || blockRight)) {
				holeScore += kMostlySurroundedScore;
			}
			// Bottom-right corner.
			else if(isOnBottomRightCorner && (blockAbove || blockLeft)) {
				holeScore += kMostlySurroundedScore;
			}
			// Bottom edge.
			else if(isOnBottomEdge && ((blockAbove && blockLeft) || (blockAbove && blockRight) || (blockLeft && blockRight))) {
				holeScore += kMostlySurroundedScore;
			}
			// Left edge.
			else if(isOnLeftEdge && ((blockAbove && blockBelow) || (blockAbove && blockRight) || (blockBelow && blockRight))) {
				holeScore += kMostlySurroundedScore;
			}
			// Right edge.
			else if(isOnRightEdge && ((blockAbove && blockBelow) || (blockAbove && blockLeft) || (blockBelow && blockLeft))) {
				holeScore += kMostlySurroundedScore;
			}
			// Middle space.
			else if((blockAbove && blockLeft && blockRight) || (blockAbove && blockBelow && blockLeft) || (blockAbove && blockBelow && blockRight) || (blockBelow && blockLeft && blockRight)) {
				holeScore += kMostlySurroundedScore;
			}
			
			// Check for spaces surrounded on all sides but two.
			// Bottom-left corner.
			else if(isOnBottomLeftCorner) {
				holeScore += kPartiallySurroundedScore;
			}
			// Bottom-right corner.
			else if(isOnBottomRightCorner) {
				holeScore += kPartiallySurroundedScore;
			}
			// Bottom edge.
			else if(isOnBottomEdge && (blockAbove || blockLeft || blockRight)) {
				holeScore += kPartiallySurroundedScore;
			}
			// Left edge.
			else if(isOnLeftEdge && (blockAbove || blockBelow || blockRight)) {
				holeScore += kPartiallySurroundedScore;
			}
			// Right edge.
			else if(isOnRightEdge && (blockAbove || blockBelow || blockLeft)) {
				holeScore += kPartiallySurroundedScore;
			}
			// Middle space.
			else if((blockAbove && blockRight) || (blockAbove && blockBelow) || (blockAbove && blockLeft) || (blockRight && blockBelow) || (blockRight && blockLeft) || (blockBelow && blockLeft)) {
				holeScore += kPartiallySurroundedScore;
			}
			
			// Add the bonus, just for the block above being filled.
			if(blockAbove) {
				holeScore += kBlockAboveBonus;
			}
		}
	}
	
	return holeScore;
}
- (NSArray *)_scoresForSolutions:(NSArray *)solutions ofPiece:(SPGamePiece *)piece inGame:(SPGameController *)gameController {
	NSMutableArray *scores = [NSMutableArray array];
	for(SPSolution *solution in solutions) {
		// Calculate the depth score for this solution.
		const float depthScore = (float)solution.bottomEdgeRow / gameController.gridNumRows;
		const float kDepthWeight = 0.75f;
		
		// Calculate the number of holes on the board for this solution.
		NSSet *gameBoardBlocks = [gameController gameBlocksAfterMovingPiece:piece toLeftEdgeColumn:solution.leftEdgeColumn depth:solution.bottomEdgeRow orientation:solution.orientation];
		const CGFloat holeScore = [self _holeScoreForGameBoardBlocks:gameBoardBlocks inGame:gameController];
		const float kHoleWeight = -0.75f;
		
		// Add all of the scores (weighted) to get the aggregate score.
		const float aggregateScore = kDepthWeight * depthScore + kHoleWeight * holeScore;
		[scores addObject:[NSNumber numberWithFloat:aggregateScore]];
	};
	
	return scores;
}
- (SPGameActionType)_actionTypeToFulfillSolution:(SPSolution *)solution inGame:(SPGameController *)gameController {
	// First, check to see the difference in rotation.
	if(gameController.currentlyDroppingPiece.rotation != solution.orientation) {
		return SPGameActionRotate;
	}
	
	// Next, check for the difference in column.
	const NSInteger columnDiff = solution.leftEdgeColumn - gameController.currentlyDroppingPiece.leftEdgeColumn;
	if(columnDiff) {
		return columnDiff < 0 ? SPGameActionMoveLeft : SPGameActionMoveRight;
	}
	
	// Otherwise, just return "down".
	return SPGameActionMoveDown;
}
- (void)makeMoveInGame:(SPGameController *)gameController {
	// Figure out all of the possible ways the currently-dropping piece can land.
	NSArray *possibleSolutions = [self _possibleSolutionsForPiece:gameController.currentlyDroppingPiece gameController:gameController];
	
#if 1
#else
	// TODO: Cull solutions that are impossible (e.g. too far to get to).
	possibleSolutions = [self _culledSolutions:possibleSolutions forGame:gameController];
#endif
	
	// Determine a placement score for each solution (how "good" the placement would be).
	NSArray *solutionScores = [self _scoresForSolutions:possibleSolutions ofPiece:gameController.currentlyDroppingPiece inGame:gameController];
	
	// Get the highest-scored solution.
	__block CGFloat highestScore = -10000.0f;
	__block SPSolution *highestScoredSolution = nil;
	[possibleSolutions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGFloat solutionScore = [[solutionScores objectAtIndex:idx] floatValue];
		if(solutionScore > highestScore) {
			highestScore = solutionScore;
			highestScoredSolution = (SPSolution *)obj;
		}
	}];
	
	// Make the move to execute the solution with the highest score.
	SPGameActionType actionType = [self _actionTypeToFulfillSolution:highestScoredSolution inGame:gameController];
	
	// Randomly select a move.
	switch(actionType) {
		case SPGameActionRotate:
			[gameController rotateCurrentPiece];
			break;
			
		case SPGameActionMoveLeft:
			[gameController moveCurrentPieceLeft];
			break;
			
		case SPGameActionMoveRight:
			[gameController moveCurrentPieceRight];
			break;
			
		case SPGameActionMoveDown:
			// no-op.
			break;
			
		default:
			NSLog(@"WARNING: Game Player attempted to produce incorrect game action type: %i", actionType);
			break;
	}
}

@end
