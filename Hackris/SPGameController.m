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
		_gridNumRows = 10;
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
- (BOOL)_canMovePiece:(SPGamePiece *)piece alongVector:(CGPoint)movementVector {
	__block BOOL foundIntersection = NO;
	[piece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *pieceBlock = (CALayer *)obj;
		const CGPoint positionAfterMovement = CGPointMake(pieceBlock.position.x + movementVector.x, pieceBlock.position.y + movementVector.y);
		
		// Check to see if the component block hits the bottom of sides of the game board.
		if(positionAfterMovement.x < 10.0f || positionAfterMovement.x > self.gameContainerLayer.bounds.size.width - 10.0f || positionAfterMovement.y > self.gameContainerLayer.bounds.size.height - 10.0f) {
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
- (void)_movePiece:(SPGamePiece *)piece alongVector:(CGPoint)vector {
	[piece.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		CALayer *componentBlock = (CALayer *)obj;
		componentBlock.position = CGPointMake(componentBlock.position.x + vector.x, componentBlock.position.y + vector.y);
	}];
}

- (BOOL)_canExecuteGameAction:(SPGameAction *)action againstPiece:(SPGamePiece *)piece {
	if(SPGameActionRotate == action.type) {
		// TODO: Handle the rotation action check.
		return NO;
	}
	else {
		const CGPoint movementVector = CGPointMake((SPGameActionMoveLeft == action.type ? -20.0f : 20.0f), 0.0f);
		return [self _canMovePiece:piece alongVector:movementVector];
	}
	
	NSLog(@"WARNING: Unknown game action type: %i", action.type);
	return NO;
}
- (void)_executeGameAction:(SPGameAction *)action againstPiece:(SPGamePiece *)piece {
	switch(action.type) {
		case SPGameActionMoveLeft:
			[self _movePiece:piece alongVector:CGPointMake(-20.0f, 0.0f)];
			break;
			
		case SPGameActionMoveRight:
			[self _movePiece:piece alongVector:CGPointMake(20.0f, 0.0f)];
			break;
			
		case SPGameActionRotate:
			[piece rotate];
			break;
			
		default:
			NSLog(@"WARNING: Attempted to execute invalid game action type: %i", action.type);
			break;
	}
}


- (SPGamePiece *)_currentlyDroppingPiece {
	if(!self.currentlyDroppingPiece) {
		// Create a piece with a randomly-selected type.
		self.currentlyDroppingPiece = [[SPGamePiece alloc] initWithGamePieceType:(rand() % SPGamePieceNumTypes)];
		
		// Add the game piece's component blocks and position them.
		const CGPoint droppingPieceOrigin = CGPointMake(8.0f * 20.0f, -1.0f * [self.currentlyDroppingPiece numBlocksHigh] * 20.0f);
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
		const CGPoint downVector = CGPointMake(0.0f, 20.0f);
		if([self _canMovePiece:currentPiece alongVector:downVector]) {
			[self _movePiece:currentPiece alongVector:downVector];
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
		}
		
		// Clear the game action.
		self.nextGameAction = nil;
	}
	
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
