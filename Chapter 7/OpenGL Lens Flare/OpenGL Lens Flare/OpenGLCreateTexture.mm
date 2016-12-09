//
//  OpenGLCreateTexture.mm
//  MultiTexture
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
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

-(int)createTexture:(NSString *)imageFileName imageID:(GLuint *)imageID mipmapID:(int)mipmapID
{
	UIImage *tempImage;
	GLuint imageWidth;
	GLuint imageHeight;
	CGColorSpaceRef csr;
	void *imagedata;
	CGContextRef contextRef;
	CGImageRef imgRef;
	
	tempImage=[UIImage imageNamed:imageFileName];
	
	if(tempImage==NULL)
	{
		return -1;			
	}
	
	imgRef=tempImage.CGImage;
	
	imageWidth=CGImageGetWidth(imgRef);	
	imageHeight=CGImageGetHeight(imgRef);
    
	csr=CGColorSpaceCreateDeviceRGB();
	
	imagedata=malloc(imageWidth*imageHeight*sizeof(long));
	
	contextRef=CGBitmapContextCreate(imagedata, imageWidth, imageHeight, 8, sizeof(long)*imageWidth, csr, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
	
	CGColorSpaceRelease(csr);
	CGContextClearRect(contextRef, CGRectMake(0, 0, imageWidth, imageHeight));
	
	//must come in this order
	
	CGContextTranslateCTM(contextRef,0,imageHeight);
	CGContextScaleCTM(contextRef, 1.0, -1.0); 
    
	CGContextDrawImage(contextRef, CGRectMake(0,0,imageWidth,imageHeight),tempImage.CGImage);
	CGContextRelease(contextRef);
	
	if(imageID!=nil)
	{
		glGenTextures(1, imageID);
		glBindTexture(GL_TEXTURE_2D,*imageID);
	}
    
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
	glTexImage2D(GL_TEXTURE_2D, mipmapID, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imagedata);
	
	return 0;
}

-(void)renderTextureAt:(CGPoint)position  name:(GLuint)name   size:(GLfloat)size r:(GLfloat)r g:(GLfloat)g b:(GLfloat)b a:(GLfloat)a;
{


    float scaledX,scaledY;
    GLfloat zoomBias=.1;                   //just an extra scaling, and this will be affected at some point when zoom is in place.
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
    scaledY=2.0*position.y/frame.size.height;
    
   
    //   static float x=25, y=25, z=0.5;
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_LIGHTING);
    
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();		
    glLoadIdentity();	
	
    glOrthof(-1,1,-1.0*aspectRatio,1.0*aspectRatio, -1, 1);
    
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
