//
//  OpenGLSolarSystemController.m
//  OpenGLSolarSystemController
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLCreateTexture.h"
#import "OpenGLSolarSystem.h" 
#import "OpenGLSolarSystemController.h"

@implementation OpenGLSolarSystemController

-(id)init
{
    m_FieldOfView=30.0;
	[self initGeometry];
    [self setClipping];
    
    m_LensFlare=[[LensFlare alloc]init];
	
    m_FlareSource=[[OpenGLCreateTexture getObject]loadTexture:@"gimp_sun3.png"];
    
    m_Constellations=[[OpenGLConstellations alloc]init];

	return self;
}

-(void)initGeometry
{
    //Let 1.0=1 million miles.
    // The sun's radius=.4.
    // The earth's radius=.04 (10x larger to make it easier to see).
    
    m_Eyeposition=GLKVector3Make(0.0, 0.0, 93.25);
    
    m_Earth=[[Planet alloc] init:48 slices:48 radius:0.04 
                          squash:1.0 textureFile:@"earth_light.png"];
    
    [m_Earth setPositionX:0.0 Y:0.0 Z:93.0];
	
    m_Sun=[[Planet alloc] init:48 slices:48 radius:0.4 
                        squash:1.0 textureFile:@"sun_surface.png"];	
}

-(void)execute
{
    float earth_sx,earth_sy,earth_sz,earth_sr;                                                            
    float sun_sx,sun_sy,sun_sz,sun_sr;
    GLfloat paleYellow[]={1.0,1.0,0.3,1.0};
    GLfloat white[]={1.0,1.0,1.0,1.0};			
    GLfloat cyan[]={0.0,1.0,1.0,1.0};	
    GLfloat	black[]={0.0,0.0,0.0,0.0};
    GLfloat sunPos[4]={0.0,0.0,0.0,1.0};
    
    glMatrixMode(GL_MODELVIEW);
    glShadeModel(GL_SMOOTH);
    glEnable(GL_LIGHTING);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  
    [m_Constellations execute:m_ConstOutlinesOn names:m_ConstNamesOn];

    glPushMatrix();
    
    glTranslatef(-m_Eyeposition.x,-m_Eyeposition.y,-m_Eyeposition.z);       //1
    
     glLightfv(SS_SUNLIGHT,GL_POSITION,sunPos);
    glEnable(SS_SUNLIGHT);
    
      glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, paleYellow);
    
       [self executePlanet:m_Sun sx:&sun_sx sy:&sun_sy sz:&sun_sz                    //2
              screenRadius:&sun_sr render:FALSE];
    
      glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);
    
    glPopMatrix();
    
    if((m_LensFlare!=NULL) && (sun_sz>0))                                                           //3
    {        
        float sunWidth=75;                                                                                               //4
        
        sunWidth*=(sun_sr/5.0);
        
        [[OpenGLCreateTexture getObject]renderTextureInRect:                     //5
         CGRectMake(sun_sx-sunWidth/2.0, sun_sy-sunWidth/2.0,sunWidth,sunWidth)
                                                       name:m_FlareSource.name depth:-10 r:1.0 g:1.0 b:1.0 a:1.0];
    }
    
    glEnable(SS_FILLLIGHT2);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();                                                                                                          
    
    glTranslatef(-m_Eyeposition.x,-m_Eyeposition.y,-m_Eyeposition.z);        //6
	
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, cyan);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, white);
    
    [self executePlanet:m_Earth sx:&earth_sx sy:&earth_sy sz:&earth_sz     //7
           screenRadius:&earth_sr render:TRUE];
    
    glPopMatrix();
    
    if(m_LensFlareOn)
    {
        if((m_LensFlare!=NULL) && (sun_sz>0))                                                             //8
        {        
            float scale=1.0;
            CGRect frame = [[UIScreen mainScreen] bounds];		
            float delX=frame.size.width/2.0-sun_sx;
            float delY=frame.size.height/2.0-sun_sy;
            float grazeDist=earth_sr+sun_sr;
            float percentVisible=1.0;
            float vanishDist=earth_sr-sun_sr; 
            
            float distanceBetweenBodies=sqrt(delX*delX+delY*delY);
            
            if((distanceBetweenBodies>vanishDist) && (distanceBetweenBodies<grazeDist))
            {         
                percentVisible=(distanceBetweenBodies-vanishDist)/(2.0*sun_sr);
                
                if(percentVisible>1.3)                                                                                     //9
                    percentVisible=1.3; 
                else if(percentVisible<0.2)
                    percentVisible=1.3; 
            }
            else if(distanceBetweenBodies>grazeDist)
            {
                percentVisible=1.0;               
            }
            else
            {
                percentVisible=0.0;               
            }
            
            scale=STANDARD_FOV/m_FieldOfView;  
            
            if(percentVisible>0.0)
                [m_LensFlare execute:[[UIScreen mainScreen]applicationFrame]  //10
                              source:CGPointMake(sun_sx,sun_sy) scale:scale alpha:percentVisible];
        }
    }
}

                                                                        //11
