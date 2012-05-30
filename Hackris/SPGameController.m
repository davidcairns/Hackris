//
//  SPGameController.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameController.h"
#import "SPGamePiece.h"
#import "SPGameController+SPGameInteraction.h"
#import "SPGameAction.h"

#define DC_DRAW_BACKGROUND_GRID 1

#pragma mark 
@interface SPGameController ()
@property(nonatomic, strong)CALayer *gameContainerLayer;

// Game Rules
@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;
@property(nonatomic, readonly)NSTimeInterval gameStepInterval;
// How often the (computer) 'player' can issue game actions:
@property(nonatomic, readonly)NSTimeInterval gameActionInterval;

// Game State
@property(nonatomic, assign)NSTimeInterval currentGameTime;
@property(nonatomic, assign)NSTimeInterval lastGameStepTimestamp;
@property(nonatomic, strong)SPGamePiece *currentlyDroppingPiece;
@property(nonatomic, strong)NSMutableSet *gameBlocks;

// Game Interaction.
@property(nonatomic, assign)NSTimeInterval lastGameActionTimestamp;
@property(nonatomic, strong)SPGameAction *nextGameAction;

@end

@implementation SPGameController
@synthesize gameContainerLayer = _gameContainerLayer;
@synthesize gridNumRows = _gridNumRows;
@synthesize gridNumColumns = _gridNumColumns;
@synthesize gameStepInterval = _gameStepInterval;
@synthesize gameActionInterval = _gameActionInterval;
@synthesize currentGameTime = _currentGameTime;
@synthesize lastGameStepTimestamp = _lastGameStepTimestamp;
@synthesize currentlyDroppingPiece = _currentlyDroppingPiece;
@synthesize gameBlocks = _gameBlocks;
@synthesize lastGameActionTimestamp = _lastGameActionTimestamp;
@synthesize nextGameAction = _nextGameAction;

- (id)init {
	if((self = [super init])) {
		// Create our game container layer.
		self.gameContainerLayer = [CALayer layer];
		self.gameContainerLayer.backgroundColor = [[UIColor blueColor] CGColor];
		self.gameContainerLayer.delegate = self;
		
		// Set up the game's rules.
		_gridNumRows = 16;
		_gridNumColumns = 10;
		_gameStepInterval = 0.5f;
		_gameActionInterval = 0.25f;
		
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
		for(CGFloat penX = 0.0f; penX <= 20.0f * self.gridNumColumns; penX += 20.0f) {
			CGContextMoveToPoint(ctx, penX, 0.0f);
			CGContextAddLineToPoint(ctx, penX, 20.0f * self.gridNumRows);
		}
		for(CGFloat penY = 0.0f; penY <= 20.0f * self.gridNumRows; penY += 20.0f) {
			CGContextMoveToPoint(ctx, 0.0f, penY);
			CGContextAddLineToPoint(ctx, 20.0f * self.gridNumColumns, penY);
		}
		
		CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] CGColor]);
		CGContextStrokePath(ctx);
	}
	
	// Pop context state.
	CGContextRestoreGState(ctx);
#endif
}


#pragma mark 
- (BOOL)_canMovePiece:(SPGamePiece *)piece toNewBlockLocations:(NSArray *)newBlockLocations {
	__block BOOL foundIntersection = NO;
	[newBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint positionAfterMovement = [(NSValue *)obj CGPointValue];
		
		// Check to see if the component block hits the bottom of sides of the game board.
		if(positionAfterMovement.x < 10.0f || positionAfterMovement.x > 20.0f * self.gridNumColumns - 10.0f || positionAfterMovement.y > 20.0f * self.gridNumRows - 10.0f) {
			foundIntersection = YES;
			*stop = YES;
		}
		
		// Check to see if the component block intersects with any of the other game blocks.
		for(CALayer *gameBlock in self.gameBlocks) {
			// If this game block is part of the game piece in question, just bail -- a piece can't intersect with itself!
			if([piece.componentBlocks containsObject:gameBlock]) {
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
	[piece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *componentBlock = (CALayer *)obj;
		componentBlock.position = [(NSValue *)[blockLocations objectAtIndex:idx] CGPointValue];
	}];
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
		// Create a piece with a randomly-selected type.
		const SPGamePieceType gamePieceType = rand() % SPGamePieceNumTypes;
		self.currentlyDroppingPiece = [[SPGamePiece alloc] initWithGamePieceType:gamePieceType];
		
		// Add the game piece's component blocks and position them.
		const NSInteger droppingPieceBlockOffset = self.gridNumColumns / 2;
		const CGPoint droppingPieceOrigin = CGPointMake((CGFloat)droppingPieceBlockOffset * 20.0f, -1.0f * [self.currentlyDroppingPiece numBlocksHigh] * 20.0f);
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
	return nil;
}
- (void)_performLineClears {
	// Check each row for filled-ness.
	for(NSInteger rowIndex = 0; rowIndex < self.gridNumRows; rowIndex++) {
		NSSet *blocksInRow = [self _blocksInRow:rowIndex];
		if(blocksInRow.count >= self.gridNumColumns) {
			// Clear the row!
			[blocksInRow enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
				CALayer *block = (CALayer *)obj;
				[block removeFromSuperlayer];
				[self.gameBlocks removeObject:block];
			}];
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
		self.lastGameStepTimestamp = self.currentGameTime;
		
		// See if we can move the piece down.
		NSArray *newBlockLocations = [currentPiece blockLocationsAfterApplyingAction:[SPGameAction gameActionWithType:SPGameActionMoveDown]];
		if([self _canMovePiece:currentPiece toNewBlockLocations:newBlockLocations]) {
			[self _moveBlocksForPiece:currentPiece toNewBlockLocations:newBlockLocations];
		}
		else {
			[self _clearCurrentlyDroppingPiece];
		}
	}
	
	// Determine if it's time to execute the next game action.
	if(self.nextGameAction && (self.currentGameTime - self.lastGameActionTimestamp >= self.gameActionInterval)) {
		self.lastGameActionTimestamp = self.currentGameTime;
		
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
	[self _performLineClears];
	
	// Make sure our background layer gets displayed.
	[self.gameContainerLayer setNeedsDisplay];
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
