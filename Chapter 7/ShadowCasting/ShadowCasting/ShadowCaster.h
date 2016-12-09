
//
//  ShadowCaster.h
//  ShadowCasting
//
//  Created by mike on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


/*
* ==============================================================================
*  Name        : Shadows.h
*  Part of     : OpenGLEx / Shadows
*
*  Copyright (c) 2004-2006 Nokia Corporation.
*  This material, including documentation and any related
*  computer programs, is protected by copyright controlled by
*  Nokia Corporation.
* ==============================================================================
*/


#ifndef SHADOWS_H
#define SHADOWS_H

// INCLUDES

//#include <e32base.h> // for CBase definition
//#include <GLES/gl.h> // OpenGL ES header file

#include <OpenGLES/EAGL.h>

#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>

//#include "glutils.h" // Misc GLU and GLUT functions

// MACROS
#define FRUSTUM_LEFT   -1.f     //left vertical clipping plane
#define FRUSTUM_RIGHT   1.f     //right vertical clipping plane
#define FRUSTUM_BOTTOM -1.f     //bottom horizontal clipping plane
#define FRUSTUM_TOP     1.f     //top horizontal clipping plane
#define FRUSTUM_NEAR    3.f     //near depth clipping plane
#define FRUSTUM_FAR  1000.f     //far depth clipping plane

// CLASS DECLARATION

typedef int TInt;
typedef unsigned int  TUint;
typedef bool TBool;

//Class that does the actual OpenGL ES rendering.

class CShadows
{
 public:  // Constructors and destructor

    
    /**
     * Standard constructor that must never Leave.
     * Stores the given screen width and height.
     * @param aWidth Width of the screen.
     * @param aHeight Height of the screen.
     */
    
     CShadows( unsigned int aWidth, unsigned int aHeight);

     virtual ~CShadows();

 public: // New functions

     /**
      * Initializes OpenGL ES, sets the vertex and color
      * arrays and pointers. Also selects the shading mode.
      */
     void AppInit( void );

     /**
      * Called upon application exit. Does nothing.
      */
     void AppExit( void );

     /**
      * Draws the ground plane.
      */
     void DrawPlane( void );

     /**
      * Draws the lamp.
      */
     void DrawLamp( void );

     /**
      * Draws the shadows.
      */
     void DrawShadowObject( void );

     /**
      * Draw the object.
      */
     void DrawObject( void );

     /**
      * Calculate proper shadow matrix.
      */
     void CalculateProjectionMatrix( void );

     /**
      * Renders one frame.
      * @param aFrame Number of the frame to be rendered.
      */
     void AppCycle( int aFrame );

     /**
      * Rotates light to left
      */
     void RotateLightLeft( void );

     /**
      * Rotates light to right
      */
     void RotateLightRight( void );

     /**
      * Notifies that the screen size has dynamically changed during execution of
      * this program. Resets the viewport to this new size.
      * @param aWidth New width of the screen.
      * @param aHeight New height of the screen.
      */
     void SetScreenSize( unsigned int aWidth, unsigned int aHeight );

    void AppCycleOld( TInt aFrame );

     void drawCube(void);

 protected:  // New functions

     /**
      * Second phase contructor. Does nothing.
      */
     void ConstructL( void );

 private:  // Data

     /** Width of the screen */
      unsigned int iScreenWidth;

     /** Height of the screen */
      unsigned int iScreenHeight;


     /** Radius of the light. */
     GLfloat iLightRadius;

     /** Angle of the light. */
     GLfloat iLightAngle;


     /** X coordinate of the light */
     GLfloat iLightPosX;

     /** Y coordinate of the light */
     GLfloat iLightPosY;

     /** Z coordinate of the light */
     GLfloat iLightPosZ;


     /** Light position. */
     GLfloat iLightPos[4];

     /** Shadow projection matrix. */
     GLfloat iShadowMat[16];


     /** Whether the light is rotated left each frame or not. */
     bool iIsLightRotatedLeft;

     /** Whether the light is rotated right each frame or not. */
     bool iIsLightRotatedRight;

 }; 
#endif



 //  End of File
