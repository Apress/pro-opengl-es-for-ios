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



-(id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat)squash 
      textureFile:(NSString *)textureFile bumpmapFile:(NSString *)bumpmapFile
{
    unsigned int colorIncrment=0;
    unsigned int blue=0;
    unsigned int red=255;
    int numVertices=0;
    
    if(textureFile!=nil)
        m_TextureInfo=[self loadTexture:textureFile];
        
    if(bumpmapFile!=nil)
        m_BumpMapInfo=[self loadTexture:bumpmapFile];
    
    m_Scale=radius;
    m_Squash=squash;
    
    colorIncrment=255/stacks;
    
    if ((self = [super init]))
    {
        m_Stacks = stacks;
        m_Slices = slices;
        m_VertexData = nil;
        m_TexCoordsData = nil;
        
        //vertices
        
        GLfloat *vPtr = m_VertexData =
        (GLfloat*)malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) *
                                                (m_Stacks)));
        
        //color data
        
        GLubyte *cPtr = m_ColorData =
        (GLubyte*)malloc(sizeof(GLubyte) * 4 * ((m_Slices*2+2) *
                                                (m_Stacks)));
        
        //normal pointers for lighting
        
        GLfloat *nPtr = m_NormalData = (GLfloat*)
        malloc(sizeof(GLfloat) * 3 * ((m_Slices*2+2) * (m_Stacks)));
        
        GLfloat *tPtr=nil;                                          //3
        
        if(textureFile!=nil)
        {
            tPtr=m_TexCoordsData =
            (GLfloat *)malloc(sizeof(GLfloat) * 2 * ((m_Slices*2+2) *
                                                     (m_Stacks)));
        }
        
        unsigned int phiIdx, thetaIdx;
        
        //latitude
        
        for(phiIdx=0; phiIdx < m_Stacks; phiIdx++)
        {
            //starts at -1.57 goes up to +1.57 radians
            
            //the first circle
            
            float phi0 = M_PI * ((float)(phiIdx+0) * (1.0/(float)
                                                      (m_Stacks)) - 0.5);
            
            //the next, or second one.
            
            float phi1 = M_PI * ((float)(phiIdx+1) * (1.0/(float)
                                                      (m_Stacks)) - 0.5);
            float cosPhi0 = cos(phi0);
            float sinPhi0 = sin(phi0);
            float cosPhi1 = cos(phi1);
            float sinPhi1 = sin(phi1);
            
            float cosTheta, sinTheta;
            
            //longitude
            
            for(thetaIdx=0; thetaIdx < m_Slices; thetaIdx++)
            {
                //Increment along the longitude circle each "slice."
                
                float theta = -2.0*M_PI * ((float)thetaIdx) *
                (1.0/(float)(m_Slices-1));
                cosTheta = cos(theta);
                sinTheta = sin(theta);
                
                //We're generating a vertical pair of points, such
                //as the first point of stack 0 and the first point
                //of stack 1
                //above it. This is how TRIANGLE_STRIPS work,
                //taking a set of 4 vertices and essentially drawing
                //two triangles
                //at a time. The first is v0-v1-v2 and the next is
                //v2-v1-v3. Etc.
                
                //Get x-y-z for the first vertex of stack.
                
                vPtr[0] = m_Scale*cosPhi0 * cosTheta;
                vPtr[1] = m_Scale*sinPhi0*m_Squash;
                vPtr[2] = m_Scale*(cosPhi0 * sinTheta);
                
                //the same but for the vertex immediately above the
                //previous one
                
                vPtr[3] = m_Scale*cosPhi1 * cosTheta;
                vPtr[4] = m_Scale*sinPhi1*m_Squash;
                vPtr[5] = m_Scale*(cosPhi1 * sinTheta);
                
                //normal pointers for lighting
                
                nPtr[0] = cosPhi0 * cosTheta;
                nPtr[2] = cosPhi0 * sinTheta;
                nPtr[1] = sinPhi0;
                
                nPtr[3] = cosPhi1 * cosTheta;
                nPtr[5] = cosPhi1 * sinTheta;
                nPtr[4] = sinPhi1;
                
                if(tPtr!=nil)                               //4
                {
                    GLfloat texX = (float)thetaIdx *
                    (1.0f/(float)(m_Slices-1));
                    tPtr[0] = texX;
                    tPtr[1] = (float)(phiIdx+0) *
                    (1.0f/(float)(m_Stacks));
                    tPtr[2] = texX;
                    tPtr[3] = (float)(phiIdx+1) *
                    (1.0f/(float)(m_Stacks));
                }
                
                cPtr[0] = red;
                cPtr[1] = 0;
                cPtr[2] = blue;
                cPtr[4] = red;
                cPtr[5] = 0;
                cPtr[6] = blue;
                cPtr[3] = cPtr[7] = 255;
                
                cPtr += 2*4;
                vPtr += 2*3;
                nPtr += 2*3;
                
                
                if(tPtr!=nil)                               //5
                    tPtr += 2*2;
            }
            
            blue+=colorIncrment;
            red-=colorIncrment;
            
            // Degenerate triangle to connect stacks and maintain
            //winding order.
            
            vPtr[0] = vPtr[3] = vPtr[-3];
            vPtr[1] = vPtr[4] = vPtr[-2];
            vPtr[2] = vPtr[5] = vPtr[-1];
            
            nPtr[0] = nPtr[3] = nPtr[-3];
            nPtr[1] = nPtr[4] = nPtr[-2];
            nPtr[2] = nPtr[5] = nPtr[-1];
            
            if(tPtr!=nil)
            {
                tPtr[0] = tPtr[2] = tPtr[-2];         //6
                tPtr[1] = tPtr[3] = tPtr[-1];
            }
            
        }
        
        numVertices=(vPtr-m_VertexData)/6;
    }
    
    m_Angle=0.0;
    m_RotationalIncrement=0.0;
    
    m_Pos[0]=0.0;
    m_Pos[1]=0.0;
    m_Pos[2]=0.0;
    
    return self;
}

