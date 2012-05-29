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
	layer.bounds = CGRectMake(0.0f, 0.0f, 20.0f, 20.0f);
	layer.backgroundColor = [color CGColor];
	return layer;
}
@end


#pragma mark 
@interface SPGamePiece ()
@property(nonatomic, readonly)SPGamePieceType gamePieceType;
@property(nonatomic, strong)NSArray *componentBlocks;

// Mutable state
@property(nonatomic, assign)SPGamePieceRotation rotation;
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
				pieceColor = [UIColor blueColor];
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
- (void)rotate {
	self.rotation += 1;
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
