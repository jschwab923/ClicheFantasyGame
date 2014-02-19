//
//  JWCSceneInsideHouse.m
//  Cliche Fantasy Game
//
//  Created by Jeff Schwab on 2/18/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "JWCSceneInsideHouse.h"
#import "JWCColliderType.h"
#import "JWCSceneForestMushrooms.h"
#import "JWCSpriteNodeWall.h"

@interface JWCSceneInsideHouse () <SKPhysicsContactDelegate>

@property (nonatomic) NSArray *walkingRightFrames;

@property (nonatomic) SKSpriteNode *mainCharacter;

@property (nonatomic) JWCSpriteNodeWall *frontDoor;

@end

@implementation JWCSceneInsideHouse

- (instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.contactDelegate = self;
        
        [self setupBackgroundAndBarriers];
        
        NSMutableArray *walkRightFrames = [NSMutableArray array];
        SKTextureAtlas *hunterWalkingRightAtlas = [SKTextureAtlas atlasNamed:@"HunterWalkingRight"];
        
        int numWalkingImages = (int)hunterWalkingRightAtlas.textureNames.count;
        SKTexture *standingStill = [hunterWalkingRightAtlas textureNamed:@"walkinge000"];
        [walkRightFrames addObject:standingStill];
        for (int i = 0; i < numWalkingImages-1; i++) {
            NSString *textureName = [NSString stringWithFormat:@"walkinge000%d", i];
            SKTexture *temp = [hunterWalkingRightAtlas textureNamed:textureName];
            [walkRightFrames addObject:temp];
        }
        self.walkingRightFrames = walkRightFrames;
        
        // Setup initial standing still position and main character
        SKTexture *temp = self.walkingRightFrames[0];
        self.mainCharacter = [SKSpriteNode spriteNodeWithTexture:temp];
        self.mainCharacter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(CGRectGetWidth(self.mainCharacter.frame)*.6, CGRectGetHeight(self.mainCharacter.frame)*.7)];
        self.mainCharacter.name = @"hero";
        self.mainCharacter.zPosition = 20;
        self.mainCharacter.position =  CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)-50);
        
        self.mainCharacter.physicsBody.affectedByGravity = NO;
        self.mainCharacter.physicsBody.allowsRotation = NO;
        
        // Setup collisions with walls
        self.mainCharacter.physicsBody.categoryBitMask = JWCColliderTypeHero;
        self.mainCharacter.physicsBody.contactTestBitMask = JWCColliderTypeWall | JWCColliderTypeMushroom;
        [self addChild:self.mainCharacter];

    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInNode:self];
    NSLog(@"%f %f", point.x, point.y);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchedPoint = [[touches anyObject] locationInNode:self];
 
    CGFloat multiplierForDirection;
    
    CGFloat walkVelocity = CGRectGetWidth(self.frame) / 4;
    
    CGPoint moveDifference = CGPointMake(touchedPoint.x - self.mainCharacter.position.x, touchedPoint.y - self.mainCharacter.position.y);
    
    CGFloat moveDistance = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    
    CGFloat moveDuration = moveDistance/walkVelocity;
    
    if (moveDifference.x < 0) {
        multiplierForDirection = -1;
    } else {
        multiplierForDirection = 1;
    }
    self.mainCharacter.xScale = fabs(self.mainCharacter.xScale) * multiplierForDirection;
    
    if ([self.mainCharacter actionForKey:@"walkingRight"]) {
        [self.mainCharacter removeActionForKey:@"walkingRight"];
    }
    
    if (![self.mainCharacter actionForKey:@"walkingRightInPlace"]) {
        [self walkingRight];
    }
    
    SKAction *moveAction = [SKAction moveTo:touchedPoint duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        [self cancelWalking];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction, doneAction]];
    
    [self.mainCharacter runAction:moveActionWithDone withKey:@"moveToLocation"];
}

- (void)walkingRight
{
    SKAction *moveAction = [SKAction repeatActionForever:
                            [SKAction animateWithTextures:self.walkingRightFrames
                                             timePerFrame:0.15f
                                                   resize:NO
                                                  restore:YES]];
    [self.mainCharacter runAction:moveAction withKey:@"walkingRightInPlace"];
}

- (void)cancelWalking
{
    [self.mainCharacter removeActionForKey:@"moveToLocation"];
    [self.mainCharacter removeActionForKey:@"walkingRightInPlace"];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self cancelWalking];
    
    [self loadForestScene];
}

- (void)setupBackgroundAndBarriers
{
    // Setup background and barriers
    SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"InsideHouse"];
    background.anchorPoint = CGPointZero;
    background.zPosition = 5;
    [self addChild:background];
    
    SKSpriteNode *lowerHouseHalf = [SKSpriteNode spriteNodeWithImageNamed:@"InsideHouseUnderParts"];
    lowerHouseHalf.anchorPoint = CGPointZero;
    lowerHouseHalf.zPosition = 100;
    [self addChild:lowerHouseHalf];
    
    SKSpriteNode *tableTop = [SKSpriteNode spriteNodeWithImageNamed:@"InsideHouseTableTop"];
    tableTop.position = CGPointMake(267, 177);
    tableTop.zPosition = 0;
    tableTop.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:tableTop.size];
    tableTop.physicsBody.dynamic = NO;
    tableTop.physicsBody.density = -1;
    tableTop.physicsBody.affectedByGravity = NO;
    tableTop.physicsBody.categoryBitMask = JWCColliderTypeWall;
    [self addChild:tableTop];
    
    self.frontDoor = [[JWCSpriteNodeWall alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(56, 20)];
    self.frontDoor.position = CGPointMake(287, 18);
    self.frontDoor.zPosition = 100;
    self.frontDoor.physicsBody.categoryBitMask = JWCColliderTypeDoor;
    [self addChild:self.frontDoor];
}

- (void)loadForestScene
{
    SKTransition *reveal = [SKTransition fadeWithDuration:.5];
    SKScene *forestScene = [[JWCSceneForestMushrooms alloc] initWithSize:self.size];
    [self.view presentScene:forestScene transition:reveal];
}

- (void)update:(NSTimeInterval)currentTime
{
    
}

@end
