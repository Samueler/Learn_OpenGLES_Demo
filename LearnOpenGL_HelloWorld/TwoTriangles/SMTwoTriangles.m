//
//  SMTwoTriangles.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/8.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMTwoTriangles.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>


float firstTriangle[] = {
    -0.9, -0.5, 0,
    0.0, -0.5, 0,
    -0.45, 0.5, 0
};

float secondTriangle[] = {
    0.0, -0.5, 0,
    0.9, -0.5, 0,
    0.45, 0.5, 0
};

@interface SMTwoTriangles () <GLKViewDelegate> {
    GLuint VAOs[2], VBOs[2];
}

@property (nonatomic, strong) GLKView *glkView;

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, assign) GLuint vShader;
@property (nonatomic, assign) GLuint fShader;
@property (nonatomic, assign) GLuint program;

@end

@implementation SMTwoTriangles

- (void)loadView {
    
    [super loadView];
    
    self.view = self.glkView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupOpenGLContext];
    
    [self setupShader];
    
    [self linkShaders];
    
    [self deleteShaders];
    
    [self setupVAOAndVBO];
}

- (void)setupOpenGLContext {
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:self.context];
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableColorFormatRGBA8888;
    view.delegate = self;
}

- (void)setupShader {
    self.vShader = [self setupShader:GL_VERTEX_SHADER source:@"SMVertice.vsh"];
//    self.fShader = [self setupShader:GL_FRAGMENT_SHADER source:@"SMFragment.fsh"];
    // 使用Unifom
    self.fShader = [self setupShader:GL_FRAGMENT_SHADER source:@"SMUniform.fsh"];
}

- (GLuint)setupShader:(GLenum)shaderType source:(NSString *)sourceFileName {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:sourceFileName ofType:nil];
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    const char *shaderUTF8 = [shaderString UTF8String];
    
    GLuint shader = glCreateShader(shaderType);
    
    glShaderSource(shader, 1, &shaderUTF8, NULL);
    glCompileShader(shader);
    
    GLint compileResult = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
    
    if (compileResult == GL_FALSE) {
        GLint infoLen = 0;
        
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            
            NSLog(@"Shader Compiling Error:%@", [NSString stringWithUTF8String:infoLog]);
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        
        return 0;
    }
    
    return shader;
}

- (void)linkShaders {
    
    self.program = glCreateProgram();
    
    glAttachShader(_program, self.vShader);
    glAttachShader(_program, self.fShader);
    
    glLinkProgram(_program);
    
    GLint linkResult = 0;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkResult);
    
    if (linkResult == GL_FALSE) {
        
        GLint infoLen = 0;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen) {
            char *infoLog = malloc(sizeof(char) * linkResult);
            glGetProgramInfoLog(_program, infoLen, NULL, infoLog);
            
            NSLog(@"Program Link Shaders Failure:%@", [NSString stringWithUTF8String:infoLog]);
            
            exit(1);
        }
    }
}

- (void)deleteShaders {
    glDeleteShader(self.vShader);
    glDeleteShader(self.fShader);
}

- (void)setupVAOAndVBO {
    
    glGenVertexArrays(2, VAOs);
    glGenBuffers(2, VBOs);
    
    glBindVertexArray(VAOs[0]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(firstTriangle), &firstTriangle, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glBindVertexArray(VAOs[1]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(secondTriangle), &secondTriangle, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
}

- (void)render {
    
    glClearColor(1, 1, 1, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program);
    
    // 使用uniform
    int vertexColorLoaction = glGetUniformLocation(self.program, "ourColor");
    glUniform4f(vertexColorLoaction, 0.4, 0.3, 0.6, 1);
    
    glBindVertexArray(VAOs[0]);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    glBindVertexArray(VAOs[1]);
    glBindBuffer(GL_ARRAY_BUFFER, VBOs[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(secondTriangle), &secondTriangle, GL_STATIC_DRAW);
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self render];
}

#pragma mark - Lazy Load

- (GLKView *)glkView {
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:self.view.bounds];
    }
    return _glkView;
}

@end
