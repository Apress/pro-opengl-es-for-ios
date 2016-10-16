//
//  OpenGLText.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
#import "OpenGLSolarSystem.h"
#import "OpenGLText.h"
#import "OpenGLCreateTexture.h"

@implementation OpenGLText

-(id)initWithText:(NSString*)string size:(CGSize)size alignment:(UITextAlignment)alignment font:(UIFont*)font                                                                                                             //1
{
    NSUInteger width;
    NSUInteger height;
    NSUInteger i;
    CGContextRef context;
    void* data;
    CGColorSpaceRef  colorSpace;
    GLint saveName;
	
    glEnable(GL_TEXTURE_2D);	
	
    width = size.width;
	
    if((width != 1) && (width & (width - 1)))                                                           //2
    {
        i = 1;
		
        while(i < width)
            i *= 2;
        
        width = i;
    }
    height = size.height;
	
    if((height != 1) && (height & (height - 1))) 
    {
        i = 1;
		
        while(i < height)
            i *= 2;
		
        height = i;
    }
    
    colorSpace = CGColorSpaceCreateDeviceGray();                                               //3
	
    data = calloc(height, width);                                                                                     //4
    
    context = CGBitmapContextCreate(data, width, height, 8, width, colorSpace, kCGImageAlphaNone);
    
    CGColorSpaceRelease(colorSpace);                                                                      
	
    CGContextSetGrayFillColor(context, 1.0, 1.0);                                                   //5
    
    UIGraphicsPushContext(context);                                                                         //6
    
    [string drawInRect:CGRectMake(0, 0, size.width, size.height) withFont:font      
         lineBreakMode:UILineBreakModeWordWrap alignment:alignment];
	
    UIGraphicsPopContext();                                                                                         
	
    glGenTextures(1, &m_Name);                                                                                //7
    glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
    
    glBindTexture(GL_TEXTURE_2D, m_Name);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0,    //8
                 GL_LUMINANCE,  GL_UNSIGNED_BYTE, data);
    
    glBindTexture(GL_TEXTURE_2D, saveName);                                                  //9
    
    m_Width=width;
    m_Height=height;
    m_MaxS=size.width/(float)width;
    m_MaxT=size.height/(float)height;
    
    CGContextRelease(context);
    free(data);
    
    return self;
}

-(void)renderAtPoint:(CGPoint)point depth:(CGFloat)depth red:(float)red green:(float)green          
                blue:(float)blue alpha:(float)alpha
{
    
    float scale;
    
    int boxRect[4];
    
    glBindTexture(GL_TEXTURE_2D,m_Name);
	
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE,GL_ONE_MINUS_SRC_ALPHA);
	
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);
	
    glColor4f(red, green, blue, alpha);
	
    boxRect[0]=0;                                                                                                              
    boxRect[1]=0;
    boxRect[2]=m_Width;
    boxRect[3]=m_Height;
	
    scale=[[UIScreen mainScreen] scale];                          //10                                        
    
    glTexParameteriv(GL_TEXTURE_2D, GL_TEXTURE_CROP_RECT_OES,(GLint *)boxRect);//11
    
    glDrawTexfOES(point.x*scale, (480-point.y)*scale, depth, m_Width,m_Height);                 //12
    
    glDisable(GL_TEXTURE_2D);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    glEnable(GL_LIGHTING);
}

@end
