//
//  OpenGL_SolarSystemViewController.m
//  BouncySquare
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLSolarSystem.h" 
#import "OpenGLSolarSystemViewController.h"

@interface OpenGLSolarSystemViewController () 
{
    
    
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

@end


@implementation OpenGLSolarSystemViewController

@synthesize context = _context;
@synthesize effect = _effect;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) 
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    view.drawableMultisample=GLKViewDrawableMultisample4X;
    
    [EAGLContext setCurrentContext:self.context];
    
    m_SolarSystem=[[OpenGLSolarSystemController alloc] init];
	
    [self initLighting];
    
    UIPinchGestureRecognizer *pinchGesture = 
    [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer:pinchGesture];
    
    UIPanGestureRecognizer *panGesture = 
    [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGesture];
    
    [self createUI];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender 
{
    static CGPoint prevLocation;
    CGPoint translate = [sender translationInView:self.view];
    
    UIGestureRecognizerState state;
    
    state=sender.state;
    
    if(state==UIGestureRecognizerStateBegan)
    {      
        prevLocation=translate;
        [m_SolarSystem lookAtTarget];
    }
    else if(state==UIGestureRecognizerStateChanged)
    {
        CGPoint currlocation =translate;
		
        m_PointerLocation=CGPointMake(currlocation.x, currlocation.y);
        
        [self setHoverPosition:0 location:currlocation prevLocation:prevLocation];
        
        prevLocation=currlocation;
    }
}

- (IBAction)handlePinchGesture:(UIGestureRecognizer *)sender 
{
    static float startFOV=0.0;
    CGFloat factor = [(UIPinchGestureRecognizer *)sender scale];
    UIGestureRecognizerState state;
    
    state=sender.state;
    
    if(state==UIGestureRecognizerStateBegan)
    {      
        startFOV=[m_SolarSystem getFieldOfView];
    }
    else if(state==UIGestureRecognizerStateChanged)
    {
        float minFOV=5.0;
        float maxFOV=75.0;
        float currentFOV;
        
        currentFOV=startFOV*factor;
        
        if((currentFOV>=minFOV) && (currentFOV<=maxFOV))
            [m_SolarSystem setFieldOfView:currentFOV];
    }     
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{   
    glEnable(GL_DEPTH_TEST);
    
	glClearColor(0.0f,0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
	[m_SolarSystem execute];    
}

-(void)initLighting
{
	GLfloat sunPos[]={0.0,0.0,0.0,1.0};			
	GLfloat posFill1[]={-15.0,15.0,0.0,1.0};			
	GLfloat posFill2[]={-10.0,-4.0,1.0,1.0};			
    
	GLfloat white[]={1.0,1.0,1.0,1.0};			
	GLfloat dimblue[]={0.0,0.0,.2,1.0};			
    
	GLfloat cyan[]={0.0,1.0,1.0,1.0};			
	GLfloat yellow[]={1.0,1.0,0.0,1.0};
	GLfloat dimmagenta[]={.75,0.0,.25,1.0};			
    
    GLfloat brightambient[]={0.6,0.8,1.0,1.0};

    float matAmbient[]={.5f,.5f,.5f,1.0f};
    GLfloat diffuse[]={0.0,0.0,.2,.1};			

	//lights go here
	
	glLightfv(SS_SUNLIGHT,GL_POSITION,sunPos);
	glLightfv(SS_SUNLIGHT,GL_DIFFUSE,white);
	glLightfv(SS_SUNLIGHT,GL_SPECULAR,yellow);		
	
	glLightfv(SS_FILLLIGHT1,GL_POSITION,posFill1);
	glLightfv(SS_FILLLIGHT1,GL_DIFFUSE,dimblue);
	glLightfv(SS_FILLLIGHT1,GL_SPECULAR,cyan);	
    
	glLightfv(SS_FILLLIGHT2,GL_POSITION,posFill2);
	glLightfv(SS_FILLLIGHT2,GL_SPECULAR,dimmagenta);
	glLightfv(SS_FILLLIGHT2,GL_DIFFUSE,dimblue);
    
    glLightfv(SS_AMBIENTLIGHT,GL_AMBIENT,brightambient);
	glLightfv(SS_AMBIENTLIGHT,GL_DIFFUSE,diffuse);
    
	//let's us see the backside of the planets
	
    
	//materials go here
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, cyan);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, white);
    	
    glMaterialfv(GL_FRONT,GL_AMBIENT,matAmbient);

	glMaterialf(GL_FRONT_AND_BACK,GL_SHININESS,25);				
    
	glShadeModel(GL_SMOOTH);				
	glLightModelf(GL_LIGHT_MODEL_TWO_SIDE,0.0);
	
	glEnable(GL_LIGHTING);
	glEnable(SS_SUNLIGHT);
	glEnable(SS_FILLLIGHT1);
	glEnable(SS_FILLLIGHT2);
    glEnable(SS_AMBIENTLIGHT);
}

