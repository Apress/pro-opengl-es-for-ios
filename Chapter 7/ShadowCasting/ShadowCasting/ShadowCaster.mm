/******************************************************************************
 
 @File         OGLESShadowTechniques.cpp
 
 @Title        Introducing the POD 3d file format
 
 @Version      
 
 @Copyright    Copyright (C)  Imagination Technologies Limited.
 
 @Platform     Independant
 
 @Description  Shows how to load POD files and play the animation with basic
 lighting
 
 ******************************************************************************/
#include <string.h>


#import "ShadowCaster.h"

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#include <math.h>

/*
 * ==============================================================================
 *  Name        : Shadows.cpp
 *  Part of     : OpenGLEx / Shadows
 *
 *  Copyright (c) 2004-2006 Nokia Corporation.
 *  This material, including documentation and any related
 *  computer programs, is protected by copyright controlled by
 *  Nokia Corporation.
 * ==============================================================================
 */
 
 // INCLUDES
//#include <e32std.h>
//#include <e32math.h>


// LOCAL MACROS
 #define MATERIAL_MAX (1 << 16)
 #define LIGHT_MAX    (1 << 16)
 
 #define MATERIALCOLOR(r, g, b, a)    \
        (GLfixed)(r * MATERIAL_MAX),   \
        (GLfixed)(g * MATERIAL_MAX),   \
        (GLfixed)(b * MATERIAL_MAX),   \
        (GLfixed)(a * MATERIAL_MAX)
 
 #define LIGHTCOLOR(r, g, b, a)       \
        (GLfixed)(r * LIGHT_MAX),      \
        (GLfixed)(g * LIGHT_MAX),      \
        (GLfixed)(b * LIGHT_MAX),      \
        (GLfixed)(a * LIGHT_MAX)
 
 
 // CONSTANTS
 /** Vertice coordinates for the ground plane */
 static const GLbyte planeVertices[4 * 3] =
    {
    1,-1,0,
    1,1,0,
    -1,1,0,
    -1,-1,0
    };
 
 /** Indices for drawing the triangles of the ground plane */
 static const GLubyte planeTriangles[2 * 3] =
     {
     0,1,2,
     0,2,3
     };
 
 /** Vertice coordinates for the shadow object */
 static const GLbyte objVertices[48 * 3] =
     {
     /* Front */
     /* Outer ring */
     0,0,0,   // 0
     0,10,0,  // 1
     0,10,10, // 2
     0,0,10,  // 3
     /* Inner ring */
     0,2,2,   // 4
     0,8,2,   // 5
     0,8,8,   // 6
     0,2,8,   // 7
 
     /* Right */
     /* Outer ring */
     0,10,0,    // 8
     -10,10,0,  // 9
     -10,10,10, // 10
     0,10,10,   // 11
     /* Inner ring */
     -2,10,2,   // 12
     -8,10,2,   // 13
     -8,10,8,   // 14
     -2,10,8,   // 15
 
     /* Back */
     /* Outer ring */
     -10,10,0,  // 16
     -10,0,0,   // 17
     -10,0,10,  // 18
     -10,10,10, // 19
     /* Inner ring */
     -10,8,2,   // 20
     -10,2,2,   // 21
     -10,2,8,   // 22
     -10,8,8,   // 23
 
     /* Left */
     /* Outer ring */
     -10,0,0,   // 24
     0,0,0,     // 25
     0,0,10,    // 26
     -10,0,10,  // 27
     /* Inner ring */
     -8,0,2,    // 28
     -2,0,2,    // 29
     -2,0,8,    // 30
     -8,0,8,    // 31
 
     /* Top */
     /* Outer ring */
     0,0,10,    // 32
     0,10,10,   // 33
     -10,10,10, // 34
     -10,0,10,  // 35
     /* Inner ring */
     -2,2,10,   // 36
     -2,8,10,   // 37
     -8,8,10,   // 38
     -8,2,10,   // 39
 
     /* Bottom */
     /* Outer ring */
     -10,0,0,   // 40
     -10,10,0,  // 41
     0,10,0,    // 42
     0,0,0,     // 43
     /* Inner ring */
     -8,2,0,    // 44
     -8,8,0,    // 45
     -2,8,0,    // 46
     -2,2,0     // 47
     };
 
 /** Indices for drawing the triangles of the shadow object */
 static const GLubyte objTriangles[48 * 3] =
     {
     /* Front */
     0,5,4,
     0,1,5,
     1,6,5,
     1,2,6,
     2,7,6,
     2,3,7,
     3,4,7,
     3,0,4,
     /* Right */
     8,13,12,
     8,9,13,
     9,14,13,
     9,10,14,
     10,15,14,
     10,11,15,
     11,12,15,
     11,8,12,
     /* Back */
     16,21,20,
     16,17,21,
     17,22,21,
     17,18,22,
     18,23,22,
     18,19,23,
     19,20,23,
     19,16,20,
     /* Left */
     24,29,28,
     24,25,29,
     25,30,29,
     25,26,30,
     26,31,30,
     26,27,31,
     27,28,31,
     27,24,28,
     /* Top */
     32,37,36,
     32,33,37,
     33,38,37,
     33,34,38,
     34,39,38,
     34,35,39,
     35,36,39,
     35,32,36,
     /* Bottom */
     40,45,44,
     40,41,45,
     41,46,45,
     41,42,46,
     42,47,46,
     42,43,47,
     43,44,47,
     43,40,44
 
     };
 
 /** Normals for the shadow object */
 static const GLbyte objNormals[48 * 3] =
     {
     /* Front */
     1,0,0,
     1,0,0,
     1,0,0,
     1,0,0,
     1,0,0,
     1,0,0,
     1,0,0,
     1,0,0,
     /* Right */
     0,1,0,
     0,1,0,
     0,1,0,
     0,1,0,
     0,1,0,
     0,1,0,
     0,1,0,
     0,1,0,
     /* Back */
     -1,0,0,
     -1,0,0,
     -1,0,0,
     -1,0,0,
     -1,0,0,
     -1,0,0,
     -1,0,0,
     -1,0,0,
     /* Left */
     0,-1,0,
     0,-1,0,
     0,-1,0,
     0,-1,0,
     0,-1,0,
     0,-1,0,
     0,-1,0,
     0,-1,0,
     /* Top */
     0,0,1,
     0,0,1,
     0,0,1,
     0,0,1,
     0,0,1,
     0,0,1,
     0,0,1,
     0,0,1,
     /* Bottom */
     0,0,-1,
     0,0,-1,
     0,0,-1,
     0,0,-1,
     0,0,-1,
     0,0,-1,
     0,0,-1,
     0,0,-1
     };
 
 
 /** Diffuse material definition for the shadow object. */
 static const GLfixed objDiffuseFront[4]  = { MATERIALCOLOR(1.0, 0.5, 0.0, 1.0) };
 /** Ambient material definition for the shadow object. */
 static const GLfixed objAmbientFront[4]  = { MATERIALCOLOR(1.0, 0.5, 0.0, 1.0) };
 
 /** Global ambient light. */
 static const GLfixed globalAmbient[4]      = { LIGHTCOLOR(0.2, 0.2, 0.2, 1.0) };
 
 /** Lamp diffuse parameters. */
 static const GLfixed lightDiffuseLamp[4]   = { LIGHTCOLOR(0.7, 0.7, 0.7, 1.0) };
 /** Lamp ambient parameters. */
 static const GLfixed lightAmbientLamp[4]   = { LIGHTCOLOR(0.3, 0.3, 0.3, 1.0) };
 
 
 
 // ============================ MEMBER FUNCTIONS ===============================
 
 // -----------------------------------------------------------------------------
 // CShadows::CShadows
 // C++ default constructor can NOT contain any code, that
 // might leave.
 // -----------------------------------------------------------------------------
 //
