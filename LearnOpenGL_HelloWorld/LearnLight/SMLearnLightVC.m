//
//  SMLearnLightVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/2/1.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMLearnLightVC.h"
#import <OpenGLES/ES3/gl.h>
#import "SMShaderCompiler.h"
#import "GLESMath.h"
#import <GLKit/GLKit.h>

@interface SMLearnLightVC () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) SMShaderCompiler *lightCompiler;
@property (nonatomic, strong) SMShaderCompiler *boxCompiler;

@end

@implementation SMLearnLightVC {
    GLuint _lightVAO, _boxVAO, _VBO;
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
    [self setupVAOAndVBO];
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
    self.lightCompiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMLearnLight.vsh" fragment:@"SMLearnLight.fsh"];
    self.boxCompiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMLearnLightBox.vsh" fragment:@"SMLearnLightBox.fsh"];
}

- (void)setupVAOAndVBO {
    
    float vertices[] = {
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f, -0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        
        -0.5f, -0.5f, -0.5f,
        0.5f, -0.5f, -0.5f,
        0.5f, -0.5f,  0.5f,
        0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f,  0.5f,
        -0.5f, -0.5f, -0.5f,
        
        -0.5f,  0.5f, -0.5f,
        0.5f,  0.5f, -0.5f,
        0.5f,  0.5f,  0.5f,
        0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f,  0.5f,
        -0.5f,  0.5f, -0.5f,
    };
    
    glGenVertexArrays(1, &_lightVAO);
    glBindVertexArray(_lightVAO);
    
    glGenBuffers(1, &_VBO);
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glGenVertexArrays(1, &_boxVAO);
    glBindVertexArray(_boxVAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
}

- (void)startRender {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3, 0.1, 0.5, 1.0);
    
    [self.lightCompiler userProgram];
    
    KSMatrix4 _lightModelMatrix, _lightViewMatrix, _lightProjectMatrix, _boxModelMatrix, _boxViewMatrix, _boxProjectMatrix;
    
    ksMatrixLoadIdentity(&_lightModelMatrix);
    ksMatrixLoadIdentity(&_lightViewMatrix);
    ksMatrixLoadIdentity(&_lightProjectMatrix);
    ksMatrixLoadIdentity(&_boxModelMatrix);
    ksMatrixLoadIdentity(&_boxViewMatrix);
    ksMatrixLoadIdentity(&_boxProjectMatrix);
    
    ksPerspective(&_lightProjectMatrix, 45.0, self.view.bounds.size.width / self.view.bounds.size.width, 0.1, 100.0);
    ksRotate(&_lightModelMatrix, 30.0, 0.5, 1.0, 0);
    ksScale(&_lightModelMatrix, 0.3, 0.3, 0.3);
    ksTranslate(&_lightViewMatrix, 0.8, 0.5, -3.0);
    
    glUniformMatrix4fv(glGetUniformLocation(self.lightCompiler.program, "projectMatrix"), 1, GL_FALSE, (GLfloat *)&_lightProjectMatrix.m[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(self.lightCompiler.program, "viewMatrix"), 1, GL_FALSE, (GLfloat *)&_lightViewMatrix.m[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(self.lightCompiler.program, "modelMatrix"), 1, GL_FALSE, (GLfloat *)&_lightModelMatrix.m[0][0]);
    
    glBindVertexArray(_lightVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    [self.boxCompiler userProgram];
    
    ksPerspective(&_boxProjectMatrix, 45.0, self.view.bounds.size.width / self.view.bounds.size.width, 0.1, 100.0);
    ksRotate(&_boxModelMatrix, 45.0, 0.4, 1.0, 0);
    ksTranslate(&_boxViewMatrix, 0.0, 0.0, -5.0);
    
    glUniformMatrix4fv(glGetUniformLocation(self.boxCompiler.program, "projectMatrix"), 1, GL_FALSE, (GLfloat *)&_boxProjectMatrix.m[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(self.boxCompiler.program, "viewMatrix"), 1, GL_FALSE, (GLfloat *)&_boxViewMatrix.m[0][0]);
    glUniformMatrix4fv(glGetUniformLocation(self.boxCompiler.program, "modelMatrix"), 1, GL_FALSE, (GLfloat *)&_boxModelMatrix.m[0][0]);
    
    glUniform3f(glGetUniformLocation(self.boxCompiler.program, "lightColor"), 1.0, 1.0, 1.0);
    glUniform3f(glGetUniformLocation(self.boxCompiler.program, "boxColor"), 1.0, 0.5, 0.3);
    
    glBindVertexArray(_boxVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
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
