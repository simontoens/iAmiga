//
//  OGLDisplay.h
//  iAmiga
//
//  Created by Stuart Carnie on 1/13/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import "UIKitDisplayView.h"
#import "OGLShaderProgram.h"

#import "NoEffect.h"
#import "TexturedCRTEffect.h"

#import "OGLTypes.h"

@interface OGLDisplay : UIView<DisplayViewSurface> {
	EAGLContext			*_glContext;
	GLuint				m_framebuffer;
    GLuint				m_renderbuffer;
	GLint				_renderWidth, _renderHeight;
	
	GLuint				_texture;
	
	GLuint				_displayBuffers[2];
	
	void				*_pixels;
	GLsizei				_displaySize[2];
	
	CADisplayLink		*_displayLink;
	
	DisplayEffect		_displayEffect;
	OGLShaderProgram	*_shaderEffect;
	
	NoEffect			*_noEffect;
	TexturedCRTEffect	*_texturedEffect;
	
}

- (id)initWithFrame:(CGRect)frame displaySize:(CGSize)displaySize;

#ifdef __cplusplus
extern "C" 
#endif
void UpdateOGLScreen(void);

@end

#ifdef __cplusplus
extern "C" 
#endif
UIView<DisplayViewSurface>* CreateOGLDisplayView(int width, int height);

#ifdef __cplusplus
extern "C"
#endif
UIView* GetSharedOGLDisplayView(void);
