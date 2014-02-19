//
//  JWCSpriteNodeWall.m
//  Cliche Fantasy Game
//
//  Created by Jeff Schwab on 2/18/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "JWCSpriteNodeWall.h"
#import "JWCColliderType.h"

@implementation JWCSpriteNodeWall

- (id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        [self setupPhysicsBody];
    }
    return self;
}

- (void)setupPhysicsBody
{
    self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    self.physicsBody.dynamic = NO;
    self.physicsBody.density = -1;
    self.physicsBody.affectedByGravity = NO;
    self.physicsBody.categoryBitMask = JWCColliderTypeWall;
}

@end
