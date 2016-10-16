//
//  miniglu.h
//  OpenGLSolarSystem
//
//  Created by mike on 9/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
               GLfloat centerx, GLfloat centery, GLfloat centerz,
               GLfloat upx, GLfloat upy, GLfloat upz);


GLKQuaternion gluGetOrientation();

void gluMultMatrixVector3f(const GLfloat matrix[16], const GLfloat in[4],GLfloat out[4]);
void gluGetScreenLocation(GLfloat xa,GLfloat ya,GLfloat za,GLfloat *sx, GLfloat *sy,GLfloat *sz);
GLint gluProject(GLfloat objx, GLfloat objy, GLfloat objz, 
				 const GLfloat modelMatrix[16], 
				 const GLfloat projMatrix[16],
				 const GLint viewport[4],
				 GLfloat *winx, GLfloat *winy, GLfloat *winz);