//
//  miniglu.m
//  OpenGLSolarSystem
//
//  Created by mike on 9/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "miniglu.h"

static GLKQuaternion m_Quaternion;

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
               GLfloat centerx, GLfloat centery, GLfloat centerz,
               GLfloat upx, GLfloat upy, GLfloat upz)
{
    GLKVector3 up;                                                                                                                   //1
    GLKVector3 from,to;                                                                                                            
    GLKVector3 lookat; 
    GLKVector3 axis;
    float angle;
    
    lookat.x=centerx;			                                                    //2
    lookat.y=centery;
    lookat.z=centerz;
    
    from.x=eyex; 			                                                                       
    from.y=eyey;
    from.z=eyez;
    
    to.x=lookat.x;					                                  
    to.y=lookat.y;
    to.z=lookat.z;
    
    up.x=upx;
    up.y=upy;
    up.z=upz;       
    
    GLKVector3 temp = GLKVector3Subtract(to,from); 			                                                    //3
    GLKVector3 n=GLKVector3Normalize(temp);

    temp = GLKVector3CrossProduct(n,up); 			                                                    //3
    GLKVector3 v=GLKVector3Normalize(temp);
    
    GLKVector3 u = GLKVector3CrossProduct(v,n); 			                                                    //3
    
    m_Quaternion=GLKQuaternionMakeWithMatrix3(GLKMatrix3MakeWithRows(v,u,GLKVector3Negate(n)));
                
    axis=GLKQuaternionAxis(m_Quaternion);
    angle=GLKQuaternionAngle(m_Quaternion);
    glRotatef(angle*57.29, axis.x, axis.y, axis.z);  
}

GLint gluProject(GLfloat objx, GLfloat objy, GLfloat objz, 
				 const GLfloat modelMatrix[16], 
				 const GLfloat projMatrix[16],
				 const GLint viewport[4],
				 GLfloat *winx, GLfloat *winy, GLfloat *winz)
{
    float in[4];
    float out[4];
    
    in[0]=objx;                                                                                                                     //1
    in[1]=objy;
    in[2]=objz;
    in[3]=1.0;
    
    gluMultMatrixVector3f(modelMatrix, in, out);                                                          //2
	
    gluMultMatrixVector3f(projMatrix, out, in);
	
    if (in[3] == 0.0) 
        in[3]=1;
	
    in[0] /= in[3];
    in[1] /= in[3];
    in[2] /= in[3];
	
    /* Map x, y and z to range 0-1 */
	
    in[0] = in[0] * 0.5 + 0.5;                                                                                               //3
    in[1] = in[1] * 0.5 + 0.5;
    in[2] = in[2] * 0.5 + 0.5;
	
    /* Map x,y to viewport */
    in[0] = in[0] * viewport[2] + viewport[0];                                                          
    in[1] = in[1] * viewport[3] + viewport[1];
	
    *winx=in[0];
    *winy=in[1];
    *winz=in[3];
    
    return(GL_TRUE);
}

void gluGetScreenLocation(GLfloat xa,GLfloat ya,GLfloat za,GLfloat *sx, GLfloat *sy,GLfloat *sz)
{
    GLfloat mvmatrix[16];
    GLfloat projmatrix[16];
    GLfloat x,y,z;
    GLint viewport[4];
	
    glGetIntegerv(GL_VIEWPORT,viewport);                                                         //4
    glGetFloatv(GL_MODELVIEW_MATRIX,mvmatrix);
    glGetFloatv(GL_PROJECTION_MATRIX,projmatrix);
	
    gluProject(xa,ya,za,mvmatrix,projmatrix,viewport,&x,&y,&z);                 
	
    y=viewport[3]-y;                                                                                                      //5
    
    *sx=x;
    *sy=y;
    
    if(sz!=NULL)
        *sz=z;
	
    float scale=[[UIScreen mainScreen] scale];                                                        //6
	
    *sx/=scale;
    *sy/=scale;
}

void gluMultMatrixVector3f(const GLfloat matrix[16], const GLfloat in[4],GLfloat out[4])
{
    int i;
	
    for (i=0; i<4; i++) 
    {
        out[i] = 
        in[0] * matrix[0*4+i] +
        in[1] * matrix[1*4+i] +
        in[2] * matrix[2*4+i] +
        in[3] * matrix[3*4+i];
    }
}

GLKQuaternion gluGetOrientation()
{
    return m_Quaternion;    
}


