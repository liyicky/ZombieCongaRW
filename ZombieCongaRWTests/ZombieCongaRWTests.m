//
//  ZombieCongaRWTests.m
//  ZombieCongaRWTests
//
//  Created by Jason Cheladyn on 10/8/13.
//  Copyright (c) 2013 Jason Cheladyn. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LIYMyScene.h"

@interface ZombieCongaRWTests : XCTestCase

@end

@implementation ZombieCongaRWTests
{
    LIYMyScene *_testScene;
    SKSpriteNode *_zombie;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _testScene = [[LIYMyScene alloc] init];

}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddZombie
{
    int nodeCountBeforeZombie = _testScene.children.count;
    
    [_testScene addZombie];
    int nodeCountAfterZombie = _testScene.children.count;
    
    XCTAssertEqual(nodeCountBeforeZombie + 1, nodeCountAfterZombie, @"There should be 1 additional node");
}




@end
