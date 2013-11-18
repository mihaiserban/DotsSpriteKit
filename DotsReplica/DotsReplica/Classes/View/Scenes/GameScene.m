//
//  GameScene.m
//  ConnectDots
//
//  Created by mihaiserban on 9/11/13.
//  Copyright (c) 2013 ProtonicService. All rights reserved.
//

#import "GameScene.h"
#import "DotSprite.h"
#import "UIColor+Tools.h"
#import "NSMutableArray+Shuffling.h"
#import "GameManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import "AVFoundation/AVFoundation.h"

#define kGridItems 7
#define KGridMargins 30
#define kDotWidth 35

#define kParticleArrangeDuration 0.4
#define kParticleMoveDuration 0.15
#define kParticleBounceDuration 0.05

typedef NS_ENUM(NSInteger, DotDirection) {
    DotDirectionLeft = 0,
    DotDirectionRight,
    DotDirectionUp,
    DotDirectionDown,
    DotDirectionUndefined
};

@interface GameScene () <SKPhysicsContactDelegate>

@property (nonatomic, strong) NSArray *possibleColors;
@property (nonatomic, strong) NSMutableArray *selectedDots;
@property (nonatomic, strong) NSMutableArray *collumns; //[collumns kGridItems][rows kGridItems]

@property (nonatomic, assign) CGFloat dotSpacing;
@property (nonatomic, strong) SKShapeNode *shapeLine;

@property (nonatomic, strong) SKEmitterNode *freezeNode;
@property (nonatomic, strong) SKEmitterNode *gravityEmmiter;
@end

@implementation GameScene

#pragma mark - Init

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.speed = 0;
        self.physicsWorld.contactDelegate = self;
        
        _timeFreezed = NO;
        _gravityEnabled = NO;
        _hintsEnabled = NO;
        _removeColorEnabled = NO;
        
        self.possibleColors = kColorSet1;
        
        self.selectedDots = [NSMutableArray array];
        self.collumns = [NSMutableArray arrayWithCapacity:kGridItems+1];

        
        //init shape line
        self.shapeLine = [[SKShapeNode alloc] init];
        [self addChild:self.shapeLine];
        
        self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        
//        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
//        
//        myLabel.text = @"Hello, World!";
//        myLabel.fontColor = [SKColor redColor];
//        myLabel.fontSize = 30;
//        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),
//                                       CGRectGetMidY(self.frame));
//        
//        [self addChild:myLabel];
        
        [self buildGridView];
    }
    return self;
}

-(DotSprite*)createDotSprite
{
    UIColor *color = [self randomColor];
    
    DotSprite *sprite = [DotSprite spriteNodeWithImageNamed:@"octogon.png"];
    
    sprite.alpha = 0.9;
    sprite.size = CGSizeMake(kDotWidth, kDotWidth);
    
    sprite.color = color;
    sprite.spriteColor = color;
    sprite.colorBlendFactor = 1.0;
    
    sprite.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:sprite.size.width * 0.5];
    
    return sprite;
}

- (SKEmitterNode *) newSmokeEmitter
{
    NSString *smokePath = [[NSBundle mainBundle] pathForResource:@"Smoke" ofType:@"sks"];
    SKEmitterNode *smoke = [NSKeyedUnarchiver unarchiveObjectWithFile:smokePath];
    [smoke setNumParticlesToEmit:5];
    
    return smoke;
}

- (SKEmitterNode *) freezeEmmiter
{
    NSString *freezePath = [[NSBundle mainBundle] pathForResource:@"Freeze" ofType:@"sks"];
    SKEmitterNode *freeze = [NSKeyedUnarchiver unarchiveObjectWithFile:freezePath];
    
    return freeze;
}

- (SKEmitterNode *) gravityEmmiter
{
    NSString *freezePath = [[NSBundle mainBundle] pathForResource:@"gravity" ofType:@"sks"];
    SKEmitterNode *freeze = [NSKeyedUnarchiver unarchiveObjectWithFile:freezePath];
    
    return freeze;
}

-(void)createDotSpriteSelectAnimationForDotSprite:(DotSprite*)sprite
{
    DotSprite *spriteToAnimate = [self createDotSprite];
    spriteToAnimate.alpha = 0.4;
    spriteToAnimate.colorBlendFactor = 0.9;
    spriteToAnimate.color = sprite.color;
    SKAction *fadeOut = [SKAction fadeOutWithDuration:kParticleMoveDuration];
    SKAction *enlarge = [SKAction scaleBy:1.8 duration:kParticleMoveDuration];
    SKAction *remove = [SKAction removeFromParent];
    
    [spriteToAnimate runAction: [SKAction sequence:@[enlarge,fadeOut,remove]] ];
    
    [sprite addChild:spriteToAnimate];
    
}