-(void)setHoverPosition:(unsigned)nFlags location:(CGPoint)location prevLocation:(CGPoint)prevLocation 
{
    int dx;
    int dy;
    GLKQuaternion orientation,tempQ;
    GLKVector3 offset,objectLoc,vpLoc;
    GLKVector3 offsetv=GLKVector3Make(0.0,0.0,0.0);						
    float reference=300;
    float scale=4.0;	
    GLKMatrix3 matrix3;
    
    CGRect frame = [[UIScreen mainScreen] bounds];		
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    orientation=gluGetOrientation();                                                                       //1
    
    vpLoc=[m_SolarSystem getEyeposition];                                                 //2
    
    objectLoc=[m_SolarSystem getTargetLocation];                                          //3
    
    offset.x=(objectLoc.x-vpLoc.x);
    offset.y=(objectLoc.y-vpLoc.y);
    offset.z=(objectLoc.z-vpLoc.z);
    
    offsetv.z=GLKVector3Distance(objectLoc,vpLoc);
    
    dx=location.x-prevLocation.x;                                                                           //5
    dy=location.y-prevLocation.y;
    
    float multiplier;
    
    multiplier=frame.size.width/reference;                                                         //6
    
    glMatrixMode(GL_MODELVIEW);
    
    float c,s;
    float rad=scale*multiplier*dy/reference;
    
    s=sinf(rad*.5);
    c=cosf(rad*.5);
    
    tempQ=GLKQuaternionMake(s,0.0,0.0,c);                           //rotate around the X-axis
    orientation=GLKQuaternionMultiply(tempQ,orientation);
    
    rad=scale*multiplier*dx/reference;
    
    s=sinf(rad*.5);
    c=cosf(rad*.5);
    
    tempQ=GLKQuaternionMake(0.0,s,0.0,c);                           //rotate around the Y-axis
    orientation=GLKQuaternionMultiply(tempQ,orientation);	
    
    matrix3=GLKMatrix3MakeWithQuaternion(orientation);
    
    matrix3=GLKMatrix3Transpose(matrix3);
    offsetv=GLKMatrix3MultiplyVector3(matrix3, offsetv);
    
    vpLoc.x=objectLoc.x+offsetv.x;                                                                      //9
    vpLoc.y=objectLoc.y+offsetv.y;
    vpLoc.z=objectLoc.z+offsetv.z;
    
    [m_SolarSystem setEyeposition:vpLoc];
    
    [m_SolarSystem lookAtTarget];                                                                    //10
}


-(void)createUI
{
    CGRect frame=CGRectMake(-100, 20, 75, 35);
    
    m_Button1=[self createButton:frame normalImageFile:@"bluebutton-100x35-clipped.png" selectedImageFile:NULL
                           title:@"names" selector:@selector(buttonAction:)
                      titleColor:[UIColor cyanColor]];
    
    
    [self.view addSubview:m_Button1];
    
    frame=CGRectMake(-150, 55, 75, 35);
    
    m_Button2=[self createButton:frame normalImageFile:@"greenbutton-100x35-clipped.png" selectedImageFile:NULL
                           title:@"lines" selector:@selector(buttonAction:) titleColor:[UIColor whiteColor]];
    
    [self.view addSubview:m_Button2];
    
    frame=CGRectMake(-200, 90, 75, 35);
    
    m_Button3=[self createButton:frame normalImageFile:@"redbutton-100x35-clipped.png" selectedImageFile:NULL
                           title:@"lens flare" selector:@selector(buttonAction:) 
                      titleColor:[UIColor whiteColor]];
    
    [self.view addSubview:m_Button3];
    
    frame=CGRectMake(-250, 125, 75, 35);
    
    m_Button4=[self createButton:frame normalImageFile:@"purplebutton-100x35-clipped.png" selectedImageFile:NULL
                           title:@"sweep" selector:@selector(buttonAction:) 
                      titleColor:[UIColor whiteColor]];
    
    [self.view addSubview:m_Button4];
    
    [NSTimer scheduledTimerWithTimeInterval:.3 target:self selector:@selector(hudUpdate:) userInfo:NULL repeats:YES];
    
    UIImage *greenDotImage=[UIImage imageNamed:@"green_dot.png"];
    m_GreenHUDVertImage=[[UIImageView alloc]initWithImage:greenDotImage];
    m_GreenHUDVertImage.alpha=0.0;
    
    [self.view addSubview:m_GreenHUDVertImage];
    
    m_GreenHUDHorImage=[[UIImageView alloc]initWithImage:greenDotImage];
    m_GreenHUDHorImage.alpha=0.0;
    
    [self.view addSubview:m_GreenHUDHorImage];
    
    frame=CGRectMake(20, 250, 75, 35);
    
    m_Label=[self createLabel:frame title:@"testing" titleColor:[UIColor greenColor] fontSize:12 textAlignment:UITextAlignmentLeft];
    
    [self.view addSubview:m_Label];
}

