//
//  Shader.fsh
//  OpenGL_Reflection
//
//  Created by mike on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
