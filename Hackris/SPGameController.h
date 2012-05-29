//
//  SPGameController.h
//  Hackris
//
//  Created by David Cairns on 5/28/12.
//  Copyright (c) 2012 smallpower. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface SPGameController : NSObject

@property(nonatomic, strong, readonly)CALayer *gameContainerLayer;

- (void)updateWithTimeDelta:(NSTimeInterval)timeDelta;

@end
