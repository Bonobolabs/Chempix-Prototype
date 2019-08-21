//
//  Molecule.m
//  ARtest
//
//  Created by Nathan Hamey on 16/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import "Molecule.h"
#import "Atom.h"
#import "UIColor+Blend.h"

@implementation Molecule

-(void)initialise
{
    self.atomsArray = [[NSMutableArray alloc] init];
    
    self.containerNode = [SCNNode node];
    [self addChildNode:self.containerNode];

}

-(void)addAtomOfElement:(NSString*)element withId:(NSInteger)atomId atX:(float)x Y:(float)y Z:(float)z;
{
    Atom *atom = [Atom node];
    [self.containerNode addChildNode:atom];
    
    //set parameters
    atom.atomCoordinates = SCNVector3Make(x, y, z);
    atom.position = atom.atomCoordinates;
    atom.atomElement = element;
    atom.atomId = atomId;
    
    //generate 3D object
    [atom generate];
    
    //add to molcule array of atoms
    [self.atomsArray addObject:atom];
    
    //NSLog(@"Added Atom %ld: %@ at X%f Y%f Z%f", atomId, element, x, y, z);
}

-(void)generateBonds
{
    for (Atom *firstatom in self.atomsArray)
    {
        SCNVector3 first_atom_position = firstatom.atomCoordinates;
        
        for (Atom *secondatom in self.atomsArray)
        {
            //check if same atom
            if (secondatom.atomId != firstatom.atomId)
            {
                //calculate distance between atom centers

                SCNVector3 second_atom_position = secondatom.atomCoordinates;
                float distance = sqrtf(pow(first_atom_position.x-second_atom_position.x, 2) + pow(first_atom_position.y-second_atom_position.y, 2) + pow(first_atom_position.z-second_atom_position.z, 2));
                NSLog(@"distance from %@ to %@ is %f", firstatom.atomElement, secondatom.atomElement, distance);
                
                //if the distance is below a threshold
                //look up a table in the element definition to get distances for each other atom type to determine a bond
                
                float threshold = 0;

                for (NSDictionary *thresholddict in firstatom.bondThresholds)
                {
                    if ([[thresholddict objectForKey:@"Element"] isEqualToString:firstatom.atomElement])
                    {
                        threshold = [[thresholddict objectForKey:@"Threshold"] floatValue];
                        NSLog(@"threshold is %f", threshold);
                    }
                }
                
                
                if (distance <= threshold)
                {
                    //and the bond doesn't already exist
                    bool found = NO;
                    for (NSNumber *bonded in secondatom.bondsArray)
                    {
                        NSInteger bondid = [bonded intValue];
                        NSLog(@"found bond to %ld from %ld", bondid, secondatom.atomId);
                        if (bondid == firstatom.atomId) found = YES;
                    }
                    
                    if (!found) [self addBondBetween:firstatom.atomId and:secondatom.atomId];
                }

            }

        }
        
        //calculate distance between atom centers
        //float distance = sqrtf(pow(startcoords.x-endcoords.x, 2) + pow(startcoords.y-endcoords.y, 2) + pow(startcoords.z-endcoords.z, 2));
        //float distance = GLKVector3Distance(SCNVector3ToGLKVector3(cooridnateSetOne.position), SCNVector3ToGLKVector3(coordinateSetTwo.position));

    }
    
}

