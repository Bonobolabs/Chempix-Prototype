//
//  Atom.m
//  ARtest
//
//  Created by Nathan Hamey on 16/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import "Atom.h"
#import "UIColor+Blend.h"

@implementation Atom

-(void)generate
{
    //prepare paths and load file
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"Elements.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) path = [[NSBundle mainBundle] pathForResource:@"Elements" ofType:@"plist"];
    
    //load definitions of elements
    NSArray *elements = [[NSArray alloc] initWithContentsOfFile:path];

    //parse array
    for (NSDictionary *element in elements)
    {
        if ([self.atomElement isEqualToString:[element objectForKey:@"Name"]])
        {
            self.atomColor = [UIColor colorFromHexString:[element objectForKey:@"Color"]];
            self.atomSize = [[element objectForKey:@"Size"] floatValue];
            self.atomSymbol = [element objectForKey:@"Symbol"];
        }

    }
    
    //create the sphere object
    SCNSphere *sphere = [SCNSphere sphereWithRadius:self.atomSize];
    sphere.segmentCount = 45;
    SCNNode *spherenode = [SCNNode nodeWithGeometry:sphere];
    [self addChildNode:spherenode];
    //test.categoryBitMask = 0x1 << 5;
    
    self.atomMaterial = [SCNMaterial material];
    
    self.atomMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
    self.atomMaterial.diffuse.contents = self.atomColor;
    self.atomMaterial.diffuse.intensity = 1;
    self.atomMaterial.reflective.contents = [UIImage imageNamed:@"environment_sphere_2"];
    self.atomMaterial.reflective.intensity = 1;
    self.atomMaterial.metalness.contents = [UIColor whiteColor];
    self.atomMaterial.metalness.intensity = 0.9;
    self.atomMaterial.roughness.contents = [UIImage imageNamed:@"roughness_1"];
    self.atomMaterial.roughness.intensity = 5;
    self.atomMaterial.shininess = 2;
    self.atomMaterial.normal.contents = [UIImage imageNamed:@"scuffed-plastic-normal"];
    self.atomMaterial.normal.intensity = 1;
    self.atomMaterial.transparency = 1;
    self.atomMaterial.locksAmbientWithDiffuse = NO;
    self.atomMaterial.doubleSided = NO;
    self.atomMaterial.writesToDepthBuffer = true;
    spherenode.geometry.materials = @[self.atomMaterial];
    
    //NSLog(@"Generated %@ atom content", self.atomElement);
    
    
    
    SCNNode *symbolnode = [SCNNode node];
    [self addChildNode:symbolnode];
    
    //SCNPlane *plane = [SCNPlane planeWithWidth:symbol_size height:symbol_size];
    //SCNNode *symboltest = [SCNNode nodeWithGeometry:plane];
    
    SCNNode *symboltest = [SCNNode node];
    
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = self.atomColor;
    mat.selfIllumination.contents = [UIColor whiteColor];// [UIImage imageNamed:glareimage];
    mat.blendMode = SCNBlendModeScreen;
    mat.diffuse.intensity = 0.5;
    mat.writesToDepthBuffer = false;
    
    [symbolnode addChildNode:symboltest];
    symboltest.position = SCNVector3Make(0, 0, self.atomSize+0.1);
    symboltest.renderingOrder = 10;
    
    SCNBillboardConstraint *look = [SCNBillboardConstraint billboardConstraint];
    symbolnode.constraints = @[look];
    
    NSString *elementletters = self.atomSymbol;
    SCNText *text = [SCNText textWithString:elementletters extrusionDepth:0];
    text.alignmentMode = kCAAlignmentCenter;
    text.flatness = 0;
    text.font = [UIFont systemFontOfSize:1 weight:UIFontWeightBold];
    //text.containerFrame = CGRectMake(-1, -1, 1, 1);
    SCNNode *textnode = [SCNNode nodeWithGeometry:text];
    textnode.geometry.materials = @[mat];
    
    //get bounding box of text
    SCNVector3 min = SCNVector3Zero;
    SCNVector3 max = SCNVector3Zero;
    [textnode.geometry getBoundingBoxMin:&min max:&max];
    
    CGSize sizeMax = CGSizeMake( max.x - min.x,
                                max.y - min.y);
    
    textnode.position = SCNVector3Make(-sizeMax.width/2, -sizeMax.height*2, textnode.position.z);
    

    [symboltest addChildNode:textnode];
    

}


@end
