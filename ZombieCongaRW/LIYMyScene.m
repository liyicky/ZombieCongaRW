//
//  LIYMyScene.m
//  ZombieCongaRW
//
//  Created by Jason Cheladyn on 10/8/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import "LIYMyScene.h"
#import "LIYGameOverScene.h"
#import "math.m"
@import AVFoundation;

static const float ZOMBIE_RADIANS_PER_SEC = 4 * M_PI;
static const float ZOMBIE_SPEED = 120.0;
static const float CAT_RADIANS_PER_SEC = 4 * M_PI;
static const float CAT_SPEED = 120.0;
static const float BG_POINTS_PER_SEC = 50;

@implementation LIYMyScene
{
    SKSpriteNode *_zombie;
    SKAction *_zombieAnimation;
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    AVAudioPlayer *_backgroundMusicPlayer;
    CGPoint _velocity;
    CGPoint _lastTouchPosition;
    SKNode *_backgroundLayer;
    SKAction *_catCollisionSound;
    SKAction *_enemyCollisionSound;
    
    int _lives;
    BOOL _gameOver;
    BOOL _invincible;
    
    
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor whiteColor];
        _backgroundLayer = [SKNode node];
        [self addChild:_backgroundLayer];
        
        for (int i=0; i<2; i++) {
            SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"background"];
            background.anchorPoint = CGPointZero;
            background.position    = CGPointMake(i * background.size.width, 0);
            background.name        = @"bg";
            [_backgroundLayer addChild:background];
        }
        
        [self playBackgroundMusic:@"bgMusic.mp3"];
        [self addZombie];
        _zombie.zPosition = 100;
        _lives      = 5;
        _gameOver   = NO;
        _invincible = NO;
        
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
        
        _catCollisionSound = [SKAction playSoundFileNamed:@"hitCat.wav" waitForCompletion:NO];
        _enemyCollisionSound = [SKAction playSoundFileNamed:@"hitCatLady.wav" waitForCompletion:NO];
    }
    
    return self;
}

-(void)update:(NSTimeInterval)currentTime
{
    [self moveBackground];
    [self moveSprite:_zombie velocity:_velocity];
    
    if (_lastUpdateTime) {
        _dt = currentTime - _lastUpdateTime;
    } else {
        _dt = 0;
    }
    
    _lastUpdateTime = currentTime;
    
    [self checkBounds];
    [self rotateSprite:_zombie toFace:_velocity rotateRadiansPerSec:ZOMBIE_RADIANS_PER_SEC];
    [self moveConga];
    
    if (_lives <= 0 && !_gameOver) {
        _gameOver = YES;
        [_backgroundMusicPlayer stop];
        SKScene *gameOverScene = [[LIYGameOverScene alloc] initWithSize:self.size won:NO];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        [self.view presentScene:gameOverScene transition:reveal];

    }
    
}

- (void)didEvaluateActions
{
    [self checkCollisions];
}

- (void)addZombie
{
    _zombie.name = @"zombie";
    _zombie = [SKSpriteNode spriteNodeWithImageNamed:@"zombie1"];
    _zombie.position = CGPointMake(100, 100);
    [_backgroundLayer addChild:_zombie];

}

- (void)addEnemy
{
    SKSpriteNode *enemy = [SKSpriteNode spriteNodeWithImageNamed:@"enemy"];
    enemy.name = @"enemy";
    CGPoint enemyScreenPositon = CGPointMake(self.size.width + enemy.size.width/2, ScalarRandomRange(enemy.size.height/2, self.size.height-enemy.size.height/2));
    enemy.position = [_backgroundLayer convertPoint:enemyScreenPositon fromNode:self];
    [_backgroundLayer addChild:enemy];
    
    SKAction *remove = [SKAction removeFromParent];
    SKAction *move = [SKAction moveTo:CGPointMake(-enemy.size.width/2, enemy.position.y) duration:4.0];
    SKAction *howToBlocks = [SKAction runBlock:^{
        NSLog(@"RARWRWRWR!");
    }];
    SKAction *seq = [SKAction sequence:@[move, remove]];
    [enemy runAction:seq];
    
}

- (void)addCat
{
    SKSpriteNode *cat = [SKSpriteNode spriteNodeWithImageNamed:@"cat"];
    CGPoint catScreenPosition = CGPointMake(ScalarRandomRange(0, self.size.width), ScalarRandomRange(0, self.size.height));
    cat.position = [_backgroundLayer convertPoint:catScreenPosition fromNode:self];
    cat.xScale = 0;
    cat.yScale = 0;
    cat.name = @"cat";
    [_backgroundLayer addChild:cat];
    
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
    _velocity = CGPointMultiplyScalar(direction, ZOMBIE_SPEED);
}