-(void)executePlanet:(Planet *)planet sx:(float *)sx sy:(float *)sy sz:(float *)sz 
        screenRadius:(float *)screenRadius render:(BOOL)render
{
    static GLfloat angle=0.0;
    GLKVector3 planetPos;
    float temp;
    float distance;
    CGRect frame = [[UIScreen mainScreen] bounds];		
    
    glPushMatrix();
    
    planetPos=[planet getPosition];
    
    glTranslatef(planetPos.x,planetPos.y,planetPos.z);
	
    if(render)                                                                                                                      
        [planet execute];                                                   //12
        
    distance=GLKVector3Distance(m_Eyeposition, planetPos);
    temp=(0.5*frame.size.width)/tanf(GLKMathDegreesToRadians(m_FieldOfView)/2.0);
    *screenRadius=temp*[planet getRadius]/distance;
    
    gluGetScreenLocation(planetPos.x,-planetPos.y,planetPos.z,sx,sy,sz);     //13
    
    glPopMatrix();
	
    angle+=.5;
}

-(float)getFieldOfView
{
    return m_FieldOfView;
}

-(void)setFieldOfView:(float)fov
{
    m_FieldOfView=fov;
    
    [self setClipping];
}

-(void)setClipping
{
	float aspectRatio;
	const float zNear = .1;					
	const float zFar = 2000;					
	GLfloat	size;
	float scale;
	CGRect frame = [[UIScreen mainScreen] bounds];		
    
	aspectRatio=(float)frame.size.width/(float)frame.size.height;					
	scale=[[UIScreen mainScreen]scale];
           
	glMatrixMode(GL_PROJECTION);				
	glLoadIdentity();
    
	size = zNear * tanf(GLKMathDegreesToRadians (m_FieldOfView) / 2.0);	
    
	glFrustumf(-size, size, -size/aspectRatio, size/aspectRatio, zNear, zFar);	
	glViewport(0, 0, frame.size.width*scale, frame.size.height*scale);		
	
	glMatrixMode(GL_MODELVIEW);				
}

-(GLKVector3)getTargetLocation
{
    return [m_Earth getPosition];
}

-(void)lookAtTarget
{  
    GLKVector3 targetLocation=[m_Earth getPosition];
    
    gluLookAt(m_Eyeposition.x,m_Eyeposition.y,m_Eyeposition.z,
              targetLocation.x,targetLocation.y,targetLocation.z,
              0.0,1.0,0.0);
}

-(GLKVector3)getEyeposition
{
    return m_Eyeposition;
}

-(void)setEyeposition:(GLKVector3)loc
{
    m_Eyeposition=loc;
}

-(void)setFeatureNames:(BOOL)constNames outlines:(BOOL)constOutlines lensFlare:(BOOL)lensFlare
{
    m_ConstNamesOn=constNames;
    m_ConstOutlinesOn=constOutlines;
    m_LensFlareOn=lensFlare;    
}

@end