-(void)addBondBetween:(NSInteger)first and:(NSInteger)second
{
    //get info about the two atoms from the atoms in the molecule atom array
    
    //this node will be added to the first atom
    SCNNode *bond_start_node = [SCNNode node];
    
    //this node will be a child of the start node, with its relative position converted from world xyz
    //this enables us to use the look constraint to keep a bond pointing between the two even though
    //the whole molecule gets transformed
    SCNNode *bond_end_node = [SCNNode node];
    [bond_start_node addChildNode:bond_end_node];
    
    SCNVector3 startcoords;
    float start_offset = 0;
    SCNVector3 endcoords;
    float end_offset = 0;

    SCNMaterial *start_mat = [SCNMaterial material];
    SCNMaterial *end_mat = [SCNMaterial material];

    for (Atom *firstatom in self.atomsArray)
    {
        if (firstatom.atomId == first)
        {
            startcoords = firstatom.atomCoordinates;
            start_offset = firstatom.atomSize;
            start_mat = firstatom.atomMaterial;
            bond_start_node.position = startcoords;
            [firstatom addChildNode:bond_start_node];
            
            [firstatom.bondsArray addObject:[NSNumber numberWithInteger:second]];

        }
    }

    for (Atom *secondatom in self.atomsArray)
    {
        if (secondatom.atomId == second)
        {
            endcoords = secondatom.atomCoordinates;
            end_offset = secondatom.atomSize;
            end_mat = secondatom.atomMaterial;
            bond_end_node.position = [self convertPosition:endcoords toNode:bond_start_node];
            
            [secondatom.bondsArray addObject:[NSNumber numberWithInteger:second]];

        }
    }
    
    //setup a constraint that will point the bond from the first to the second atom
    //easier than working out the matrix for rotation!
    SCNConstraint *constraint = [SCNLookAtConstraint lookAtConstraintWithTarget:bond_end_node];
    
    //calculate distance between atom centers
    float total_distance = sqrtf(pow(startcoords.x-endcoords.x, 2) + pow(startcoords.y-endcoords.y, 2) + pow(startcoords.z-endcoords.z, 2));
    
    //float cylHeight = GLKVector3Distance(SCNVector3ToGLKVector3(cooridnateSetOne.position), SCNVector3ToGLKVector3(coordinateSetTwo.position));
    
    //distance between the surfaces of the two atoms taking into account their sizes
    float distance = total_distance - start_offset - end_offset;
    //NSLog(@"distance between %ld and %ld is %f", first, second, distance);
    
    //bond width
    float cylinder_radius = 0.075;
    
    //the bond cylinder will be shorter than the distance to allow for the connecting cones to come off each end
    float cone_offset = 0.075;
    float cylinder_height = distance - cone_offset;
    
    //create container node
    SCNNode *containernode = [SCNNode node];
    [self.containerNode addChildNode:containernode];
    
    //setup cylinder orientation node
    SCNNode *orientationnode = [SCNNode node];
    [containernode addChildNode:orientationnode];

    //set position of the container node at first atom and point to the second
    containernode.position = startcoords;
    containernode.constraints = @[constraint];

    //setup the orientation node so its Z is pointing along the bond
    orientationnode.rotation = SCNVector4Make(1, 0, 0, M_PI/2);
    
    //create cylinder
    SCNCylinder *cylinder = [SCNCylinder cylinderWithRadius:cylinder_radius height:cylinder_height];
    cylinder.radialSegmentCount = 45;
    cylinder.heightSegmentCount = 1;
    
    SCNNode *cylindernode = [SCNNode nodeWithGeometry:cylinder];
    [orientationnode addChildNode:cylindernode];
    
    cylindernode.pivot = SCNMatrix4MakeTranslation(0, distance/2, 0);
    cylindernode.position = SCNVector3Make(0, -start_offset, 0);
    
    //create a material for the cylinder
    SCNMaterial *bond_mat = [SCNMaterial material];
    bond_mat.lightingModelName = SCNLightingModelPhysicallyBased;
    
    bond_mat.diffuse.contents = [UIColor colorFromHexString:@"#94a3a7"];
    bond_mat.diffuse.intensity = 1;
    bond_mat.reflective.contents = [UIImage imageNamed:@"environment_sphere_2"];
    bond_mat.reflective.intensity = 1;
    bond_mat.metalness.contents = [UIColor whiteColor];
    bond_mat.metalness.intensity = 0.9;
    bond_mat.roughness.contents = [UIImage imageNamed:@"roughness_1"];
    bond_mat.roughness.intensity = 5;
    bond_mat.shininess = 2;
    bond_mat.normal.contents = [UIImage imageNamed:@"scuffed-plastic-normal"];
    bond_mat.normal.intensity = 1;
    //bond_mat.transparency = 0.9;
    bond_mat.locksAmbientWithDiffuse = NO;
    bond_mat.doubleSided = NO;
    bond_mat.writesToDepthBuffer = true;
    cylindernode.geometry.materials = @[bond_mat];
    
    //create the starting cone at the start of the cylinder connecting to the first atom
    
    float start_cone_size = cylinder_radius * 0.75;
    float start_cone_top_radius = cylinder_radius + start_cone_size;
    float start_cone_bottom_radius = cylinder_radius;
    float start_cone_height = start_cone_size;
    
    SCNCone *startcone = [SCNCone coneWithTopRadius:start_cone_top_radius bottomRadius:start_cone_bottom_radius height:start_cone_height];
    startcone.radialSegmentCount = 45;
    startcone.heightSegmentCount = 1;
    
    SCNNode *weldstartnode = [SCNNode nodeWithGeometry:startcone];
    [cylindernode addChildNode:weldstartnode];
    
    weldstartnode.pivot = SCNMatrix4MakeTranslation(0, -cylinder_height/2 - start_cone_height/2, 0);

    //set the material from the first atom
    weldstartnode.geometry.materials = @[start_mat];

    //create the ending cone at the end of the cylinder connecting to the second atom
    
    float end_cone_size = cylinder_radius * 0.75;
    float end_cone_top_radius = cylinder_radius + end_cone_size;
    float end_cone_bottom_radius = cylinder_radius;
    float end_cone_height = end_cone_size * 2;
    
    SCNCone *endcone = [SCNCone coneWithTopRadius:end_cone_top_radius bottomRadius:end_cone_bottom_radius height:end_cone_height];
    endcone.radialSegmentCount = 45;
    endcone.heightSegmentCount = 1;
    
    SCNNode *weldendnode = [SCNNode nodeWithGeometry:endcone];
    [cylindernode addChildNode:weldendnode];
    
    weldendnode.pivot = SCNMatrix4MakeTranslation(0, -cylinder_height/2 - end_cone_height/2, 0);
    weldendnode.rotation = SCNVector4Make(1, 0, 0, M_PI);
    weldendnode.position = SCNVector3Make(0, 0, 0);
    
    //set the material from the first atom
    weldendnode.geometry.materials = @[end_mat];
    
    //NSLog(@"Added Bond between atom %ld and atom %ld", first, second);
    //handy: //https://stackoverflow.com/questions/35002232/draw-scenekit-object-between-two-points/42941966#42941966

}

