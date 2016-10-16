//
//  Shader.fsh
//  AtmoShader
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//
//
// Atmospheric scattering fragment shader
//
// Original Author: Sean O'Neil
//
// Copyright (c) 2004 Sean O'Neil
//


varying lowp vec4 colorVarying;
varying lowp vec4 frontSecondaryColorVarying;  


precision mediump float;                            
varying vec2 v_texCoord;                            
uniform sampler2D s_texture; 


varying vec3 v3LightPos;
uniform float g;
uniform float g2;

varying vec3 v3Direction;


void main (void)
{    
 /*   
    v3LightPos.x=0;
    v3LightPos.y=4;
    v3LightPos.z=-2;
 */   
  float fCos = dot(v3LightPos, v3Direction) / length(v3Direction);
    //    float fCos = dot(normalize(v3LightPos), normalize(v3Direction));

	float fRayleighPhase = 0.75 * (1.0 + fCos*fCos);
	float fMiePhase = 1.5 * ((1.0 - g2) / (2.0 + g2)) * (1.0 + fCos*fCos) / pow(1.0 + g2 - 2.0*g*fCos, 1.5);

    
    gl_FragColor = fRayleighPhase * colorVarying + 1000.0*fMiePhase * frontSecondaryColorVarying;
 
    
    // gl_FragColor = fRayleighPhase * colorVarying;
    
    //   gl_FragColor =fMiePhase * frontSecondaryColorVarying;


    //   gl_FragColor=colorVarying;
    //          gl_FragColor.r=gl_FragColor.g=1.0;
    //    gl_FragColor.a=1.0;
    
	//gl_FragColor.a = gl_FragColor.b;
}