//
//  LIYMainMenuScene.m
//  ZombieCongaRW
//
//  Created by Jason Cheladyn on 11/6/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import "LIYMainMenuScene.h"
#import "LIYMyScene.h"

@implementation LIYMainMenuScene

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"MainMenu.png"];
        bg.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:bg];
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    SKScene *myScene = [[LIYMyScene alloc] initWithSize:self.size];
    SKTransition *reveal = [SKTransition doorsOpenHorizontalWithDuration:1.0];
    [self.view presentScene:myScene transition:reveal];
}

@end
