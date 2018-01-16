//
//  SMLearnShaderVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/15.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMLearnShaderVC.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

@interface SMLearnShaderVC () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, assign) GLuint vShader;
@property (nonatomic, assign) GLuint fShader;
@property (nonatomic, assign) GLuint program;

@end

@implementation SMLearnShaderVC {
    GLuint _VAO, _VBO;
}

- (void)loadView {
    
    [super loadView];
    
    self.view = self.glkView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupContext];
    [self setupShaders];
    [self setupLinkShaders];
    [self deleteShaders];
    [self setupVAOAndVBO];
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
    self.vShader = [self setupShader:GL_VERTEX_SHADER sourceFileName:@"SMLearnShader.vsh"];
    self.fShader = [self setupShader:GL_FRAGMENT_SHADER sourceFileName:@"SMLearnShader.fsh"];
}

- (GLuint)setupShader:(GLenum)shaderType sourceFileName:(NSString *)fileName {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSError *error = nil;
    NSString *sourceString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Get Shader Source String Failure:%@", error.localizedDescription);
        return 0;
    }
    
    const char *UTF8SourceStr = [sourceString UTF8String];
    
    GLuint shader = glCreateShader(shaderType);
    
    glShaderSource(shader, 1, &UTF8SourceStr, NULL);
    glCompileShader(shader);
    
    
    GLint compileResult = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
    
    if (!compileResult) {
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

- (void)setupLinkShaders {
    self.program = glCreateProgram();
    
    glAttachShader(self.program, self.vShader);
    glAttachShader(self.program, self.fShader);
    glLinkProgram(self.program);
    
    GLint linkResult = 0;
    glGetProgramiv(self.program, GL_LINK_STATUS, &linkResult);
    if (!linkResult) {
        GLint infoLenth = 0;
        glGetProgramiv(self.program, GL_INFO_LOG_LENGTH, &infoLenth);
        
        char *infoLog = malloc(sizeof(char) * infoLenth);
        if (infoLenth) {
            glGetProgramInfoLog(self.program, infoLenth, NULL, infoLog);
            NSLog(@"Program Link Shaders Error:%@", [NSString stringWithUTF8String:infoLog]);
            free(infoLog);
            exit(1);
        }
    }
}

- (void)deleteShaders {
    glDeleteShader(self.vShader);
    glDeleteShader(self.fShader);
}

- (void)setupVAOAndVBO {
    float vertices[] = {
        // 位置              // 颜色
         0.0,  0.5, 0.0,  1.0, 0.0, 0.0,
        -0.5, -0.5, 0.0,  0.0, 1.0, 0.0,
         0.5, -0.5, 0.0,  0.0, 0.0, 1.0
    };
    
    glGenVertexArrays(1, &(_VAO));
    glBindVertexArray(_VAO);
    
    glGenBuffers(1, &(_VBO));
    glBindBuffer(GL_ARRAY_BUFFER, _VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void *)(3 * sizeof(float)));
    glEnableVertexAttribArray(1);
}

- (void)startRender {
    
    glClearColor(0.2, 0.3, 0.3, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glUseProgram(self.program);
    
    glBindVertexArray(_VAO);
    glDrawArrays(GL_TRIANGLES, 0, 3);
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
