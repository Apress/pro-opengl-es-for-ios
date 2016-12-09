//
//  Shader.fsh
//  ShadowCasting
//
//  Created by mike on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
