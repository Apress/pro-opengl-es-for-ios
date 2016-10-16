
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#include <math.h>


@interface OpenGLOutlines : NSObject
{
	NSMutableArray *m_Data;
	GLfloat m_Red;
	GLfloat m_Green;
	GLfloat m_Blue;
	GLfloat m_Alpha;
}

-(OpenGLOutlines *)init:(NSString *)filename red:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue alpha:(GLfloat)alpha;
-(void)execute:(BOOL)showLines showNames:(BOOL)showNames;


@end
