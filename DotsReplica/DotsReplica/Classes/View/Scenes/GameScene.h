//
//  GameScene.h
//  ConnectDots
//

//  Copyright (c) 2013 ProtonicService. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol GameSceneProtocol <NSObject>

-(void)linkedNumberOfSprites:(int)numberOfSprites;

@end

@interface GameScene : SKScene
@property (nonatomic, unsafe_unretained) id<GameSceneProtocol> delegate;

@property (nonatomic, assign) BOOL timeFreezed;
@property (nonatomic, assign) BOOL gravityEnabled;
@property (nonatomic, assign) BOOL hintsEnabled;
@property (nonatomic, assign) BOOL removeColorEnabled;

-(void)freezeTime;
-(void)enableGravity;
-(void)showHints;
-(void)removeColor:(UIColor*)color;

@end
