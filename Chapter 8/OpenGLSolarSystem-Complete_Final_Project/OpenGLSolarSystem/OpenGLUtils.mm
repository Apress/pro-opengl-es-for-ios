//
//  OpenGLUtils.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLUtils.h"
#import "OpenGLSolarSystem.h"

static OpenGLUtils *m_Singleton;

@implementation OpenGLUtils

+(OpenGLUtils *)getObject
{
	@synchronized(self)
	{
		if(m_Singleton==nil)
		{
			[[self alloc]init];
		}
	}
	
	return m_Singleton;
}

+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if (m_Singleton == nil) 
		{
            m_Singleton = [super allocWithZone:zone];
            
            return m_Singleton;  // assignment and return on first alUI
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

-(void)sphereToRectTheta:(float)theta phi:(float)phi radius:(float)radius  
                  xprime:(float *)xprime   yprime:(float *)yprime zprime:(float *)zprime
{
    float cos_theta,sin_theta,cos_phi,sin_phi;
    
    phi=RADIANS_PER_90_DEGREES-phi;       /* phi is to be measured starting from the z-axis. */
    
    sin_theta=sin(theta);
    cos_theta=cos(theta);
    
    sin_phi=sin(phi);
    cos_phi=cos(phi);
    
    *xprime=(float)(radius*cos_theta*sin_phi);	
    *yprime=(float)(radius*cos_phi);
    *zprime=(float)-1.0*(radius*sin_theta*sin_phi);
}

@end