- (UIButton *)createButton:(CGRect)frame normalImageFile:(NSString *)normalImageFile 
         selectedImageFile:(NSString *)selectedImageFile title:(NSString *)title 
                  selector:(SEL)selector titleColor:(UIColor *)titleColor
{
    UILabel *label;
    UIImage *normalImage=[UIImage imageNamed:normalImageFile];
    UIImage *selectedImage=[UIImage imageNamed:selectedImageFile];
    
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
	button.frame = frame;
	[button setTitleColor:titleColor forState:0];
    [button setImage:normalImage forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
	button.backgroundColor = NULL;
	button.alpha=.65;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    
    frame=CGRectMake(0, 5, frame.size.width, 20);
    label=[self createLabel:frame title:title titleColor:titleColor fontSize:15 textAlignment:UITextAlignmentCenter];	
    
    [button addSubview:label];
    
	return button;
}

-(UILabel *)createLabel:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor 
               fontSize:(int)fontSize textAlignment:(UITextAlignment)textAlignment
{
    UILabel *label;
    
    label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.opaque = NO;
    label.textAlignment = textAlignment;
    label.textColor = titleColor;
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = title;
    label.adjustsFontSizeToFitWidth=TRUE;
    label.minimumFontSize=10;
    
    return label;
}

-(void)displayUI
{
    CGRect frame;
    
    [UIView beginAnimations:NULL context:NULL];
    
    frame=m_Button1.frame;
    
    [UIView setAnimationDuration:1.25];
    
    m_Button1.frame=CGRectMake(20, m_Button1.frame.origin.y, m_Button1.frame.size.width, m_Button1.frame.size.height);
    m_Button2.frame=CGRectMake(20, m_Button2.frame.origin.y, m_Button2.frame.size.width, m_Button2.frame.size.height);
    m_Button3.frame=CGRectMake(20, m_Button3.frame.origin.y, m_Button3.frame.size.width, m_Button3.frame.size.height);
    m_Button4.frame=CGRectMake(20, m_Button4.frame.origin.y, m_Button4.frame.size.width, m_Button4.frame.size.height);
    
    [UIView commitAnimations];
}

-(void)buttonAction:(id)sender
{
    if(sender==m_Button1)
    {
        if(m_ConstNamesOn)
            m_ConstNamesOn=FALSE;
        else
            m_ConstNamesOn=TRUE;
    }
    if(sender==m_Button2)
    {
        if(m_ConstOutlinesOn)
            m_ConstOutlinesOn=FALSE;
        else
            m_ConstOutlinesOn=TRUE;    
    }
    if(sender==m_Button3)
    {
        if(m_LensFlareOn)
            m_LensFlareOn=FALSE;
        else
            m_LensFlareOn=TRUE;    
    }
    if(sender==m_Button4)
    {
        [self scan];
    }
    
    [m_SolarSystem setFeatureNames:m_ConstNamesOn outlines:m_ConstOutlinesOn lensFlare:m_LensFlareOn];    
}

-(void)hudUpdate:(NSTimer *)timer
{
    static int counter=0;
    
    m_Label.text=[NSString stringWithFormat:@"%3.2f",counter/10.0];
    
    counter+=42;
}

-(void)scan
{
    CGRect mainFrame = [[UIScreen mainScreen] bounds];		
    CGRect vertSweepStart=CGRectMake(20, 0, 2.0, mainFrame.size.height);
    CGRect vertSweepEnd=CGRectMake(mainFrame.size.width+10, 0, 2.0, mainFrame.size.height);
    
    CGRect horSweepStart=CGRectMake(0,20,mainFrame.size.width,2.0);
    CGRect horSweepEnd=CGRectMake(0,mainFrame.size.height,mainFrame.size.width,2.0);
    
    m_GreenHUDVertImage.frame=vertSweepStart;
    m_GreenHUDVertImage.alpha=1.0;
    
    m_GreenHUDHorImage.frame=horSweepStart;
    m_GreenHUDHorImage.alpha=1.0;
    
    [UIView animateWithDuration:5.0
                     animations:^{ 
                         m_GreenHUDVertImage.frame=vertSweepEnd; 
                         m_GreenHUDVertImage.alpha=0.0;
                         
                         m_GreenHUDHorImage.frame=horSweepEnd; 
                         m_GreenHUDHorImage.alpha=0.0;
                     }
                     completion:^(BOOL  completed){
                         
                     }
     ];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self displayUI];
    
    [super viewDidAppear:animated];
}

@end
