//
//  SPGameAction.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SPGameActionRotate = 0, 
	SPGameActionMoveLeft, 
	SPGameActionMoveRight, 
	SPGameActionMoveDown, 
	SPGameNumActions, 
} SPGameActionType;
NSString *SPGameActionNameForType(SPGameActionType type);


@interface SPGameAction : NSObject

+ (SPGameAction *)gameActionWithType:(SPGameActionType)type;

@property(nonatomic, assign, readonly)SPGameActionType type;

@end
