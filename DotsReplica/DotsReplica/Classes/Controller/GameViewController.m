//
//  GameViewController.m
//  ConnectDots
//
//  Created by mihaiserban on 9/11/13.
//  Copyright (c) 2013 ProtonicService. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"
#import "GameManager.h"

#define kGameTime 60 //60 seconds

@interface GameViewController () <GameSceneProtocol>

@property (nonatomic, weak) IBOutlet UIView *topBar;
@property (nonatomic, weak) IBOutlet UILabel *scoreTitle;
@property (nonatomic, weak) IBOutlet UILabel *timeTitle;

@property (nonatomic, weak) IBOutlet UILabel *scoreLbl;
@property (nonatomic, weak) IBOutlet UILabel *timeLbl;

@property (nonatomic, assign) int secondsRemaining;
@property (nonatomic, assign) int points;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) GameScene * scene;

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [GameScene sceneWithSize:skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    [_scene setDelegate:self];
    
    // Present the scene.
    [skView presentScene:_scene];
    
    
    [self playGame];
}

#pragma mark - Game logic

-(void)resetGame
{
    [_timer invalidate];
    _timer = nil;
    
    _secondsRemaining = kGameTime;
    _points = 0;

    [self updateLabels];
}

-(void)finishGame
{
    //save score
    [self playGame];
}

-(void)playGame
{
    [self resetGame];
    
    //start timer
    [self startTimer];
}

-(void)pauseGame
{
    [self stopTimer];
}

-(void)resumeGame
{
    [self startTimer];
}

- (void)updateCounter:(NSTimer *)theTimer {
    if(_secondsRemaining > 0 ){
        _secondsRemaining -- ;
        [_timeLbl setText:[NSString stringWithFormat:@"%i",_secondsRemaining]];
    }
    else{
        _secondsRemaining = 0;
        [self stopTimer];
        [self finishGame];
    }
}

-(void)startTimer{
    [self stopTimer];

    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateCounter:) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if([_timer isValid])
    {
        [_timer invalidate];
        _timer = nil;
    }
}

-(void)updateLabels
{
    [_scoreLbl setText:[NSString stringWithFormat:@"%i",_points]];
    [_timeLbl setText:[NSString stringWithFormat:@"%i",_secondsRemaining]];
}

#pragma mark - GameSceneProtocol

-(void)linkedNumberOfSprites:(int)numberOfSprites
{
    _points += numberOfSprites;
    
    [self updateLabels];
}

#pragma mark - Powerups

-(IBAction)freezeTime
{
    //freeze the timer, add a particle freezing node
    [_scene freezeTime];
}

-(IBAction)enableGravity
{
    //drop all to the ground, rearrange them
    [_scene enableGravity];
}

-(IBAction)showHints
{
    //highlight possible selections
    //possible to forsee the best next moves
    [_scene showHints];
}

-(IBAction)removeColor
{
    //remove all of the same color
    [_scene removeColor:[UIColor redColor]];
}

#pragma mark - Other

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
