//
//  OpenGLCreateTexture.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLCreateTexture.h"

static OpenGLCreateTexture *m_Singleton;

@implementation OpenGLCreateTexture


- (id)init
{
    if (self) 
    {
    }
    
    return self;
}

+(OpenGLCreateTexture *)getObject
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

+ (id)allocWithZone:(NSZone *)zone
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


-(void)renderTextureInRect:(CGRect)rect  name:(GLuint)name depth:(GLfloat)depth 
                         r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a                                       //1
{   
    CGRect frame = [[UIScreen mainScreen] bounds];		
    
    GLfloat	 vertices[] = 
    {
        rect.origin.x,                                rect.origin.y,                                 depth,
        rect.origin.x + rect.size.width,rect.origin.y,	                               depth,
        rect.origin.x,                                 rect.size.height+rect.origin.y ,depth,
        rect.origin.x + rect.size.width,rect.size.height+rect.origin.y ,depth
    };  
    
    static  GLfloat textureCoords[] = 
    {				
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    };
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D); 
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();		
    glLoadIdentity();	   
    
    glDisable(GL_LIGHTING);                                                                                          //2
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glDisableClientState(GL_COLOR_ARRAY);	
    
    glOrthof(0,frame.size.width,frame.size.height,0,0,1000);                               //3
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    
    glColor4f(r,g,b,a);
    
    glBindTexture(GL_TEXTURE_2D,name);
    glVertexPointer(3, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    glMatrixMode(GL_MODELVIEW); 
    glPopMatrix();
    
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    
    glEnable(GL_LIGHTING);	
    glDisable(GL_TEXTURE_2D);	
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);	
}

-(void)renderTextureAt:(CGPoint)position  name:(GLuint)name   
                  size:(GLfloat)size r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a
{
    
    
    float scaledX,scaledY;
    GLfloat zoomBias=.1; 
    GLfloat scaledSize;
    
    static const GLfloat squareVertices[] = 
    {
        -1.0f, -1.0f, 0.0,
        1.0f, -1.0f, 0.0,
        -1.0f,  1.0f, 0.0,
        1.0f,  1.0f, 0.0,
    };  
    
    static  GLfloat textureCoords[] = 
    {				
        0.0, 0.0,
        1.0, 0.0,
        0.0, 1.0,
        1.0, 1.0
    };
    
    CGRect frame = [[UIScreen mainScreen] bounds];		
    float aspectRatio=frame.size.height/frame.size.width;
    
    scaledX=2.0*position.x/frame.size.width;
    scaledY=(2.0*position.y/frame.size.height)*aspectRatio;
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);                                                                                           //2
    
    glDisable(GL_CULL_FACE);
    glDisableClientState(GL_COLOR_ARRAY);
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();		
    glLoadIdentity();	
	
    glOrthof(-1,1,-1.0*aspectRatio,1.0*aspectRatio, -1, 1);                                     //3
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    
    glTranslatef(scaledX,scaledY,0);
    
    scaledSize=zoomBias*size;
    
    glScalef(scaledSize,scaledSize, 1);
    
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glEnable(GL_TEXTURE_2D); 
    glEnable(GL_BLEND);
	glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_COLOR);
    glBindTexture(GL_TEXTURE_2D,name);
    glTexCoordPointer(2, GL_FLOAT,0,textureCoords);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
    glColor4f(r,g,b,a);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_LIGHTING);
}

@end
