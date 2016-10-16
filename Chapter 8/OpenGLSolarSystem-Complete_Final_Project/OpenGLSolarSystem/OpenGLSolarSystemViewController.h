//
//  OpenGLSolarSystemViewController.h
//  BouncySquare
//
//  Created by mike on 9/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "OpenGLSolarSystem.h" 
#import "OpenGLSolarSystemController.h"
#import "miniglu.h"
#include <math.h>

@interface OpenGLSolarSystemViewController : GLKViewController
{
    OpenGLSolarSystemController *m_SolarSystem;
    CGPoint m_PointerLocation;
    
    UIButton *m_Button1;
    UIButton *m_Button2;
    UIButton *m_Button3;
    UIButton *m_Button4;
    
    UIImageView *m_GreenHUDHorImage;
    UIImageView *m_GreenHUDVertImage;
    UILabel *m_Label;
    
    BOOL m_ConstNamesOn;
    BOOL m_LensFlareOn;
    BOOL m_ConstOutlinesOn;
};

-(void)viewDidLoad;
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
-(void)setHoverPosition:(unsigned)nFlags location:(CGPoint)location         
           prevLocation:(CGPoint)prevLocation;
-(UIButton *)createButton:(CGRect)frame normalImageFile:(NSString *)normalImageFile 
         selectedImageFile:(NSString *)selectedImageFile title:(NSString *)title 
                 selector:(SEL)selector titleColor:(UIColor *)titleColor;
-(void)scan;
-(UILabel *)createLabel:(CGRect)frame title:(NSString *)title titleColor:(UIColor *)titleColor 
               fontSize:(int)fontSize textAlignment:(UITextAlignment)textAlignment;
-(void)createUI;
-(void)initLighting;


@end
