//
//  SPHackrisGameAction.m
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPHackrisGameAction.h"

NSString *SPHackrisGameActionNameForType(SPHackrisGameActionType type) {
	switch(type) {
		case SPHackrisGameActionRotate:
			return @"SPHackrisGameActionRotate";
			break;
		case SPHackrisGameActionMoveLeft:
			return @"SPHackrisGameActionMoveLeft";
			break;
		case SPHackrisGameActionMoveRight:
			return @"SPHackrisGameActionMoveRight";
			break;
		case SPHackrisGameActionMoveDown:
			return @"SPHackrisGameActionMoveDown";
			break;
		default:
			return @"???";
			break;
	}
}

@interface SPHackrisGameAction ()
@property(nonatomic, assign)SPHackrisGameActionType type;
@end

@implementation SPHackrisGameAction
@synthesize type = _type;

+ (SPHackrisGameAction *)gameActionWithType:(SPHackrisGameActionType)type {
	SPHackrisGameAction *gameAction = [[SPHackrisGameAction alloc] init];
	gameAction.type = type;
	return gameAction;
}

@end
