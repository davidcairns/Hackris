//
//  SPGameController.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameController.h"
#import "SPGameController+SPGameInteraction.h"
#import "SPGameController+SPGameBoardAccess.h"
#import "SPGameAction.h"
#import "SPBlockSize.h"

#define DC_DRAW_BACKGROUND_GRID 1

#pragma mark 
@interface SPGameController ()
@property(nonatomic, strong)CALayer *gameContainerLayer;

// Game State
@property(nonatomic, assign)NSTimeInterval currentGameTime;
@property(nonatomic, assign)NSTimeInterval lastGameStepTimestamp;
@property(nonatomic, strong)SPGamePiece *currentlyDroppingPiece;
@property(nonatomic, strong)NSMutableSet *gameBlocks;

// Game Interaction.
@property(nonatomic, strong)SPGameAction *nextGameAction;
@property(nonatomic, strong)NSArray *grabbedBlocks;
@property(nonatomic, assign)CGPoint grabInitialTouchLocation;
@property(nonatomic, strong)NSArray *grabbedBlocksInitialLocations;
@end

@implementation SPGameController
@synthesize gameContainerLayer = _gameContainerLayer;
@synthesize gridNumRows = _gridNumRows;
@synthesize gridNumColumns = _gridNumColumns;
@synthesize gameStepInterval = _gameStepInterval;
@synthesize currentGameTime = _currentGameTime;
@synthesize lastGameStepTimestamp = _lastGameStepTimestamp;
@synthesize currentlyDroppingPiece = _currentlyDroppingPiece;
@synthesize gameBlocks = _gameBlocks;
@synthesize nextGameAction = _nextGameAction;
@synthesize grabbedBlocks = _grabbedBlocks;
@synthesize grabInitialTouchLocation = _grabInitialTouchLocation;
@synthesize grabbedBlocksInitialLocations = _grabbedBlocksInitialLocations;

- (id)init {
	if((self = [super init])) {
		// Seed the system random number generator!
		srand(time(NULL));
		
		// Create our game container layer.
		self.gameContainerLayer = [CALayer layer];
		self.gameContainerLayer.backgroundColor = [[UIColor blueColor] CGColor];
		self.gameContainerLayer.delegate = self;
		
		// Set up the game's rules.
		const CGRect screenBounds = [[UIScreen mainScreen] bounds];
		_gridNumRows = screenBounds.size.height / SPBlockSize;
		_gridNumColumns = screenBounds.size.width / SPBlockSize;
		_gameStepInterval = 0.05f;
		
		// Create our game's state objects.
		self.gameBlocks = [NSMutableSet set];
	}
	return self;
}


#pragma mark - CALayerDelegate
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
#if DC_DRAW_BACKGROUND_GRID
	// Push context state.
	CGContextSaveGState(ctx);
	
	if(layer == self.gameContainerLayer) {
		// Draw a grid!
		for(CGFloat penX = 0.0f; penX <= SPBlockSize * self.gridNumColumns; penX += SPBlockSize) {
			CGContextMoveToPoint(ctx, penX, 0.0f);
			CGContextAddLineToPoint(ctx, penX, SPBlockSize * self.gridNumRows);
		}
		for(CGFloat penY = 0.0f; penY <= SPBlockSize * self.gridNumRows; penY += SPBlockSize) {
			CGContextMoveToPoint(ctx, 0.0f, penY);
			CGContextAddLineToPoint(ctx, SPBlockSize * self.gridNumColumns, penY);
		}
		
		CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] CGColor]);
		CGContextStrokePath(ctx);
	}
	
	// Pop context state.
	CGContextRestoreGState(ctx);
#endif
}


#pragma mark 
- (void)resetGame {
	// Remove all of our game blocks.
	[self.gameBlocks enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		[(CALayer *)obj removeFromSuperlayer];
	}];
	[self.gameBlocks removeAllObjects];
	
	// Clear out pending game state.
	self.currentlyDroppingPiece = nil;
	self.nextGameAction = nil;
	self.currentGameTime = 0;
	self.lastGameStepTimestamp = 0;
	
	self.grabbedBlocks = nil;
	self.grabbedBlocksInitialLocations = nil;
}


