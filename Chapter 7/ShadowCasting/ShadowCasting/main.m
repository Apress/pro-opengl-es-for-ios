//
//  main.m
//  ShadowCasting
//
//  Created by mike on 8/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShadowCastingAppDelegate.h"

int main(int argc, char *argv[])
{
    NSException *exception2;
    
    @try
	{
        @autoreleasepool 
        {
            return UIApplicationMain(argc, argv, nil, NSStringFromClass([ShadowCastingAppDelegate class]));
        }
	}
	@catch(NSException *exception)
	{
		exception2=exception;
        
        NSLog(@"Crash! %@",exception2.reason);		
	}
}
