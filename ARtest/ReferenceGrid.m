//
//  ReferenceGrid.m
//  ARtest
//
//  Created by Nathan Hamey on 19/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import "ReferenceGrid.h"

@implementation ReferenceGrid

-(void)generate
{
    self.containerNode = [SCNNode node];
    [self addChildNode:self.containerNode];
    
    self.isVisible = NO;
    self.containerNode.opacity = 0;

    self.gridPointMaterial = [SCNMaterial material];
    self.gridPointMaterial.diffuse.contents = [UIColor whiteColor];
    self.gridPointMaterial.selfIllumination.contents = [UIColor whiteColor];
    self.gridPointMaterial.selfIllumination.intensity = 1;
    self.gridPointMaterial.transparency = 1;
    self.gridPointMaterial.doubleSided = NO;
    
    float grid_size = 0.5;
    
    float number_of_points = 30;
    float point_spacing = grid_size / number_of_points;
    
    //four corners
    [self generatePointAtX:-grid_size/2 Z:-grid_size/2];
    [self generatePointAtX:grid_size/2 Z:-grid_size/2];
    [self generatePointAtX:-grid_size/2 Z:grid_size/2];
    [self generatePointAtX:grid_size/2 Z:grid_size/2];

    
    float x = -grid_size/2;
    float z = -grid_size/2;
    
//    for(int i = 0; i < number_of_points; i++)
//    {
//        for(int i = 0; i < number_of_points; i++)
//        {
//            [self generatePointAtX:x Z:z];
//            x += point_spacing;
//        }
//
//        x = -grid_size/2;
//        z += point_spacing;
//    }
    
    self.name = @"Reference Grid";

}

-(void)generatePointAtX:(float)x Z:(float)z
{
//    float box_size = 0.01;
//    SCNBox *box = [SCNBox boxWithWidth:box_size height:0 length:box_size chamferRadius:0];
//    SCNNode *boxnode = [SCNNode nodeWithGeometry:box];
//    [self addChildNode:boxnode];
    
//    float plane_size = 0.01;
//    SCNPlane *plane = [SCNPlane planeWithWidth:plane_size height:plane_size];
//    SCNNode *pointnode = [SCNNode nodeWithGeometry:plane];
//    [self addChildNode:pointnode];
    
    float sphere_size = 0.0004;
    SCNSphere *sphere = [SCNSphere sphereWithRadius:sphere_size];
    sphere.segmentCount = 10;
    SCNNode *pointnode = [SCNNode nodeWithGeometry:sphere];
    [self.containerNode addChildNode:pointnode];
    
    pointnode.castsShadow = NO;
    
    pointnode.geometry.materials = @[self.gridPointMaterial];
    
    pointnode.position = SCNVector3Make(x, sphere_size, z);
}

-(void)show
{
    self.isVisible = YES;
    [self.containerNode removeAllActions];
    
    SCNAction *wait = [SCNAction waitForDuration:0.05];
    SCNAction *fade = [SCNAction fadeOpacityTo:0.5 duration:1];
    SCNAction *fadein = [SCNAction sequence:@[wait, fade]];
    [self.containerNode runAction:fadein];
    
}

-(void)hide
{
    self.isVisible = NO;
    [self removeAllActions];
    
    SCNAction *fade = [SCNAction fadeOpacityTo:0 duration:0.3];
    [self.containerNode runAction:fade];
}

@end