- (NSInteger)fallDepthForPiece:(SPGamePiece *)piece leftEdgeColumn:(NSInteger)leftEdgeColumn orientation:(SPGamePieceRotation)orientation {
	// Get the arrangement of this piece's blocks for this orientation.
	NSArray *relativeBlockLocations = [SPGamePiece relativeBlockLocationsForPieceType:piece.gamePieceType orientation:orientation];
	
	// Determine how far we have to offset the whole piece based on this orientation (such that its left edge falls in the column specified).
	__block NSInteger pieceColumnOffset = 0;
	__block NSInteger pieceBottomRowOffset = 0;
	[relativeBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint relativeLocation = [(NSValue *)obj CGPointValue];
		const NSInteger columnOffsetForBlock = relativeLocation.x / SPBlockSize;
		pieceColumnOffset = MIN(pieceColumnOffset, columnOffsetForBlock);
		const NSInteger rowOffsetForBlock = relativeLocation.y / SPBlockSize;
		pieceBottomRowOffset = MAX(pieceBottomRowOffset, rowOffsetForBlock);
	}];
	
	NSInteger depth = -1;
	while(depth < self.gridNumRows) {
		depth++;
		
		// Determine the piece's absolute block locations given this depth.
		NSMutableArray *locations = [NSMutableArray array];
		[relativeBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			const CGPoint relativeLocation = [(NSValue *)obj CGPointValue];
			const CGPoint absoluteLocation = CGPointMake(relativeLocation.x + SPBlockSize * (CGFloat)(leftEdgeColumn - pieceColumnOffset) + 0.5f * SPBlockSize, relativeLocation.y + SPBlockSize * (CGFloat)depth + 0.5f * SPBlockSize);
			[locations addObject:[NSValue valueWithCGPoint:absoluteLocation]];
		}];
		
		if(![self _canMovePiece:piece toNewBlockLocations:locations]) {
			// Rewind to the last depth that worked.
			depth -= 1;
			break;
		}
	}
	
	return depth > 0 ? depth + pieceBottomRowOffset : 0;
}

- (SPGameBoardDescription *)descriptionOfCurrentBoard {
	return [SPGameBoardDescription gameBoardDescriptionForBlocks:self.gameBlocks gridNumRows:self.gridNumRows gridNumColumns:self.gridNumColumns];
}
- (SPGameBoardDescription *)descriptionOfCurrentBoardSansPiece:(SPGamePiece *)piece {
	NSMutableSet *gameBlocks = [self.gameBlocks mutableCopy];
	
	// Remove the blocks that are part of this piece.
	for(CALayer *pieceBlock in piece.componentBlocks) {
		[gameBlocks removeObject:pieceBlock];
	}
	
	// Create the game board description from these blocks and return it.
	return [SPGameBoardDescription gameBoardDescriptionForBlocks:gameBlocks gridNumRows:self.gridNumRows gridNumColumns:self.gridNumColumns];
}


- (BOOL)_canMovePiece:(SPGamePiece *)piece toNewBlockLocations:(NSArray *)newBlockLocations {
	__block BOOL foundIntersection = NO;
	[newBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint positionAfterMovement = [(NSValue *)obj CGPointValue];
		
		// Check to see if the component block hits the bottom of sides of the game board.
		if(positionAfterMovement.x < 0.5f * SPBlockSize || positionAfterMovement.x > SPBlockSize * self.gridNumColumns - 0.5f * SPBlockSize || positionAfterMovement.y > SPBlockSize * self.gridNumRows - 0.5f * SPBlockSize) {
			foundIntersection = YES;
			*stop = YES;
			return;
		}
		
		// Check to see if the component block intersects with any of the other game blocks.
		for(CALayer *gameBlock in self.gameBlocks) {
			// If this game block is part of the game piece in question, just bail -- a piece can't intersect with itself!
			if([piece.componentBlocks containsObject:gameBlock]) {
				continue;
			}
			
			// If this game block is currently being dragged, just bail.
			if([self.grabbedBlocks containsObject:gameBlock]) {
				continue;
			}
			
			// If this game block occupies the space below the piece's block.
			if((fabsf(positionAfterMovement.x - gameBlock.position.x) < 0.01f) && (fabsf(positionAfterMovement.y - gameBlock.position.y) < 0.01f)) {
				foundIntersection = YES;
				*stop = YES;
				break;
			}
		}
	}];
	
	return !foundIntersection;
}
- (void)_moveBlocksForPiece:(SPGamePiece *)piece toNewBlockLocations:(NSArray *)blockLocations {
	[CATransaction begin];
//	[CATransaction setAnimationDuration:0.1f];
	[CATransaction setDisableActions:YES];
	[piece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *componentBlock = (CALayer *)obj;
		componentBlock.position = [(NSValue *)[blockLocations objectAtIndex:idx] CGPointValue];
	}];
	[CATransaction commit];
}

