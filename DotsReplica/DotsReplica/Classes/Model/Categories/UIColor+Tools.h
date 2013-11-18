//
//  UIColor+Tools.h
//  ConnectDots
//
//  Created by mihaiserban on 9/12/13.
//  Copyright (c) 2013 ProtonicService. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Tools)
- (UIColor *)colorByDarkeningColor;
- (UIColor *)colorByChangingAlphaTo:(CGFloat)newAlpha;
@end
