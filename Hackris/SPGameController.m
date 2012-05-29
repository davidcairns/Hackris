//
//  SPGameController.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGameController.h"
#import "SPGamePiece.h"

@interface SPGameController ()
@property(nonatomic, strong)CALayer *gameContainerLayer;

// Game Rules
@property(nonatomic, readonly)NSInteger gridNumRows;
@property(nonatomic, readonly)NSInteger gridNumColumns;
@property(nonatomic, readonly)NSTimeInterval gameStepInterval;

// Game State
@property(nonatomic, assign)NSTimeInterval currentGameTime;
@property(nonatomic, assign)NSTimeInterval lastGameStepTimestamp;
@property(nonatomic, strong)SPGamePiece *currentlyDroppingPiece;
@property(nonatomic, strong)NSMutableSet *gameBlocks;

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

- (id)init {
	if((self = [super init])) {
		// Create our game container layer.
		self.gameContainerLayer = [CALayer layer];
		self.gameContainerLayer.backgroundColor = [[UIColor blueColor] CGColor];
		self.gameContainerLayer.delegate = self;
		
		// Set up the game's rules.
		_gridNumRows = 10;
		_gridNumColumns = 10;
		_gameStepInterval = 0.5f;
		
		// Create our game's state objects.
		self.gameBlocks = [NSMutableSet set];
	}
	return self;
}


#pragma mark - CALayerDelegate
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
	// Push context state.
	CGContextSaveGState(ctx);
	
	if(layer == self.gameContainerLayer) {
		// Draw a grid!
		for(CGFloat penX = 0.0f; penX <= self.gameContainerLayer.bounds.size.width; penX += 20.0f) {
			CGContextMoveToPoint(ctx, penX, 0.0f);
			CGContextAddLineToPoint(ctx, penX, self.gameContainerLayer.bounds.size.height);
		}
		for(CGFloat penY = 0.0f; penY <= self.gameContainerLayer.bounds.size.width; penY += 20.0f) {
			CGContextMoveToPoint(ctx, 0.0f, penY);
			CGContextAddLineToPoint(ctx, self.gameContainerLayer.bounds.size.width, penY);
		}
		
		CGContextSetStrokeColorWithColor(ctx, [[UIColor redColor] CGColor]);
		CGContextStrokePath(ctx);
	}
	
	// Pop context state.
	CGContextRestoreGState(ctx);
}


#pragma mark 
- (BOOL)_canMovePieceDown:(SPGamePiece *)piece {
	// Check to see if there are any blocks in the game that obstruct this piece's component blocks.
	__block BOOL foundIntersection = NO;
	[piece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *pieceBlock = (CALayer *)obj;
		const CGPoint positionBelowPieceBlock = CGPointMake(pieceBlock.position.x, pieceBlock.position.y + 20.0f);
		
		// Check to see if the component block hits the bottom of the game board.
		if(positionBelowPieceBlock.y > self.gameContainerLayer.bounds.size.height) {
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
			if((fabsf(positionBelowPieceBlock.x - gameBlock.position.x) < 0.01f) && (fabsf(positionBelowPieceBlock.y - gameBlock.position.y) < 0.01f)) {
				foundIntersection = YES;
				*stop = YES;
				break;
			}
		}
	}];
	
	return !foundIntersection;
}
- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta {
	// Increment the current game time.
	self.currentGameTime += timeDelta;
	
	// Check to see if we need to spawn a new piece.
	if(!self.currentlyDroppingPiece) {
		// Create a piece with a randomly-selected type.
		self.currentlyDroppingPiece = [[SPGamePiece alloc] initWithGamePieceType:(rand() % SPGamePieceNumTypes)];
		
		// Add the game piece's component blocks and position them.
		const CGPoint droppingPieceOrigin = CGPointMake(3.0f * 20.0f, -1.0f * [self.currentlyDroppingPiece numBlocksHigh] * 20.0f);
		[self.currentlyDroppingPiece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			CALayer *componentBlock = (CALayer *)obj;
			componentBlock.position = CGPointMake(droppingPieceOrigin.x + componentBlock.position.x, droppingPieceOrigin.y + componentBlock.position.y);
			[self.gameContainerLayer addSublayer:componentBlock];
			[self.gameBlocks addObject:componentBlock];
		}];
	}
	
	// Determine if it's time to move the currently-dropping piece down.
	if(self.currentGameTime - self.lastGameStepTimestamp >= self.gameStepInterval) {
		// Step the game state.
		self.lastGameStepTimestamp = self.currentGameTime;
		
		// See if we can move the piece down.
		if([self _canMovePieceDown:self.currentlyDroppingPiece]) {
			// Move the piece down.
			[self.currentlyDroppingPiece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				CALayer *componentBlock = (CALayer *)obj;
				componentBlock.position = CGPointMake(componentBlock.position.x, componentBlock.position.y + 20.0f);
			}];
		}
		else {
			self.currentlyDroppingPiece = nil;
		}
	}
	
	// Make sure our background layer gets displayed.
	[self.gameContainerLayer setNeedsDisplay];
}

@end