-(void)setInitialState
{

    //find the center in y so that the position the molecule sits at in y can be set
    float lowest_atom_x = 1000;
    float lowest_atom_y = 1000;
    float lowest_atom_z = 1000;
    for (Atom *atom in self.atomsArray)
    {
        if (atom.position.x < lowest_atom_x) lowest_atom_x = atom.position.x;
        if (atom.position.y < lowest_atom_y) lowest_atom_y = atom.position.y;
        if (atom.position.z < lowest_atom_z) lowest_atom_z = atom.position.z;
    }
    
    float highest_atom_x = -1000;
    float highest_atom_y = -1000;
    float highest_atom_z = -1000;
    for (Atom *atom in self.atomsArray)
    {
        if (atom.position.x > highest_atom_x) highest_atom_x = atom.position.x;
        if (atom.position.y > highest_atom_y) highest_atom_y = atom.position.y;
        if (atom.position.z > highest_atom_z) highest_atom_z = atom.position.z;
    }

    self.moleculeSizeX = highest_atom_x-lowest_atom_x;
    self.moleculeSizeY = highest_atom_y-lowest_atom_y;
    self.moleculeSizeZ = highest_atom_z-lowest_atom_z;
    self.moleculeCalculatedCenter = SCNVector3Make(lowest_atom_x+self.moleculeSizeX/2, self.moleculeSizeY/2, lowest_atom_z+self.moleculeSizeZ/2);
    self.containerNode.pivot = SCNMatrix4MakeTranslation(self.moleculeCalculatedCenter.x, -self.moleculeCalculatedCenter.y, self.moleculeCalculatedCenter.z);

    float start_scale = 0.05;
    self.containerNode.scale = SCNVector3Make(start_scale, start_scale, start_scale);
    
    
    self.hidden = YES;
}

-(void)animateSpin:(BOOL)animate
{
    
//    if (animate)
//    {
//        //spin around Y
//        SCNAction *spin = [SCNAction rotateByX:0 y:M_PI*2 z:0 duration:30];
//        spin.timingMode = SCNActionTimingModeLinear;
//        SCNAction *loopspin = [SCNAction repeatActionForever:spin];
//
//        [self.containerNode runAction:loopspin];
//    } else
//    {
//        [self.containerNode removeAllActions];
//    }

    
    
}

-(void)show
{

    [self.containerNode removeAllActions];
    
    self.hidden = NO;

    self.containerNode.position = SCNVector3Make(0, 0, 0);
    //self.containerNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);

    //rise up off the page and settle to floating height

    float distance_off_page = 1;// + self.moleculeSizeY/2;
    float overshoot = 0.25;

    SCNAction *floatup = [SCNAction moveBy:SCNVector3Make(0, distance_off_page + overshoot, 0) duration:0.5];
    floatup.timingMode = SCNActionTimingModeEaseInEaseOut;

    SCNAction *floatsettle = [SCNAction moveBy:SCNVector3Make(0, -overshoot, 0) duration:0.5];
    floatsettle.timingMode = SCNActionTimingModeEaseOut;

    SCNAction *floatin = [SCNAction sequence:@[floatup, floatsettle]];
    [self.containerNode runAction:floatin];
    
    //scale up
    float start_scale = 0.1;
    self.containerNode.scale = SCNVector3Make(start_scale, start_scale, start_scale);
    
    float scale_overshoot = 0.1;
    SCNAction *scaleup = [SCNAction scaleTo:1 + scale_overshoot duration:0.5];
    scaleup.timingMode = SCNActionTimingModeEaseOut;
    
    SCNAction *scalesettle = [SCNAction scaleTo:1 duration:1];
    scalesettle.timingMode = SCNActionTimingModeEaseOut;
    
    SCNAction *scalein = [SCNAction sequence:@[scaleup, scalesettle]];
    [self.containerNode runAction:scalein];
    
    
//    //spin around X
//    SCNAction *spin = [SCNAction rotateByX:M_PI/2 y:0 z:0 duration:5];
//    spin.timingMode = SCNActionTimingModeEaseInEaseOut;
//    [self.containerNode runAction:spin];
    
    //    SCNAction *floatup = [SCNAction moveBy:SCNVector3Make(0, distance_off_page, 0) duration:1];
    //    floatup.timingMode = SCNActionTimingModeEaseInEaseOut;
    //    [self.positionNode runAction:floatup completionHandler:
    //     ^{
    //
    //
    //     }];
    
}

-(void)adjustFloatingPositionBy:(float)y
{
    
    float distance_off_page = 1;// + self.moleculeSizeY/2;
    float max = distance_off_page + 3;
    float capped_y = MAX(distance_off_page,MIN(max,self.containerNode.position.y+y));
    self.containerNode.position = SCNVector3Make(0, capped_y, 0);
    
}

-(void)hide
{
    
}



@end
