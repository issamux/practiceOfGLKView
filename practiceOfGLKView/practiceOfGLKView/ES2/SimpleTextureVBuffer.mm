//
//  SimpleTextureBuffer.m
//  practiceOfGLKView
//
//  Created by nakano_michiharu on 9/17/13.
//  Copyright (c) 2013 nakano_michiharu. All rights reserved.
//

#import "SimpleTextureVBuffer.h"
#include "gameDefs.h"
enum {
	_VERTEX_ATTRIB_POSITION = 0,
	_VERTEX_ATTRIB_TEXCOORD,
};


@interface SimpleTextureVBuffer()
{
}
@end

@implementation SimpleTextureVBuffer

-(void)setParamOfVertex:(SIMPLE_TEXTURE_VERTEX*)vertex ofX:(float)x ofY:(float)y
					ofZ:(float)z ofS:(float)s ofT:(float)t
{
	vertex->x = x;
	vertex->y = y;
	vertex->z = z;
	vertex->s = s;
	vertex->t = t;
}


- (id)init
{
	self = [super init];
	if (self != nil) {
		CGSize screenSize = [VArrayBase getScreenSize];
		const float textureSize = 16.0f;
		float width = textureSize / screenSize.width;
		float height = textureSize / screenSize.height;
		{
			// 頂点座標をテクスチャサイズにあわせる
			[self setParamOfVertex:&_texSquare[0] ofX:-width ofY:height ofZ:0.0f
							   ofS:0.0f ofT:0.0f];
			
			[self setParamOfVertex:&_texSquare[1] ofX:width ofY:height ofZ:0.0f
							   ofS:1.0f ofT:0.0f];
			
			[self setParamOfVertex:&_texSquare[2] ofX:-width ofY:-height ofZ:0.0f
							   ofS:0.0f ofT:1.0f];
			
			[self setParamOfVertex:&_texSquare[3] ofX:width ofY:-height ofZ:0.0f
							   ofS:1.0f ofT:1.0f];
		}
		
	}
	return self;
}

-(void)setupVerticesByTexSize:(CGSize)sizeTexture withRenderBufferSize:(CGSize)sizeRenderBuf
{
	float width = sizeTexture.width / sizeRenderBuf.width;
	float height = sizeTexture.height / sizeRenderBuf.height;
	// 頂点座標をテクスチャサイズにあわせる
	[self setParamOfVertex:&_texSquare[0] ofX:-width ofY:height ofZ:0.0f
					   ofS:0.0f ofT:0.0f];
	
	[self setParamOfVertex:&_texSquare[1] ofX:width ofY:height ofZ:0.0f
					   ofS:1.0f ofT:0.0f];
	
	[self setParamOfVertex:&_texSquare[2] ofX:-width ofY:-height ofZ:0.0f
					   ofS:0.0f ofT:1.0f];
	
	[self setParamOfVertex:&_texSquare[3] ofX:width ofY:-height ofZ:0.0f
					   ofS:1.0f ofT:1.0f];
}



-(BOOL)loadResourceWithName:(NSString*)strNameOfResource
{
	BOOL result = NO;
	@try {
		// 構造体サイズが20バイトでない場合はこのコードを使えません
		assert((sizeof(_texSquare[0]) == 20));
		glGenVertexArraysOES(1, &_vertexArray);
		glBindVertexArrayOES(_vertexArray);
		{
			for (int indexVet = 0; indexVet < _SIMPLETEXTV_NUM_VERTICES; indexVet++) {
				//dbgLog(@"[%d] x:%f,  y:%f,  z:%f", indexVet, _texSquare[indexVet].x, _texSquare[indexVet].y, _texSquare[indexVet].z);
				//dbgLog(@"[%d] s:%f, t:%f", indexVet, _texSquare[indexVet].s, _texSquare[indexVet].t);
			}
			glGenBuffers(1, &_vertexBuffer);
			glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
			glBufferData(GL_ARRAY_BUFFER, sizeof(_texSquare), _texSquare, GL_DYNAMIC_DRAW);
			glEnableVertexAttribArray(_VERTEX_ATTRIB_POSITION);
			glEnableVertexAttribArray(_VERTEX_ATTRIB_TEXCOORD);
			glVertexAttribPointer(_VERTEX_ATTRIB_POSITION, 3, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(0));
			glVertexAttribPointer(_VERTEX_ATTRIB_TEXCOORD, 2, GL_FLOAT, GL_FALSE, 20, BUFFER_OFFSET(12));
	
		}
		glBindVertexArrayOES(0);
		
		_count = _SIMPLETEXTV_NUM_VERTICES;
	}
	@catch (NSException *exception) {
		assert(false);
	}
	return result;
}

@end
