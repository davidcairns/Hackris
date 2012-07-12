//
//  SPGamePlayer.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPHackrisGameController.h"
#import "SPHackrisSolution.h"
#import "SPHackrisGameAction.h"

@interface SPHackrisGamePlayer : NSObject

- (SPHackrisSolution *)solutionForGame:(SPHackrisGameController *)gameController;
- (SPHackrisGameActionType)actionTypeToFulfillSolution:(SPHackrisSolution *)solution inGame:(SPHackrisGameController *)gameController;

@end
