//
//  SPGameController+SPGameInteraction.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameController.h"

@interface SPGameController (SPGameInteraction)

// Interacting with game state.
- (void)moveCurrentPieceLeft;
- (void)moveCurrentPieceRight;
- (void)rotateCurrentPiece;

@end
