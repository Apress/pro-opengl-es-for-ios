//
//  main.m
//  OpenGL Lens Flare
//
//  Created by mike on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenGLLensFlareAppDelegate.h"

int main(int argc, char *argv[])
{
    NSException *exception2;
	    
	@try
	{
        @autoreleasepool 
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([OpenGLLensFlareAppDelegate class]));
        }
	}
	@catch(NSException *exception)
	{
		exception2=exception;

        NSLog(@"Crash! %@",exception2.reason);		

	}
	
}
