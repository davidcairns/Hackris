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
- (NSInteger)_numberOfHolesInGameBoardBlocks:(NSSet *)gameBoardBlocks inGame:(SPGameController *)gameController {
	// Find the number of holes (open spaces surrounded by four blocks).
	NSInteger numHoles = 0;
	for(NSInteger rowIndex = 0; rowIndex < gameController.gridNumRows; rowIndex++) {
		for(NSInteger columnIndex = 0; columnIndex < gameController.gridNumColumns; columnIndex++) {
			// Get the location for this (row, column).
			const CGPoint location = [self _locationForRow:rowIndex column:columnIndex];
			
			// If this space contains a block, bail this iteration.
			if([self _blockAtLocation:location inGroup:gameBoardBlocks]) {
				continue;
			}
			
			// Check the spaces around this one.
			CALayer *blockAbove = [self _blockAtLocation:[self _locationForRow:rowIndex - 1 column:columnIndex] inGroup:gameBoardBlocks];
			CALayer *blockBelow = [self _blockAtLocation:[self _locationForRow:rowIndex + 1 column:columnIndex] inGroup:gameBoardBlocks];
			CALayer *blockLeft = [self _blockAtLocation:[self _locationForRow:rowIndex column:columnIndex - 1] inGroup:gameBoardBlocks];
			CALayer *blockRight = [self _blockAtLocation:[self _locationForRow:rowIndex column:columnIndex + 1] inGroup:gameBoardBlocks];
			// Check for spaces at the bottom edge.
			if((gameController.gridNumRows - 1 == rowIndex) && blockAbove && blockLeft && blockRight) {
				numHoles++;
			}
			// Check for spaces on the left edge.
			else if((0 == columnIndex) && blockAbove && blockBelow && blockRight) {
				numHoles++;
			}
			// Check for spaces on the right edge.
			else if((gameController.gridNumColumns - 1 == columnIndex) && blockAbove && blockBelow && blockLeft) {
				numHoles++;
			}
			// Check for spaces in the middle.
			else if(blockAbove && blockBelow && blockLeft && blockRight) {
				numHoles++;
			}
		}
	}
	
	return numHoles;
}
- (NSArray *)_scoresForSolutions:(NSArray *)solutions ofPiece:(SPGamePiece *)piece inGame:(SPGameController *)gameController {
	NSMutableArray *scores = [NSMutableArray array];
	[solutions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		SPSolution *solution = (SPSolution *)obj;
		
		// Calculate the depth score for this solution.
		const float depthScore = (float)solution.bottomEdgeRow / gameController.gridNumRows;
		const float kDepthWeight = 0.25f;
		
		// Calculate the number of holes on the board for this solution.
		NSSet *gameBoardBlocks = [gameController gameBlocksAfterAddingPieceOfType:piece.gamePieceType leftEdgeColumn:solution.leftEdgeColumn depth:solution.bottomEdgeRow orientation:solution.orientation];
		const NSInteger numberOfHoles = [self _numberOfHolesInGameBoardBlocks:gameBoardBlocks inGame:gameController];
		const float holeScore = (float)(gameController.gridNumRows * gameController.gridNumColumns - numberOfHoles) / (float)(gameController.gridNumRows * gameController.gridNumColumns);
		const float kHoleWeight = 0.75f;
		
		// Add all of the scores (weighted) to get the aggregate score.
		const float aggregateScore = kDepthWeight * depthScore + kHoleWeight * holeScore;
		[scores addObject:[NSNumber numberWithFloat:aggregateScore]];
	}];
	
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
	NSMutableArray *possibleSolutions = [NSMutableArray arrayWithArray:[self _possibleSolutionsForPiece:gameController.currentlyDroppingPiece gameController:gameController]];
//	NSLog(@"Possible solutions: %@", possibleSolutions);
	
#if 1
#else
	// TODO: Cull solutions that are impossible (e.g. too far to get to).
	possibleSolutions = [self _culledSolutions:possibleSolutions forGame:gameController];
#endif
	
	// Determine a placement score for each solution (how "good" the placement would be).
	NSArray *solutionScores = [self _scoresForSolutions:possibleSolutions ofPiece:gameController.currentlyDroppingPiece inGame:gameController];
	
	// Get the highest-scored solution.
	__block float highestScore = -1;
	__block SPSolution *highestScoredSolution = nil;
	[possibleSolutions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const float solutionScore = [[solutionScores objectAtIndex:idx] floatValue];
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
