//
//  SPHackrisSolution.m
//  Hackris
//
//  Created by David Cairns on 6/5/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPHackrisSolution.h"

@implementation SPHackrisSolution
@synthesize boardDescription = _boardDescription;
@synthesize leftEdgeColumn = _leftEdgeColumn;
@synthesize bottomEdgeRow = _bottomEdgeRow;
@synthesize orientation = _orientation;

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@ %p -- left edge column: %i, bottom edge row: %i, orientation: %i>", [self class], self, self.leftEdgeColumn, self.bottomEdgeRow, self.orientation];
}

@end
