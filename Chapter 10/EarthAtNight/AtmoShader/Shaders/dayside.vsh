//
//  dayside.vsh
//  AtmoShader
//
//  used for the daylight side of the earth. The alpha of this fades to 0
//      at the terminator so the night's texture can show through
//
//  Created by mike on 9/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec2 v_texCoord;  

varying lowp vec4 colorVarying;
varying lowp vec4 specularColorVarying;

uniform mat4 modelViewProjectionMatrix;
uniform mat3 normalMatrix;
uniform vec3 lightPosition;
uniform vec3 eyePosition;

void main()
{
    float shininess=25.0;
    float balance=.75;
    
    vec3 normalDirection = normalize(normalMatrix * normal);
    vec3 eyeNormal = normalize(eyePosition);
    vec3 lightDirection;

    float specular=0.0;
    
    v_texCoord=texCoord;
    
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
        
    lightDirection=normalize(lightPosition);
    
    float nDotVP = max(0.0, dot(normalDirection,lightDirection));

    float nDotVPReflection = dot(reflect(-lightDirection,normalDirection),eyeNormal);
 
    specular = pow(max(0.0,nDotVPReflection),shininess)*balance;
    specularColorVarying=vec4(specular,specular,specular,0.0);    
                            
    colorVarying = diffuseColor * nDotVP*1.3;
    
    gl_Position = modelViewProjectionMatrix * position;
}

