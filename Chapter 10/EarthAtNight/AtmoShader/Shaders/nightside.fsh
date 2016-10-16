//
//  nightside.fsh
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;


precision mediump float;                            
varying vec2 v_texCoord;                            
uniform sampler2D s_texture; 
uniform sampler2D cloud_texture;

void main()                                         
{       
    vec4 newColor;
    vec4 cloudColor;
    vec4 surfaceColor;
    float cloudNightBrightness=.1;      //just a small boost to ensure the clouds to actually show at night
    
    newColor=1.0-colorVarying;
    
    cloudColor=texture2D(cloud_texture, v_texCoord );
    surfaceColor=texture2D( s_texture, v_texCoord );
      
    if(cloudColor[0]>0.4)
    {
        cloudColor[3]=1.0;
        gl_FragColor=cloudNightBrightness*cloudColor+0.6*surfaceColor*newColor;
    }
    else   
        gl_FragColor = surfaceColor*newColor;
}     