//
//  SMLearn3DVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/1/20.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMLearn3DVC.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>
#import "SMShaderCompiler.h"
#import "SMMath.h"

@interface SMLearn3DVC () <GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) SMShaderCompiler *compiler;

@end

@implementation SMLearn3DVC {
    GLuint _VAO, _VBO, _EBO, _smileTexture, _boxTexture;
}

- (void)loadView {
    [super loadView];
    
    self.view = self.glkView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupShaders];
    [self setupTextures];
    [self setupVAOAndVBOAndEBO];
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.delegate = self;
}

- (void)setupShaders {
    self.compiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMLearn3D.vsh" fragment:@"SMLearn3D.fsh"];
}

- (void)setupTextures {
    
    glGenTextures(1, &_boxTexture);
    glBindTexture(GL_TEXTURE_2D, _boxTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    GLubyte *boxTextureData = [self textureData:@"box.jpg"];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)[self imageRefWidth:@"box.jpg"], (GLsizei)[self imageRefWidth:@"box.jpg"], 0, GL_RGBA, GL_UNSIGNED_BYTE, boxTextureData);
    free(boxTextureData);
    
    
    glGenTextures(1, &_smileTexture);
    glBindTexture(GL_TEXTURE_2D, _smileTexture);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

    GLubyte *smileTextureData = [self textureData:@"smile.png"];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)[self imageRefWidth:@"smile.png"], (GLsizei)[self imageRefWidth:@"smile.png"], 0, GL_RGBA, GL_UNSIGNED_BYTE, smileTextureData);
    
    free(smileTextureData);
}

- (CGImageRef)imageRef:(NSString *)imageName {
    return [[UIImage imageNamed:imageName] CGImage];
}

- (size_t)imageRefWidth:(NSString *)imageName {
    return CGImageGetWidth([self imageRef:imageName]);
}

- (size_t)imageRefHeight:(NSString *)imageName {
    return CGImageGetHeight([self imageRef:imageName]);
}

- (GLubyte *)textureData:(NSString *)imageName {
    size_t width = [self imageRefWidth:imageName];
    size_t height = [self imageRefHeight:imageName];
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
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self imageRef:imageName]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return textureData;
}

- (void)setupVAOAndVBOAndEBO {
    
    float vertices[] = {
        0.5f,  0.25f, 0.0f, 1.0f, 1.0f,
        0.5f, -0.25f, 0.0f, 1.0f, 0.0f,
       -0.5f, -0.25f, 0.0f, 0.0f, 0.0f,
       -0.5f,  0.25f, 0.0f, 0.0f, 1.0f
    };
    
    GLuint indices[] = {
        0, 1, 3,
        1, 2, 3
    };
    
    glGenVertexArrays(1, &_VAO);
    glGenBuffers(1, &_VBO);
    glGenBuffers(1, &_EBO);
    
    glBindVertexArray(_VAO);
    
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void*)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
}

- (void)startRender {
    
    glClearColor(0.7, 0.5, 0.2, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _boxTexture);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _smileTexture);
    
    [self.compiler userProgram];
    
    int boxLocation = glGetUniformLocation(self.compiler.program, "boxTexture");
    glUniform1i(boxLocation, 0);
    
    int smileLocation = glGetUniformLocation(self.compiler.program, "smileTexture");
    glUniform1i(smileLocation, 1);
    
    GLfloat model[] = {
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 3.0,
        0.0, 0.0, 0.0, 1.0
    };
    
    glUniformMatrix4fv(glGetUniformLocation(self.compiler.program, "modelMatrix"), 1, GL_FALSE, (GLfloat *)&model[0]);
    
    GLfloat view[] = {
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 3.0,
        0.0, 0.0, 0.0, 1.0
    };
    glUniformMatrix4fv(glGetUniformLocation(self.compiler.program, "viewMatrix"), 1, GL_FALSE, (GLfloat *)&view[0]);
    
    GLfloat project[] = {
        1.0, 0.0, 0.0,  0.0,
        0.0, 1.0, 0.0,  0.0,
        0.0, 0.0, 1.0, -3.0,
        0.0, 0.0, 0.0,  1.0
    };
    glUniformMatrix4fv(glGetUniformLocation(self.compiler.program, "projectMatrix"), 1, GL_FALSE, (GLfloat *)&project[0]);
    
    
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
