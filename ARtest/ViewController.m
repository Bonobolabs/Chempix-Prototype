//
//  ViewController.m
//  ARtest
//
//  Created by Nathan Hamey on 14/8/19.
//  Copyright © 2019 Nate. All rights reserved.
//

#import "ViewController.h"
#import "Molecule.h"
#import "ReferenceGrid.h"

@interface ViewController () <ARSCNViewDelegate, SCNSceneRendererDelegate, SKSceneDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *gameSceneView;
@property (nonatomic, strong) IBOutlet UILabel *moleculeNameLabel;

//camera
@property (nonatomic, strong) SCNCamera *camera;

//floor
@property (nonatomic, strong) SCNFloor *floor;
@property (nonatomic, strong) SCNNode *floorNode;

@property (nonatomic, strong) SCNNode *moleculesContainerNode;
@property (nonatomic, strong) NSMutableArray *moleculesArray;

@property (nonatomic, strong) NSMutableArray *moleculeData;
@property (nonatomic, strong) NSMutableArray *elementData;

//scene and spritekit
@property (nonatomic, strong) SCNScene *gameScene;

//lighting
@property (nonatomic, strong) SCNNode *lightDirectionalNode;
@property (nonatomic, strong) SCNLight *lightDirectional;

//spritekit
@property (nonatomic, strong) SKScene *spriteKitScene;

@property (nonatomic, strong) ReferenceGrid *referenceGrid;

@property (nonatomic, strong) Molecule *currentMolecule;


@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.moleculesArray = [[NSMutableArray alloc] init];
    self.moleculeData = [[NSMutableArray alloc] init];
    self.elementData = [[NSMutableArray alloc] init];

    [self loadMoleculeData];
    [self setupSession];
}

-(void)setupSession
{
 
    [self setupScene];
    [self setupCamera];
    [self setupLighting];
    [self setupGestures];
    
    [self setupFloor];

    //this is an object that generates a debug grid to help know where the floor plane is
    self.referenceGrid = [ReferenceGrid node];
    [self.gameScene.rootNode addChildNode:self.referenceGrid];
    [self.referenceGrid generate];
    self.referenceGrid.position = self.floorNode.position;

    
}

-(void)resetSession
{
    
}

-(void)setupGestures
{
    //Setup Gestures
    UIPanGestureRecognizer *slide = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cameraSlide:)];
    slide.delegate = self;
    [self.gameSceneView addGestureRecognizer:slide];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(cameraPinch:)];
    pinch.delegate = self;
    [self.gameSceneView addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *doubletap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraDoubleTap:)];
    doubletap.numberOfTapsRequired = 2;
    doubletap.numberOfTouchesRequired = 1;
    [self.gameSceneView addGestureRecognizer:doubletap];
    
    UITapGestureRecognizer *doubletwofingertap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraDoubleTwoFingerTap:)];
    doubletwofingertap.numberOfTapsRequired = 2;
    doubletwofingertap.numberOfTouchesRequired = 2;
    [self.gameSceneView addGestureRecognizer:doubletwofingertap];
    
    UILongPressGestureRecognizer *press = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cameraLongPress:)];
    press.minimumPressDuration = .01;
    press.delegate = self;
    [self.gameSceneView addGestureRecognizer:press];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Create a session configuration
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];

    configuration.lightEstimationEnabled = YES;
    
    // Run the view's session
    [self.gameSceneView.session runWithConfiguration:configuration];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.gameSceneView.session pause];
}


