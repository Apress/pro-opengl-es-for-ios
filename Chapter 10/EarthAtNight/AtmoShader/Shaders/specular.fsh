//
//  Shader.fsh
//  AtmoShader
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;


precision mediump float;                            
varying vec2 v_texCoord;                            
uniform sampler2D s_texture; 

void main()                                         
{       
    vec4 newColor;
  
    newColor=1.0-colorVarying;
        
    gl_FragColor = texture2D( s_texture, v_texCoord )*newColor;
}     