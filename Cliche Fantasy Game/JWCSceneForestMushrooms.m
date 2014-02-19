//
//  JWCMyScene.m
//  Cliche Fantasy Game
//
//  Created by Jeff Schwab on 2/17/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//


#import "JWCSceneForestMushrooms.h"
#import "GameOverScene.h"
#import "JWCSpriteNodeWall.h"
#import "JWCColliderType.h"

#import "YMCPhysicsDebugger.h"

@interface JWCSceneForestMushrooms () <SKPhysicsContactDelegate>
{
    int _touchedRightEdge;
    int _touchLeftEdge;
    
    int _nextMushroomSpawn;
    int _nextMushroom;
    
    BOOL _pickingUpMushroom;
    BOOL _walkCancelled;
}

@property (nonatomic) NSArray *cliffNodes;

@property (nonatomic) SKSpriteNode *mainCharacter;
@property (nonatomic) SKSpriteNode *background;

@property (nonatomic) NSArray *mushrooms;
@property (nonatomic) SKSpriteNode *currentMushroom;

@property (nonatomic) NSArray *walkingRightFrames;
@property (nonatomic) NSArray *pickingUpRightFrames;

@property (nonatomic) long unsigned pointsScored;
@property (nonatomic) SKLabelNode *pointsLabel;

@end

@implementation JWCSceneForestMushrooms

- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
     
        self.physicsWorld.contactDelegate = self;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        [self setUpCliffBoundaries];
        
        self.pointsLabel = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNeue"];
        self.pointsLabel.text = @"Mushrooms Collected: 0";
        self.pointsLabel.fontSize = 15;
        self.pointsLabel.fontColor = [UIColor blackColor];
        self.pointsLabel.position = CGPointMake(CGRectGetWidth(self.pointsLabel.frame)*.6, 0);
        self.pointsLabel.zPosition = 100;
        
        [self addChild:self.pointsLabel];
        
        SKSpriteNode *ladder = [SKSpriteNode spriteNodeWithImageNamed:@"ETallerLadder"];
        ladder.zPosition = 1;
        ladder.position = CGPointMake(183, 170);
        [self addChild:ladder];
        
        for (int i = 0; i < 2; i++) {
            self.background = [SKSpriteNode spriteNodeWithImageNamed:@"ForestBackground"];
            self.background.anchorPoint = CGPointZero;
            self.background.position = CGPointMake(i * CGRectGetWidth(self.background.frame), 0);
            self.background.name = @"background";
            self.background.zPosition = 0;
            [self addChild:self.background];
        }
        
        // Setup walking right frames
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
        
        // Setup picking up frames
        NSMutableArray *pickingUpFrames = [NSMutableArray new];
        SKTextureAtlas *hunterPickingUpRightAtlas = [SKTextureAtlas atlasNamed:@"HunterPickingUpRight"];
        
        int numPickingUpImages = (int)hunterPickingUpRightAtlas.textureNames.count;
        for (int i = 0; i < numPickingUpImages; i++) {
            NSString *textureName = [NSString stringWithFormat:@"pickupe000%d", i];
            SKTexture *temp = [hunterPickingUpRightAtlas textureNamed:textureName];
            [pickingUpFrames addObject:temp];
        }
        self.pickingUpRightFrames = pickingUpFrames;
        
        // Setup initial standing still position and main character
        SKTexture *temp = self.walkingRightFrames[0];
        self.mainCharacter = [SKSpriteNode spriteNodeWithTexture:temp];
        self.mainCharacter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(CGRectGetWidth(self.mainCharacter.frame)*.6, CGRectGetHeight(self.mainCharacter.frame)*.7)];
        self.mainCharacter.name = @"hero";
        self.mainCharacter.zPosition = 20;
        self.mainCharacter.position =  CGPointMake(20, CGRectGetHeight(self.frame)- 30);
        
        self.mainCharacter.physicsBody.affectedByGravity = NO;
        self.mainCharacter.physicsBody.allowsRotation = NO;
        
        // Setup collisions with walls
        self.mainCharacter.physicsBody.categoryBitMask = JWCColliderTypeHero;
        self.mainCharacter.physicsBody.contactTestBitMask = JWCColliderTypeWall | JWCColliderTypeMushroom;
        [self addChild:self.mainCharacter];
        
        _nextMushroom = 0;
        NSMutableArray *tempMushrooms = [NSMutableArray new];
        SKTextureAtlas *mushroomAtlas = [SKTextureAtlas atlasNamed:@"Mushrooms"];
        for (int i = 0; i < mushroomAtlas.textureNames.count; i++) {
            NSString *textureName;
            if (i < 10) {
                textureName = [NSString stringWithFormat:@"Mushroom_000%d_Layer-%d", i, i+1];
            } else {
                textureName = [NSString stringWithFormat:@"Mushroom_00%d_Layer-%d", i, i+1];
            }
            SKTexture *mushroomTexture = [mushroomAtlas textureNamed:textureName];
            SKSpriteNode *mushroom = [SKSpriteNode spriteNodeWithTexture:mushroomTexture];
            mushroom.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(CGRectGetWidth(mushroom.frame)*.8, CGRectGetHeight(mushroom.frame)*.5)];
            mushroom.physicsBody.categoryBitMask = JWCColliderTypeMushroom;
            mushroom.physicsBody.affectedByGravity = NO;
            mushroom.zPosition = 10;
            mushroom.physicsBody.density = -1;
            [tempMushrooms addObject:mushroom];
        }
        self.mushrooms = tempMushrooms;
    }
    
    [self spawnMushroom];
    
    __unused NSTimer *gameDurationTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f
                                                                           target:self
                                                                         selector:@selector(gameOver)
                                                                         userInfo:nil
                                                                          repeats:NO];

    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchedPoint = [[touches anyObject] locationInNode:self];
    
    if (touchedPoint.x >= 500) {
        _touchedRightEdge = 1;
    }
    
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
    _walkCancelled = NO;
}

