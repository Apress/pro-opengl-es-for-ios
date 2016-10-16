

#import "OpenGLOutlines.h"
#import "OpenGLUtils.h"
#import "OpenGLSolarSystem.h"
#import "OpenGLText.h"

#import "miniGLU.h"

@implementation OpenGLOutlines

- (id)init
{
    self = [super init];
    
    if (self) 
    {
        self=[self init:@"outlines" red:0.0 green:1.0 blue:1.0 alpha:.1];
    }
    
    return self;
}


-(OpenGLText *)createLabel:(NSString *)label
{
    float fontSize=20;
    CGSize size;
    OpenGLText *labelTexture;
    GLfloat scale;
    
    scale=[[UIScreen mainScreen] scale];
    
    UIFont *tempFont=[UIFont fontWithName:@"Copperplate" size:fontSize*scale];
    
    size=[label sizeWithFont:tempFont];	
    
    labelTexture=[[OpenGLText alloc]initWithText:label size:size alignment:UITextAlignmentLeft font:tempFont];	
    
    return labelTexture;
}

-(OpenGLOutlines *)init:(NSString *)filename red:(GLfloat)red green:(GLfloat)green blue:(GLfloat)blue alpha:(GLfloat)alpha
{
	float x,y,z;
	int i,j;
	NSNumber *ra,*dec;	
	NSMutableArray *coordArray;				//numbers in order: ra,dec, x,y,z
    OpenGLText *nameTexture;
	NSMutableDictionary *dict;
	NSString *thePath = [[NSBundle mainBundle]  pathForResource:filename ofType:@"plist"];
	int numpoints=0;
	GLfloat *data;
	int numbytes;
	int index=0;
	NSMutableDictionary *coords;
	NSString *name;
	NSData *nsdata;
	
	m_Red=red;
	m_Green=green;
	m_Blue=blue;
	m_Alpha=alpha;
	
	m_Data = [[NSMutableArray alloc] initWithContentsOfFile:thePath];
	
	//convert the ra/dec to xyz
	
	for(i=0;i<[m_Data count];i++)								//each i is a different outline set.
	{
		dict=[m_Data objectAtIndex:i];							//object points to each outline set
		
		name=[dict objectForKey:@"name"];
		
		if([name length])						//some objects might not have a name
		{
			ra=(NSNumber *)[dict objectForKey:@"name_ra"];
			dec=(NSNumber *)[dict objectForKey:@"name_dec"];
            
            [[OpenGLUtils getObject]sphereToRectTheta:15.0*[ra floatValue]/DEGREES_PER_RADIAN phi:[dec floatValue]/DEGREES_PER_RADIAN radius:STANDARD_RADIUS xprime:&x yprime:&y zprime:&z];
            
			numbytes=3*sizeof(GLfloat);
			data=(GLfloat *)malloc(3*sizeof(numbytes));					//store the xyz of the name
			data[0]=x;
			data[1]=y;
			data[2]=z;
			nsdata=[[NSData alloc]initWithBytes:data length:numbytes];
			
			[dict setObject:nsdata forKey:@"binary_name_coords"];
            
            nameTexture=[self createLabel:name];
            
            [dict setObject:nameTexture forKey:@"name_texture"];
		}
		
		//now grab the line coordinates;
		
		coordArray=[dict objectForKey:@"coordinates"];
		
		numpoints=[coordArray count];
        
		numbytes=numpoints*3*sizeof(GLfloat);			//3 for x,y and z
		
		data=(GLfloat *)malloc(numbytes);	
        
		for(j=0;j<numpoints;j++)
		{
			//convert the ra/dec to x,y,z
			
			coords=[coordArray objectAtIndex:j];
			
			ra=(NSNumber *)[coords objectForKey:@"ra"];
			dec=(NSNumber *)[coords objectForKey:@"dec"];
			
			//precalculate the x,y,z;	
			
			[[OpenGLUtils getObject]sphereToRectTheta:15.0*[ra floatValue]/DEGREES_PER_RADIAN phi:[dec floatValue]/DEGREES_PER_RADIAN radius:STANDARD_RADIUS xprime:&x yprime:&y zprime:&z];
			
			//create nice compressed data array
			
			index=j*3;
			
			data[index+0]=x;
			data[index+1]=y;
			data[index+2]=z;		
		}
		
		nsdata=[[NSData alloc]initWithBytes:data length:numbytes];
		
		[dict setObject:nsdata forKey:@"binarydata"];
	}
    
	return self;
}

- (void)execute:(BOOL)showLines showNames:(BOOL)showNames
{
	int i;
	int count;
	NSMutableArray *colorArray;
	NSMutableDictionary *object;
	float red,green,blue,alpha;
	GLfloat *data=nil;
	int numVertices;
	GLfloat sx,sy,sz;

	GLfloat lineWidth=3.0;
	GLfloat scale;
    
    scale=[[UIScreen mainScreen] scale];
    
    glLineWidth(lineWidth*scale);
    
	glPushMatrix();
	
	count=[m_Data count];
	
    if(showLines)
    {
        for(i=0;i<count;i++)									    //enumerate each outline set
        {
            glMatrixMode(GL_MODELVIEW);
            glBindTexture(GL_TEXTURE_2D,0);
            glDisableClientState(GL_COLOR_ARRAY);
            glDisable(GL_TEXTURE_2D);			
            glDisable(GL_LIGHTING);	
            glEnable(GL_DEPTH_TEST);
            glEnableClientState(GL_VERTEX_ARRAY);
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
            
            object=[m_Data objectAtIndex:i];						//object points to each outline set
            
            colorArray=[object objectForKey:@"color_main"];
            
            if(m_Red<0)
            {
                red=[[colorArray objectAtIndex:0]floatValue];
                green=[[colorArray objectAtIndex:1]floatValue];
                blue=[[colorArray objectAtIndex:2]floatValue];
                alpha=[[colorArray objectAtIndex:3]floatValue];
            }
            else
            {
                red=m_Red;
                green=m_Green;
                blue=m_Blue;
                alpha=m_Alpha;
            }
            
            glColor4f(red,green,blue,alpha);
            
            numVertices=[[object objectForKey:@"coordinates"]count];
            data=(GLfloat *)[[object objectForKey:@"binarydata"]bytes];
            
            if(numVertices>0)
            {
                glVertexPointer(3,GL_FLOAT,0,data);	
                
                glDrawArrays(GL_LINE_STRIP,0,numVertices);
            }
        }
    }
    
    if(showNames)
    {
        for(i=0;i<count;i++)									    //enumerate each outline set
        {   
            object=[m_Data objectAtIndex:i];						//object points to each outline set
            
            data=(GLfloat *)[[object objectForKey:@"binary_name_coords"]bytes];
            
            if(data!=nil)
            {         
                gluGetScreenLocation((GLfloat)data[0],(GLfloat)data[1],(GLfloat)data[2],&sx,&sy,&sz);
                
                if(sz>0)
                {
                    OpenGLText *nameTexture;
                    
                    nameTexture=(OpenGLText *)[object objectForKey:@"name_texture"];
                    [nameTexture renderAtPoint:CGPointMake(sx,sy) depth:STANDARD_RADIUS red:0.6 green:.1 blue:.2 alpha:0.0];
                }
            }
        }
    }
end:	
	
	glDisableClientState(GL_VERTEX_ARRAY);	
	glPopMatrix();
	glEnable(GL_LIGHTING);
}

@end
