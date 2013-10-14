//
//  LIYMyScene.m
//  ZombieCongaRW
//
//  Created by Jason Cheladyn on 10/8/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import "LIYMyScene.h"

@implementation LIYMyScene
{
    SKSpriteNode *_zombie;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        [self addChild:background];
        
        background.anchorPoint = CGPointZero;
        background.position    = CGPointZero;
        
        [self addZombie];
    }
    
    return self;
}

- (void)addZombie
{
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    [self addChild:_zombie];

}

-(void)update:(NSTimeInterval)currentTime
{
    _zombie.position = (CGPointMake(_zombie.position.x + 1, _zombie.position.y));
}






@end
