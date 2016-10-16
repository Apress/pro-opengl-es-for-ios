//
//  planet.m
//
//  Created by mike on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "planet.h"

@implementation Planet

- (id) init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat) squash textureFile:(NSString *)textureFile		//chapter 5
{
	unsigned int colorIncrment=0;				
	unsigned int blue=0;
	unsigned int red=255;
    
    m_UseTexture=YES;
    m_UseNormals=YES;
    m_UseInterleaved=YES;
    m_InterleavedData=NULL;
    
	m_Scale=radius;						
	m_Squash=squash;
	
	colorIncrment=255/stacks;					
	
	if ((self = [super init])) 
	{
		m_Stacks = stacks;
		m_Slices = slices;
		m_VertexData = nil;
		       
		//vertices
		
		GLfloat *vtxPtr = m_VertexData = 			
        (GLfloat*)malloc(sizeof(GLfloat) * NUM_XYZ_ELS * ((m_Slices*2+2) * (m_Stacks)));		
		
		//color data
		
		GLfloat *colPtr = m_ColorData = 					
        (GLfloat*)malloc(sizeof(GLfloat) * NUM_RGBA_ELS * ((m_Slices*2+2) * (m_Stacks)));				
		
		//normal pointers for lighting
		
		GLfloat *norPtr = m_NormalData = 
            (GLfloat*)malloc(sizeof(GLfloat) * NUM_NXYZ_ELS * ((m_Slices*2+2) * (m_Stacks)));			//normals
		
        GLfloat	*textPtr=nil;
        
        textPtr=m_TexCoordsData = (GLfloat *)malloc(sizeof(GLfloat) * NUM_ST_ELS * ((m_Slices*2+2) * (m_Stacks)));			//texture coords
        
		unsigned int	phiIdx, thetaIdx;
		
		//latitude
		
		for(phiIdx=0; phiIdx < m_Stacks; phiIdx++)			
		{
			//starts at -1.57 goes up to +1.57 radians
			
			//the first circle
            
			float phi0 = M_PI * ((float)(phiIdx+0) * (1.0/(float)(m_Stacks)) - 0.5);	
			
			//the next, or second one.
            
			float phi1 = M_PI * ((float)(phiIdx+1) * (1.0/(float)(m_Stacks)) - 0.5);				
			float cosPhi0 = cos(phi0);				
			float sinPhi0 = sin(phi0);
			float cosPhi1 = cos(phi1);
			float sinPhi1 = sin(phi1);
			
			float cosTheta, sinTheta;
			
			//longitude
			
			for(thetaIdx=0; thetaIdx < m_Slices; thetaIdx++)			
			{
				//increment along the longitude circle each "slice"
				
				float theta = -2.0*M_PI * ((float)thetaIdx) * (1.0/(float)(m_Slices-1));			
				cosTheta = cos(theta);		
				sinTheta = sin(theta);
				
				//we're generating a vertical pair of points, such 
				//as the first point of stack 0 and the first point of stack 1
				//above it. This is how TRIANGLE_STRIPS work, 
				//taking a set of 4 vertices and essentially drawing two triangles
				//at a time. The first is v0-v1-v2 and the next is v2-v1-v3. Etc.
				
				//get x-y-z for the first vertex of stack
				
				vtxPtr[0] = m_Scale*cosPhi0 * cosTheta; 	
				vtxPtr[1] = m_Scale*sinPhi0*m_Squash;		
				vtxPtr[2] = m_Scale*(cosPhi0 * sinTheta); 
                
				//the same but for the vertex immediately above the previous one
				
				vtxPtr[3] = m_Scale*cosPhi1 * cosTheta; 
				vtxPtr[4] = m_Scale*sinPhi1*m_Squash;		
				vtxPtr[5] = m_Scale*(cosPhi1 * sinTheta); 
                
				//normal pointers for lighting
				
				norPtr[0] = cosPhi0 * cosTheta; 
				norPtr[2] = cosPhi0 * sinTheta; 
				norPtr[1] = sinPhi0;		//get x-y-z for the first vertex of stack N
				norPtr[3] = cosPhi1 * cosTheta; 
				norPtr[5] = cosPhi1 * sinTheta; 
				norPtr[4] = sinPhi1;	
                
                
				if(textPtr!=nil)
				{
					GLfloat texX = (float)thetaIdx * (1.0f/(float)(m_Slices-1));
                    
					textPtr[0] = texX; 
					textPtr[1] = (float)(phiIdx+0) * (1.0f/(float)(m_Stacks));
					textPtr[2] = texX; 
					textPtr[3] = (float)(phiIdx+1) * (1.0f/(float)(m_Stacks));
				}
                
                if(0)
                {
                    //needed to switch back to bytes
                    
                    colPtr[0] = red;				
                    colPtr[1] = 0;
                    colPtr[2] = blue;
                    colPtr[4] = red;
                    colPtr[5] = 0;
                    colPtr[6] = blue;
                    colPtr[3] = colPtr[7] = 255;
				}
                else
                {
                    colPtr[0] =(GLfloat)red/255.0f;				
                    colPtr[1] = 0.0f/255.0f;
                    colPtr[2] = (GLfloat)blue/255.0f;
                    colPtr[4] = (GLfloat)red/255.0f;
                    colPtr[5] = 0.0f/255.0;
                    colPtr[6] =(GLfloat) blue/255.0f;
                    colPtr[3] = colPtr[7] = 255.0f/255.0f;
                }
                
				colPtr += 2*NUM_RGBA_ELS;				
				vtxPtr += 2*NUM_XYZ_ELS;
				norPtr += 2*NUM_NXYZ_ELS;
                
                if(textPtr!=nil)									
					textPtr += 2*NUM_ST_ELS;
			}
			
			blue+=colorIncrment;				
			red-=colorIncrment;
			
			// degenerate triangle to connect stacks and maintain winding order
			
			vtxPtr[0] = vtxPtr[3] = vtxPtr[-3]; vtxPtr[1] = vtxPtr[4] = vtxPtr[-2]; vtxPtr[2] = vtxPtr[5] = vtxPtr[-1];
			norPtr[0] = norPtr[3] = norPtr[-3]; norPtr[1] = norPtr[4] = norPtr[-2]; norPtr[2] = norPtr[5] = norPtr[-1];
            
            textPtr[0] = textPtr[2] = textPtr[-2]; textPtr[1] = textPtr[3] = textPtr[-1];
		}
    }
	
    m_NumVertices=((m_Slices*2+2) * (m_Stacks));
    
	m_Angle=0.0;
	m_RotationalIncrement=0.0;
	
	m_Pos.x=0.0;
	m_Pos.y=0.0;
	m_Pos.z=0.0;
	
    if(textureFile!=NULL)
        [self loadTexture:textureFile];
    
    [self createVAO];
    
    [self setBlendMode:PLANET_BLEND_MODE_SOLID];
    
	return self;
}

