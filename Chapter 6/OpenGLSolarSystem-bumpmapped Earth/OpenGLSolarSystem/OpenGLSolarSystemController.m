//
//  OpenGLSolarSystemController.m
//  OpenGLSolarSystemController
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLSolarSystem.h" 
#import "OpenGLSolarSystemController.h"

@implementation OpenGLSolarSystemController

-(id)init
{
	[self initGeometry];					
	
	return self;
}

-(void)initGeometry
{
	m_Eyeposition[X_VALUE]=0.0;				
	m_Eyeposition[Y_VALUE]=0.0;
	m_Eyeposition[Z_VALUE]=3.0;
    
	m_Earth=[[Planet alloc] init:50 slices:50 radius:1.0 squash:1.0 textureFile:@"earth_light.png" bumpmapFile:@"earth_normal_hc.png"];	
	[m_Earth setPositionX:0.0 Y:0.0 Z:0.0];			
}

-(void)execute
{
    GLfloat posFill1[]={-8.0,0.0,5.0,1.0};			
    static GLfloat angle=0.0;
    GLfloat orbitalIncrement=.5;
    GLfloat sunPos[4]={0.0,0.0,0.0,1.0};
	
    glLightfv(SS_FILLLIGHT1,GL_POSITION,posFill1);
    
    glEnable(GL_DEPTH_TEST);	
    
    glClearColor(0.0, 0.25f, 0.35f, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
	
    glPushMatrix();
    
    glTranslatef(-m_Eyeposition[X_VALUE],-m_Eyeposition[Y_VALUE],-m_Eyeposition[Z_VALUE]);
    glLightfv(SS_SUNLIGHT,GL_POSITION,sunPos);
    
    glEnable(SS_FILLLIGHT1);
    glDisable(SS_FILLLIGHT2);
	
    glPushMatrix();
	
    angle+=orbitalIncrement;
    
    [self executePlanet:m_Earth];
    
    glPopMatrix();
	
    glPopMatrix();
}

-(void)executePlanet:(Planet *)planet
{
    GLfloat posX, posY, posZ;
    static GLfloat angle=0.0;
    
    glPushMatrix();
    
    [planet getPositionX:&posX Y:&posY Z:&posZ];
	
    glTranslatef(posX,posY,posZ);
    
    glRotatef(angle,0.0,1.0,0.0);
	
    [planet execute];
	
    glPopMatrix();
	
    angle+=.4;
}
-(GLKTextureInfo *)loadTexture:(NSString *)filename
{
    NSError *error;
    GLKTextureInfo *info;  
    
    NSString *path=[[NSBundle mainBundle]pathForResource:filename ofType:NULL];
    
    info=[GLKTextureLoader textureWithContentsOfFile:path options:NULL error:&error];
    
    glBindTexture(GL_TEXTURE_2D, info.name);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT); 	
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);	
    
    return info;
}

@end
