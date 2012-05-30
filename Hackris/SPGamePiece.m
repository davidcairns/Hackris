//
//  SPGamePiece.m
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import "SPGamePiece.h"


@interface CALayer (SPGamePieceBlock)
+ (CALayer *)SPGamePieceBlock_layerWithColor:(UIColor *)color;
@end
@implementation CALayer (SPGamePieceBlock)
+ (CALayer *)SPGamePieceBlock_layerWithColor:(UIColor *)color {
	CALayer *layer = [CALayer layer];
	layer.bounds = CGRectMake(0.0f, 0.0f, 18.0f, 18.0f);
	layer.backgroundColor = [color CGColor];
	layer.cornerRadius = 3.0f;
	return layer;
}
@end


#pragma mark 
@interface SPGamePiece ()
@property(nonatomic, strong)NSArray *componentBlocks;
@end

@implementation SPGamePiece
@synthesize gamePieceType = _gamePieceType;
@synthesize componentBlocks = _componentBlocks;
@synthesize rotation = _rotation;

- (id)initWithGamePieceType:(SPGamePieceType)gamePieceType {
	NSAssert(gamePieceType >= 0 && gamePieceType < SPGamePieceNumTypes, @"Invalid game piece type!");
	
	if((self = [super init])) {
		// Hold on to the game piece type.
		_gamePieceType = gamePieceType;
		
		// Determine the color of the blocks based on the piece type.
		UIColor *pieceColor = nil;
		switch(gamePieceType) {
			case SPGamePieceTypeStraight:
				pieceColor = [UIColor cyanColor];
				break;
			case SPGamePieceTypeLeftL:
				pieceColor = [UIColor redColor];
				break;
			case SPGamePieceTypeRightL:
				pieceColor = [UIColor magentaColor];
				break;
			case SPGamePieceTypeT:
				pieceColor = [UIColor greenColor];
				break;
			case SPGamePieceTypeSquare:
				pieceColor = [UIColor orangeColor];
				break;
			default:
				NSLog(@"Invalid game piece type!");
				break;
		}
		
		// Set up our four component blocks.
		self.componentBlocks = [NSArray arrayWithObjects:
								[CALayer SPGamePieceBlock_layerWithColor:pieceColor], 
								[CALayer SPGamePieceBlock_layerWithColor:pieceColor], 
								[CALayer SPGamePieceBlock_layerWithColor:pieceColor], 
								[CALayer SPGamePieceBlock_layerWithColor:pieceColor], 
								nil];
		
		[self.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			CALayer *componentBlock = (CALayer *)obj;
			
			// Arrange this component block based on the piece type.
			switch(gamePieceType) {
				case SPGamePieceTypeStraight:
					componentBlock.position = CGPointMake(10.0f, 10.0f + 20.0f * (CGFloat)idx);
					break;
					
				case SPGamePieceTypeLeftL:
					if(3 == idx) {
						componentBlock.position = CGPointMake(10.0f, 10.0f);
					}
					else {
						componentBlock.position = CGPointMake(30.0f, 10.0f + 20.0f * (CGFloat)idx);
					}
					break;
					
				case SPGamePieceTypeRightL:
					if(3 == idx) {
						componentBlock.position = CGPointMake(30.0f, 10.0f);
					}
					else {
						componentBlock.position = CGPointMake(10.0f, 10.0f + 20.0f * (CGFloat)idx);
					}
					break;
					
				case SPGamePieceTypeT:
					if(3 == idx) {
						componentBlock.position = CGPointMake(30.0f, 30.0f);
					}
					else {
						componentBlock.position = CGPointMake(10.0f, 10.0f + 20.0f * (CGFloat)idx);
					}
					break;
					
				case SPGamePieceTypeSquare:
				{
					const CGFloat blockPositionX = (idx < 2 ? 10.0f : 30.0f);
					componentBlock.position = CGPointMake(blockPositionX, 10.0f + 20.0f * (CGFloat)(idx % 2));
				}
					break;
					
				default:
					NSLog(@"Invalid game piece type!");
					break;
			}
		}];
	}
	return self;
}


