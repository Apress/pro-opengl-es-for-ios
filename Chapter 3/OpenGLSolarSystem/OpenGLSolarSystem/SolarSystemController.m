//
//  SolarSystemController.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SolarSystemController.h"

@implementation SolarSystemController

-(id)init
{
	[self initGeometry];					
	
	return self;
}

-(void)initGeometry
{
	m_Earth=[[Planet alloc] init:10 slices:10 radius:1.0 squash:1.0];	
}

-(void)execute
{
	static GLfloat angle=0;
	
	glLoadIdentity();
	glTranslatef(0.0, -0.0, -3.0f);
	
	glRotatef(angle,0.0,1.0,0.0);
	
	[m_Earth execute];
	
	angle+=.5;
}

@end