- (void)renderer:(id <SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time {
    ARLightEstimate *estimate = self.gameSceneView.session.currentFrame.lightEstimate;
    if (!estimate) {
        return;
    }
    
    //update the opacity of the reference grid as the camera moves in Y
    CGFloat camera_y = self.gameSceneView.pointOfView.position.y;
    CGFloat range = 0.1;
    CGFloat proximity_to_floor = MIN(1, ABS(camera_y - self.floorNode.position.y) / range);
    //NSLog(@"camera proximity to floor: %f", proximity_to_floor);
    self.referenceGrid.opacity = proximity_to_floor;
    
    //adjust lighting per frame so that it matches the camera scene
    CGFloat intensity = estimate.ambientIntensity / 200.0;
    self.lightDirectional.intensity = 200;
    self.gameSceneView.scene.lightingEnvironment.intensity = intensity;
    //NSLog(@"light estimate: %f", estimate.ambientIntensity);

    
}

-(void)setupScene
{
    self.gameSceneView.delegate = self;
    //self.gameSceneView.allowsCameraControl = NO;
    self.gameSceneView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    self.gameSceneView.rendersContinuously = YES;
    self.gameSceneView.preferredFramesPerSecond = 60;
    self.gameSceneView.jitteringEnabled = NO;
    //self.gameSceneView.debugOptions = SCNDebugOptionShowWireframe;
    self.gameSceneView.showsStatistics = NO;
    
    self.gameScene = [SCNScene scene];
    self.gameSceneView.scene = self.gameScene;
    
    //put molecules in container node
    self.moleculesContainerNode = [SCNNode node];
    [self.gameScene.rootNode addChildNode:self.moleculesContainerNode];

}

-(void)setupFloor
{
    
    //use this for putting shadows on
    
    self.floor = [SCNFloor floor];
    
    SCNMaterial *floormat = [SCNMaterial material];
    floormat.writesToDepthBuffer = true;
    floormat.diffuse.contents = [UIColor clearColor];
    floormat.writesToDepthBuffer = true;
    floormat.readsFromDepthBuffer = true;
    //floormat.colorBufferWriteMask = [];
    floormat.lightingModelName = SCNLightingModelConstant;
    self.floor.materials = @[floormat];
    self.floorNode = [SCNNode nodeWithGeometry:self.floor];
    [self.gameScene.rootNode addChildNode:self.floorNode];
    
    self.floorNode.position = SCNVector3Make(0, -0.1, 0);
}

-(void)setupCamera
{
    self.camera.wantsHDR = true;
    self.camera.wantsExposureAdaptation = YES;
    self.camera.maximumExposure = 1;
    self.camera.minimumExposure = 1;
    self.camera.whitePoint = 1; //default is 1
    self.camera.exposureOffset = 1; //default is 0
    self.camera.exposureAdaptationDarkeningSpeedFactor = 2;
    self.camera.exposureAdaptationBrighteningSpeedFactor = 2;
    
    self.camera.bloomIntensity = 1;
    self.camera.bloomThreshold = 0.3;
    self.camera.bloomBlurRadius = 30;
    self.camera.contrast = 1;
    self.camera.saturation = 1;
}

-(void)setupLighting
{
    UIImage *env = [UIImage imageNamed: @"environment_sphere"];
    self.gameSceneView.scene.lightingEnvironment.contents = env;
    
    self.gameSceneView.autoenablesDefaultLighting = NO;
    
    //directional
    self.lightDirectionalNode = [SCNNode node];
    [self.gameScene.rootNode addChildNode:self.lightDirectionalNode];
    
    self.lightDirectional = [SCNLight light];
    self.lightDirectional.type = SCNLightTypeDirectional;
    //self.lightDirectional.categoryBitMask = 0;
    //self.lightDirectional.attenuationStartDistance = 1000;
    //self.lightDirectional.attenuationEndDistance = 2000;
    self.lightDirectional.attenuationFalloffExponent = 1;
    self.lightDirectional.intensity = 1000;
    self.lightDirectional.color = [UIColor whiteColor];
    self.lightDirectional.castsShadow = true;
    self.lightDirectional.automaticallyAdjustsShadowProjection = true;
    self.lightDirectional.shadowSampleCount = 64;
    self.lightDirectional.shadowRadius = 40;
    self.lightDirectional.shadowMode = SCNShadowModeDeferred;
    self.lightDirectional.shadowMapSize = CGSizeMake(1024, 1024);
    self.lightDirectional.shadowColor = [UIColor colorWithWhite:0 alpha:0.75];
    self.lightDirectionalNode.light = self.lightDirectional;

    self.lightDirectionalNode.position = SCNVector3Make(0, 100, 0);
    self.lightDirectionalNode.rotation = SCNVector4Make(1, 0, 0, -M_PI/2);
}

# pragma mark - Generate and load Molecules

-(void)loadMoleculeData
{
    //prepare paths and load file
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *path = [documentsPath stringByAppendingPathComponent:@"Molecules.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) path = [[NSBundle mainBundle] pathForResource:@"Molecules" ofType:@"plist"];
    NSDictionary *moleculeDict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    //get array of molecules
    //NSArray *molecules = [moleculeDict objectForKey:@"Molecules"];
    self.moleculeData = [moleculeDict objectForKey:@"Molecules"];
    
    
}

-(void)generateMolecule:(NSInteger)moleculeId
{
    
    NSDictionary *selectedmolecule = [self.moleculeData objectAtIndex:moleculeId];

    //create molecule object
    Molecule *molecule = [Molecule node];
    [molecule initialise];

    //generate the atoms and bonds
    
    [self.moleculesContainerNode addChildNode:molecule];
    
    molecule.moleculeType = [selectedmolecule objectForKey:@"Type"];

    //get array of atoms
    NSArray *atoms = [selectedmolecule objectForKey:@"Atoms"];
    
    //parse array
    NSInteger atomindex = 0;
    for (NSDictionary *atom in atoms)
    {
        NSInteger atomId = atomindex;
        NSString *element = [atom objectForKey:@"Element"];
        float x = [[atom objectForKey:@"X"] floatValue];
        float y = [[atom objectForKey:@"Y"] floatValue];
        float z = [[atom objectForKey:@"Z"] floatValue];
        
        atomindex += 1;
        
        [molecule addAtomOfElement:element withId:atomId atX:x Y:y Z:z];
    }
    
    //get array of bonds
    NSArray *bonds = [selectedmolecule objectForKey:@"Bonds"];
    
    //parse array
    for (NSDictionary *bond in bonds)
    {
        NSInteger first = [[bond objectForKey:@"First"] intValue];
        NSInteger second = [[bond objectForKey:@"Second"] intValue];
        
        [molecule addBondBetween:first and:second];
    }
    
    NSString *moleculeName = [selectedmolecule objectForKey:@"Type"];
    molecule.name = moleculeName;
    
    molecule.moleculeId = moleculeId;
    //molecule.name = [NSString stringWithFormat:@"%ld", moleculeId];
    
    NSLog(@"Generated molecule for %@ and id %ld", moleculeName, moleculeId);
    
    //initial scale
    molecule.viewingScale = 0.01;
    molecule.scale = SCNVector3Make(molecule.viewingScale, molecule.viewingScale, molecule.viewingScale);
    
    [molecule setInitialState];
    
    [self.moleculesArray addObject:molecule];

    self.currentMolecule = molecule;
    molecule.isSelected = YES;
    
}

NSInteger new_moleculeid;
-(void)loadMoleculeAt:(SCNVector3)position
{
    
    NSInteger count = [self.moleculeData count];
    
    //quick bit of code that makes each new molecule you create the next in the data file
    if (new_moleculeid == count - 1)
    {
        new_moleculeid = 0;
        
    } else
    {
        new_moleculeid += 1;
    }
    
    //NSLog(@"new id %ld", new_moleculeid);
    
    
    //tuesday could use name here
    //check to see if molecule already exists, if does, just move it
    bool exists = NO;
    for (Molecule *molecule in self.moleculesArray)
    {
        if (molecule.moleculeId == new_moleculeid)
        {
            exists = YES;
            self.currentMolecule = molecule;
        }
    }
    
    //if not, generate it
    if (!exists)
    {
        [self generateMolecule:new_moleculeid];
        
    }
    
    self.currentMolecule.position = position;
    [self.currentMolecule show];
    [self.currentMolecule animateSpin:YES];
    
    [self updateUI];
    
}


#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}



# pragma mark - Gestures

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
//    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ! self.mapCamera.cameraShouldAllowPan) {
//        return NO;
//    }
    return YES;
}

bool two_finger_slide;
float startx;
float starty;
float slide_distance;
float slide_x;
float slide_y;
-(void)cameraSlide:(UIPanGestureRecognizer *)gestureRecognizer
{

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        CGPoint startpos = [gestureRecognizer locationInView:self.view];
        startx = startpos.x;
        starty = startpos.y;
        slide_distance = 0;
        slide_x = 0;
        slide_y = 0;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint pos = [gestureRecognizer locationInView:self.view];
        slide_distance = hypotf(startx - pos.x, starty - pos.y);
        
        slide_x = startx - pos.x;
        slide_y = starty - pos.y;

    }
    
    if (gestureRecognizer.numberOfTouches == 1 && !two_finger_slide)
    {
        //basic little snippet to connect horizontal swiping to rotating the molecule
        //a better way to do it is to have rotation based on momentum that's a property that gets updated per frame
        [self.currentMolecule animateSpin:NO];
        
        CGPoint v = [gestureRecognizer velocityInView:self.view];
        //float vmax = MIN( MAX(ABS(v.x), ABS(v.y)), 50);
        
        float vmax = 100;
        float v_x = MAX(-vmax, MIN(v.x, vmax));
        
        //NSLog(@"%f", v_x);
        
        float rot = M_PI*2 * v_x * 0.0001;
        SCNAction *rotate = [SCNAction rotateByX:0 y:rot z:0 duration:0.5];
        rotate.timingMode = SCNActionTimingModeEaseOut;
        [self.currentMolecule runAction:rotate];
        
        
        //move
        float move_y = slide_y * 0.001;
        //NSLog(@"pixel %f world %f", slide_y, move_y);

        [self.currentMolecule adjustFloatingPositionBy:move_y];
    }
    
    else if (gestureRecognizer.numberOfTouches == 2) two_finger_slide = YES;

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled)
    {
        two_finger_slide = NO;
    }
    
    
}