- (void)checkBounds
{
    CGPoint zombiePosition = _zombie.position;
    CGPoint zombieVelocity = _velocity;
    CGPoint bottomLeft = [_backgroundLayer convertPoint:CGPointZero fromNode:self];
    CGPoint topRight = [_backgroundLayer convertPoint:CGPointMake(self.size.width, self.size.height) fromNode:self];
    
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
    [_backgroundLayer enumerateChildNodesWithName:@"cat" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *cat = (SKSpriteNode *)node;
        if (CGRectIntersectsRect(cat.frame, _zombie.frame)) {
            [self runAction:_catCollisionSound];
            cat.name = @"train";
            [cat removeAllActions];
            cat.xScale    = 1;
            cat.yScale    = 1;
            cat.zRotation = 0;
            [cat runAction:[SKAction colorizeWithColor:[SKColor greenColor] colorBlendFactor:0.6 duration:0.2]];
        }
    }];
    
    if (_invincible == NO) {
        [_backgroundLayer enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode *node, BOOL *stop) {
            SKSpriteNode *enemy = (SKSpriteNode *)node;
            CGRect enemyFrame = CGRectInset(enemy.frame, 20, 20);
            if (CGRectIntersectsRect(enemyFrame, _zombie.frame)) {
                [self runAction:_enemyCollisionSound];
                [self loseCats];
                _lives--;
                _invincible = YES;
                float blinkTimes = 10;
                float blinkDuration = 3.0;
                SKAction *damaged = [SKAction customActionWithDuration:blinkDuration actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                    float slice = blinkDuration / blinkTimes;
                    float remainder = fmodf(elapsedTime, slice);
                    node.hidden = remainder > slice / 2;
                }];
                [_zombie runAction:damaged];
                [_zombie runAction:[SKAction sequence:@[[SKAction waitForDuration:blinkDuration],[SKAction runBlock:^{
                    _invincible = NO;
                    _zombie.hidden = NO;
                }]]]];
            }
        }];

    }
}

- (void)moveConga
{
    __block int trainCount = 0;
    __block CGPoint targetPosition = _zombie.position;
    __block CGFloat targetRotation = _zombie.zRotation;
    [_backgroundLayer enumerateChildNodesWithName:@"train" usingBlock:^(SKNode *node, BOOL *stop) {
        trainCount++;
        if (!node.hasActions) {
            float actionDuration = 0.3;
            CGPoint offset = CGPointSubtract(targetPosition, node.position);
            CGPoint direction = CGPointNormalize(offset);
            CGPoint amountToMovePerSec = CGPointMultiplyScalar(direction, CAT_SPEED);
            CGPoint amountToMove = CGPointMultiplyScalar(amountToMovePerSec, actionDuration);
            SKAction *moveConga = [SKAction moveByX:amountToMove.x y:amountToMove.y duration:actionDuration];
            [node runAction:moveConga];
            node.zRotation = targetRotation;
            
        }
        
        targetPosition = node.position;
        targetRotation = node.zRotation;

    }];
    
    if (trainCount >= 30 && !_gameOver) {
        _gameOver = YES;
        [_backgroundMusicPlayer stop];
        SKScene *gameOverScene = [[LIYGameOverScene alloc] initWithSize:self.size won:YES];
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        [self.view presentScene:gameOverScene transition:reveal];
    }
}

- (void)loseCats
{
    __block int lostCount = 0;
    [_backgroundLayer enumerateChildNodesWithName:@"train" usingBlock:^(SKNode *node, BOOL *stop) {
        CGPoint randomeSpot = node.position;
        randomeSpot.x += ScalarRandomRange(-100, 100);
        randomeSpot.y += ScalarRandomRange(-100, 100);
        
        node.name = @"";
        [node runAction:[SKAction sequence:@[[SKAction group:@[[SKAction rotateByAngle:M_PI * 4 duration:1.0],
                                                               [SKAction moveTo:randomeSpot duration:1.0],
                                                               [SKAction scaleTo:0 duration:1.0]]],
                                             [SKAction removeFromParent]
                                             ]]];
        lostCount++;
        if (lostCount >= 2) {
            *stop = YES;
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

- (void)moveBackground
{
    CGPoint bgVelocity = CGPointMake(-BG_POINTS_PER_SEC, 0);
    CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity, _dt);
    _backgroundLayer.position = CGPointAdd(_backgroundLayer.position, amtToMove);

    [_backgroundLayer enumerateChildNodesWithName:@"bg" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        CGPoint bgScreenPosition = [_backgroundLayer convertPoint:bg.position toNode:self];
        if (bgScreenPosition.x <= -bg.size.width) {
            bg.position = CGPointMake(bg.position.x + bg.size.width*2, bg.position.y);
        }
    }];
}

- (void)playBackgroundMusic:(NSString *)filename
{
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    _backgroundMusicPlayer.numberOfLoops = -1;
    [_backgroundMusicPlayer prepareToPlay];
    [_backgroundMusicPlayer play];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_backgroundLayer];
    _lastTouchPosition = location;
    [self moveZombieTo:location];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:_backgroundLayer];
    _lastTouchPosition = location;
    [self moveZombieTo:location];
}



@end