-(bool)execute
{		
    glMatrixMode(GL_MODELVIEW);				
    glEnable(GL_CULL_FACE);					
    glCullFace(GL_BACK);					
    glEnable(GL_LIGHTING);
    
    glFrontFace(GL_CW);						
    
    glEnable(GL_TEXTURE_2D);
    glEnableClientState(GL_VERTEX_ARRAY);			
    glVertexPointer(3, GL_FLOAT, 0, m_VertexData);			
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glClientActiveTexture(GL_TEXTURE0);                                 
    
    glBindTexture(GL_TEXTURE_2D, m_TextureInfo.name);
    
    glTexCoordPointer(2, GL_FLOAT, 0, m_TexCoordsData);	
    
    glClientActiveTexture(GL_TEXTURE1);
    glTexCoordPointer(2, GL_FLOAT,0,m_TexCoordsData);
    
    glMatrixMode(GL_MODELVIEW); 
    
    glEnableClientState(GL_NORMAL_ARRAY);
    glNormalPointer(GL_FLOAT, 0, m_NormalData);	
    
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, m_ColorData);	
    
    [self multiTextureBumpMap:m_BumpMapInfo.name tex1:m_TextureInfo.name];
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, (m_Slices+1)*2*(m_Stacks-1)+2);	
	
    return true;
}

-(void)getPositionX:(GLfloat *)x Y:(GLfloat *)y Z:(GLfloat *)z
{
	*x=m_Pos[0];
	*y=m_Pos[1];
	*z=m_Pos[2];
}

-(void)setPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
	m_Pos[0]=x;
	m_Pos[1]=y;
	m_Pos[2]=z;	
}

-(GLfloat)getRotation
{
	return m_Angle;
}

-(void)setRotation:(GLfloat)angle
{
	m_Angle=angle;
}

-(void)incrementRotation
{
	m_Angle+=m_RotationalIncrement;
}

-(GLfloat)getRotationalIncrement
{
	return m_RotationalIncrement;
}

-(void)setRotationalIncrement:(GLfloat)inc
{
	m_RotationalIncrement=inc;
}

-(GLKTextureInfo *)loadTexture:(NSString *)filename
{
    NSError *error;
    GLKTextureInfo *info;
    NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,
                           [NSNumber numberWithBool:TRUE],GLKTextureLoaderGenerateMipmaps,nil];

    
    NSString *path=[[NSBundle mainBundle]pathForResource:filename ofType:NULL];
    
    info=[GLKTextureLoader textureWithContentsOfFile:path options:options error:&error];
    
    glBindTexture(GL_TEXTURE_2D, info.name);
    
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_S,GL_REPEAT); 	
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_WRAP_T,GL_REPEAT);	
    
    return info;
}

-(void)multiTextureBumpMap:(GLuint)tex0 tex1:(GLuint)tex1
{
    GLfloat x,y,z;
    static float lightAngle=0.0;
    
    lightAngle+=1.0;							//1
    
    if(lightAngle>180)
        lightAngle=0;
    
    // Set up the light vector.
    
    x = sin(lightAngle * (3.14159 / 180.0));                 			//2
    y = 0.0;
    z = cos(lightAngle * (3.14159 / 180.0));
    
    // Half shifting to have a value between 0.0 and 1.0.
    
    x = x * 0.5 + 0.5;						//3
    y = y * 0.5 + 0.5;
    z = z * 0.5 + 0.5;
    
    glColor4f(x, y, z, 1.0);  						//4
    
    //The color and normal map are combined.
    
    glActiveTexture(GL_TEXTURE0);					//5
    glBindTexture(GL_TEXTURE_2D, tex0);
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_COMBINE);	//6
    glTexEnvf(GL_TEXTURE_ENV, GL_COMBINE_RGB, GL_DOT3_RGB);	//7
    glTexEnvf(GL_TEXTURE_ENV, GL_SRC0_RGB, GL_TEXTURE);	//8
    glTexEnvf(GL_TEXTURE_ENV, GL_SRC1_RGB, GL_PREVIOUS);	//9
    
    // Set up the Second Texture, and combine it with the result of the Dot3 combination.
    
    glActiveTexture(GL_TEXTURE1);					//10
    glBindTexture(GL_TEXTURE_2D, tex1);
    
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);	//11
}

@end