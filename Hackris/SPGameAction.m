//
//  SPGameAction.m
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameAction.h"

NSString *SPGameActionNameForType(SPGameActionType type) {
	switch(type) {
		case SPGameActionRotate:
			return @"SPGameActionRotate";
			break;
		case SPGameActionMoveLeft:
			return @"SPGameActionMoveLeft";
			break;
		case SPGameActionMoveRight:
			return @"SPGameActionMoveRight";
			break;
		case SPGameActionMoveDown:
			return @"SPGameActionMoveDown";
			break;
		default:
			return @"???";
			break;
	}
}

@interface SPGameAction ()
@property(nonatomic, assign)SPGameActionType type;
@end

@implementation SPGameAction
@synthesize type = _type;

+ (SPGameAction *)gameActionWithType:(SPGameActionType)type {
	SPGameAction *gameAction = [[SPGameAction alloc] init];
	gameAction.type = type;
	return gameAction;
}

@end