-(void)setBlendMode:(GLuint)blendMode
{
    glEnable(GL_BLEND);

    if(blendMode==PLANET_BLEND_MODE_NONE)
        glDisable(GL_BLEND);    
    else if(blendMode==PLANET_BLEND_MODE_FADE)
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    else if(blendMode==PLANET_BLEND_MODE_ATMO)
        glBlendFunc(GL_ONE, GL_ONE);
    else if(blendMode==PLANET_BLEND_MODE_SOLID)
        glDisable(GL_BLEND);    
}

-(void)createInterleavedData
{
    int i;
    GLfloat *vtxPtr;
    GLfloat *norPtr;
    GLfloat *colPtr;
    GLfloat *textPtr;
    int xyzSize;
    int nxyzSize;
    int rgbaSize;
    int textSize;
    
    struct VAOInterleaved *startData;
    
    int structSize=sizeof(struct VAOInterleaved);
    long allocSize=structSize*m_NumVertices;
    
    m_InterleavedData=(struct VAOInterleaved *)malloc(allocSize);
    
    startData=m_InterleavedData;
    
    vtxPtr=m_VertexData;
    norPtr=m_NormalData;
    colPtr=m_ColorData;
    textPtr=m_TexCoordsData;

    xyzSize=sizeof(GLfloat)*NUM_XYZ_ELS;
    nxyzSize=sizeof(GLfloat)*NUM_NXYZ_ELS;
    rgbaSize=sizeof(GLfloat)*NUM_RGBA_ELS;
    textSize=sizeof(GLfloat)*NUM_ST_ELS;
    
    for(i=0;i<m_NumVertices;i++)
    {       
        memcpy(&startData->xyz,vtxPtr,xyzSize);     //geometry
        memcpy(&startData->nxyz,norPtr,nxyzSize);   //normals
        memcpy(&startData->rgba,colPtr,rgbaSize);   //colors
        memcpy(&startData->st,textPtr,textSize);   //texture coords

        startData++;
        
        vtxPtr+=NUM_XYZ_ELS;
        norPtr+=NUM_NXYZ_ELS;
        colPtr+=NUM_RGBA_ELS;
        textPtr+=NUM_ST_ELS;
    }
}

