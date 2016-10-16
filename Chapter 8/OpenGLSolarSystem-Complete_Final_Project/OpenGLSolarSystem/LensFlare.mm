//
//  LensFlare.mm
//  OpenGL Lens Flare
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Flare.h"
#import "LensFlare.h"
//#import "OpenGL_CreateTexture.h"

@implementation LensFlare

- (id)init
{
    self = [super init];
    
    if (self) 
    {
        [self createFlares];
    }
    
    return self;
}

-(void)createFlares
{
    m_Flares=[NSMutableArray array];
    
    GLfloat ff=.004;
    
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"   size:1.0   vectorPosition:(.05-ff)        r:1.0 g:0.73 b:0.30 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:1.5        vectorPosition:(.055-ff)       r:1.0 g:0.73 b:0.50 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png" size:1.5    vectorPosition:(.06-ff)        r:.75 g:1.00 b:0.40 a:.2]];
    [m_Flares addObject:[[Flare alloc]init:@"halo.png"      size:0.5        vectorPosition:(.030-ff)       r:1.0 g:0.73 b:0.20 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"halo.png"      size:0.3        vectorPosition:(.05-ff)        r:1.0 g:0.85 b:0.40 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"   size:0.3        vectorPosition:(.065-ff)       r:0.5 g:0.95 b:0.56 a:.33]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"  size:0.3        vectorPosition:(.03-ff)        r:1.0 g:0.85 b:0.56 a:.35]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"   size:0.35  vectorPosition:(.05-ff)        r:1.0 g:0.90 b:0.40 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"      size:1.5        vectorPosition:(.07-ff)     r:0.8 g:0.95 b:0.56 a:.55]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"      size:0.3  vectorPosition:(.06-ff)     r:1.0 g:0.85 b:0.56 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"halo.png"      size:1.5        vectorPosition:(.02-ff)        r:1.0 g:0.85 b:0.56 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:0.5        vectorPosition:(.068-ff)       r:1.0 g:0.85 b:0.56 a:.45]];
    [m_Flares addObject:[[Flare alloc]init:@"flare_fuzzy.png"      size:0.5 vectorPosition:(.03-ff)        r:1.0 g:0.85 b:0.56 a:.45]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:0.3        vectorPosition:(.017-ff)       r:1.0 g:0.85 b:0.56 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png" size:0.25   vectorPosition:(.06-ff)        r:1.0 g:0.85 b:0.56 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:1.5        vectorPosition:(.09-ff)        r:1.0 g:0.85 b:0.56 a:.44]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"   size:0.56       vectorPosition:(.065-ff)       r:0.5 g:0.95 b:0.56 a:.33]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"   size:0.56       vectorPosition:(.071-ff)       r:0.5 g:0.85 b:0.56 a:.65]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"  size:1.0        vectorPosition:(.01-ff)        r:1.0 g:0.85 b:0.56 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"   size:0.25  vectorPosition:(.030-ff)       r:1.0 g:0.70 b:0.50 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:1.5        vectorPosition:(.02-ff)        r:1.0 g:0.70 b:0.56 a:.5]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png" size:1.0    vectorPosition:(.018-ff)        r:1.0 g:0.60 b:0.25 a:.5]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"  size:1.0    vectorPosition:(.035-ff)        r:1.0 g:0.75 b:0.56 a:.35]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"        size:10.0       vectorPosition:(0.0)         r:1.0 g:0.60 b:0.56 a:1.0]];
    
