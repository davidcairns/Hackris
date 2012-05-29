//
//  SPGamePlayer.h
//  Hackris
//
//  Created by David Cairns on 5/29/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPGameController.h"

@interface SPGamePlayer : NSObject

- (void)makeMoveInGame:(SPGameController *)gameController;

@end
