//
//  SPHackrisGameController+SPGameInteraction.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPHackrisGameController.h"

@interface SPHackrisGameController (SPGameInteraction)

// Interacting with game state.
- (void)moveCurrentPieceLeft;
- (void)moveCurrentPieceRight;
- (void)rotateCurrentPiece;

@end
