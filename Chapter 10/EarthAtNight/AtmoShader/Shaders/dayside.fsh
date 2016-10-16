//
//  dayside.fsh
//  AtmoShader
//
//  used for the daylight side of the earth. The alpha of this fades to 0
//      at the terminator so the night's texture can show through
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

precision mediump float;                            

varying lowp vec4 colorVarying;
varying lowp vec4 specularColorVarying;


uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 lightPosition;

varying vec2 v_texCoord;                            
uniform sampler2D s_texture; 
uniform sampler2D cloud_texture;

void main()                                         
{       
    vec4 finalSpecular=vec4(0,0,0,1);
    vec4 surfaceColor;
    vec4 cloudColor;
    
    float halfBlue;            //a value used to detect a mainly blue fragment. 
    
    surfaceColor=texture2D( s_texture, v_texCoord );
    cloudColor=texture2D(cloud_texture, v_texCoord );

    //if the fragment is mainly blue, that is if red and green are less than
    //half of the blue component, then this is the ocean so it is shiny enough
    //to have a specular reflection.
    
    halfBlue=0.5*surfaceColor[2];
    
    if(halfBlue>1.0)
        halfBlue=1.0;
    
    if((surfaceColor[0]<halfBlue) && (surfaceColor[1]<halfBlue))
        finalSpecular=specularColorVarying;
  
    if(cloudColor[0]>0.20)
    {
        cloudColor[3]=1.0;
        gl_FragColor=(cloudColor*1.3+surfaceColor*.4)*colorVarying;
    }
   else
        gl_FragColor=(surfaceColor+finalSpecular)*colorVarying;
}     