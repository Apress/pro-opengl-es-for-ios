//
//  OpenGLConstellations.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLConstellations.h"

@implementation OpenGLConstellations

- (id)init
{
    self = [super init];
    
    if (self) 
    {
        m_Outlines=[[OpenGLOutlines alloc]init];
        m_Stars=[[OpenGLStars alloc]init];
    }
    
    return self;
}

-(void)execute:(BOOL)constOutlinesOn names:(BOOL)constNamesOn
{
    [m_Outlines execute:constOutlinesOn showNames:constNamesOn];
    
    [m_Stars execute];
}

@end
