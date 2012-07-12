//
//  SPHackrisSolution.h
//  Hackris
//
//  Created by David Cairns on 6/5/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPHackrisGameBoardDescription.h"

@interface SPHackrisSolution : NSObject
@property(nonatomic, strong)SPHackrisGameBoardDescription *boardDescription;

@property(nonatomic, assign)NSInteger leftEdgeColumn;
@property(nonatomic, assign)NSInteger bottomEdgeRow;
@property(nonatomic, assign)SPGamePieceRotation orientation;
@end