- (BOOL)_canExecuteGameAction:(SPGameAction *)action againstPiece:(SPGamePiece *)piece {
	// Get the locations of the piece's component blocks after this action is applied.
	NSArray *newBlockLocations = [piece blockLocationsAfterApplyingAction:action];
	
	// Check to see if all of the piece's component blocks locations are valid.
	return [self _canMovePiece:piece toNewBlockLocations:newBlockLocations];
}
- (void)_executeGameAction:(SPGameAction *)action againstPiece:(SPGamePiece *)piece {
	NSArray *newBlockLocations = [piece blockLocationsAfterApplyingAction:action];
	[self _moveBlocksForPiece:piece toNewBlockLocations:newBlockLocations];
}


- (SPGamePiece *)_currentlyDroppingPiece {
	if(!self.currentlyDroppingPiece) {
//		NSLog(@"NEW PIECE!");
		
		// Create a piece with a randomly-selected type.
		const SPGamePieceType gamePieceType = rand() % SPGamePieceNumTypes;
		self.currentlyDroppingPiece = [[SPGamePiece alloc] initWithGamePieceType:gamePieceType];
		
		// Add the game piece's component blocks and position them.
		const NSInteger droppingPieceBlockOffset = self.gridNumColumns / 2;
		const CGPoint droppingPieceOrigin = CGPointMake((CGFloat)droppingPieceBlockOffset * SPBlockSize, -1.0f * [self.currentlyDroppingPiece numBlocksHigh] * SPBlockSize);
		[self.currentlyDroppingPiece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			CALayer *componentBlock = (CALayer *)obj;
			componentBlock.position = CGPointMake(droppingPieceOrigin.x + componentBlock.position.x, droppingPieceOrigin.y + componentBlock.position.y);
			
			[self.gameContainerLayer addSublayer:componentBlock];
			[self.gameBlocks addObject:componentBlock];
		}];
	}
	
	return self.currentlyDroppingPiece;
}
- (void)_clearCurrentlyDroppingPiece {
	self.currentlyDroppingPiece = nil;
}

- (NSSet *)_blocksInRow:(NSInteger)rowIndex {
	// NOTE: Rows are indexed from the bottom (highest y-coordinate) to the top (lowest y-coordinate).
	
	// Determine which y-value corresponds to this row.
	const CGFloat rowY = self.gameContainerLayer.bounds.size.height - SPBlockSize * (CGFloat)rowIndex - 0.5f * SPBlockSize;
	
	NSMutableSet *blocks = [NSMutableSet set];
	[self.gameBlocks enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		CALayer *gameBlock = (CALayer *)obj;
		if(fabsf(gameBlock.position.y - rowY) < 0.001f) {
			[blocks addObject:gameBlock];
		}
	}];
	
	return [NSSet setWithSet:blocks];
}
- (void)_performLineClearIfNecessary {
	NSInteger rowIndex = 0;
	while(rowIndex < self.gridNumRows) {
		// Check each row for filled-ness.
		NSSet *blocksInRow = [self _blocksInRow:rowIndex];
		// NOTE: Blocks from the currently-dropping piece don't count for filled-ness.
		const BOOL rowContainsDroppingBlocks = [blocksInRow intersectsSet:[NSSet setWithArray:self.currentlyDroppingPiece.componentBlocks]];
		// NOTE: Blocks currently 'grabbed' also do not count.
		const BOOL rowContainsGrabbedBlocks = [blocksInRow intersectsSet:[NSSet setWithArray:self.grabbedBlocks]];
		if(blocksInRow.count >= self.gridNumColumns && !rowContainsDroppingBlocks && !rowContainsGrabbedBlocks) {
			// Clear the row!
			[CATransaction begin];
			[CATransaction setDisableActions:YES];
			[CATransaction setCompletionBlock:^ {
				// Remove the blocks from the layer hierarchy.
				for(CALayer *block in blocksInRow) {
					[block removeFromSuperlayer];
					[self.gameBlocks removeObject:block];
				}
				
				// Make all of the higher lines fall.
				[CATransaction begin];
				[CATransaction setDisableActions:YES];
				for(NSInteger fallingRowIndex = rowIndex + 1; fallingRowIndex < self.gridNumRows; fallingRowIndex++) {
					NSSet *fallingRowBlocks = [self _blocksInRow:fallingRowIndex];
					[fallingRowBlocks enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
						CALayer *fallingBlock = (CALayer *)obj;
						fallingBlock.position = CGPointMake(fallingBlock.position.x, fallingBlock.position.y + SPBlockSize);
					}];
				}
				[CATransaction commit];
			}];
			[blocksInRow enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
				CALayer *block = (CALayer *)obj;
				[self.gameBlocks removeObject:block];
				
				// Animate the blocks flying off to the side.
				block.position = CGPointMake(block.position.x - SPBlockSize * self.gridNumColumns, block.position.y);
			}];
			[CATransaction commit];
		}
		else {
			// Move up to the next line.
			rowIndex++;
		}
	}
}

- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta {
	// Increment the current game time.
	self.currentGameTime += timeDelta;
	
	// Get the currently-dropping piece.
	SPGamePiece *currentPiece = [self _currentlyDroppingPiece];
	
	// Determine if it's time to move the currently-dropping piece down.
	if(self.currentGameTime - self.lastGameStepTimestamp >= self.gameStepInterval) {
		// Step the game state.
		self.lastGameStepTimestamp += self.gameStepInterval;
		
		// See if we can move the piece down.
		NSArray *newBlockLocations = [currentPiece blockLocationsAfterApplyingAction:[SPGameAction gameActionWithType:SPGameActionMoveDown]];
		if([self _canMovePiece:currentPiece toNewBlockLocations:newBlockLocations]) {
			[self _moveBlocksForPiece:currentPiece toNewBlockLocations:newBlockLocations];
		}
		else {
			// Check to see if the game has "clogged".
			if([(CALayer *)currentPiece.componentBlocks.lastObject position].y < 0.0f) {
				[self resetGame];
			}
			else {
				[self _clearCurrentlyDroppingPiece];
				
				// Also clear the next game action; it's no longer valid!
				self.nextGameAction = nil;
			}
		}
		
		// Determine if it's time to execute the next game action.
		if(self.nextGameAction) {
			// If we can do so, execute the game action.
			if([self _canExecuteGameAction:self.nextGameAction againstPiece:currentPiece]) {
				// Actually execute the game action.
				[self _executeGameAction:self.nextGameAction againstPiece:currentPiece];
				
				// If this was a rotation action, update the piece's rotation.
				if(SPGameActionRotate == self.nextGameAction.type) {
					self.currentlyDroppingPiece.rotation = (self.currentlyDroppingPiece.rotation + 1) % SPGamePieceRotationNumAngles;
				}
			}
			
			// Clear the game action.
			self.nextGameAction = nil;
		}
		
		// Check for line-clear!
		[self _performLineClearIfNecessary];
	}
	
	// Make sure our background layer gets displayed.
	[self.gameContainerLayer setNeedsDisplay];
}


