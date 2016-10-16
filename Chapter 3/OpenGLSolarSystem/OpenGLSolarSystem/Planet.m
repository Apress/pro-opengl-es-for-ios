/*

===== IMPORTANT =====

=====================

File: Planet.m	: taken from the Touchfighter example
Abstract: Planet.

Version: 2.0


*/

#import "Planet.h"

GLshort	*_texData=NULL;

@implementation Planet

- (id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat) squash
{
	unsigned int colorIncrment=0;				//1
	unsigned int blue=0;
	unsigned int red=255;
	
	m_Scale=radius;						
	m_Squash=squash;
	
	colorIncrment=255/stacks;					//2
	
	if ((self = [super init])) 
	{
		m_Stacks = stacks;
		m_Slices = slices;
		m_VertexData = nil;
        
		//vertices
		
		GLfloat *vPtr =  m_VertexData = 			
		(GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));	//3
		
		
		//color data
		
		GLubyte *cPtr = m_ColorData= 					
		(GLubyte*)malloc(sizeof(GLubyte) * 4 * ((m_Slices *2+2) * (m_Stacks)));	//4			
        
		unsigned int	phiIdx, thetaIdx;
        
		//latitude
		
		for(phiIdx=0; phiIdx < m_Stacks; phiIdx++)		//5
		{
			//starts at -1.57 goes up to +1.57 radians
			
			//the first circle
            //6
			float phi0 = M_PI * ((float)(phiIdx+0) * (1.0f/(float)( m_Stacks)) - 0.5f);	
			
			//the next, or second one.
            //7
			float phi1 = M_PI * ((float)(phiIdx+1) * (1.0f/(float)( m_Stacks)) - 0.5f);				
			float cosPhi0 = cos(phi0);			//8
			float sinPhi0 = sin(phi0);
			float cosPhi1 = cos(phi1);
			float sinPhi1 = sin(phi1);
			
			float cosTheta, sinTheta;
			
            //longitude
            
			for(thetaIdx=0; thetaIdx < m_Slices; thetaIdx++)	//9		
			{
				//Increment along the longitude circle each "slice."
				
				float theta = 2.0f*M_PI * ((float)thetaIdx) * (1.0f/(float)( m_Slices -1));			
				cosTheta = cos(theta);		
				sinTheta = sin(theta);
                
				//We're generating a vertical pair of points, such 
				//as the first point of stack 0 and the first point of stack 1
				//above it. This is how TRIANGLE_STRIPS work, 
				//taking a set of 4 vertices and essentially drawing two triangles
				//at a time. The first is v0-v1-v2 and the next is v2-v1-v3, and so on.
                
                
                //Get x-y-z for the first vertex of stack.
                
				vPtr [0] = m_Scale*cosPhi0 * cosTheta; 	//10
				vPtr [1] = m_Scale*sinPhi0*m_Squash;			
                vPtr [2] = m_Scale*cosPhi0 * sinTheta; 
                
				
                //The same but for the vertex immediately above the previous one.
                
				vPtr [3] = m_Scale*cosPhi1 * cosTheta; 
				vPtr [4] = m_Scale*sinPhi1*m_Squash;		
				vPtr [5] = m_Scale* cosPhi1 * sinTheta; 
                
				cPtr [0] = red;				//11
				cPtr [1] = 0;
				cPtr [2] = blue;
				cPtr [4] = red;
				cPtr [5] = 0;
				cPtr [6] = blue;
				cPtr [3] = cPtr[7] = 255;
				
				cPtr += 2*4;				//12
				
				vPtr += 2*3;
            }
            
			blue+=colorIncrment;				//13
			red-=colorIncrment;
		}
	}
	
	return self;
}

/****************************************************************************************
 * execute : strips out any stuff that I don't need from execute, used for testing		*
 *		the moon. Rotation is in radians.												*
 ****************************************************************************************/
- (bool)execute
{		
	glMatrixMode(GL_MODELVIEW);				//1
	glEnable(GL_CULL_FACE);					//2
	glCullFace(GL_BACK);					//3
    
	glEnableClientState(GL_VERTEX_ARRAY);			//4
	glEnableClientState(GL_COLOR_ARRAY);			//5
    
	glVertexPointer(3, GL_FLOAT, 0, m_VertexData);			//6
    
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_ColorData);		//7
	glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_Slices +1)*2*(m_Stacks-1)+2);	//8
    
	return true;
}


@end