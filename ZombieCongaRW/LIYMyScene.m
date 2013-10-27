//
//  LIYMyScene.m
//  ZombieCongaRW
//
//  Created by Jason Cheladyn on 10/8/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import "LIYMyScene.h"
#import "math.m"

static const float ZOMBIE_RADIANS_PER_SEC = 4 * M_PI;

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
        
        [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_RADIANS_PER_SEC];
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
    sprite.position = CGPointAdd(sprite.position, ammountToMove);
}

- (void)moveZombieTo:(CGPoint)touch
{
    CGPoint offset = CGPointSubtract(touch, _zombie.position);
    CGPoint direction = CGPointNormalize(offset);
    _velocity = CGPointMultiplyScalar(direction, _speed);
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

- (void)rotateSprite:(SKSpriteNode *)sprite toFace:(CGPoint)velocity rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
    
    CGFloat curRotation = sprite.zRotation;
    CGFloat timeDelta   = _dt;
    CGFloat shortest = ScalarShortestAngleBetween(curRotation, CGPointToAngle(velocity));
    CGFloat amtToRotate = timeDelta * rotateRadiansPerSec;
    
    if (fabsf(shortest) < amtToRotate)
        amtToRotate = fabsf(shortest);
    
    amtToRotate = curRotation + (amtToRotate * ScalarSign(shortest));
    sprite.zRotation = amtToRotate;
    
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
