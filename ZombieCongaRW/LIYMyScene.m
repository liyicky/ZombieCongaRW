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
    
    CGPoint _velocity;
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

-(void)update:(NSTimeInterval)currentTime
{
    [self moveSprite:_zombie velocity:_velocity];
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    
    _lastUpdateTime = currentTime;
    
}

- (void)addZombie
{
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    [self addChild:_zombie];

}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)veloctiy
{
    CGPoint ammountToMove = CGPointMake(veloctiy.x * _dt, veloctiy.y * _dt);
    NSLog(@"Ammount to move: %@", NSStringFromCGPoint(ammountToMove));
    sprite.position = CGPointMake(sprite.position.x + ammountToMove.x, sprite.position.y + ammountToMove.y);
}

- (void)moveZombieTo:(CGPoint)touch
{
    CGPoint offset = CGPointMake(touch.x - _zombie.position.x, touch.y - _zombie.position.y);
    CGFloat length = sqrtf(offset.x * offset.x + offset.y * offset.y);
    CGPoint direction = CGPointMake(offset.x / length, offset.y / length);
    _velocity = CGPointMake(direction.x * 120, direction.y * 120);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.scene];
    [self moveZombieTo:location];
}





@end