#pragma mark 
+ (NSArray *)relativeBlockLocationsForPieceType:(SPGamePieceType)pieceType orientation:(SPGamePieceRotation)orientation {
	// Calculate our blocks' locations relative to the locus position, given piece type, and rotation value.
	NSMutableArray *newBlockLocations = [NSMutableArray array];
	for(NSInteger componentBlockIndex = 0; componentBlockIndex < 4; componentBlockIndex++) {
		CGPoint newLocation = CGPointZero;
		switch(pieceType) {
			case SPGamePieceTypeStraight:
				if(SPGamePieceRotationNone == orientation || SPGamePieceRotationUpsideDown == orientation) {
					newLocation = CGPointMake(0.0f, 20.0f * (componentBlockIndex - 1));
				}
				else {
					newLocation = CGPointMake(20.0f * (componentBlockIndex - 1), 0.0f);
				}
				break;
				
			case SPGamePieceTypeLeftL:
				switch(orientation) {
					case SPGamePieceRotationNone:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(-20.0f, -20.0f);
						}
						else {
							newLocation = CGPointMake(0.0f, 20.0f * (componentBlockIndex - 1));
						}
						break;
						
					case SPGamePieceRotationClockwise:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(20.0f, -20.0f);
						}
						else {
							newLocation = CGPointMake(-20.0f * (componentBlockIndex - 1), 0.0f);
						}
						break;
						
					case SPGamePieceRotationUpsideDown:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(20.0f, 20.0f);
						}
						else {
							newLocation = CGPointMake(0.0f, -20.0f * (componentBlockIndex - 1));
						}
						break;
						
					case SPGamePieceRotationCounterClockwise:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(-20.0f, 20.0f);
						}
						else {
							newLocation = CGPointMake(20.0f * (componentBlockIndex - 1), 0.0f);
						}
						break;
						
					default:
						break;
				}
				break;
				
			case SPGamePieceTypeRightL:
				switch(orientation) {
					case SPGamePieceRotationNone:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(20.0f, -20.0f);
						}
						else {
							newLocation = CGPointMake(0.0f, 20.0f * (componentBlockIndex - 1));
						}
						break;
						
					case SPGamePieceRotationClockwise:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(20.0f, 20.0f);
						}
						else {
							newLocation = CGPointMake(-20.0f * (componentBlockIndex - 1), 0.0f);
						}
						break;
						
					case SPGamePieceRotationUpsideDown:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(-20.0f, 20.0f);
						}
						else {
							newLocation = CGPointMake(0.0f, 20.0f * (componentBlockIndex - 1));
						}
						break;
						
					case SPGamePieceRotationCounterClockwise:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(-20.0f, -20.0f);
						}
						else {
							newLocation = CGPointMake(20.0f * (componentBlockIndex - 1), 0.0f);
						}
						break;
						
					default:
						break;
				}
				break;
				
			case SPGamePieceTypeT:
				switch(orientation) {
					case SPGamePieceRotationNone:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(20.0f, 0.0f);
						}
						else {
							newLocation = CGPointMake(0.0f, 20.0f * (componentBlockIndex - 1));
						}
						break;
						
					case SPGamePieceRotationClockwise:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(0.0f, 20.0f);
						}
						else {
							newLocation = CGPointMake(-20.0f * (componentBlockIndex - 1), 0.0f);
						}
						break;
						
					case SPGamePieceRotationUpsideDown:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(-20.0f, 0.0f);
						}
						else {
							newLocation = CGPointMake(0.0f, -20.0f * (componentBlockIndex - 1));
						}
						break;
						
					case SPGamePieceRotationCounterClockwise:
						if(3 == componentBlockIndex) {
							newLocation = CGPointMake(0.0f, -20.0f);
						}
						else {
							newLocation = CGPointMake(20.0f * (componentBlockIndex - 1), 0.0f);
						}
						break;
						
					default:
						break;
				}
				break;
				
			case SPGamePieceTypeSquare:
				newLocation = CGPointMake(componentBlockIndex < 2 ? 0.0f : 20.0f, 20.0f * (CGFloat)(componentBlockIndex % 2) - 20.0f);
				break;
				
			default:
				NSLog(@"WARNING: Attempted to lay out invalid piece type: %i", pieceType);
				break;
		}
		
		[newBlockLocations addObject:[NSValue valueWithCGPoint:newLocation]];
	}
	
	return [NSArray arrayWithArray:newBlockLocations];
}
+ (NSArray *)_blockLocationsForLocusPosition:(CGPoint)locusPosition pieceType:(SPGamePieceType)pieceType orientation:(SPGamePieceRotation)orientation {
	// Get the block locations relative to the locus position.
	NSArray *relativeBlockLocations = [self relativeBlockLocationsForPieceType:pieceType orientation:orientation];
	
	// Generate the array of absolute locations.
	NSMutableArray *absoluteBlockLocations = [NSMutableArray array];
	[relativeBlockLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		const CGPoint relativeLocation = [(NSValue *)obj CGPointValue];
		const CGPoint absoluteLocation = CGPointMake(relativeLocation.x + locusPosition.x, relativeLocation.y + locusPosition.y);
		[absoluteBlockLocations addObject:[NSValue valueWithCGPoint:absoluteLocation]];
	}];
	
	return [NSArray arrayWithArray:absoluteBlockLocations];
}
- (NSArray *)blockLocationsAfterApplyingAction:(SPGameAction *)action {
	if(SPGameActionRotate == action.type) {
		SPGamePieceRotation newOrientation = (self.rotation + 1) % SPGamePieceRotationNumAngles;
		CALayer *locusBlock = [self.componentBlocks objectAtIndex:1];
		return [[self class] _blockLocationsForLocusPosition:locusBlock.position pieceType:self.gamePieceType orientation:newOrientation];
	}
	else {
		// Determine the proper movement vector for this action.
		CGPoint movementVector = CGPointZero;
		if(SPGameActionMoveLeft == action.type) {
			movementVector = CGPointMake(-20.0f, 0.0f);
		}
		else if(SPGameActionMoveRight == action.type) {
			movementVector = CGPointMake(20.0f, 0.0f);
		}
		else if(SPGameActionMoveDown == action.type) {
			movementVector = CGPointMake(0.0f, 20.0f);
		}
		else {
			NSLog(@"WARNING: Invalid action type: %i", action.type);
			return nil;
		}
		
		// Calculate the new block position for each of our component blocks after applying the movement vector translation.
		NSMutableArray *newBlockLocations = [NSMutableArray array];
		[self.componentBlocks enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			CALayer *componentBlock = (CALayer *)obj;
			NSValue *locationValue = [NSValue valueWithCGPoint:CGPointMake(componentBlock.position.x + movementVector.x, componentBlock.position.y + movementVector.y)];
			[newBlockLocations addObject:locationValue];
		}];
		return [NSArray arrayWithArray:newBlockLocations];
	}
	
	return nil;
}


- (NSInteger)numBlocksHigh {
	switch(self.gamePieceType) {
		case SPGamePieceTypeStraight:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 4 : 1);
			break;
		case SPGamePieceTypeLeftL:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 3 : 2);
			break;
		case SPGamePieceTypeRightL:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 3 : 2);
			break;
		case SPGamePieceTypeT:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 3 : 2);
			break;
		case SPGamePieceTypeSquare:
			return 2;
			break;
			
		default:
			NSLog(@"WARNING: Bad game piece type!");
			return 0;
			break;
	}
}
- (NSInteger)numBlocksWide {
	switch(self.gamePieceType) {
		case SPGamePieceTypeStraight:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 1 : 4);
			break;
		case SPGamePieceTypeLeftL:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 2 : 3);
			break;
		case SPGamePieceTypeRightL:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 2 : 3);
			break;
		case SPGamePieceTypeT:
			return ((SPGamePieceRotationNone == self.rotation || SPGamePieceRotationUpsideDown == self.rotation) ? 2 : 3);
			break;
		case SPGamePieceTypeSquare:
			return 2;
			break;
			
		default:
			NSLog(@"WARNING: Bad game piece type!");
			return 0;
			break;
	}
}

@end