#pragma mark - Animations

-(void)animateBubble:(DotSprite*)sprite
{
    //[self rotateSprite:sprite];
}

-(void)moveBubble:(DotSprite*)sprite
{
    int moveBy = 1.5;
    float duration = 1.0;
    SKAction *moveLeft = [SKAction moveBy:CGVectorMake(-moveBy, 0) duration:duration];
    SKAction *moveBackCenter = [SKAction moveBy:CGVectorMake(moveBy, 0) duration:duration];
    
    SKAction *moveRight = [SKAction moveBy:CGVectorMake(moveBy, 0) duration:duration];
    SKAction *moveBackCenter2 = [SKAction moveBy:CGVectorMake(-moveBy, 0) duration:duration];
    
    SKAction *moveForever = nil;
    
    if ([self randomNumberBetween:0 to:1]) {
        moveForever = [SKAction repeatActionForever:[SKAction sequence:@[moveLeft,moveBackCenter,moveRight,moveBackCenter2]]];
    }
    else
    {
        moveForever = [SKAction repeatActionForever:[SKAction sequence:@[moveRight,moveBackCenter2,moveLeft,moveBackCenter]]];
    }
    
    
    [sprite runAction:moveForever];
}

-(void)rotateSprite:(DotSprite*)sprite
{
    SKAction *rotate = [SKAction rotateByAngle:[self randomNumberBetween:-M_PI to:M_PI] duration:3.0];
    SKAction *spinForever = [SKAction repeatActionForever:rotate];
    
    [sprite runAction:spinForever];
}

#pragma mark - Scene methods

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

#pragma mark - Touches

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    if ([touches count]) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint location = [touch locationInNode:self];
        
        //get intersecting dot
        DotSprite *sprite = [self dotForPoint:location];
        if (sprite) {
            [self addObject:sprite toArray:self.selectedDots];
            [self createDotSpriteSelectAnimationForDotSprite:sprite];
            [[GameManager sharedInstance] playSound];
            CGMutablePathRef myPath = [self pathForSelectedDots];

            self.shapeLine.path = myPath;
            self.shapeLine.lineWidth = 3.0;

            self.shapeLine.strokeColor = [sprite.spriteColor colorByDarkeningColor];
        }
    }
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //touches ended, remove the selected dots
    if ([self.selectedDots count] > 1) {
        if ([[self delegate] respondsToSelector:@selector(linkedNumberOfSprites:)]) {
            [[self delegate] linkedNumberOfSprites:(int)[self.selectedDots count]];
        }
    }

    [self removeSelectedDots];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    //touches ended, remove the selected dots
    if ([self.selectedDots count] > 1) {
        if ([[self delegate] respondsToSelector:@selector(linkedNumberOfSprites:)]) {
            [[self delegate] linkedNumberOfSprites:(int)[self.selectedDots count]];
        }
    }
    [self removeSelectedDots];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] && [self.selectedDots count]) {
        UITouch *touch = [[touches allObjects] objectAtIndex:0];
        CGPoint location = [touch locationInNode:self];
        
        CGMutablePathRef myPath = [self pathForSelectedDots];
        
        CGPathAddLineToPoint(myPath, NULL, location.x, location.y);
       
        self.shapeLine.path = myPath;
        
        //get intersecting dot
        DotSprite *sprite = [self dotForPoint:location];
        
        if (sprite && ![self.selectedDots containsObject:sprite]) {
            DotSprite *dotSprite = [self.selectedDots lastObject];
            if (sprite.spriteColor == dotSprite.spriteColor && [self isDotSprite:sprite nearDotSprite:dotSprite]) {
                [self addObject:sprite toArray:self.selectedDots];
                [self createDotSpriteSelectAnimationForDotSprite:sprite];
                [[GameManager sharedInstance] playSound];
                myPath = [self pathForSelectedDots];
                
                self.shapeLine.path = myPath;
            }
        }
    }
}

#pragma mark - Helper methods

-(int)randomNumberBetween:(int)from to:(int)to {
    
    return (int)from + arc4random() % (to-from+1);
}

-(UIColor*)randomColor
{
    NSUInteger randomIndex = arc4random() % [_possibleColors count];
    return [_possibleColors objectAtIndex:randomIndex];
}

-(float)distanceFrom:(CGPoint)point1 to:(CGPoint)point2
{
    CGFloat xDist = (point2.x - point1.x);
    CGFloat yDist = (point2.y - point1.y);
    return sqrt((xDist * xDist) + (yDist * yDist));
}

