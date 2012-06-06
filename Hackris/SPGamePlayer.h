//
//  SPGamePlayer.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGameController.h"
#import "SPSolution.h"
#import "SPGameAction.h"

@interface SPGamePlayer : NSObject

#if 1
- (SPSolution *)solutionForGame:(SPGameController *)gameController;
- (SPGameActionType)actionTypeToFulfillSolution:(SPSolution *)solution inGame:(SPGameController *)gameController;
#else
- (void)makeMoveInGame:(SPGameController *)gameController;
#endif

@end
