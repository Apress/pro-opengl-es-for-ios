//
//  OpenGLText.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenGLText : NSObject ///////////////////////////////////////
{
	GLuint m_Name;
	NSUInteger m_Width;
	NSUInteger m_Height;
	GLfloat m_MaxS;
	GLfloat m_MaxT;
}

-(id)initWithText:(NSString*)string size:(CGSize)size alignment:(UITextAlignment)alignment font:(UIFont*)font;
-(void)renderAtPoint:(CGPoint)point depth:(CGFloat)depth red:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

@end