#pragma mark - Interaction
- (CGPoint)_closestIntersectionForTouchLocation:(CGPoint)touchLocation {
	// Determine the location intersection closest to this touch location.
	const NSInteger closestColumn = roundf(touchLocation.x / SPBlockSize);
	const NSInteger closestRow = roundf(touchLocation.y / SPBlockSize);
	CGPoint closestIntersection = CGPointMake(SPBlockSize * (CGFloat)closestColumn, SPBlockSize * (CGFloat)closestRow);
	closestIntersection.x = MAX(SPBlockSize, MIN(closestIntersection.x, SPBlockSize * self.gridNumColumns - SPBlockSize));
	closestIntersection.y = MAX(SPBlockSize, MIN(closestIntersection.y, SPBlockSize * self.gridNumRows - SPBlockSize));
	return closestIntersection;
}
- (void)grabBlocksNearestTouchLocation:(CGPoint)touchLocation {
	// Determine the location intersection closest to this touch location.
	const CGPoint closestIntersection = [self _closestIntersectionForTouchLocation:touchLocation];
	
	// Determine the radius in which to search.
	const CGFloat searchRadius = sqrtf(SPBlockSize * SPBlockSize + SPBlockSize * SPBlockSize);
	
	// Find the (maximum four) blocks closest to the location intersection.
	NSMutableArray *closestBlocks = [NSMutableArray array];
	[self.gameBlocks enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
		CALayer *gameBlock = (CALayer *)obj;
		
		// If this block is part of the currently-dropping piece, just bail.
		if([self.currentlyDroppingPiece.componentBlocks containsObject:gameBlock]) {
			return;
		}
		
		// Calculate the distance between this game block and our 'closest intersection'.
		const CGFloat xDiff = fabsf(gameBlock.position.x - closestIntersection.x);
		const CGFloat yDiff = fabsf(gameBlock.position.y - closestIntersection.y);
		const CGFloat distanceFromClosestIntersection = sqrtf(xDiff * xDiff + yDiff * yDiff);
		
		// If this game block is within our search radius, and isn't part of the currently-dropping piece, add it to our 'closest blocks'.
		if(distanceFromClosestIntersection <= searchRadius && ![self.currentlyDroppingPiece.componentBlocks containsObject:gameBlock]) {
			gameBlock.shadowRadius = 20.0f;
			gameBlock.shadowOpacity = 0.75f;
			[closestBlocks addObject:gameBlock];
		}
	}];
	
	// Set our grabbed-blocks collection
	self.grabbedBlocks = [NSArray arrayWithArray:closestBlocks];
	self.grabInitialTouchLocation = closestIntersection;
	
	NSMutableArray *grabbedBlockLocations = [NSMutableArray array];
	for(CALayer *grabbedBlock in self.grabbedBlocks) {
		[grabbedBlockLocations addObject:[NSValue valueWithCGPoint:grabbedBlock.position]];
	}
	self.grabbedBlocksInitialLocations = [NSArray arrayWithArray:grabbedBlockLocations];
}
- (void)moveGrabbedBlocksToTouchLocation:(CGPoint)touchLocation {
	// Determine the nearest location intersection to pop to.
	const CGPoint closestIntersection = [self _closestIntersectionForTouchLocation:touchLocation];
	
	// Calculate the movement vector from the initial grab point to this intersection point.
	const CGPoint movementVector = CGPointMake(closestIntersection.x - self.grabInitialTouchLocation.x, closestIntersection.y - self.grabInitialTouchLocation.y);
	
	// Place our grabbed blocks in the spaces surrounding the drop point.
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	[self.grabbedBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *grabbedBlock = (CALayer *)obj;
		CGPoint blockInitialLocation = [(NSValue *)[self.grabbedBlocksInitialLocations objectAtIndex:idx] CGPointValue];
		grabbedBlock.position = CGPointMake(blockInitialLocation.x + movementVector.x, blockInitialLocation.y + movementVector.y);
	}];
	[CATransaction commit];
}
- (void)dropGrabbedBlocksAtTouchLocation:(CGPoint)touchLocation {
	// Make sure the blocks get to the right place.
	[self moveGrabbedBlocksToTouchLocation:touchLocation];
	
	// Reset the display state of the grabbed blocks.
	[self.grabbedBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *grabbedBlock = (CALayer *)obj;
		grabbedBlock.shadowRadius = 0.0f;
		grabbedBlock.shadowOpacity = 0.0f;
	}];
	
	// Clear our grabbed-blocks collection.
	self.grabbedBlocks = nil;
	self.grabbedBlocksInitialLocations = nil;
}

@end


#pragma mark 
@implementation SPGameController (SPGameInteraction)
- (void)moveCurrentPieceLeft {
	self.nextGameAction = [SPGameAction gameActionWithType:SPGameActionMoveLeft];
}
- (void)moveCurrentPieceRight {
	self.nextGameAction = [SPGameAction gameActionWithType:SPGameActionMoveRight];
}
- (void)rotateCurrentPiece {
	self.nextGameAction = [SPGameAction gameActionWithType:SPGameActionRotate];
}
@end


#pragma mark 
@implementation SPGameController (SPGameBoardAccess)
- (NSSet *)gameBlocksSet {
	return [NSSet setWithSet:self.gameBlocks];
}
@end