CShadows::CShadows( unsigned int aWidth, unsigned int aHeight )
{
    iScreenWidth=aWidth;
    iScreenHeight=aHeight;  
    
    AppInit();
}
 
 
 // Destructor.
 CShadows::~CShadows()
{


}
 
 
 // -----------------------------------------------------------------------------
 // CShadows::AppInit
 // Initialize OpenGL ES.
 // -----------------------------------------------------------------------------
 //
 void CShadows::AppInit( void )
     {

    
     // Initialize viewport and projection.
 //   SetScreenSize( iScreenWidth, iScreenHeight );
            
     // Set the screen background color.
     glClearColor( 0.f, 1.0f, 0.0f, 1.f );
 
     // Enable auto normalization for object's normals.
     glEnable( GL_NORMALIZE  );
 
     // Enable vertex and  normal arrays.
     glEnableClientState( GL_VERTEX_ARRAY );
     glEnableClientState( GL_NORMAL_ARRAY );
 
     // Set shadow object's front and back materials.
     glMaterialxv( GL_FRONT_AND_BACK, GL_AMBIENT,  objAmbientFront  );
     glMaterialxv( GL_FRONT_AND_BACK, GL_DIFFUSE,  objDiffuseFront  );
 
     // Set the normal pointer.
     glNormalPointer( GL_BYTE, 0, objNormals );
 
     // Set up global ambient light.
     glLightModelxv( GL_LIGHT_MODEL_AMBIENT, globalAmbient );
 
     // Do not use perspective correction
     glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST );
 
     // Set up lamp.
     glEnable(   GL_LIGHT0 );
     glLightxv( GL_LIGHT0, GL_DIFFUSE,  lightDiffuseLamp  );
     glLightxv( GL_LIGHT0, GL_AMBIENT,  lightAmbientLamp  );
     glLightxv( GL_LIGHT0, GL_SPECULAR, lightDiffuseLamp  );
 
     glPointSize( 5.0 ); // For drawing the lamp object
 
     // Initial position of the lamp
         
