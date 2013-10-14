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

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAddZombie
{
    LIYMyScene *testScene = [[LIYMyScene alloc] init];
    int nodeCountBeforeZombie = testScene.children.count;
    
    [testScene addZombie];
    int nodeCountAfterZombie = testScene.children.count;
    
    XCTAssertEqual(nodeCountBeforeZombie + 1, nodeCountAfterZombie, @"There should be 1 additional node");
}






@end
