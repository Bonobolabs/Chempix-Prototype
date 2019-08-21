//
//  Molecule.h
//  ARtest
//
//  Created by Nathan Hamey on 16/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Molecule : SCNNode

@property (nonatomic, readwrite) NSInteger moleculeId;

@property (nonatomic, readwrite) NSString* moleculeType;

@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, readwrite) float viewingScale;

@property (nonatomic, readwrite) float moleculeSizeX;
@property (nonatomic, readwrite) float moleculeSizeY;
@property (nonatomic, readwrite) float moleculeSizeZ;


@property (nonatomic, strong) SCNNode *containerNode;
@property (nonatomic, assign) SCNVector3 moleculeCalculatedCenter;
@property (nonatomic, strong) NSMutableArray *atomsArray;

-(void)addAtomOfElement:(NSString*)element withId:(NSInteger)atomId atX:(float)x Y:(float)y Z:(float)z;
-(void)addBondBetween:(NSInteger)first and:(NSInteger)second;
-(void)generateBonds;

-(void)initialise;
-(void)animateSpin:(BOOL)animate;
-(void)setInitialState;
-(void)show;
-(void)hide;
-(void)adjustFloatingPositionBy:(float)y;

@end

NS_ASSUME_NONNULL_END
