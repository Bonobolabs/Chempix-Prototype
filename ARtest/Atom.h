//
//  Atom.h
//  ARtest
//
//  Created by Nathan Hamey on 16/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Atom : SCNNode

@property (nonatomic, readwrite) NSInteger atomId;

@property (nonatomic, readwrite) NSString* atomElement;
@property (nonatomic, readwrite) NSString* atomSymbol;
@property (nonatomic, readwrite) UIColor* atomColor;
@property (nonatomic, readwrite) float atomSize;
@property (nonatomic, assign) SCNVector3 atomCoordinates;
@property (nonatomic, strong) SCNMaterial *atomMaterial;


-(void)generate;

@end

NS_ASSUME_NONNULL_END
