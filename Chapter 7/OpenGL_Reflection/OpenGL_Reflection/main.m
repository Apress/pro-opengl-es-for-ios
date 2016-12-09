//
//  main.m
//  OpenGL_Reflection
//
//  Created by mike on 7/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "OpenGL_ReflectionAppDelegate.h"

int main(int argc, char *argv[])
{
    NSException *exception2;
    
    @try
	{
        @autoreleasepool 
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([OpenGL_ReflectionAppDelegate class]));
        }
	}
	@catch(NSException *exception)
	{
		exception2=exception;
        
        NSLog(@"Crash! %@",exception2.reason);		
        
	}
}