-(DotDirection)directionFromDotSprite:(DotSprite*)fromDotSprite toDotSprite:(DotSprite*)dotSprite
{
    DotDirection direction = DotDirectionUndefined;
    if (fromDotSprite.position.y == dotSprite.position.y) {
        //mean on the same row, horizontal
        if (fromDotSprite.position.x < dotSprite.position.x) {
            direction = DotDirectionRight;
        }
        else
        {
            direction = DotDirectionLeft;
        }
    }
    else if (fromDotSprite.position.x == dotSprite.position.x)
    {
        //mean on the same row, vertical
        if (fromDotSprite.position.y < dotSprite.position.y) {
            direction = DotDirectionUp;
        }
        else
        {
            direction = DotDirectionDown;
        }
    }
    else
    {
        //nothing, return undefined
    }
    return direction;
}

-(BOOL)isDotSprite:(DotSprite*)newSpriteToAdd nearDotSprite:(DotSprite*)dotSprite
{
    
    //dotSprite is the last object
    
    //newSpriteToAdd must be 1 cell away and vertical or horizontal
    
    NSUInteger rowIdLastObj = 0;
    NSUInteger columnIdLastObj = 0;
    for (int i = 0; i < [self.collumns count]; i++) {
        
        NSMutableArray *row = [self.collumns objectAtIndex:i];
        
        if ([row containsObject:dotSprite]) {
            //we found location of our last selected dot
            columnIdLastObj = i;
            rowIdLastObj = [row indexOfObject:dotSprite];
            break;
        }
    }
    
    NSUInteger rowIdTestingObj = 0;
    NSUInteger columnIdTestingObj = 0;
    for (int i = 0; i < [self.collumns count]; i++) {
        
        NSMutableArray *row = [self.collumns objectAtIndex:i];
        
        if ([row containsObject:newSpriteToAdd]) {
            //we found location of our last selected dot
            columnIdTestingObj = i;
            rowIdTestingObj = [row indexOfObject:newSpriteToAdd];
            break;
        }
    }
    
    BOOL isNearDot = NO;
    
    int rowDifference = ABS(rowIdLastObj) - ABS(rowIdTestingObj);
    int collumnDifference = ABS(columnIdLastObj) - ABS(columnIdTestingObj);
    
//    //go all directions
    if (abs(rowDifference) <= 1 && abs(collumnDifference) <= 1) {
        isNearDot = YES;
    }
    
    
    return isNearDot;
}

-(DotSprite*)dotForPoint:(CGPoint)point
{
    for (NSMutableArray *row in self.collumns) {
        for (DotSprite *node in row) {
            if ([node containsPoint:point]) {
                return node;
            }
        }
    }
    
    return nil;
}

-(void)addObject:(id)obj toArray:(NSMutableArray*)array
{
    if (![array containsObject:obj]) {
        [array addObject:obj];
    }
}

-(CGMutablePathRef)pathForSelectedDots
{
    CGMutablePathRef myPath = CGPathCreateMutable();
    for (int i = 0; i < [self.selectedDots count]; i++) {
        DotSprite *sprite = [self.selectedDots objectAtIndex:i];
        if (i == 0) {
            CGPathMoveToPoint(myPath, NULL, sprite.position.x, sprite.position.y);
        }
        else
        {
            CGPathAddLineToPoint(myPath, NULL, sprite.position.x, sprite.position.y);
        }
    }
    return myPath;
}

#pragma mark - Methods

-(void)buildGridView
{
    //the width of the grid in which we will layout out dots
    float gridWidth = self.size.width - 2*KGridMargins;
    
    float startY = (self.size.height - gridWidth)/2;
    
    //calculate the spacing between each item
    _dotSpacing = gridWidth/kGridItems;
    
    for (int i = 0; i <= kGridItems; i++) {
        
        NSMutableArray *row = [NSMutableArray arrayWithCapacity:kGridItems+1];
        
        for (int j = 0; j <= kGridItems; j++) {
            
            DotSprite *sprite = [self createDotSprite];
            [self animateBubble:sprite];
            sprite.position = CGPointMake(arc4random() % (int)self.size.width, arc4random() % (int)self.size.height);
            
            
            [self addChild:sprite];
            [self addObject:sprite toArray:row];
            
            SKAction *move = [SKAction moveTo:CGPointMake(KGridMargins + (i*_dotSpacing), j*_dotSpacing + startY) duration:kParticleArrangeDuration];
            [sprite runAction:move];
        }
        [self.collumns addObject:row];
    }
}