/*
     iLightRadius = 10.0;
     iLightAngle  = 0.0;
     iLightPosX   = iLightRadius * cos(iLightAngle); // 10.0
     iLightPosY   = iLightRadius * sin(iLightAngle); // 0.0
     iLightPosZ   = 50.0;
 
     iLightPos[0] = iLightPosX;
     iLightPos[1] = iLightPosY;
     iLightPos[2] = iLightPosZ;
     iLightPos[3] = 0.0;
 */
         iLightRadius = 10.0;
         iLightAngle  = 0.0;
         iLightPosX   = iLightRadius * cos(iLightAngle); 
         iLightPosY   = 50.0; 
         iLightPosZ   = iLightRadius * sin(iLightAngle);;
         
         iLightPos[0] = iLightPosX;
         iLightPos[1] = iLightPosY;
         iLightPos[2] = iLightPosZ;
         iLightPos[3] = 0.0;
         
         
     iIsLightRotatedLeft  = true;
     iIsLightRotatedRight = false;
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::AppExit
 // Release any allocations made in AppInit.
 // -----------------------------------------------------------------------------
 //
 void CShadows::AppExit( void )
     {
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::DrawPlane
 // Draw the ground plane.
 // -----------------------------------------------------------------------------
 //
 void CShadows::DrawPlane( void )
     {
     glColor4f( 255.f, 255.f, 255.f, 255.f ); // White
     glVertexPointer( 3, GL_BYTE, 0, planeVertices );
     glDrawElements( GL_TRIANGLES, 2 * 3, GL_UNSIGNED_BYTE, planeTriangles );
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::DrawLamp
 // Draw the lamp.
 // -----------------------------------------------------------------------------
 //
 void CShadows::DrawLamp( void )
     {
     /* The lamp is drawn using one vertex from the shadow object
        vertex list. The lamp is drawn as a single point. */
 
     glColor4f( 255.f, 255.f, 0.f, 255.f ); // Yellow
     glVertexPointer( 3, GL_BYTE, 0, objVertices );
     glDrawElements( GL_POINTS, 1, GL_UNSIGNED_BYTE, objTriangles );
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::DrawShadowObject
 // Draw shadows.
 // -----------------------------------------------------------------------------
 //
 void CShadows::DrawShadowObject( void )
     {
     glColor4f( 0.f, 0.f, 0.f, 255.f ); // Black
     glVertexPointer( 3, GL_BYTE, 0, objVertices );
     glDrawElements( GL_TRIANGLES, 48 * 3, GL_UNSIGNED_BYTE, objTriangles );
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::DrawObject
 // Draw the shadow object.
 // -----------------------------------------------------------------------------
 //
 void CShadows::DrawObject( void )
     {
     glDrawElements( GL_TRIANGLES, 48 * 3, GL_UNSIGNED_BYTE, objTriangles );
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::CalculateProjectionMatrix
 // Calculate proper shadow matrix.
 // -----------------------------------------------------------------------------
 //
 void CShadows::CalculateProjectionMatrix( void )
     {
         
         
     /* Shadows are calculated using appropriate projection matrix, which is
        defined, e.g., in OpenGL Programming Guide on page 584, or in Jim Blinn's
        Corner: A Trip Down the Graphics Pipeline on page 60. The latter also
        includes localized light sources as in our case. The general modelview
        matrix for creating a planar shadow can be expressed as:
 
        shadowMat =
 
        [ dtop-l[0]*g[0],     -l[1]*g[0],     -l[2]*g[0],     -l[3]*g[0],
              -l[0]*g[1], dotp-l[1]*g[1],     -l[2]*g[1],     -l[3]*g[1],
              -l[0]*g[2],     -l[1]*g[2], dotp-l[2]*g[2],     -l[3]*g[2],
          -l[0]*g[3],     -l[1]*g[3],     -l[2]*g[3], dotp-l[3]*g[3] ],
 
        where l - list(4) - light position
              g - list(4) - ground plane equation in form Ax + By + Cz + d = 0
          dotp = l[0]*g[0]+l[1]*g[1]+l[2]*g[2]+l[3]*g[3]
 
        Note that in this example the ground plane is a x-y-plane in origin, i.e.,
        the plane equation is g = [0,0,1,0]. Therefore the matrix can be written
        using only the light position parameters.
 
        Note that if you have a local light source, then g[2] = 1. In the case of
        directional light g[2] = 0.
     */
/* 
     GLfloat shadowMat_local[16] = { iLightPosZ,     0.0,        0.0,    0.0, \
                                        0.0,      iLightPosZ,    0.0,    0.0, \
                                       -iLightPosX, -iLightPosY,    0.0,   -1.0, \
                                       0.0,        0.0,         0.0, iLightPosZ };
*/

         
#if(0)
    GLfloat shadowMat_local[16] = 
         { iLightPosZ,     0.0,        0.0,    0.0, \
             0.0,      iLightPosZ,    0.0,    0.0, \
             -iLightPosX, -iLightPosY,    0.0,   -1.0, \
             0.0,        0.0,         0.0, iLightPosZ };
         
#else
    GLfloat shadowMat_local[16] = 
    {  iLightPosY,        0.0,         0.0,         0.0, \
      -iLightPosX,        0.0, -iLightPosZ,        -1.0, \
              0.0,        0.0,  iLightPosY,         0.0, \
              0.0,        0.0,         0.0,  iLightPosY };
#endif
         
     for ( int i=0;i<16;i++ )
     {
         iShadowMat[i] = shadowMat_local[i];
     }
 
}
 
 
 // -----------------------------------------------------------------------------
 // CShadows::AppCycle
 // Draws and animates the objects.
 // -----------------------------------------------------------------------------
 //


/****************************************************************************************
 * drawFrame :                                                                          *
 ****************************************************************************************/
void CShadows::AppCycle(TInt aFrame)
{
 //   AppCycleOld(aFrame);
  //  return;
    
    static TInt frameNumber=0;
	static GLfloat spinX=0;
	static GLfloat spinY=0;
    static GLfloat worldZ=-5.0f;
    
    // Replace the implementation of this method to do your own custom drawing.
/*	
	static const GLfloat cubeVertices[] = 
    {
		-10.5f,10.5f, 10.5f,
        10.5f, 10.5f, 10.5f,
        10.5f,-10.5f, 10.5f,
		-10.5f,-10.5f, 10.5f,
		
		
		-10.5f, 10.5f,-10.5f,
        10.5f, 10.5f,-10.5f,
        10.5f,-10.5f,-10.5f,
		-10.5f,-10.5f,-10.5f,	
	};
*/	
    static const GLfloat cubeVertices[] = 
    {
		-0.5f,0.5f, 0.5f,
        0.5f, 0.5f, 0.5f,
        0.5f,-0.5f, 0.5f,
		-0.5f,-0.5f, 0.5f,
		
		
		-0.5f, 0.5f,-0.5f,
        0.5f, 0.5f,-0.5f,
        0.5f,-0.5f,-0.5f,
		-0.5f,-0.5f,-0.5f,	
	};
   
    
    static const GLbyte cubeVerticesByte[] = 
    {
		-10,10, 10,
        10, 10, 10,
        10,-10, 10,
		-10,-10, 10,
		
		
		-10, 10,-10,
        10, 10,-10,
        10,-10,-10,
		-10,-10,-10,	
	};
    
	static const GLubyte cubeColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
		
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
	static const GLubyte cubeIndices[6*3*2]=
    {
         3,1,0,
        3,2,1,
        2,6,1,
        6,5,1,
        1,5,4,
        1,4,0,
        4,5,7,
        5,6,4,
        0,4,7,
        0,7,3,
        3,7,2,
        2,6,7,
    };
    
    static const GLfloat cubeNormals1[] = 
    {
        0.0f, -1.0f, 0.0f,           //top
		0.0f, -1.0f, 0.0f,
        
        1.0f, 0.0f, 0.0f,           //right
        1.0f, 0.0f, 0.0f,
        
        0.0f, 0.0f, 1.0f,           //front 
        0.0f, 0.0f, 1.0f,
    };
    
    
	static const GLubyte tfan1[6 * 3] =
	{
		1,0,3,
		1,3,2,
		1,2,6,
		1,6,5,
		1,5,4,
		1,4,0
	};
    
	static const GLubyte tfan2[6 * 3] =
	{
		7,4,5,
		7,5,6,
		7,6,2,
		7,2,3,
		7,3,0,
		7,0,4
	};
    
    static const GLfloat cubeNormals2[] = 
    {       
        0.0f, 0.0f,-1.0f,           //back
        0.0f, 0.0f,-1.0f,
        
		0.0f,-1.0f, 0.0f,           //bottom
        0.0f,-1.0f, 0.0f,
        
        -1.0f, 0.0f, 0.0f,           //left
        -1.0f, 0.0f, 0.0f,
	};
    
    static float transY = 0.0f;
    
    glClearColor( .5f, 0.1f, 0.6f, 1.f );
    
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
        
    // Update light position
    
    if ( iIsLightRotatedLeft )
    {
        iLightAngle += (GLfloat)0.1;
    }
    
    if ( iIsLightRotatedRight )
    {
        iLightAngle -= (GLfloat)0.1;
    }
  /*  
    iLightPosX   = iLightRadius * cos( iLightAngle );
    iLightPosY   = iLightRadius * sin( iLightAngle );
    iLightPos[0] = iLightPosX;
    iLightPos[1] = iLightPosY;
 */  
    
    float m_LightRadius=10.0;
    

    iLightPosX   = m_LightRadius * cos( iLightAngle );
    iLightPosZ   = m_LightRadius * sin( iLightAngle );
    iLightPos[0] = iLightPosX;
    iLightPos[2] = iLightPosZ;

    
    // Move camera
    glLoadIdentity();
    
    /*
     gluLookAt( 0.f, 20.f,  150.0,   // Camera position
     0.f, 20.f,    0.f,   // Look at point
     0.f,  1.f,    0.f ); // Up direction
     */
    glTranslatef(0.f, 1.0f, worldZ);
    
//    glRotatef( -55.f, 1.f, 0.f, 0.f );
    //    glRotatef( rotx, 1.f, 0.f, 0.f );
    
 //   rotx++;
    
    glDisable( GL_LIGHTING ); // Plane, lamp, and shadows don't need lighting
    glShadeModel( GL_FLAT );  // Plane, lamp, and shadows are single colored
    
    // Draw plane
    
    /*
    glPushMatrix();
    glScalef( 80.0, 60.0, 1.0 );
    DrawPlane();
    glPopMatrix();
    */
    
    // Draw the lamp
    

    glLightfv( GL_LIGHT0, GL_POSITION, iLightPos ); // Update lamp position
    glPushMatrix();
    glTranslatef( iLightPosX, iLightPosY, iLightPosZ );
    DrawLamp();
    glPopMatrix();

    glDisable( GL_DEPTH_TEST );  // Disable depth test while drawing shadows
    glDisableClientState(GL_NORMAL_ARRAY);

    // To ensure that shadows are drawn on top
    // of the ground plane
    CalculateProjectionMatrix(); // Calculate/update shadowMat
    glPushMatrix();              // Store the current modelview for drawing
    // the actual objects after shadows are drawn
    // modelview = M_camera
    glMultMatrixf( iShadowMat ); // Multiply shadow matrix with current
    // modelview after camera xforms and before
    // model xforms
    
    // Draw shadows
    glTranslatef( 0.0, .50, 0.0 );  // Translate object above the ground plane
 //   glRotatef( float(aFrame), 1.0, 0.0, 0.0 ); // Rotate object
//    glRotatef( float(aFrame), 0.0, 1.0, 0.0 );
 //   glRotatef( float(aFrame), 0.0, 0.0, 1.0 );
 ///   glTranslatef( .5, -.5, -.5 ); // Move origin to the middle of the
    // shadow object
    
//     DrawShadowObject(); // Draw shadows, i.e., draw the shadow object with the
    
 //   glPopMatrix();
    
//return;
    
    glColor4f( 0.f, 0.f, 0.f, 255.f ); // Black
//    glVertexPointer( 3, GL_BYTE, 0, cubeVerticesByte );
    
    glVertexPointer( 3, GL_FLOAT, 0, cubeVertices);
    
 //   glDrawElements( GL_TRIANGLES, 6 * 3, GL_UNSIGNED_BYTE, cubeIndices );

    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
    
    // correct modelview matrix:
    // modelview = M_camera * M_shadow * M_object
    glPopMatrix();      // modelview = M_camera
    

    glEnableClientState(GL_NORMAL_ARRAY);

    glEnable( GL_DEPTH_TEST ); // Shadows are drawn -> enable depth test
    glEnable( GL_LIGHTING );   // Enable lighting for drawing the objects
    glShadeModel( GL_SMOOTH ); // To make the lighting work properly
    
    // Draw shadow object
    glTranslatef( 0.0, 0.0, 30.0 );
    glRotatef( float(aFrame), 1.0, 0.0, 0.0 );
////    glRotatef( float(aFrame), 0.0, 1.0, 0.0 );
  //  glRotatef( float(aFrame), 0.0, 0.0, 1.0 );
//    glTranslatef( 5.0, -5.0, -5.0 );
    
    glNormalPointer(GL_FLOAT, 0,cubeNormals1);
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);

    glNormalPointer(GL_FLOAT, 0,cubeNormals2);
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
    
 //   DrawObject();
  

/*    
    glClearColor(0.0f, 0.7f, 0.2f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);	
    
    [self updateLightPosition];
    
    glDisable( GL_LIGHTING ); 
    
    //    [self drawPlatform:0.0f y:0.0f z:m_WorldZ];
    
    glLoadIdentity();
    
    glTranslatef(5.0f,5.0f,m_WorldZ);
    
    {
        glDisable(GL_LIGHTING);
        glShadeModel(GL_FLAT);
        
        [self drawLight];
        
        glDisable( GL_DEPTH_TEST );  // Disable depth test while drawing shadows
        
        // To ensure that shadows are drawn on top
        // of the ground plane
        [self calculateShadowMatrix]; // Calculate/update shadowMat
        
        glPushMatrix();              // Store the current modelview for drawing
        // the actual objects after shadows are drawn
        // modelview = M_camera
        glMultMatrixf( iShadowMat ); // Multiply shadow matrix with current
        // modelview after camera xforms and before
        // model xforms
        
        //position the shadows
        glTranslatef( 0.0, 0.0, 30.0 );  // Translate object above the ground plane
        glRotatef( float(frameNumber), 1.0, 0.0, 0.0 ); // Rotate object
        glRotatef( float(frameNumber), 0.0, 1.0, 0.0 );
        glRotatef( float(frameNumber), 0.0, 0.0, 1.0 );
        glTranslatef( 5.0, 5.0, -5.0 ); // Move origin to the middle of the
        
        //draw the shadows 
        
        glDisableClientState(GL_COLOR_ARRAY);
        glEnableClientState(GL_VERTEX_ARRAY);
        
        glColor4f( 0.f, 0.f, 0.f, 255.f ); // Black
        glVertexPointer( 3, GL_FLOAT, 0, cubeVertices );
        //       glDrawElements( GL_TRIANGLES, 48 * 3, GL_UNSIGNED_BYTE, faces );  
        
        //use these instead of the above
        
        glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
        glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
        
        glPopMatrix();      // modelview = M_camera
        
        glEnable( GL_DEPTH_TEST ); // Shadows are drawn -> enable depth test
        glEnable( GL_LIGHTING );   // Enable lighting for drawing the objects
        glShadeModel( GL_SMOOTH );
        
    }
    
    glTranslatef( 0.0, 0.0, 30.0 );
    glRotatef( float(frameNumber), 1.0, 0.0, 0.0 );
    glRotatef( float(frameNumber), 0.0, 1.0, 0.0 );
    glRotatef( float(frameNumber), 0.0, 0.0, 1.0 );
    glTranslatef( 5.0, -5.0, -5.0 );
    
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
    glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
    
    frameNumber++;
    
    [(EAGLView *)self.view presentFramebuffer];
 */   
    return;
}

//the original
#if(1)
 void CShadows::AppCycleOld( TInt aFrame )
     {
  //       drawCube();
         
 //        return;
         
         static float rotx=0;
         
     /* The order of rendering in our case is following:
        1. Draw all the ground object, i.e., the plane
        2. Draw shadows. If we have multiple ground object, each would have
           to be rendered separately with each different light sources.
        3. Draw the shadow objects. */
 
    glClearColor( 0.f, 0.4f, 0.7f, 1.f );

     glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );

         
     // Update light position
     if ( iIsLightRotatedLeft )
         {
         iLightAngle += (GLfloat)0.1;
         }
 
     if ( iIsLightRotatedRight )
         {
         iLightAngle -= (GLfloat)0.1;
         }
 
     iLightPosX   = iLightRadius * cos( iLightAngle );
     iLightPosY   = iLightRadius * sin( iLightAngle );
     iLightPos[0] = iLightPosX;
     iLightPos[1] = iLightPosY;
 
 
     // Move camera
     glLoadIdentity();
         
/*
     gluLookAt( 0.f, 20.f,  150.0,   // Camera position
                0.f, 20.f,    0.f,   // Look at point
                0.f,  1.f,    0.f ); // Up direction
*/
    glTranslatef(0.f, 20.f, -150.0f);
         
     glRotatef( -55.f, 1.f, 0.f, 0.f );
//    glRotatef( rotx, 1.f, 0.f, 0.f );

         rotx++;
         
     glDisable( GL_LIGHTING ); // Plane, lamp, and shadows don't need lighting
     glShadeModel( GL_FLAT );  // Plane, lamp, and shadows are single colored

     // Draw plane
     glPushMatrix();
     glScalef( 80.0, 60.0, 1.0 );
     DrawPlane();
     glPopMatrix();

     // Draw the lamp
     glLightfv( GL_LIGHT0, GL_POSITION, iLightPos ); // Update lamp position
     glPushMatrix();
     glTranslatef( iLightPosX, iLightPosY, iLightPosZ );
     DrawLamp();
     glPopMatrix();
 
     glDisable( GL_DEPTH_TEST );  // Disable depth test while drawing shadows
                                  // To ensure that shadows are drawn on top
                                  // of the ground plane
     CalculateProjectionMatrix(); // Calculate/update shadowMat
     glPushMatrix();              // Store the current modelview for drawing
                                  // the actual objects after shadows are drawn
                                  // modelview = M_camera
     glMultMatrixf( iShadowMat ); // Multiply shadow matrix with current
                                  // modelview after camera xforms and before
                                  // model xforms
 
     // Draw shadows
     glTranslatef( 0.0, 0.0, 30.0 );  // Translate object above the ground plane
     glRotatef( float(aFrame), 1.0, 0.0, 0.0 ); // Rotate object
     glRotatef( float(aFrame), 0.0, 1.0, 0.0 );
     glRotatef( float(aFrame), 0.0, 0.0, 1.0 );
     glTranslatef( 5.0, -5.0, -5.0 ); // Move origin to the middle of the
                                      // shadow object
 
     DrawShadowObject(); // Draw shadows, i.e., draw the shadow object with the
                         // correct modelview matrix:
                         // modelview = M_camera * M_shadow * M_object
     glPopMatrix();      // modelview = M_camera
 
     glEnable( GL_DEPTH_TEST ); // Shadows are drawn -> enable depth test
     glEnable( GL_LIGHTING );   // Enable lighting for drawing the objects
     glShadeModel( GL_SMOOTH ); // To make the lighting work properly
 
     // Draw shadow object
     glTranslatef( 0.0, 0.0, 30.0 );
     glRotatef( float(aFrame), 1.0, 0.0, 0.0 );
     glRotatef( float(aFrame), 0.0, 1.0, 0.0 );
     glRotatef( float(aFrame), 0.0, 0.0, 1.0 );
     glTranslatef( 5.0, -5.0, -5.0 );
     DrawObject();
 
     }
#endif

 // -----------------------------------------------------------------------------
 // CShadows::RotateLightLeft
 // Rotates light to left.
 // -----------------------------------------------------------------------------
 //
 void CShadows::RotateLightLeft( void )
     {
     iIsLightRotatedLeft = !iIsLightRotatedLeft;
     }
 
 
 // -----------------------------------------------------------------------------
 // CShadows::RotateLightRight
 // Rotates light to right.
 // -----------------------------------------------------------------------------
 //
 void CShadows::RotateLightRight( void )
     {
     iIsLightRotatedRight = !iIsLightRotatedRight;
     }
 
 // -----------------------------------------------------------------------------
 // CShadows::SetScreenSize
 // Reacts to the dynamic screen size change during execution of this program.
 // -----------------------------------------------------------------------------
 //
 void CShadows::SetScreenSize( TUint aWidth, TUint aHeight )
{
     iScreenWidth  = aWidth;
     iScreenHeight = aHeight;
 
     // Reinitialize viewport and projection.
     glViewport( 0, 0, iScreenWidth, iScreenHeight );
 
     // Recalculate the view frustrum
     glMatrixMode( GL_PROJECTION );
     glLoadIdentity();
     GLfloat aspectRatio = (GLfloat)(iScreenWidth) / (GLfloat)(iScreenHeight);
     glFrustumf( FRUSTUM_LEFT * aspectRatio, FRUSTUM_RIGHT * aspectRatio,
                 FRUSTUM_BOTTOM, FRUSTUM_TOP,
                 FRUSTUM_NEAR, FRUSTUM_FAR );
     glMatrixMode( GL_MODELVIEW );     
}

void CShadows::drawCube(void)
{
    static TInt frameNumber=0;

    
	static GLfloat z=-6.0;
	static GLfloat spinX=0;
	static GLfloat spinY=0;
    
    
    // Replace the implementation of this method to do your own custom drawing.
	
	static const GLfloat cubeVertices[] = 
    {
		-0.5f, 0.5f, 0.5f,
        0.5f, 0.5f, 0.5f,
        0.5f,-0.5f, 0.5f,
		-0.5f,-0.5f, 0.5f,
		
		
		-0.5f, 0.5f,-0.5f,
        0.5f, 0.5f,-0.5f,
        0.5f,-0.5f,-0.5f,
		-0.5f,-0.5f,-0.5f,	
	};
	
	static const GLubyte cubeColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
		
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
	
	static const GLubyte tfan1[6 * 3] =
	{
		1,0,3,
		1,3,2,
		1,2,6,
		1,6,5,
		1,5,4,
		1,4,0
	};
    
	static const GLubyte tfan2[6 * 3] =
	{
		7,4,5,
		7,5,6,
		7,6,2,
		7,2,3,
		7,3,0,
		7,0,4
	};
    
    static float transY = 0.0f;
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);	
    
	//this makes it look almost exactly like the 2D jello cube
	
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    //    glTranslatef(0.0f,-1.0f,0.0f);
    //    glRotatef(sceneRotation, 1.0f, 0.0f, 0.0f);
    
    //    m_WorldRotation+=.25;
    
	glEnable(GL_CULL_FACE);
	glCullFace(GL_BACK);
	
    glFrontFace(GL_CCW);
    
    glPushMatrix();
    
    //	glMatrixMode(GL_MODELVIEW);
    //	glLoadIdentity();
	
	glTranslatef(0.0f, (GLfloat)(sinf(transY)/2.0f)+1.0,z);
    //	glTranslatef(0.0f, 2.0f,z);
    
	transY += 0.075f;
	
    //	glRotatef(spinX, 1.0, 0.0, 0.0);
	
    
    
	glVertexPointer(3, GL_FLOAT, 0, cubeVertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, cubeColors);
	glEnableClientState(GL_COLOR_ARRAY);
	
    glPushMatrix();
//    glRotatef(m_WorldRotationX, 1.0f, 0.0f, 0.0f);
    glRotatef(spinX, 0.0f, 1.0f, 0.0f);
    
	glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan1);
	glDrawElements( GL_TRIANGLE_FAN, 6 * 3, GL_UNSIGNED_BYTE, tfan2);
    
    glPopMatrix();
    glPopMatrix();
    
	spinY+=.25;
	spinX+=.25;
}
