//
//  OpenGLConstellations.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLOutlines.h"
#import "OpenGLStars.h"

@interface OpenGLConstellations : NSObject
{
    OpenGLOutlines *m_Outlines;
    OpenGLStars *m_Stars;
}

-(void)execute:(BOOL)constOutlinesOn names:(BOOL)constNamesOn;

@end
