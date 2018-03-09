//
//  SMFilterView.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/2/25.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMFilterView.h"
#import <OpenGLES/ES3/gl.h>
#import "SMShaderCompiler.h"

@implementation SMFilterView {
    NSString *_filterName;
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _renderBuffer, _frameBuffer, _texture, _VAO, _VBO, _EBO;
    SMShaderCompiler *_compiler;
}

#pragma mark - Initializations

- (instancetype)initWithFrame:(CGRect)frame filter:(NSString *)filterName {
    if (self = [super initWithFrame:frame]) {
        
        _filterName = filterName;
        
        [self setupLayer];
        [self setupContext];
        [self clearRenderBuffers];
        [self setupRenderBuffers];
        [self setupShaders];
        [self setupTexture];
        [self setupVAOAndVBO];
    }
    return self;
}

#pragma mark - Override Functions

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self startRender];
}

#pragma mark - Private Functions

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_context];
}

- (void)clearRenderBuffers {
    if (_renderBuffer) {
        glDeleteRenderbuffers(1, &_renderBuffer);
        _renderBuffer = 0;
    }
    
    if (_frameBuffer) {
        glDeleteRenderbuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (void)setupRenderBuffers {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupShaders {
    _compiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMLearnFilter.vsh" fragment:[NSString stringWithFormat:@"%@.fsh", _filterName]];
}

- (void)setupTexture {
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    
    UIImage *image = [UIImage imageNamed:@"lyf.jpg"];
    CGImageRef imageRef = [image CGImage];
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    GLubyte *textureData = (GLubyte *)malloc(width * height * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    glGenerateMipmap(GL_TEXTURE_2D);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(textureData);
}

- (void)setupVAOAndVBO {
    float vertices[] = {
         1.0,  0.65, 0.0, 1.0, 1.0,
         1.0, -0.65, 0.0, 1.0, 0.0,
        -1.0, -0.65, 0.0, 0.0, 0.0,
        -1.0,  0.65, 0.0, 0.0, 1.0
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
    glClearColor(0.3, 0.8, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    glBindVertexArray(_VAO);
    glBindTexture(GL_TEXTURE_2D, _texture);
    [_compiler userProgram];
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
