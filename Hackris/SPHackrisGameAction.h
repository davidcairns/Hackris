//
//  SPHackrisGameAction.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SPHackrisGameActionRotate = 0, 
	SPHackrisGameActionMoveLeft, 
	SPHackrisGameActionMoveRight, 
	SPHackrisGameActionMoveDown, 
	SPGameNumActions, 
} SPHackrisGameActionType;
NSString *SPHackrisGameActionNameForType(SPHackrisGameActionType type);


@interface SPHackrisGameAction : NSObject

+ (SPHackrisGameAction *)gameActionWithType:(SPHackrisGameActionType)type;

@property(nonatomic, assign, readonly)SPHackrisGameActionType type;

@end
