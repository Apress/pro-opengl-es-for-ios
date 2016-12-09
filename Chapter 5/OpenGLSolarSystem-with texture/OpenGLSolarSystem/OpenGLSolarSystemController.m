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
	m_Eyeposition[X_VALUE]=0.0;				//1
	m_Eyeposition[Y_VALUE]=0.0;
	m_Eyeposition[Z_VALUE]=5.0;
    
	m_Earth=[[Planet alloc] init:50 slices:50 radius:.3 squash:1.0 textureFile:@"earth_light.png"];	//2
	[m_Earth setPositionX:0.0 Y:0.0 Z:-2.0];			//3
	
	m_Sun=[[Planet alloc] init:50 slices:50 radius:1.0 squash:1.0 textureFile:nil];	//4	
	[m_Sun setPositionX:0.0 Y:0.0 Z:0.0];
}
-(void)execute
{
	GLfloat paleYellow[]={1.0,1.0,0.3,1.0};			//1
	GLfloat white[]={1.0,1.0,1.0,1.0};			
	GLfloat cyan[]={0.0,1.0,1.0,1.0};	
	GLfloat black[]={0.0,0.0,0.0,0.0};				//2
	static GLfloat angle=0.0;
	GLfloat orbitalIncrement=1.25;				//3
	GLfloat sunPos[3]={0.0,0.0,0.0};					

	glPushMatrix();						//4
    
	glTranslatef(-m_Eyeposition[X_VALUE],-m_Eyeposition[Y_VALUE],	//5
                 -m_Eyeposition[Z_VALUE]);
    
	glLightfv(SS_SUNLIGHT,GL_POSITION,sunPos);		//6
	glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, cyan);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, white);
    
	glPushMatrix();						//7
	
	angle+=orbitalIncrement;					//8
	
	glRotatef(angle,0.0,1.0,0.0);					//9
	
	[self executePlanet:m_Earth];				//10
	
	glPopMatrix();						//11
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, paleYellow);	//12
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, black);	//13
    
	[self executePlanet:m_Sun];					//14
	
	glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, black);	//15
	
	glPopMatrix();						//16
}

-(void)executePlanet:(Planet *)planet
{
	GLfloat posX, posY, posZ;
		
	glPushMatrix();
    
	[planet getPositionX:&posX Y:&posY Z:&posZ];			//17
	
	glTranslatef(posX,posY,posZ);				//18
    
	[planet execute];						//19
	
	glPopMatrix();
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
