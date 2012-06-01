//
//  SPGameBoardDescription.h
//  Hackris
//
//  Created by David Cairns on 6/1/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPGameBoardDescription : NSObject

+ (SPGameBoardDescription *)gameBoardDescriptionForBlocks:(NSSet *)gameBlocks gridNumRows:(NSInteger)gridNumRows gridNumColumns:(NSInteger)gridNumColumns;

@property(nonatomic, assign, readonly)NSInteger gridNumRows;
@property(nonatomic, assign, readonly)NSInteger gridNumColumns;

- (BOOL)hasBlockAtRow:(NSInteger)rowIndex column:(NSInteger)columnIndex;

@end
