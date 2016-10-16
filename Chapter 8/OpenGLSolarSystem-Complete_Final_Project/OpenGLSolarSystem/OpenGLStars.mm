//
//  OpenGLStars.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLUtils.h"
#import "OpenGLStars.h"
#import "OpenGLSolarSystem.h"
#import "miniGLU.h"

@implementation OpenGLStars

- (id)init
{
    self = [super init];
    
    if (self) 
    {
        [self init:@"stars"];
    }
    
    return self;
}

-(void)init:(NSString *)filename                                                                                
{
    NSArray *fatData;
    NSDictionary *dict;
    NSNumber *ra,*dec;
    starData *sd;
    float mag;
    float x,y,z;
    int i;
    
    m_TotalStars=0;
    
    NSString *thePath = [[NSBundle mainBundle]  pathForResource:filename ofType:@"plist"];
    
    fatData = [[NSArray alloc] initWithContentsOfFile:thePath];		//2
    
    m_TotalStars=[fatData count];
    
    m_Data=(struct starData *)malloc([fatData count]*sizeof(struct starData));
    
    for(i=0;i<m_TotalStars;i++)                                                                                        
    {
        dict=(NSDictionary *)[fatData objectAtIndex:i];
        
        ra=(NSNumber *)[dict objectForKey:@"ra"];                                                    //3
        dec=(NSNumber *)[dict objectForKey:@"dec"];
        
        [[OpenGLUtils getObject]sphereToRectTheta:[ra floatValue]/DEGREES_PER_RADIAN 
                                               phi:[dec floatValue]/DEGREES_PER_RADIAN radius:STANDARD_RADIUS 
                                            xprime:&x yprime:&y zprime:&z];
        
        //Create nice compressed data array.
        
        sd=(struct starData *)&m_Data[i];
        
        sd->x=x;
        sd->y=y;
        sd->z=z;
        sd->mag=[[dict objectForKey:@"mag"]floatValue];
        
        mag=1.0-sd->mag/4.0;                                                                                            //4
        
        if(mag<.2)
            mag=.2;
        else if(mag>1.0)
            mag=1.0;
        
        sd->r=sd->g=sd->b=mag;
        
        sd->a=1.0;
        sd->hdnum=[[dict objectForKey:@"hdnum"]longValue];                           
    }
}

-(void)execute
{
    int len;
    GLfloat pointSize[2];
    
    glDisable(GL_LIGHTING);                                                                                             //5
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_DEPTH_TEST);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glMatrixMode(GL_MODELVIEW);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_DST_ALPHA);
    glEnable(GL_BLEND);
    
    len=sizeof(struct starData);
    
    glColorPointer(4, GL_FLOAT, len, &m_Data->r);                                                  //6
    glVertexPointer(3,GL_FLOAT,len,m_Data);	
    
    glGetFloatv(GL_SMOOTH_POINT_SIZE_RANGE,pointSize);                              //7
    glEnable(GL_POINT_SMOOTH);
    glPointSize(5.0);                             
    
    glDrawArrays(GL_POINTS,len,m_TotalStars);                                                      //8
    
    glDisableClientState(GL_VERTEX_ARRAY);	
    glDisableClientState(GL_COLOR_ARRAY);	
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
}

@end
