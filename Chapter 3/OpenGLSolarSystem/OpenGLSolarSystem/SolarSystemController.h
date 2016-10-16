//
//  SolarSystemController.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Planet.h"

@interface SolarSystemController : NSObject 
{
	Planet *m_Earth;
}

-(void)execute;
-(id)init;
-(void)initGeometry;

@end