/*
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"   size:1.0   vectorPosition:(.05-ff)        r:1.0 g:0.73 b:0.30 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:1.5        vectorPosition:(.055-ff)       r:1.0 g:0.73 b:0.50 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"pentagon_blur.png" size:1.5    vectorPosition:(.06-ff)        r:.75 g:1.00 b:0.40 a:.2]];
    [m_Flares addObject:[[Flare alloc]init:@"halo.png"      size:0.5        vectorPosition:(.030-ff)       r:1.0 g:0.73 b:0.20 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"halo.png"      size:0.3        vectorPosition:(.05-ff)        r:1.0 g:0.85 b:0.40 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"   size:0.3        vectorPosition:(.065-ff)       r:0.5 g:0.95 b:0.56 a:.33]];
    [m_Flares addObject:[[Flare alloc]init:@"pentagon.png"  size:0.3        vectorPosition:(.03-ff)        r:1.0 g:0.85 b:0.56 a:.35]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"   size:0.35  vectorPosition:(.05-ff)        r:1.0 g:0.90 b:0.40 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"      size:1.5        vectorPosition:(.07-ff)     r:0.8 g:0.95 b:0.56 a:.55]];
    [m_Flares addObject:[[Flare alloc]init:@"pentagon_blur.png"      size:0.3  vectorPosition:(.06-ff)     r:1.0 g:0.85 b:0.56 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"halo.png"      size:1.5        vectorPosition:(.02-ff)        r:1.0 g:0.85 b:0.56 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:0.5        vectorPosition:(.068-ff)       r:1.0 g:0.85 b:0.56 a:.45]];
    [m_Flares addObject:[[Flare alloc]init:@"flare_fuzzy.png"      size:0.5 vectorPosition:(.03-ff)        r:1.0 g:0.85 b:0.56 a:.45]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:0.3        vectorPosition:(.017-ff)       r:1.0 g:0.85 b:0.56 a:.4]];
    [m_Flares addObject:[[Flare alloc]init:@"pentagon_blur.png" size:0.25   vectorPosition:(.06-ff)        r:1.0 g:0.85 b:0.56 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:1.5        vectorPosition:(.09-ff)        r:1.0 g:0.85 b:0.56 a:.44]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"   size:0.56       vectorPosition:(.065-ff)       r:0.5 g:0.95 b:0.56 a:.33]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon.png"   size:0.56       vectorPosition:(.071-ff)       r:0.5 g:0.85 b:0.56 a:.65]];
    [m_Flares addObject:[[Flare alloc]init:@"pentagon.png"  size:1.0        vectorPosition:(.01-ff)        r:1.0 g:0.85 b:0.56 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"   size:0.25  vectorPosition:(.030-ff)       r:1.0 g:0.70 b:0.50 a:.3]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"      size:1.5        vectorPosition:(.02-ff)        r:1.0 g:0.70 b:0.56 a:.5]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png" size:1.0    vectorPosition:(.018-ff)        r:1.0 g:0.60 b:0.25 a:.5]];
    [m_Flares addObject:[[Flare alloc]init:@"hexagon_blur.png"  size:1.0    vectorPosition:(.035-ff)        r:1.0 g:0.75 b:0.56 a:.35]];
    [m_Flares addObject:[[Flare alloc]init:@"glow.png"        size:10.0       vectorPosition:(0.0)         r:1.0 g:0.60 b:0.56 a:.55]];
*/
    //the sun is on this side of the streak
}

-(void)execute:(CGRect)frame source:(CGPoint)source scale:(float)scale alpha:(float)alpha
{
    CGPoint position;
    NSEnumerator *e;
    Flare *object;

    static GLfloat deltaX=40,deltaY=40;
    static GLfloat offsetFromCenterX,offsetFromCenterY;
    static GLfloat startingOffsetFromCenterX,startingOffsetFromCenterY;

    int numElements;
    GLfloat cx,cy;
    
    static int counter=0;
    
    e=[m_Flares objectEnumerator];

    cx=(frame.size.width/2.0);
    cy=(frame.size.height/2.0);

    startingOffsetFromCenterX=cx-source.x;
    startingOffsetFromCenterY=source.y-cy;

    offsetFromCenterX=startingOffsetFromCenterX;
    offsetFromCenterY=startingOffsetFromCenterY;
    
    numElements=[m_Flares count];
    
    deltaX=2.0*startingOffsetFromCenterX;
    deltaY=2.0*startingOffsetFromCenterY;
    
    while (object = [e nextObject]) 
    {
        position=CGPointMake(offsetFromCenterX,offsetFromCenterY);
        
        [object renderFlareAt:position scale:scale alpha:alpha];
        
        //       if(!(counter%50))
        //           NSLog(@"Execute x=%f, y=%f, deltax=%f, deltay=%y\n",position.x,position.y,deltaX,deltaY);
        
        
        offsetFromCenterX-=deltaX*[object getVectorPosition];
        offsetFromCenterY-=deltaY*[object getVectorPosition];
    }

    counter++;
}

@end
