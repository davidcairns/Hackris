//
//  SPGameAction.m
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameAction.h"

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
