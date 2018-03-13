//
//  SMCameraView.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/3/8.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMCameraView.h"
#import <OpenGLES/ES3/gl.h>
#import "SMShaderCompiler.h"
#import <AVFoundation/AVFoundation.h>
#import "GLESMath.h"

const float kColorConversion601FullRange[] = {
    1.0,    1.0,    1.0,
    0.0,    -0.343, 1.765,
    1.4,    -0.711, 0.0,
};

@implementation SMCameraView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    SMShaderCompiler *_compiler;
    GLuint _renderBuffer, _frameBuffer, _VAO, _VBO, _EBO;
    GLint _frameWidth, _frameHeight;
    
    CVOpenGLESTextureRef _lumaTexture;
    CVOpenGLESTextureRef _chromaTexture;
    CVOpenGLESTextureCacheRef _videoTextureCache;
}

#pragma mark - Initialization Functions

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupInitializations];
    }
    return self;
}

#pragma mark - Override Funcrtions

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - Public Functions

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer != NULL) {
        
        if (_videoTextureCache == NULL) {
            NSLog(@"No Video Texture Cache!!");
            return;
        }
        
        if ([EAGLContext currentContext] != _context) {
            [EAGLContext setCurrentContext:_context];
        }
        
        [self cleanUpTextures];
        
        int frameWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int frameHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        [self cleanUpTextures];
        
        glActiveTexture(GL_TEXTURE0);
        CVReturn lumaTextureResult = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoTextureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_LUMINANCE,
                                                           frameWidth,
                                                           frameHeight,
                                                           GL_LUMINANCE,
                                                           GL_UNSIGNED_BYTE,
                                                           0,
                                                           &_lumaTexture);
        if (lumaTextureResult) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", lumaTextureResult);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        // UV-plane.
        glActiveTexture(GL_TEXTURE1);
        CVReturn chromaTextureResult = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                           _videoTextureCache,
                                                           pixelBuffer,
                                                           NULL,
                                                           GL_TEXTURE_2D,
                                                           GL_LUMINANCE_ALPHA,
                                                           frameWidth / 2,
                                                           frameHeight / 2,
                                                           GL_LUMINANCE_ALPHA,
                                                           GL_UNSIGNED_BYTE,
                                                           1,
                                                           &_chromaTexture);
        if (chromaTextureResult) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", chromaTextureResult);
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    }
    [self startRender];
}

#pragma mark - Private Functions

- (void)setupInitializations {
    
    [self setupLayer];
    [self setupContext];
    [self clearRenderFrameBuffers];
    [self setupRenderFrameBuffers];
    [self setupViewPortWidthHeight];
    [self setupShaders];
    [self setupObjects];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                       kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8};
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_context];
}

- (void)clearRenderFrameBuffers {
    if (_renderBuffer) {
        glDeleteBuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_frameBuffer) {
        glDeleteBuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (void)setupRenderFrameBuffers {
    if (!_renderBuffer) {
        glGenRenderbuffers(1, &_renderBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    }
    
    if (!_frameBuffer) {
        glGenFramebuffers(1, &_frameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    }
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupViewPortWidthHeight {
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_frameWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_frameHeight);
    glViewport(0, 0, _frameWidth, _frameHeight);
}

- (void)setupShaders {
    _compiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMCamera.vsh" fragment:@"SMCamera.fsh"];
    [_compiler userProgram];
    
    glUniform1i(glGetUniformLocation(_compiler.program, "SamplerY"), 0);
    glUniform1i(glGetUniformLocation(_compiler.program, "SamplerUV"), 1);
    glUniformMatrix3fv(glGetUniformLocation(_compiler.program, "colorConversionMatrix"), 1, GL_FALSE, kColorConversion601FullRange);
    
    if (!_videoTextureCache) {
        CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, _context, NULL, &_videoTextureCache);
        if (err != noErr) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
            return;
        }
    }
    
}

- (void)setupObjects {
    
    float vertices[] = {
         1.0,  1.0, 0.0, 1.0, 1.0,
         1.0, -1.0, 0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0, 0.0, 0.0,
        -1.0,  1.0, 0.0, 0.0, 1.0
    };
    
    GLuint indices[] = {
        0, 1, 3,
        1, 2, 3
    };
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
}

- (void)startRender {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        glClearColor(1.0, 1.0, 1.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT);
        
        glBindVertexArray(_VAO);
        [_compiler userProgram];
        
        glUniform1i(glGetUniformLocation(_compiler.program, "SamplerY"), 0);
        glUniform1i(glGetUniformLocation(_compiler.program, "SamplerUV"), 1);
        glUniformMatrix3fv(glGetUniformLocation(_compiler.program, "colorConversionMatrix"), 1, GL_FALSE, kColorConversion601FullRange);
        
        glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
        
        [_context presentRenderbuffer:GL_RENDERER];
    });
}

- (void)clearObjects {
    glDeleteBuffers(1, &_VBO);
    glDeleteBuffers(1, &_EBO);
    glDeleteVertexArrays(1, &_VAO);
}

- (void)cleanUpTextures {
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)dealloc {
    NSLog(@"SMCameraView Dealloc!!");
    [self clearObjects];
    [self cleanUpTextures];
    [self clearRenderFrameBuffers];
}

@end
