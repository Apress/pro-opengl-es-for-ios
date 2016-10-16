//
//  Shader.vsh
//  AtmoShader
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec2 v_texCoord;  

varying lowp vec4 colorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 lightPosition;

void main()
{
    v_texCoord=texCoord;
    
    vec3 eyeNormal = normalize(normalMatrix * normal);
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
        
    float nDotVP = max(0.0, dot(eyeNormal, normalize(lightPosition)));
       
    colorVarying = pow(max(0.0,nDotVP)*5.0;
    
    gl_Position = modelViewProjectionMatrix * position;
}
