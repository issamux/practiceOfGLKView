//
//  ShaderBase.m
//  practiceOfGLKView
//
//  Created by nakano_michiharu on 2013/09/15.
//  Copyright (c) 2013年 nakano_michiharu. All rights reserved.
//

#import "ShaderBase.h"

@interface ShaderBase()
{
	GLint _uniforms[NUM_UNIFORMS];
}
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;

@end

@implementation ShaderBase
@synthesize programId = _programId;

- (id)init
{
	self = [super init];
	if (self != nil) {
		_programId = 0;
		for (int index = 0; index < (sizeof(_uniforms) / sizeof(_uniforms[0])); index++) {
			_uniforms[index] = -1;
		}
	}
	return self;
}

- (void)dealloc
{
	if (self.programId != 0) {
		glDeleteProgram(_programId);
		_programId = 0;
	}
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[super dealloc];
}

- (GLint) getUniformIndex: (int) index
{
	int result = -1;
	if ((index >= 0) && (index < (sizeof(_uniforms) / sizeof(_uniforms[0])))) {
		result = _uniforms[index];
	}
	return result;
}


- (BOOL)loadShaderWithVsh: (NSString*)vshFile withFsh:(NSString*)fshFile
{
	BOOL result = NO;
	@try {
		assert(_programId == 0);
		GLuint vertShader, fragShader;
		NSString *vertShaderPathname, *fragShaderPathname;
		
		// Create shader program.
		_programId = glCreateProgram();
		
		// Create and compile vertex shader.
		vertShaderPathname = [[NSBundle mainBundle] pathForResource:vshFile ofType:@"vsh"];
		if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
			NSLog(@"Failed to compile vertex shader");
			return NO;
		}
		
		// Create and compile fragment shader.
		fragShaderPathname = [[NSBundle mainBundle] pathForResource:fshFile ofType:@"fsh"];
		if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
			NSLog(@"Failed to compile fragment shader");
			return NO;
		}
		
		// Attach vertex shader to program.
		glAttachShader(_programId, vertShader);
		
		// Attach fragment shader to program.
		glAttachShader(_programId, fragShader);
#warning -TODO
		// TODO "position"などの名前は固定にしない。
		// 呼び出し側からのテーブル設定か、シェーダーの解析にする
		// Bind attribute locations.
		// This needs to be done prior to linking.
		glBindAttribLocation(_programId, ATTRIB_VERTEX, "position");
		glBindAttribLocation(_programId, ATTRIB_NORMAL, "normal");
		
		// Link program.
		if (![self linkProgram:_programId]) {
			NSLog(@"Failed to link program: %d", _programId);
			
			if (vertShader) {
				glDeleteShader(vertShader);
				vertShader = 0;
			}
			if (fragShader) {
				glDeleteShader(fragShader);
				fragShader = 0;
			}
			if (_programId) {
				glDeleteProgram(_programId);
				_programId = 0;
			}
			
			return NO;
		}
		
		// Get uniform locations.
		_uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_programId, "modelViewProjectionMatrix");
		_uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_programId, "normalMatrix");
		
		// Release vertex and fragment shaders.
		if (vertShader) {
			glDetachShader(_programId, vertShader);
			glDeleteShader(vertShader);
		}
		if (fragShader) {
			glDetachShader(_programId, fragShader);
			glDeleteShader(fragShader);
		}
		result = YES;
	}
	@catch (NSException *exception) {
		
	}

	return result;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}



@end
