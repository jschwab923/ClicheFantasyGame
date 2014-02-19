//
//  GameOverScene.m
//  Cliche Fantasy Game
//
//  Created by Jeff Schwab on 2/17/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "GameOverScene.h"

#import "GameOverScene.h"
#import "JWCSceneForestMushrooms.h"

@implementation GameOverScene

- (id)initWithSize:(CGSize)size points:(long unsigned)points {
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Thin"];
        label.text = [NSString stringWithFormat:@"You collected %lu mushrooms!", points];
        label.fontSize = 30;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
    
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
    SKScene *myScene = [[JWCSceneForestMushrooms alloc] initWithSize:self.size];
    [self.view presentScene:myScene transition: reveal];
}

@end