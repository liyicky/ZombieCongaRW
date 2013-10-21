//
//  LIYMyScene.m
//  ZombieCongaRW
//
//  Created by Jason Cheladyn on 10/8/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import "LIYMyScene.h"
#import "math.m"

@implementation LIYMyScene
{
    SKSpriteNode *_zombie;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGFloat _speed;
    CGPoint _velocity;
    CGPoint _lastTouchPosition;
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
        [self addChild:background];
        _speed = 120.0;
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
    
    if (CGPointLenght(CGPointSubtract(_zombie.position, _lastTouchPosition)) <= _speed * _dt) {
        _zombie.position = _lastTouchPosition;
        _velocity = CGPointZero;
    } else {
        [self checkBounds];
        [self rotateSprite:_zombie toFace:_velocity];
    }
}

- (void)addZombie
{
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    [self addChild:_zombie];

}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity
{
    CGPoint ammountToMove = CGPointMultiplyScalar(velocity, _dt);
    NSLog(@"Ammount to move: %@", NSStringFromCGPoint(ammountToMove));
    sprite.position = CGPointAdd(sprite.position, ammountToMove);
}

- (void)moveZombieTo:(CGPoint)touch
{
    CGPoint offset = CGPointSubtract(touch, _zombie.position);
    CGPoint direction = CGPointNormalize(offset);
    _velocity = CGPointMultiplyScalar(direction, 120.0);
}

- (void)checkBounds
{
    CGPoint zombiePosition = _zombie.position;
    CGPoint zombieVelocity = _velocity;
    CGPoint bottomLeft = CGPointZero;
    CGPoint topRight = CGPointMake(self.size.width, self.size.height);
    
    if (zombiePosition.x <= bottomLeft.x) {
        zombiePosition.x = bottomLeft.x;
        zombieVelocity.x = -zombieVelocity.x;
    }
    
    if (zombiePosition.y <= bottomLeft.y) {
        zombiePosition.y = bottomLeft.y;
        zombieVelocity.y = -zombieVelocity.y;
    }
    
    if (zombiePosition.x >= topRight.x) {
        zombiePosition.x = topRight.x;
        zombieVelocity.x = -zombieVelocity.x;
    }
    
    if (zombiePosition.y >= topRight.y) {
        zombiePosition.y = topRight.y;
        zombieVelocity.y = -zombieVelocity.y;
    }
    
    _zombie.position = zombiePosition;
    _velocity = zombieVelocity;
}

- (void)rotateSprite:(SKSpriteNode *)sprite toFace:(CGPoint)direction
{
    sprite.zRotation = CGPointToAngle(direction);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.scene];
    _lastTouchPosition = location;
    [self moveZombieTo:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self.scene];
    _lastTouchPosition = location;
    [self moveZombieTo:location];
}


@end