float pinchstartdistance;
-(void)cameraPinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    
//    self.mapCamera.cameraPinchVelocity = [gestureRecognizer velocity];
//    self.mapCamera.cameraPinchVelocity = MIN(MAX(self.mapCamera.cameraPinchVelocity, -15), 15);
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if (gestureRecognizer.numberOfTouches == 2)
        {
            CGPoint firstPoint = [gestureRecognizer locationOfTouch:0 inView:gestureRecognizer.view];
            CGPoint secondPoint = [gestureRecognizer locationOfTouch:1 inView:gestureRecognizer.view];
            pinchstartdistance = hypotf(firstPoint.x - secondPoint.x, firstPoint.y - secondPoint.y);
//            self.mapCamera.realTimeCameraTruckPinchBegin = self.mapCamera.realTimeCameraTruck;
        }
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        if (gestureRecognizer.numberOfTouches == 2)
        {
            //basic little snippet to connect pinching to scaling the molecule
            CGPoint firstPoint = [gestureRecognizer locationOfTouch:0 inView:gestureRecognizer.view];
            CGPoint secondPoint = [gestureRecognizer locationOfTouch:1 inView:gestureRecognizer.view];
          
            float pinch_distance = pinchstartdistance - hypotf(firstPoint.x - secondPoint.x, firstPoint.y - secondPoint.y);
            
            float min = -1;
            float max = 1;
            float pinch_factor = MIN(max,MAX(min,(-pinch_distance / 500)));
            pinch_factor = pinch_factor * 0.001;

            //float target_scale = 0.05 * pinch_factor;
            
            float target_scale = MIN(0.02, MAX(0.005, self.currentMolecule.scale.x + pinch_factor));
            //self.currentMolecule.viewingScale = 0.01;
            
            //NSLog(@"pinch %f current scale %f target %f", pinch_factor, self.currentMolecule.scale.x, target_scale);

            SCNAction *scale = [SCNAction scaleTo:target_scale duration:0.1];
            scale.timingMode = SCNActionTimingModeEaseOut;
            [self.currentMolecule runAction:scale];
            
            //scale action

        }
    }
    
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateFailed)
    {
//        self.mapCamera.cameraPinchVelocity = 0;
    }
    
    
}