- (void)cancelWalking
{
    [self.mainCharacter removeActionForKey:@"moveToLocation"];
    [self.mainCharacter removeActionForKey:@"walkingRightInPlace"];
}

- (void)pickup
{
    SKAction *pickupAction = [SKAction animateWithTextures:self.pickingUpRightFrames
                                              timePerFrame:0.09f resize:NO restore:YES];
    [self.mainCharacter runAction:pickupAction completion:^{
        _pickingUpMushroom = NO;
        [self.currentMushroom removeFromParent];
        self.pointsScored++;
        self.pointsLabel.text = [NSString stringWithFormat:@"Mushrooms Collected: %lu",self.pointsScored];
        if (self.pointsScored % 4 == 0) {
            [self spawnMushroom];
        }
    }];
}

- (void)spawnMushroom
{
    for (int i = 0; i < 4; i++) {
        CGFloat randomY = [self randomValueBetween:20 andValue:CGRectGetHeight(self.frame)-20];
        CGFloat randomX = [self randomValueBetween:20 andValue:CGRectGetWidth(self.frame)-20];
        
        SKSpriteNode *mushroom = self.mushrooms[_nextMushroom];
        _nextMushroom++;
        mushroom.position = CGPointMake(randomX, randomY);
        mushroom.hidden = NO;
        
        if (_nextMushroom >= [self.mushrooms count]) {
            _nextMushroom = 0;
        }
        [self addChild:mushroom];
    }
}

- (void)gameOver
{
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size points:self.pointsScored];
    [self.view presentScene:gameOverScene transition: reveal];
}

- (CGFloat)randomValueBetween:(CGFloat)low andValue:(CGFloat)high
{
    return (((CGFloat) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}


#pragma mark - Boundary Setup Methods
- (void)setUpCliffBoundaries {
    // Setup boundaries
    JWCSpriteNodeWall *farLeftCliff = [JWCSpriteNodeWall spriteNodeWithColor:[UIColor clearColor]
                                                                        size:CGSizeMake(2, 52)];
    farLeftCliff.position = CGPointMake(63, 286);
    farLeftCliff.zPosition = 50;

    
    JWCSpriteNodeWall *leftCliff = [JWCSpriteNodeWall spriteNodeWithColor:[UIColor clearColor]
                                                                size:CGSizeMake(52, 2)];
    leftCliff.position = CGPointMake(93, 250);
    leftCliff.zPosition = 50;
    
    JWCSpriteNodeWall *leftMiddleCliff = [JWCSpriteNodeWall spriteNodeWithColor:[UIColor clearColor]
                                                                      size:CGSizeMake(65, 2)];
    leftMiddleCliff.position = CGPointMake(165, 230);
    leftMiddleCliff.zPosition = 50;
    
    JWCSpriteNodeWall *middleCliff = [JWCSpriteNodeWall spriteNodeWithColor:[UIColor clearColor]
                                                             size:CGSizeMake(2, 140)];
    middleCliff.position = CGPointMake(320, 220);
    middleCliff.zPosition = 50;
    
    JWCSpriteNodeWall *centerCliff = [JWCSpriteNodeWall spriteNodeWithColor:[UIColor clearColor]
                                                             size:CGSizeMake(110, 2)];
    centerCliff.position = CGPointMake(250, 152);
    centerCliff.zPosition = 50;
    
    [self addChild:farLeftCliff];
    [self addChild:leftCliff];
    [self addChild:leftMiddleCliff];
    [self addChild:middleCliff];
    [self addChild:centerCliff];
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    [self cancelWalking];
    
    if (!_pickingUpMushroom) {
        if (contact.bodyB.categoryBitMask == JWCColliderTypeMushroom &&
            contact.bodyB.node.hidden == NO)
        {
            self.currentMushroom = (SKSpriteNode *)contact.bodyB.node;
            _pickingUpMushroom = YES;
            [self pickup];
        } else if (contact.bodyA.categoryBitMask == JWCColliderTypeMushroom &&
                   contact.bodyA.node.hidden == NO)
        {
            self.currentMushroom = (SKSpriteNode *)contact.bodyA.node;
            _pickingUpMushroom = YES;
            [self pickup];
        }
    }
}

- (void)update:(CFTimeInterval)currentTime
{
//      if (self.mainCharacter.position.x <= 10) {
//        [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
//            SKSpriteNode *background = (SKSpriteNode *)node;
//            background.position = CGPointMake(background.position.x - 3, background.position.y);
//            
//            if (background.position.x <= -background.size.width) {
//                background.position = CGPointMake(background.position.x + background.size.width*2, background.position.y);
//            }
//        }];
//    } else if (self.mainCharacter.position.x >= 500) {
//        [self.mainCharacter runAction:[SKAction animateWithTextures:self.walkingRightFrames
//                                                       timePerFrame:0.1f resize:NO restore:YES]];
//         
//        [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
//            SKSpriteNode *background = (SKSpriteNode *)node;
//            background.position = CGPointMake(background.position.x - 2, background.position.y);
//            if (background.position.x <= -background.size.width) {
//                background.position = CGPointMake(background.position.x + background.size.width*2, background.position.y);
//            }
//        }];
//    }
}


@end
