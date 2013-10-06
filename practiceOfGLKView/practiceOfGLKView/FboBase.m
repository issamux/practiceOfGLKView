//
//  FboBase.m
//  practiceOfGLKView
//
//  Created by nakano_michiharu on 2013/10/05.
//  Copyright (c) 2013年 nakano_michiharu. All rights reserved.
//

#import "FboBase.h"
#import "SimpleFboShader.h"
#import "FboTextureBuffer.h"

static GLint sDefaultFbo = -1;

@interface FboBase()
{
	GLint _width;
	GLint _height;
	SimpleFboShader* _fboShader;
	FboTextureBuffer* _fboVArray;

	GLuint _fboHandle;
	GLuint _fboTexId;
	GLuint _fboDepthBuffer;
	
	CGSize sizeFbo;
}
- (void)setupFBO;
@end


@implementation FboBase
@synthesize width = _width;
@synthesize height = _height;

-(id)init
{
	self = [super init];
	if (self != nil) {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}


- (void)setupFBO
{
	sizeFbo.width = 512;
	sizeFbo.height = 512;
	if (sDefaultFbo < 0) {
		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &sDefaultFbo);
	}
	
	glGenFramebuffers(1, &_fboHandle);
	glGenTextures(1, &_fboTexId);
	glGenRenderbuffers(1, &_fboDepthBuffer);
	
	glBindFramebuffer(GL_FRAMEBUFFER, _fboHandle);
	glBindTexture(GL_TEXTURE_2D, _fboTexId);
	glTexImage2D(GL_TEXTURE_2D,
				 0,
				 GL_RGBA,
				 sizeFbo.width, sizeFbo.height,
				 0,
				 GL_RGBA,
				 GL_UNSIGNED_BYTE,
				 NULL);
	// テクスチャの補間をしない
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
						   GL_TEXTURE_2D, _fboTexId, 0);
	glBindRenderbuffer(GL_RENDERBUFFER, _fboDepthBuffer);
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16_OES, sizeFbo.width, sizeFbo.height);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _fboDepthBuffer);
	GLenum status;
	status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status) {
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"fbo complete");
            break;
            
        case GL_FRAMEBUFFER_UNSUPPORTED:
            NSLog(@"fbo unsupported");
            break;
            
        default:
            /* programming error; will fail on all hardware */
            NSLog(@"Framebuffer Error");
            break;
    }
	glBindFramebuffer(GL_FRAMEBUFFER, sDefaultFbo);
	
	_fboShader = [[SimpleFboShader alloc] init];
	[_fboShader loadShaderWithVsh:@"ShaderSimpleFbo" withFsh:@"ShaderSimpleTexture"];
	_fboVArray = [[FboTextureBuffer alloc] init];
	[_fboVArray loadResourceWithName:nil];
}

- (void)changeRenderTargetToFBO
{
	glBindTexture(GL_TEXTURE_2D, 0);
	glEnable(GL_TEXTURE_2D);
	glBindFramebuffer(GL_FRAMEBUFFER, _fboHandle);
	glViewport(0, 0, sizeFbo.width, sizeFbo.height);
	glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}


@end
