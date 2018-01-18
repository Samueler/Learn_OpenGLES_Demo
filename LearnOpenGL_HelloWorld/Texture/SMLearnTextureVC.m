//
//  SMLearnTextureVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/16.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMLearnTextureVC.h"
#import "SMShaderCompiler.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

@interface SMLearnTextureVC () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) SMShaderCompiler *shaderCompiler;

@end

@implementation SMLearnTextureVC {
    GLuint _VAO, _VBO, _EBO, _texture;
}

- (void)loadView {
    [super loadView];
    
    self.view = self.glkView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupContext];
    [self setupShaders];
    [self setupTextureFromImage:[UIImage imageNamed:@"kobe.jpg"]];
    [self setupVAOAndVBOAndEBO];
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableColorFormatRGBA8888;
    view.delegate = self;
}

- (void)setupShaders {
    self.shaderCompiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMTexture.vsh" fragment:@"SMTexture.fsh"];
}

- (void)setupTextureFromImage:(UIImage *)image {
    glEnable(GL_TEXTURE_2D);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    
    
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

- (void)activeTexture {
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _texture);
    GLint location = glGetUniformLocation(_shaderCompiler.program, "ourTexture");
    glUniform1f(location, 5);
}

- (void)setupVAOAndVBOAndEBO {
    
    float vertices[] = {
        // location    // colors       // texture
        1.0,  0.5, 0,  1.0, 0.0, 0.0,  1.0, 1.0,
        1.0, -0.5, 0,  0.0, 1.0, 0.0,  1.0, 0.0,
       -1.0, -0.5, 0,  0.0, 0.0, 1.0,  0.0, 0.0,
       -1.0,  0.5, 0,  1.0, 1.0, 1.0,  0.0, 1.0
    };
    
    GLuint indices[] = {
        0, 1, 3,
        1, 2, 3
    };
    
    glGenVertexArrays(1, &(_VAO));
    glBindVertexArray(_VAO);
    
    glGenBuffers(1, &(_VBO));
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &(_EBO));
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
    
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *)(6 * sizeof(float)));
    glEnableVertexAttribArray(2);
}

- (void)startRender {
    
    glClearColor(0.2, 0.5, 0.8, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindTexture(GL_TEXTURE_2D, _texture);
    [self.shaderCompiler userProgram];
    glBindVertexArray(_VAO);
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self startRender];
}

#pragma mark - Lazy Load

- (GLKView *)glkView {
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:self.view.bounds];
    }
    return _glkView;
}

@end
