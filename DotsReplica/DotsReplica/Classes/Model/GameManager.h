//
//  GameManager.h
//  ConnectDots
//
//  Created by mihaiserban on 9/12/13.
//  Copyright (c) 2013 ProtonicService. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameManager : NSObject

+ (id)sharedInstance;

-(void)playBackgroundMusic;
-(void)playDropSound;
-(void)playSound;
@end
