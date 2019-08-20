//
//  UIColor+Blend.m
//  Galaxy
//
//  Created by Nathan Hamey on 27/4/17.
//  Copyright © 2017 Nate. All rights reserved.
//

#import "UIColor+Blend.h"

@implementation UIColor (Blend)

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+(UIColor*) blend:(UIColor*) c1 and:(UIColor*) c2 alpha:(float) alpha {
    alpha = MIN( 1.f, MAX( 0.f, alpha ) );
    float beta = 1.f - alpha;
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    [c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    CGFloat r = r1 * beta + r2 * alpha;
    CGFloat g = g1 * beta + g2 * alpha;
    CGFloat b = b1 * beta + b2 * alpha;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

- (UIColor *)incrementBrightness:(CGFloat)increment {
    
    CGFloat hue, saturation, brightness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    
    brightness += increment;
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

@end

