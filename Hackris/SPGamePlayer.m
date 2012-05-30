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
@end


@implementation SPGamePlayer

- (NSSet *)_possibleSolutionsForPiece:(SPGamePiece *)currentlyDroppingPiece gameController:(SPGameController *)gameController {
	// For each column...
	NSMutableSet *solutions = [NSMutableSet set];
	for(NSInteger columnOffset = 0; columnOffset < gameController.gridNumColumns; columnOffset++) {
		// Generate each valid solution in which the piece's left edge is in this column.
		for(SPGamePieceRotation orientation = 0; orientation < SPGamePieceRotationNumAngles; orientation++) {
			if(1) {
				SPSolution *solution = [[SPSolution alloc] init];
				solution.leftEdgeColumn = columnOffset;
				solution.orientation = orientation;
				
				// Determine the depth to which this block would fall (in rows, from the top).
				solution.bottomEdgeRow = [gameController fallDepthForPiece:currentlyDroppingPiece leftEdgeColumn:columnOffset orientation:orientation];
				
				[solutions addObject:solution];
			}
		}
	}
	
	return [NSSet setWithSet:solutions];
}
- (void)makeMoveInGame:(SPGameController *)gameController {
#if 0
	// Figure out all of the possible ways the currently-dropping piece can land.
	NSMutableSet *possibleSolutions = [NSMutableSet setWithSet:[self _possibleSolutionsForPiece:gameController.currentlyDroppingPiece gameController:gameController]];
	
	// TODO: Determine a placement score for each solution (how "good" the placement would be).
	
	// TODO: Cull solutions that are impossible (e.g. too far to get to).
	
	// TODO: Make the move to execute the solution with the highest score.
	
	
#else
	// Randomly select a move.
	SPGameActionType actionType = rand() % SPGameNumActions;
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
#endif
}

@end
