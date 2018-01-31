//
//  SMTenBoxesVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/31.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMTenBoxesVC.h"
#import <GLKit/GLKit.h>
#import "SMShaderCompiler.h"
#import "GLESMath.h"

@interface SMTenBoxesVC () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) SMShaderCompiler *shaderCompiler;
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation SMTenBoxesVC {
    GLuint _boxTexture, _smileTexture, _VAO, _VBO;
}

- (void)loadView {
    [super loadView];
    
    self.view = self.glkView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self openZBuffer];
    [self setupShaders];
    [self setupTextures];
    [self setupVAOAndVBOAndEBO];
}

#pragma mark - Render Functions

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.delegate = self;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
}

- (void)openZBuffer {
    glEnable(GL_DEPTH_TEST);
}

- (void)setupShaders {
    self.shaderCompiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMTenBoxes.vsh" fragment:@"SMTenBoxes.fsh"];
}

- (void)setupTextures {
    
    glGenTextures(1, &_boxTexture);
    glBindTexture(GL_TEXTURE_2D, _boxTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    [self setupTextureData:@"box.jpg"];
    
    glGenTextures(1, &_smileTexture);
    glBindTexture(GL_TEXTURE_2D, _smileTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_LINEAR);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    [self setupTextureData:@"smile.png"];
}

- (void)setupTextureData:(NSString *)imageName {
    CGImageRef imageRef = [[UIImage imageNamed:imageName] CGImage];
    size_t imageW = CGImageGetWidth(imageRef);
    size_t imageH = CGImageGetHeight(imageRef);
    
    GLubyte *textureData = (GLubyte *)malloc(imageW * imageH * 4);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * imageW;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(textureData, imageW, imageH,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, imageH);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGContextDrawImage(context, CGRectMake(0, 0, imageW, imageH), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)imageW, (GLsizei)imageH, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    free(textureData);
}

- (void)setupVAOAndVBOAndEBO {
    
    float vertices[] = {
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 0.0f,
        
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 1.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        0.5f, -0.5f, -0.5f,  1.0f, 1.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        0.5f, -0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f, -0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f, -0.5f, -0.5f,  0.0f, 1.0f,
        
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f,
         0.5f,  0.5f, -0.5f,  1.0f, 1.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        0.5f,  0.5f,  0.5f,  1.0f, 0.0f,
        -0.5f,  0.5f,  0.5f,  0.0f, 0.0f,
        -0.5f,  0.5f, -0.5f,  0.0f, 1.0f
    };
    
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), &vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (void *)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);
}

- (void)startRender {
    
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.4, 0.5, 0.7, 1);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _boxTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _smileTexture);
    
    [self.shaderCompiler userProgram];
    
    int boxLocation = glGetUniformLocation(self.shaderCompiler.program, "boxTexture");
    glUniform1i(boxLocation, 0);
    
    int smileLocation = glGetUniformLocation(self.shaderCompiler.program, "smileTexture");
    glUniform1i(smileLocation, 1);
    
    
    KSMatrix4 _viewMatrix, _projectMatrix;
    ksMatrixLoadIdentity(&_viewMatrix);
    ksMatrixLoadIdentity(&_projectMatrix);
    
    ksTranslate(&_viewMatrix, 0, 0, -5);
    
    float aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    ksPerspective(&_projectMatrix, 45.0, aspect, 0.1, 100);
    
    glUniformMatrix4fv(glGetUniformLocation(self.shaderCompiler.program, "viewMatrix"), 1, GL_FALSE, (GLfloat *)&_viewMatrix.m[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(self.shaderCompiler.program, "projectMatrix"), 1, GL_FALSE, (GLfloat *)&_projectMatrix.m[0][0]);
    
    glBindVertexArray(_VAO);
    
    float pos[10][3] = {
        0.0f,  0.0f,  0.0f,
        2.0f,  5.0f, -15.0f,
        -1.5f, -2.2f, -2.5f,
        -3.8f, -2.0f, -12.3f,
        2.4f, -0.4f, -3.5f,
        -1.7f,  3.0f, -7.5f,
        1.3f, -2.0f, -2.5f,
        1.5f,  2.0f, -2.5f,
        1.5f,  0.2f, -1.5f,
        -1.3f,  1.0f, -1.5f
    };
    
    for (NSInteger idx = 0; idx < 10; idx++) {
        KSMatrix4 _modelMatrix;
        ksMatrixLoadIdentity(&_modelMatrix);
        
        ksTranslate(&_modelMatrix, pos[idx][0], pos[idx][1], pos[idx][2]);
        ksRotate(&_modelMatrix, 10 * idx, 1, 0.3, 0.5);
        
        glUniformMatrix4fv(glGetUniformLocation(self.shaderCompiler.program, "modelMatrix"), 1, GL_FALSE, (GLfloat *)&_modelMatrix.m[0][0]);
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
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
