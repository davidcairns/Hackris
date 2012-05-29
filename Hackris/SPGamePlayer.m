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

@implementation SPGamePlayer

- (void)makeMoveInGame:(SPGameController *)gameController {
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
}

@end
