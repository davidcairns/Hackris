//
//  SPGamePlayer.m
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGamePlayer.h"
#import "SPGameController+SPGameInteraction.h"
#import "SPGamePiece.h"
#import "SPBlockSize.h"

@implementation SPGamePlayer

+ (NSArray *)_possibleSolutionsForPiece:(SPGamePiece *)currentlyDroppingPiece baseBoardDescription:(SPGameBoardDescription *)baseGameBoardDescription {
	// For each column...
	NSMutableArray *solutions = [NSMutableArray array];
	for(NSInteger columnOffset = 0; columnOffset < baseGameBoardDescription.gridNumColumns; columnOffset++) {
		// Generate each valid solution in which the piece's left edge is in this column.
		for(SPGamePieceRotation orientation = 0; orientation < SPGamePieceRotationNumAngles; orientation++) {
			// Determine the depth to which this block would fall (in rows, from the top).
			const NSInteger fallDepth = [baseGameBoardDescription fallDepthForPiece:currentlyDroppingPiece leftEdgeColumn:columnOffset orientation:orientation];
			
			// If the piece will fall at all, save this solution.
			if(fallDepth > 0) {
				SPSolution *solution = [[SPSolution alloc] init];
				
				// Generate a game board description for this solution combo.
				solution.boardDescription = [baseGameBoardDescription gameBoardDescriptionByAddingPiece:currentlyDroppingPiece toLeftEdgeColumn:columnOffset depth:fallDepth orientation:orientation];
				
				solution.leftEdgeColumn = columnOffset;
				solution.orientation = orientation;
				solution.bottomEdgeRow = fallDepth;
				[solutions addObject:solution];
			}
		}
	}
	
	return solutions;
}
+ (CGFloat)_holeScoreForGameBoardDescription:(SPGameBoardDescription *)gameBoardDescription {
	// NOTE: How this algorithm calculates the score:
	//			• 1.0 for a space surrounded on all sides
	//			• 0.75 for a space surrounded on all sides but one
	//			• 0.5 for a space surrounded on all sides but two
	//			* A “bonus” of 0.1, if there's a block above at all
	//	const CGFloat kTotallySurroundedScore = 1.0f;
	//	const CGFloat kMostlySurroundedScore = 0.5f;
	//	const CGFloat kPartiallySurroundedScore = 0.2f;
	//	const CGFloat kBlockAboveBonus = 1.0f;
	const CGFloat kTotallySurroundedScore = 1.0f;
	const CGFloat kMostlySurroundedScore = 0.5f;
	const CGFloat kPartiallySurroundedScore = 0.2f;
	const CGFloat kBlockAboveBonus = 1.0f;
	
	// Find the number of holes (open spaces surrounded by four blocks).
	CGFloat holeScore = 0.0f;
	for(NSInteger rowIndex = 0; rowIndex < gameBoardDescription.gridNumRows; rowIndex++) {
		for(NSInteger columnIndex = 0; columnIndex < gameBoardDescription.gridNumColumns; columnIndex++) {
			// If this space contains a block, bail this iteration.
			if([gameBoardDescription hasBlockAtRow:rowIndex column:columnIndex]) {
				continue;
			}
			
			// Check for spaces surrounded on all sides.
			const BOOL isOnBottomEdge = (gameBoardDescription.gridNumRows - 1 == rowIndex);
			const BOOL isOnLeftEdge = (0 == columnIndex);
			const BOOL isOnRightEdge = (gameBoardDescription.gridNumColumns - 1 == columnIndex);
			const BOOL isOnBottomLeftCorner = isOnBottomEdge && isOnLeftEdge;
			const BOOL isOnBottomRightCorner = isOnBottomEdge && isOnRightEdge;
			const BOOL hasBlockAbove = [gameBoardDescription hasBlockAtRow:rowIndex - 1 column:columnIndex];
			const BOOL hasBlockBelow = [gameBoardDescription hasBlockAtRow:rowIndex + 1 column:columnIndex];
			const BOOL hasBlockLeft = [gameBoardDescription hasBlockAtRow:rowIndex column:columnIndex - 1];
			const BOOL hasBlockRight = [gameBoardDescription hasBlockAtRow:rowIndex column:columnIndex + 1];
			// Check for the bottom-left corner.
			if(isOnBottomLeftCorner && hasBlockAbove && hasBlockRight) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for the bottom-right corner.
			else if(isOnBottomRightCorner && hasBlockAbove && hasBlockLeft) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces at the bottom edge.
			else if(isOnBottomEdge && hasBlockAbove && hasBlockLeft && hasBlockRight) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces on the left edge.
			else if(isOnLeftEdge && hasBlockAbove && hasBlockBelow && hasBlockRight) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces on the right edge.
			else if(isOnRightEdge && hasBlockAbove && hasBlockBelow && hasBlockLeft) {
				holeScore += kTotallySurroundedScore;
			}
			// Check for spaces in the middle.
			else if(hasBlockAbove && hasBlockBelow && hasBlockLeft && hasBlockRight) {
				holeScore += kTotallySurroundedScore;
			}
			
			// Check for spaces surrounded on all sides but one.
			// Bottom-left corner.
			else if(isOnBottomLeftCorner && (hasBlockAbove || hasBlockRight)) {
				holeScore += kMostlySurroundedScore;
			}
			// Bottom-right corner.
			else if(isOnBottomRightCorner && (hasBlockAbove || hasBlockLeft)) {
				holeScore += kMostlySurroundedScore;
			}
			// Bottom edge.
			else if(isOnBottomEdge && ((hasBlockAbove && hasBlockLeft) || (hasBlockAbove && hasBlockRight) || (hasBlockLeft && hasBlockRight))) {
				holeScore += kMostlySurroundedScore;
			}
			// Left edge.
			else if(isOnLeftEdge && ((hasBlockAbove && hasBlockBelow) || (hasBlockAbove && hasBlockRight) || (hasBlockBelow && hasBlockRight))) {
				holeScore += kMostlySurroundedScore;
			}
			// Right edge.
			else if(isOnRightEdge && ((hasBlockAbove && hasBlockBelow) || (hasBlockAbove && hasBlockLeft) || (hasBlockBelow && hasBlockLeft))) {
				holeScore += kMostlySurroundedScore;
			}
			// Middle space.
			else if((hasBlockAbove && hasBlockLeft && hasBlockRight) || (hasBlockAbove && hasBlockBelow && hasBlockLeft) || (hasBlockAbove && hasBlockBelow && hasBlockRight) || (hasBlockBelow && hasBlockLeft && hasBlockRight)) {
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
			else if(isOnBottomEdge && (hasBlockAbove || hasBlockLeft || hasBlockRight)) {
				holeScore += kPartiallySurroundedScore;
			}
			// Left edge.
			else if(isOnLeftEdge && (hasBlockAbove || hasBlockBelow || hasBlockRight)) {
				holeScore += kPartiallySurroundedScore;
			}
			// Right edge.
			else if(isOnRightEdge && (hasBlockAbove || hasBlockBelow || hasBlockLeft)) {
				holeScore += kPartiallySurroundedScore;
			}
			// Middle space.
			else if((hasBlockAbove && hasBlockRight) || (hasBlockAbove && hasBlockBelow) || (hasBlockAbove && hasBlockLeft) || (hasBlockRight && hasBlockBelow) || (hasBlockRight && hasBlockLeft) || (hasBlockBelow && hasBlockLeft)) {
				holeScore += kPartiallySurroundedScore;
			}
			
			// Add the bonus, just for the block above being filled.
			if(hasBlockAbove) {
				holeScore += kBlockAboveBonus;
			}
		}
	}
	
	return holeScore;
}
+ (NSArray *)_scoresForSolutions:(NSArray *)solutions ofPiece:(SPGamePiece *)piece {
	NSMutableArray *scores = [NSMutableArray array];
	for(SPSolution *solution in solutions) {
		SPGameBoardDescription *gameBoardDescription = solution.boardDescription;
		
		// Calculate the depth score for this solution.
		const float depthScore = (float)solution.bottomEdgeRow / gameBoardDescription.gridNumRows;
		const float kDepthWeight = 0.75f;
		
		// Calculate the number of holes on the board for this solution.
		const CGFloat holeScore = [[self class] _holeScoreForGameBoardDescription:gameBoardDescription];
		const float kHoleWeight = -0.75f;
		
		// Add all of the scores (weighted) to get the aggregate score.
		const float aggregateScore = kDepthWeight * depthScore + kHoleWeight * holeScore;
		[scores addObject:[NSNumber numberWithFloat:aggregateScore]];
	};
	
	return scores;
}

#if 1
- (SPSolution *)solutionForGame:(SPGameController *)gameController {
	SPGamePiece *currentPiece = gameController.currentlyDroppingPiece;
	if(!currentPiece) {
		return nil;
	}
	
	// Get the base game board description, from which all of our solutions will stem.
	SPGameBoardDescription *baseGameBoardDescription = [gameController descriptionOfCurrentBoardSansPiece:currentPiece];
	
	// Figure out all of the possible ways the currently-dropping piece can land.
	NSArray *possibleSolutions = [[self class] _possibleSolutionsForPiece:currentPiece baseBoardDescription:baseGameBoardDescription];
	
	// Determine a placement score for each solution (how "good" the placement would be).
	NSArray *solutionScores = [[self class] _scoresForSolutions:possibleSolutions ofPiece:currentPiece];
	
	// Get the highest-scored solution.
	__block CGFloat highestScore = -10000.0f;
	__block SPSolution *highestScoredSolution = nil;
	[possibleSolutions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		SPSolution *solution = (SPSolution *)obj;
		const CGFloat solutionScore = [[solutionScores objectAtIndex:idx] floatValue];
		if(solutionScore > highestScore) {
			highestScore = solutionScore;
			highestScoredSolution = solution;
		}
		
		//		NSLog(@"%@ -- score: %f", solution, solutionScore);
	}];
	
	return highestScoredSolution;
}
- (SPGameActionType)actionTypeToFulfillSolution:(SPSolution *)solution inGame:(SPGameController *)gameController {
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
#else
- (SPGameActionType)actionTypeToFulfillSolution:(SPSolution *)solution inGame:(SPGameController *)gameController {
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
	SPGamePiece *currentPiece = gameController.currentlyDroppingPiece;
	if(!currentPiece) {
		return;
	}
	
	// Get the base game board description, from which all of our solutions will stem.
	SPGameBoardDescription *baseGameBoardDescription = [gameController descriptionOfCurrentBoardSansPiece:currentPiece];
	
	// Figure out all of the possible ways the currently-dropping piece can land.
	NSArray *possibleSolutions = [[self class] _possibleSolutionsForPiece:currentPiece baseBoardDescription:baseGameBoardDescription];
	
	// Determine a placement score for each solution (how "good" the placement would be).
	NSArray *solutionScores = [[self class] _scoresForSolutions:possibleSolutions ofPiece:currentPiece];
	
	// Get the highest-scored solution.
	__block CGFloat highestScore = -10000.0f;
	__block SPSolution *highestScoredSolution = nil;
	[possibleSolutions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		SPSolution *solution = (SPSolution *)obj;
		const CGFloat solutionScore = [[solutionScores objectAtIndex:idx] floatValue];
		if(solutionScore > highestScore) {
			highestScore = solutionScore;
			highestScoredSolution = solution;
		}
		
//		NSLog(@"%@ -- score: %f", solution, solutionScore);
	}];
	
	// Make the move to execute the solution with the highest score.
	SPGameActionType actionType = [self actionTypeToFulfillSolution:highestScoredSolution inGame:gameController];
	
//	NSLog(@"Best solution: %@ --> action: %@", highestScoredSolution, SPGameActionNameForType(actionType));
	
	// Execute the move.
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
#endif

@end
