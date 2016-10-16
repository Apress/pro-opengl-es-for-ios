//
//  Shader.vsh
//  AtmoShader
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;            //the vertex position


varying lowp vec4 colorVarying;
varying vec3 v3Direction;
varying lowp vec4 frontSecondaryColorVarying;   //makes up for the missing gl_FrontSecondaryColor of GLSL

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 lightPosition;

uniform vec3  v3CameraPos;		// The camera's current position
//uniform vec3 v3LightPos;		// The direction vector to the light source
uniform vec3  v3InvWavelength;	// 1 / pow(wavelength, 4) for the red, green, and blue channels
//uniform float fCameraHeight;	// The camera's current height (not used)
uniform float fCameraHeight2;	// fCameraHeight^2
uniform float fOuterRadius;		// The outer (atmosphere) radius
uniform float fOuterRadius2;	// fOuterRadius^2
uniform float fInnerRadius;     //
//uniform float fInnerRadius2;	// fInnerRadius^2 (not used)

uniform float fKrESun;			// Kr * ESun
uniform float fKmESun;			// Km * ESun
uniform float fKr4PI;			// Kr * 4 * PI
uniform float fKm4PI;			// Km * 4 * PI
uniform float fScale;			// 1 / (fOuterRadius - fInnerRadius)
uniform float fScaleDepth;		// The scale depth (i.e. the altitude at which the atmosphere's average density is found)
uniform float fScaleOverScaleDepth;	// fScale / fScaleDepth
uniform int   nSamples;
uniform float fSamples;
varying vec3 v3LightPos;


float scale(float fCos)
{
  //  if(fCos<0.0)fCos*= -1.0*fCos;
    
	float x = 1.0 - fCos;
	return fScaleDepth * exp(-0.00287 + x*(0.459 + x*(3.83 + x*(-6.80 + x*5.25))));
}

void main()
{
    vec3 v3Pos;
    
    //can't use the original "gl_Position" as ES 2.0 doesn't support it.
    
      v3Pos = position.xyz;                                         //original
    
 //   vec4 v4temp=modelViewProjectionMatrix*position;
 //   v3Pos=v4temp.xyz;
    
    //The camera is always x=0, and height is based on y and z 
    
	vec3 v3Ray = v3Pos - v3CameraPos;                                   //vector from camera to point B                  
	float fFar = length(v3Ray);                                         //distance from camera to far point ("B")
	v3Ray =normalize(v3Ray);                                                      //pre-normalize v3Ray, since it's used alot
    
    
	//Calculate the closest intersection of the ray with the outer 
    //atmosphere (which is the near point of the ray passing through the atmosphere)
	//quadratic equation. See http://en.wikipedia.org/wiki/Line–sphere_intersection
    
    float B = 2.0 * dot(v3CameraPos, v3Ray);                             
	float C = fCameraHeight2 - fOuterRadius2;
	float fDet = max(0.0, B*B - 4.0 * C);
	float fNear = 0.5 * (-B - sqrt(fDet));
    
    // Calculate the ray's starting position, then calculate its scattering offset
    //RMS: From email from Sean, v3Start is the location of the entry point into the sky dome

	vec3 v3Start = v3CameraPos + v3Ray * fNear;
	fFar -= fNear;
    
    
	float fStartAngle = dot(v3Ray, v3Start) / fOuterRadius;     //dividing by fOuterRadius manages the normalization
	float fStartDepth = exp(-1.0 / fScaleDepth);
	float fStartOffset = fStartDepth*scale(fStartAngle);

	// Initialize the scattering loop variables
    
	//gl_FrontColor = vec4(0.0, 0.0, 0.0, 0.0);
	float fSampleLength = fFar / fSamples;
	float fScaledLength = fSampleLength * fScale;
	vec3 v3SampleRay = v3Ray * fSampleLength;
	vec3 v3SamplePoint = v3Start + v3SampleRay * 0.5;
    
    // Now loop through the sample rays
        
	vec3 v3FrontColor = vec3(0.0, 0.0, 0.0);
    
    //needed as the glUniform1i to set nSamples fails, returning a 1282, meaning it is never used.
    //but it is used here in the loop , so could be a shader linker bug
    
   
    //	for(int i=0; i<nSamples; i++)

    for(int i=0; i<3; i++)
	{
		float fHeight = length(v3SamplePoint);
		float fDepth = exp(fScaleOverScaleDepth * (fInnerRadius - fHeight));
		float fLightAngle = dot(lightPosition,v3SamplePoint) / fHeight;
        float fCameraAngle = dot(v3Ray,v3SamplePoint) / fHeight;
        
        //the following line is from http://forum.unity3d.com/threads/12296-Atmospheric-Scattering-help/page3
        
        //		float fCameraAngle = dot(-v3Ray,(dot(v3Ray,normalize( v3SamplePoint)) / fHeight));

		float fScatter = (fStartOffset + fDepth*(scale(fLightAngle) - scale(fCameraAngle)));
		vec3 v3Attenuate = exp(-fScatter * (v3InvWavelength * fKr4PI + fKm4PI));
		v3FrontColor += v3Attenuate * (fDepth * fScaledLength);
		v3SamplePoint += v3SampleRay;
	}
    
    // Finally, scale the Mie and Rayleigh colors and 
    // set up the varying variables for the pixel shader
	
    //fKmESun=1.0;
    
    frontSecondaryColorVarying.rgb = v3FrontColor * fKmESun;
	colorVarying.rgb = v3FrontColor * (v3InvWavelength * fKrESun);
    gl_Position = modelViewProjectionMatrix * position;
	v3Direction = v3CameraPos - v3Pos;
    v3LightPos=lightPosition;
    
    
    //colorVarying.a=1.0;
    //frontSecondaryColorVarying.a=1.0;
    
    //   frontSecondaryColorVarying.r=1.0;
    
    //     colorVarying.r=.1;
    //      frontSecondaryColorVarying.b=1.0;
}
