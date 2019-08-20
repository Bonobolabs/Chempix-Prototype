//
//  UIColor+Blend.h
//  Galaxy
//
//  Created by Nathan Hamey on 27/4/17.
//  Copyright © 2017 Nate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Blend)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+(UIColor*) blend:(UIColor*) c1 and:(UIColor*) c2 alpha:(float) alpha;
- (UIColor *)incrementBrightness:(CGFloat)increment;

@end
