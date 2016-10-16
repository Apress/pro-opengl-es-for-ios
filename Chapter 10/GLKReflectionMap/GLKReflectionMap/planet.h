
#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import <GLKit/GLKit.h>
#import "OpenglIOS.h"

//#import "mathlib.h"

//used to generate interleaved data

/*
struct VBOInterleaved
{
    GLfloat x,y,z;
    GLfloat nx,ny,nz;
    
    GLfloat s,t;
};
*/

struct VAOInterleaved
{
    GLfloat xyz[NUM_XYZ_ELS];
    GLfloat nxyz[NUM_NXYZ_ELS];
    GLfloat rgba[NUM_RGBA_ELS];
    GLfloat st[NUM_ST_ELS];
};

@interface Planet : NSObject 
{
@private
	GLfloat			*m_VertexData;
	GLfloat			*m_ColorData;
	GLfloat			*m_NormalData;
	
    GLKTextureInfo  *m_TextureInfo;
    
    GLsizeiptr      m_NumVertices;
    
    int             m_NumberBatchedSpheres;
    
    long            m_TotalXYZBytes;
    long            m_TotalNormalBytes;
    
    bool            m_UseTexture;
    bool            m_UseNormals;
    bool            m_UseColors;
    bool            m_UseInterleaved;
    
	GLfloat			*m_TexCoordsData;			
	
	GLint			m_Stacks, m_Slices;
	GLfloat			m_Scale;						
	GLfloat			m_Squash;
	GLfloat			m_Angle;
    GLKVector3      m_Pos;
	GLfloat			m_RotationalIncrement;
	
    GLuint          m_VertexArrayName;
    GLuint          m_VertexBufferName;

    struct VAOInterleaved *m_InterleavedData;               //interleaved data for testing.
}

-(bool)execute:(GLKBaseEffect *)effect;
-(id)init:(GLint)stacks slices:(GLint)slices radius:(GLfloat)radius squash:(GLfloat) squash textureFile:(NSString *)textureFile;		
-(void)getPositionX:(GLfloat *)x Y:(GLfloat *)y Z:(GLfloat *)z;
-(void)setPositionX:(GLfloat)x Y:(GLfloat)y Z:(GLfloat)z;
-(GLfloat)getRotation;
-(void)setRotation:(GLfloat)angle;
-(void)getPositionX:(GLfloat *)x Y:(GLfloat *)y Z:(GLfloat *)z;
-(GLfloat)getRotationalIncrement;
-(void)setRotationalIncrement:(GLfloat)inc;
-(void)incrementRotation;
-(void)createVAO;
-(void)createInterleavedData;
-(void)setRotationalIncrement:(GLfloat)inc;
-(void)incrementRotation;
-(void)loadTexture:(NSString *)fileName;

@end