-(void)cameraDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint position = [gestureRecognizer locationInView:self.view];
    //NSLog(@"tap position %f %f", position.x, position.y);

    SCNVector3 worldpos = [self floorPositionForTouchPoint:position];
    //NSLog(@"world position %f %f %f", worldpos.x, worldpos.y, worldpos.z);
    
    [self loadMoleculeAt:worldpos];
}

-(void)cameraDoubleTwoFingerTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if (self.referenceGrid.isVisible)
    {
        [self.referenceGrid hide];
    } else
    {
        [self.referenceGrid show];
    }
}

float moved_distance;
CGPoint began_position;
CGPoint moved_position;
CGPoint end_position;
- (void)cameraLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        began_position = CGPointMake(touchLocation.x, touchLocation.y);
        moved_distance = 0;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        moved_position = CGPointMake(touchLocation.x, touchLocation.y);
        moved_distance = hypotf(began_position.x - moved_position.x, began_position.y - moved_position.y);

    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled || gestureRecognizer.state == UIGestureRecognizerStateFailed)
    {
        CGPoint touchLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
        end_position = CGPointMake(touchLocation.x, touchLocation.y);
        
        if (moved_distance < 1)
        {
            
            
            NSString *tapped = [self moleculeForTouchPoint:end_position];
            
            for (Molecule *molecule in self.moleculesArray)
            {
                if ([molecule.name isEqualToString:tapped])
                {
                    if (molecule.moleculeId != self.currentMolecule.moleculeId)
                    {
                        NSLog(@"change current molecule to %@", molecule.name);
                        self.currentMolecule = molecule;
                        [self updateUI];

                    }
                    
                } else
                {
//                    //no hits, deselect all

                }
            }
            


        }


        

    }
    
}



