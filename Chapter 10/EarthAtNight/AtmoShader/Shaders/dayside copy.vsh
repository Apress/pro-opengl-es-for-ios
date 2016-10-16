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
    vec3 normalDirection = normalize(normalMatrix * normal);
    vec3 lightDirection;
    vec3 eyeNormal = normalize(eyePosition);

    float specular=0.0;
    
    v_texCoord=texCoord;
    
    vec4 diffuseColor = vec4(1.0, 1.0, 1.0, 1.0);
        
    lightDirection=normalize(lightPosition);
    
    float nDotVP = max(0.0, dot(eyeNormal,lightDirection));

    float nDotVPReflection = dot(reflect(-lightDirection,normalDirection),eyeNormal);

    specular = pow(max(0.0,nDotVPReflection),100.0)*.75;
    specularColorVarying=vec4(specular,specular,specular,0.0);


    //colorVarying = diffuseColor * nDotVP + specular;
     
                            
    colorVarying = diffuseColor * nDotVP;
    
    gl_Position = modelViewProjectionMatrix * position;
}
