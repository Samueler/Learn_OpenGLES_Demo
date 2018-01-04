//
//  ViewController.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/4.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "ViewController.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

const float vertices[] = {
    -0.5, -0.5, 0,
     0.5, -0.5, 0,
     0.0,  0.5, 0
};

char vShaderStr[] =
"#version 300 es                                \n"
"layout (location = 0) in vec4 vPosition;       \n"
"out vec4 fragColor;                            \n"
"void main()                                    \n"
"{                                              \n"
"   gl_Position = vPosition;                    \n"
"}                                              \n";

char fShaderStr[] =
"#version 300 es                                \n"
"precision mediump float;                       \n"
"out vec4 fragColor;                            \n"
"void main()                                    \n"
"{                                              \n"
"   fragColor = vec4(1.0, 0, 0, 1.0);           \n"
"}                                              \n";

@interface ViewController () <GLKViewDelegate>

@property(nonatomic, strong) EAGLContext *context;

@property(nonatomic, assign) GLuint vShader;
@property(nonatomic, assign) GLuint fShader;
@property(nonatomic, assign) GLuint program;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!self.context)
    {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableColorFormatRGBA8888;
    view.backgroundColor = [UIColor whiteColor];
    view.delegate = self;
    [EAGLContext setCurrentContext:self.context];
    
    [self setupViewPort];
    
    [self setupShader];
    
    [self setupProgram];
    
    [self deleteShaders];
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)setupViewPort {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)setupShader {
    self.vShader = [self createShader:GL_VERTEX_SHADER source:vShaderStr];
    self.fShader = [self createShader:GL_FRAGMENT_SHADER source:fShaderStr];
}

- (GLuint)createShader:(GLenum)shaderType source:(const char *)source {
    
    // 创建shader
    GLuint shader = glCreateShader(shaderType);
    
    // 绑定shader源码
    glShaderSource(shader, 1, &source, NULL);
    // 编译着色器
    glCompileShader(shader);
    
    // 获取编译着色器失败的相关消息
    int result;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &result);
    if (!result) {
        GLint infoLen = 0;
        glGetShaderiv(shaderType, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shaderType, infoLen, NULL, infoLog);
            NSLog(@"Error compiling shader:%@", [NSString stringWithUTF8String:infoLog]);
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

- (void)setupProgram {
    self.program = glCreateProgram();
    
    glAttachShader(self.program, self.vShader);
    glAttachShader(self.program, self.fShader);
    glLinkProgram(self.program);
    
    int linkResult;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkResult);
    
    if (linkResult == GL_FALSE) {
        GLchar message[256];
        glGetProgramInfoLog(self.program, sizeof(message), 0, message);
        NSLog(@"Program link failure:%@", [NSString stringWithUTF8String:message]);
        exit(1);
    }
}

- (void)deleteShaders {
    glDeleteShader(self.vShader);
    glDeleteShader(self.fShader);
}

- (void)setupRenderBuffers {
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    glUseProgram(self.program);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self setupRenderBuffers];
}

@end
