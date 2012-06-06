//
//  SPSolution.h
//  Hackris
//
//  Created by David Cairns on 6/5/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPGameBoardDescription.h"

@interface SPSolution : NSObject
@property(nonatomic, strong)SPGameBoardDescription *boardDescription;

@property(nonatomic, assign)NSInteger leftEdgeColumn;
@property(nonatomic, assign)NSInteger bottomEdgeRow;
@property(nonatomic, assign)SPGamePieceRotation orientation;
@end