-(void)createVAO
{
    GLuint numBytesPerXYZ,numBytesPerNXYZ,numBytesPerRGBA;
    GLuint structSize=sizeof(struct VAOInterleaved); 
    
    [self createInterleavedData];
    
    //note that the context is set in the in the parent object

    glGenVertexArraysOES(1, &m_VertexArrayName);
    glBindVertexArrayOES(m_VertexArrayName);
    
    numBytesPerXYZ=sizeof(GL_FLOAT)*NUM_XYZ_ELS;
    numBytesPerNXYZ=sizeof(GL_FLOAT)*NUM_NXYZ_ELS;
    numBytesPerRGBA=sizeof(GL_FLOAT)*NUM_RGBA_ELS;

    glGenBuffers(1, &m_VertexBufferName);
    glBindBuffer(GL_ARRAY_BUFFER, m_VertexBufferName);
    glBufferData(GL_ARRAY_BUFFER, sizeof(struct VAOInterleaved)*m_NumVertices, m_InterleavedData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);                 
    glVertexAttribPointer(GLKVertexAttribPosition, NUM_XYZ_ELS, GL_FLOAT, GL_FALSE, structSize, BUFFER_OFFSET(0));
   
    glEnableVertexAttribArray(GLKVertexAttribNormal);                 
    glVertexAttribPointer(GLKVertexAttribNormal, NUM_NXYZ_ELS, GL_FLOAT, GL_FALSE, structSize, BUFFER_OFFSET(numBytesPerXYZ));
                      
    glEnableVertexAttribArray(GLKVertexAttribColor);                 
    glVertexAttribPointer(GLKVertexAttribColor, NUM_RGBA_ELS, GL_FLOAT, GL_FALSE, structSize, BUFFER_OFFSET(numBytesPerNXYZ+numBytesPerXYZ));

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);                 
    glVertexAttribPointer(GLKVertexAttribTexCoord0,NUM_ST_ELS, GL_FLOAT, GL_FALSE, structSize, BUFFER_OFFSET(numBytesPerNXYZ+numBytesPerXYZ+numBytesPerRGBA));
}

-(bool)execute:(GLuint)textureName
{		
    int objectType=GL_TRIANGLE_STRIP;                                 //GL_POINTS, GL_LINES, GL_TRIANGLE_STRIP
    static int whichFace=GL_CW;
    
    //   if(!(counter%25))
    //       NSLog(@"Execute VAOs\n");
 /*      
    if(textureName>0)
        glBindTexture(GL_TEXTURE_2D,textureName);
    else
    {
        if(m_TextureInfo!=NULL)
            glBindTexture(GL_TEXTURE_2D,m_TextureInfo.name);
        else
        {
            glDisable(GL_TEXTURE_2D);
            glBindTexture(GL_TEXTURE_2D,0);
        }
    }
 */   
    glBindVertexArrayOES(m_VertexArrayName);
		
    //commented out for shader testing
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    glFrontFace(whichFace);
    
    // this blend mode, src color/1-src color will cause the dark side 
    //of the earth to fade out to the background
    
    //	glEnable(GL_BLEND);
    //    glBlendFunc(GL_SRC_COLOR, GL_ONE_MINUS_SRC_COLOR);
    

    glDisable(GL_DEPTH_TEST);
	
    glDrawArrays(objectType, 0, (m_Slices+1)*2*(m_Stacks-1)+2);	
        
	return true;
}

-(bool)executeAtmo
{		
    int objectType=GL_TRIANGLE_STRIP;                                 //GL_POINTS, GL_LINES, GL_TRIANGLE_STRIP
    static int whichFace=GL_CW;
    
    //   if(!(counter%25))
    //       NSLog(@"Execute VAOs\n");
 
 
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);

    glDisable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D,0);

    
    glBindVertexArrayOES(m_VertexArrayName);
    
    //commented out for shader testing
    
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    glFrontFace(whichFace);

    glDisable(GL_DEPTH_TEST);
	
    glDrawArrays(objectType, 0, (m_Slices+1)*2*(m_Stacks-1)+2);	
    
	return true;
}

-(void)loadTexture:(NSString *)fileName
{    
    NSDictionary *options=[NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithBool:YES],GLKTextureLoaderOriginBottomLeft,nil];
    
    NSString *path=[[NSBundle mainBundle]pathForResource:fileName ofType:NULL];
    
    m_TextureInfo=[GLKTextureLoader textureWithContentsOfFile:path options:options error:NULL];
}

//Yes, I am old-school, I like to create my own setters/getters

-(void)getPositionX:(GLfloat *)x Y:(GLfloat *)y Z:(GLfloat *)z
{
	*x=m_Pos.x;
	*y=m_Pos.y;
	*z=m_Pos.z;
}

-(void)setPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z
{
	m_Pos.x=x;
	m_Pos.y=y;
	m_Pos.z=z;	
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

@end
