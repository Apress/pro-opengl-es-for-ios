//
//  Shader.fsh
//  Textured Square
//
//  Created by mike on 8/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