#pragma mark - Getters

-(SCNVector3)floorPositionForTouchPoint:(CGPoint)position
{
    SCNVector3 point_to_project = SCNVector3Make(position.x, position.y, 0);
    SCNVector3 from = [self.gameSceneView unprojectPoint:point_to_project];
    SCNVector3 point_to_project_end = SCNVector3Make(position.x, position.y, 1);
    SCNVector3 to = [self.gameSceneView unprojectPoint:point_to_project_end];
    
    NSArray *hitResults  = [self.gameScene.rootNode hitTestWithSegmentFromPoint:from toPoint:to options:@{SCNHitTestRootNodeKey : self.floorNode, SCNHitTestBackFaceCullingKey : @(YES) ,SCNHitTestIgnoreChildNodesKey : @(NO)}]; // SCNHitTestOptionCategoryBitMask : @(0x1 << 2)
    
    if([hitResults count] > 0)
    {
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        SCNVector3 hit_position = result.worldCoordinates;
        //NSLog(@"hit: %@", result.node.parentNode.name);
        return hit_position;//  result.node.position;
    } else
    {
        //NSLog(@"no hit");
        return SCNVector3Make(0, 0, 0);
    }
}

-(NSString*)moleculeForTouchPoint:(CGPoint)position
{
    SCNVector3 point_to_project = SCNVector3Make(position.x, position.y, 0);
    SCNVector3 from = [self.gameSceneView unprojectPoint:point_to_project];
    SCNVector3 point_to_project_end = SCNVector3Make(position.x, position.y, 1);
    SCNVector3 to = [self.gameSceneView unprojectPoint:point_to_project_end];
    
    NSArray *hitResults  = [self.moleculesContainerNode hitTestWithSegmentFromPoint:from toPoint:to options:@{SCNHitTestBackFaceCullingKey : @(YES) ,SCNHitTestIgnoreChildNodesKey : @(NO)}]; // SCNHitTestOptionCategoryBitMask : @(0x1 << 2)
    
    if([hitResults count] > 0)
    {
       SCNHitTestResult *result = [hitResults objectAtIndex:0];
        SCNNode *hitNode = result.node;
        NSLog(@"tap hit %@", hitNode.parentNode.parentNode.parentNode.name);
        return hitNode.parentNode.parentNode.parentNode.name;
        
    } else
    {
        //NSLog(@"no hit");
        return @"";
    }

    

}

#pragma mark - UI


-(void)updateUI
{
    
    self.moleculeNameLabel.alpha = 0;
    self.moleculeNameLabel.transform = CGAffineTransformMakeScale(0.1, 0.1);

    self.moleculeNameLabel.text = [self.currentMolecule.moleculeType uppercaseString];
    
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        self.moleculeNameLabel.transform = CGAffineTransformMakeScale(1, 1);
        self.moleculeNameLabel.alpha = 1;
        
    } completion:nil];
    
}


@end
