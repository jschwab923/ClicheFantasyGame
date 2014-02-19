//
//  JWCViewController.m
//  Cliche Fantasy Game
//
//  Created by Jeff Schwab on 2/17/14.
//  Copyright (c) 2014 Jeff Schwab. All rights reserved.
//

#import "JWCViewController.h"
#import "JWCSceneInsideHouse.h"

@interface JWCViewController ()

@end

@implementation JWCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewWillLayoutSubviews
{
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    
    // Create and configure the scene.
    SKScene *scene = [JWCSceneInsideHouse sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