-(void)rearrangeGridView
{
    //the width of the grid in which we will layout out dots
    float gridWidth = self.size.width - 2*KGridMargins;
    
    float startY = (self.size.height - gridWidth)/2;
    
    for (int i = 0; i < [self.collumns count]; i++) {
        
        NSMutableArray *row = [self.collumns objectAtIndex:i];
        
        for (int j = 0; j <= kGridItems; j++) {
            
            DotSprite *sprite = nil;
            
            if ([row count] > j) {
                //means we can get the sprite
                sprite = [row objectAtIndex:j];
            }
            else
            {
                sprite = [self createDotSprite];
                [self animateBubble:sprite];
                //must be offscreen
                sprite.position = CGPointMake(KGridMargins + (i*_dotSpacing), self.size.height);
                
                [self addChild:sprite];
                [self addObject:sprite toArray:row];
            }
            
            CGPoint expectedPosition = CGPointMake(KGridMargins + (i*_dotSpacing), j*_dotSpacing + startY);
            if ((int)sprite.position.x == expectedPosition.x && (int)sprite.position.y == expectedPosition.y) {
                //dont need to move
            }
            else
            {
                CGPoint moveToWithBounce = CGPointMake(KGridMargins + (i*_dotSpacing), j*_dotSpacing + startY-10);
                CGPoint moveToNormalPosition = CGPointMake(KGridMargins + (i*_dotSpacing), j*_dotSpacing + startY);
                
                SKAction *move = [SKAction moveTo:moveToWithBounce duration:kParticleMoveDuration];
                SKAction *bounce = [SKAction moveTo:moveToNormalPosition duration:kParticleBounceDuration];
                
                [sprite runAction: [SKAction sequence:@[move,bounce]] ];
            }
        }
    }
}

-(void)removeSelectedDots
{
    if ([self.selectedDots count] > 1) {
        [self playVibrate];
        for (DotSprite *node in self.selectedDots) {
            
            SKAction *fadeOut = [SKAction fadeOutWithDuration:kParticleMoveDuration];
            SKAction *remove = [SKAction removeFromParent];

            [node runAction: [SKAction sequence:@[fadeOut,remove]] ];
            
            SKEmitterNode *emmiterNode = [self newSmokeEmitter];
            [node addChild:emmiterNode];
            [emmiterNode setTargetNode:node];
            [emmiterNode setParticleColor:node.spriteColor];
            
            NSMutableArray *tempArray = nil;
            for (NSMutableArray *rowDots in self.collumns) {
                if ([rowDots containsObject:node]) {
                    tempArray = rowDots;
                    break;
                }
            }
            if (tempArray) {
                [tempArray removeObject:node];
            }
        }
    }
    
    //generate new cells and move all above down
    //go through each dot, and get all the dots above, move them down

    [self.selectedDots removeAllObjects];
    
    [self rearrangeGridView];
    
    self.shapeLine.path = nil;
}

#pragma mark - Vibration

-(void)playVibrate
{
    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
}

#pragma mark - Powerups

-(void)freezeTime
{
    //freeze the timer, add a particle freezing node
    if (_freezeNode) {
        [_freezeNode removeFromParent];
        _freezeNode = nil;
    }
    else
    {
        _freezeNode = [self freezeEmmiter];
        _freezeNode.position = self.view.center;
        [self addChild:_freezeNode];
    }

}

-(void)enableGravity
{
    //drop all to the ground, rearrange them
    if (self.gravityEnabled) {

        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.speed = 0;
        self.gravityEnabled = NO;
        
        //shuffle before rearranging
        [[self collumns] shuffle];
        for (int i = 0; i < [self.collumns count]; i++) {
            
            NSMutableArray *row = [self.collumns objectAtIndex:i];
            [row shuffle];
        }
        
        [self rearrangeGridView];
    }
    else
    {
        for (int i = 0; i < [self.collumns count]; i++) {
            
            NSMutableArray *row = [self.collumns objectAtIndex:i];
            
            for (int j = 0; j < [row count]; j++) {
                
                DotSprite *sprite = [row objectAtIndex:j];
                //add a random move left or right
                SKAction *move = [SKAction moveByX:[self randomNumberBetween:-10 to:10] y:0 duration:0.5];
                [sprite runAction:move];
            }
        }

        self.physicsWorld.gravity = CGVectorMake(0.0, -9.8);
        self.physicsWorld.speed = 1.0;
        self.gravityEnabled = YES;
    }
}

-(void)showHints
{
    //highlight possible selections
    //possible to forsee the best next moves
}

-(void)removeColor:(UIColor*)color
{
    //remove all of the same color
}

#pragma mark - SKPhysicsContactDelegate

- (void)didBeginContact:(SKPhysicsContact *)contact {
    [[GameManager sharedInstance] playDropSound];
}

- (void)didEndContact:(SKPhysicsContact *)contact
{
 
}
@end
