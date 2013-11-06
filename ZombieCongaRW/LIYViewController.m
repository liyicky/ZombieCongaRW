//
//  LIYViewController.m
//  ZombieCongaRW
//
//  Created by Jason Cheladyn on 10/8/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import "LIYViewController.h"
#import "LIYMainMenuScene.h"

@implementation LIYViewController

- (void)viewWillLayoutSubviews
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
    
        // Create and configure the scene.
        SKScene * scene = [LIYMainMenuScene sceneWithSize:skView.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
    
        // Present the scene.
        [skView presentScene:scene];
    }
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
