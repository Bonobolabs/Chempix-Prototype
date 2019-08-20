//
//  ReferenceGrid.h
//  ARtest
//
//  Created by Nathan Hamey on 19/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReferenceGrid : SCNNode

@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) SCNMaterial *gridPointMaterial;
@property (nonatomic, strong) SCNNode *containerNode;


-(void)generate;
-(void)show;
-(void)hide;

@end

NS_ASSUME_NONNULL_END
