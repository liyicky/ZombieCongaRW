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
    SKAction *_zombieAnimation;
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
        
        SKAction *spawnEnemy = [SKAction sequence:@[[SKAction performSelector:@selector(addEnemy) onTarget:self],
                                                    [SKAction waitForDuration:2.0]]];
        [self runAction:[SKAction repeatActionForever:spawnEnemy]];
        
        SKAction *spawnCat = [SKAction sequence:@[[SKAction performSelector:@selector(addCat) onTarget:self],
                                                  [SKAction waitForDuration:1.0]]];
        [self runAction:[SKAction repeatActionForever:spawnCat]];
        
        
        NSMutableArray *textures = [NSMutableArray arrayWithCapacity:10];
        for (int i = 4; i > 1; i--) {
            NSString *textureName = [NSString stringWithFormat:@"zombie%d", i];
            SKTexture *texture = [SKTexture textureWithImageNamed:textureName];
            [textures addObject:texture];
        }
        _zombieAnimation = [SKAction animateWithTextures:textures timePerFrame:0.1];
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
        [self stopZombieAnimation];
    } else {
        [self checkBounds];
        [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_RADIANS_PER_SEC];
    }
    
    [self checkCollisions];
}

- (void)addZombie
{
    _zombie.name = @"zombie";
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    [self addChild:_zombie];

}

- (void)addEnemy
{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.name = @"enemy";
    enemy.position = CGPointMake(self.size.width + enemy.size.width/2, ScalarRandomRange(enemy.size.height/2, self.size.height-enemy.size.height/2));
    [self addChild:enemy];
    
    SKAction *remove = [SKAction removeFromParent];
    SKAction *move = [SKAction moveTo:CGPointMake(-enemy.size.width/2, enemy.position.y) duration:2.0];
    SKAction *howToBlocks = [SKAction runBlock:^{
        NSLog(@"RARWRWRWR!");
    }];
    SKAction *seq = [SKAction sequence:@[move, remove]];
    [enemy runAction:seq];
    
}

- (void)addCat
{
    SKSpriteNode *cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat"];
    cat.position = CGPointMake(ScalarRandomRange(0, self.size.width), ScalarRandomRange(0, self.size.height));
    cat.xScale = 0;
    cat.yScale = 0;
    cat.name = @"cat";
    [self addChild:cat];
    
    SKAction *appear   = [SKAction scaleTo:1 duration:0.5];
    SKAction *disapear = [SKAction scaleTo:0 duration:0.5];
    SKAction *remove   = [SKAction removeFromParent];
    SKAction *wibble = [SKAction rotateByAngle:(M_PI / 16) duration:0.5];
    SKAction *wobble = [wibble reversedAction];
    SKAction *rock   = [SKAction sequence:@[wibble, wobble]];
    SKAction *scaleUp = [SKAction scaleBy:1.2 duration:0.25];
    SKAction *scaleDown = [scaleUp reversedAction];
    SKAction *fullScale = [SKAction sequence:@[scaleUp, scaleDown, scaleUp, scaleDown]];
    SKAction *group = [SKAction group:@[rock, fullScale]];
    SKAction *wait  = [SKAction repeatAction:group count:10];
    
    [cat runAction:[SKAction sequence:@[appear, wait, disapear, remove]]];
    
}

- (void)moveSprite:(SKSpriteNode *)sprite velocity:(CGPoint)velocity
{
    CGPoint ammountToMove = CGPointMultiplyScalar(velocity, _dt);
    sprite.position = CGPointAdd(sprite.position, ammountToMove);
}

- (void)animateZombie
{
    if (![_zombie actionForKey:@"zombieAnimation"]) {
        [_zombie runAction:[SKAction repeatActionForever:_zombieAnimation] withKey:@"zombieAnimation"];
    }
}

- (void)stopZombieAnimation
{
    [_zombie removeActionForKey:@"zombieAnimation"];
}

- (void)moveZombieTo:(CGPoint)touch
{
    [self animateZombie];
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

-(void)checkCollisions
{
    [self enumerateChildNodesWithName:@"cat" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *cat = (SKSpriteNode *)node;
        if (CGRectIntersectsRect(cat.frame, _zombie.frame)) {
            [cat removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *enemy = (SKSpriteNode *)node;
        CGRect enemyFrame = CGRectInset(enemy.frame, 20, 20);
        if (CGRectIntersectsRect(enemyFrame, _zombie.frame)) {
            [enemy removeFromParent];
        }
    }];

}

- (void)rotateSprite:(SKSpriteNode *)sprite toFace:(CGPoint)velocity rotateRadiansPerSec:(CGFloat)rotateRadiansPerSec
{
    
    CGFloat curRotation = sprite.zRotation;
    CGFloat timeDelta   = _dt;
    CGFloat shortest    = ScalarShortestAngleBetween(curRotation, CGPointToAngle(velocity));
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
