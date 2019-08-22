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
    self.bondsArray = [[NSMutableArray alloc] init];
    self.bondThresholds = [[NSMutableArray alloc] init];

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
            self.atomSize = [[element objectForKey:@"Size"] floatValue] / 2;
            self.atomSymbol = [element objectForKey:@"Symbol"];
            self.bondThresholds = [element objectForKey:@"Bond Thresholds"];
        }

    }
    
    //create the sphere object
    SCNSphere *sphere = [SCNSphere sphereWithRadius:self.atomSize];
    sphere.segmentCount = 25;
    SCNNode *spherenode = [SCNNode nodeWithGeometry:sphere];
    [self addChildNode:spherenode];
    //test.categoryBitMask = 0x1 << 5;
    
    self.atomMaterial = [SCNMaterial material];
    
    self.atomMaterial.lightingModelName = SCNLightingModelPhysicallyBased;
    self.atomMaterial.diffuse.contents = self.atomColor;
    self.atomMaterial.diffuse.intensity = 1;
    self.atomMaterial.reflective.contents = [UIImage imageNamed:@"environment_sphere"];
    self.atomMaterial.reflective.intensity = 1;
    self.atomMaterial.metalness.contents = [UIColor whiteColor];
    self.atomMaterial.metalness.intensity = 0.9;
    self.atomMaterial.roughness.contents = [UIImage imageNamed:@"roughness_1"];
    self.atomMaterial.roughness.intensity = 5;
    self.atomMaterial.shininess = 2;
    self.atomMaterial.normal.contents = [UIImage imageNamed:@"normal_1"];
    self.atomMaterial.normal.intensity = 1;
    self.atomMaterial.transparency = 1;
    self.atomMaterial.locksAmbientWithDiffuse = NO;
    self.atomMaterial.doubleSided = NO;
    self.atomMaterial.writesToDepthBuffer = true;
    spherenode.geometry.materials = @[self.atomMaterial];
    
    //NSLog(@"Generated %@ atom content", self.atomElement);
    
    
    
    SCNNode *symbolnode = [SCNNode node];
    [self addChildNode:symbolnode];

    SCNNode *symboltest = [SCNNode node];
    
    SCNMaterial *mat = [SCNMaterial material];
    mat.diffuse.contents = self.atomColor;
    mat.selfIllumination.contents = [UIColor whiteColor];// [UIImage imageNamed:glareimage];
    mat.blendMode = SCNBlendModeScreen;
    mat.diffuse.intensity = 0.8;
    mat.writesToDepthBuffer = false;
    
    [symbolnode addChildNode:symboltest];
    symboltest.position = SCNVector3Make(0, 0, self.atomSize+0.1);
    symboltest.renderingOrder = 10;
    
    SCNBillboardConstraint *look = [SCNBillboardConstraint billboardConstraint];
    symbolnode.constraints = @[look];
    
//    NSString *elementletters = self.atomSymbol;
//    SCNText *text = [SCNText textWithString:elementletters extrusionDepth:0];
//    text.alignmentMode = kCAAlignmentCenter;
//    text.flatness = 0;
//    text.font = [UIFont systemFontOfSize:0.3 weight:UIFontWeightBold];
//    //text.containerFrame = CGRectMake(-1, -1, 1, 1);
//    SCNNode *textnode = [SCNNode nodeWithGeometry:text];
//    textnode.geometry.materials = @[mat];
    
//    SCNPlane *plane = [SCNPlane planeWithWidth:0.1 height:0.1];
//    SCNNode *planenode = [SCNNode nodeWithGeometry:plane];
//    [symboltest addChildNode:planenode];
//    planenode.geometry.materials = @[mat];

    
//    //get bounding box of text
//    SCNVector3 min = SCNVector3Zero;
//    SCNVector3 max = SCNVector3Zero;
//    [textnode.geometry getBoundingBoxMin:&min max:&max];
//
//    CGSize sizeMax = CGSizeMake( max.x - min.x,
//                                max.y - min.y);
//
//    NSLog(@"size max y %f", sizeMax.height);
//
//    textnode.pivot = SCNMatrix4MakeTranslation(0, 0, 0);
//    textnode.position = SCNVector3Make(0, 0, 0);
//    //textnode.position = SCNVector3Make(-sizeMax.width/2, -sizeMax.height*4, textnode.position.z);
//
//
//    [symboltest addChildNode:textnode];
    

    [self generateEnvelope];
}

-(void)generateEnvelope
{
    //create the sphere object
    SCNSphere *sphere = [SCNSphere sphereWithRadius:self.atomSize*1.5];
    sphere.segmentCount = 25;
    SCNNode *spherenode = [SCNNode nodeWithGeometry:sphere];
    [self addChildNode:spherenode];
    //test.categoryBitMask = 0x1 << 5;
    
    SCNMaterial *mat = [SCNMaterial material];
    
    UIColor *positive_red = [UIColor colorFromHexString:@"bb354b"];
    UIColor *negative_blue = [UIColor colorFromHexString:@"3d92ab"];

    mat.lightingModelName = SCNLightingModelConstant;
    mat.diffuse.contents = negative_blue;
    mat.diffuse.intensity = 1;
    mat.reflective.contents = [UIImage imageNamed:@"environment_sphere_high_contrast"];
    mat.reflective.intensity = 1;
    mat.metalness.contents = [UIColor whiteColor];
    mat.metalness.intensity = 0.9;
    mat.roughness.contents = [UIColor blackColor];// [UIImage imageNamed:@"roughness_1"];
    mat.roughness.intensity = 10;
//    mat.selfIllumination.contents = negative_blue;
//    mat.selfIllumination.intensity = 10;
    mat.shininess = 0;
    //mat.normal.contents = [UIImage imageNamed:@"scuffed-plastic-normal"];
    //mat.normal.intensity = 1;
    mat.transparency = 0.05;
    mat.locksAmbientWithDiffuse = NO;
    mat.doubleSided = YES;
    mat.writesToDepthBuffer = true;
    spherenode.geometry.materials = @[mat];
    spherenode.renderingOrder = 1;
    
//    //incease density as atom size increases
//    float density = 50 + self.atomSize * 3 * 50;
//    NSLog(@"density is %f for atom size %f", density, self.atomSize);
//
//    SCNParticleSystem *particles = [SCNParticleSystem particleSystemNamed:@"Envelope_Particles" inDirectory:@""];
//    particles.emitterShape = sphere;
//    particles.warmupDuration = 5;
//    particles.birthRate = density;
//    //particles.birthRateVariation = density * 0.5;
//    particles.particleLifeSpan = 5;
//    particles.particleLifeSpanVariation = 0;
//    particles.particleVelocity = 0.001;
//    particles.particleVelocityVariation = 0;
//    particles.speedFactor = 1;
//    particles.particleSize = 0.0003;
//    particles.particleSizeVariation = 0;
//    particles.idleDuration = 0;
//    particles.idleDurationVariation = 0;
//    particles.particleColor = [UIColor whiteColor]; //
//
//    [self addParticleSystem:particles];
    
    
}


@end
