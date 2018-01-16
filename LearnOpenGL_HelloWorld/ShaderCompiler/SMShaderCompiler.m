//
//  SMShaderCompiler.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/16.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMShaderCompiler.h"
#import <OpenGLES/ES3/gl.h>

@implementation SMShaderCompiler {
    GLuint _program;
}

- (instancetype)initShaderCompilerWithVertex:(NSString *)vertexFileName fragment:(NSString *)fragmentFileName {
    if (self = [super init]) {
        [self programLinkVertexShader:vertexFileName fragmentShader:fragmentFileName];
    }
    return self;
}

- (GLuint)setupShader:(GLenum)shaderType shaderFileName:(NSString *)fileName {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Get Shader FileName Failure:%@", error.localizedDescription);
        return 0;
    }
    
    GLuint shader = glCreateShader(shaderType);
    
    const char *utf8Str = [shaderString UTF8String];
    glShaderSource(shader, 1, &utf8Str, NULL);
    glCompileShader(shader);
    
    GLint compileResult;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &compileResult);
    
    if (!compileResult) {
        GLint infoLength;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLength);
        
        if (infoLength) {
            char *infoLog = malloc(sizeof(char) * infoLength);
            glGetShaderInfoLog(shader, infoLength, NULL, infoLog);
            
            NSLog(@"Shader Compiling Error:%@", [NSString stringWithUTF8String:infoLog]);
            
            free(infoLog);
        }
        
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

- (void)programLinkVertexShader:(NSString *)vShaderFileName fragmentShader:(NSString *)fShaderFileName {
    
    _program = glCreateProgram();
    
    GLuint vShader = [self setupShader:GL_VERTEX_SHADER shaderFileName:vShaderFileName];
    GLuint fShader = [self setupShader:GL_FRAGMENT_SHADER shaderFileName:fShaderFileName];
    
    glAttachShader(_program, vShader);
    glAttachShader(_program, fShader);
    
    glLinkProgram(_program);
    
    GLint linkResult;
    glGetProgramiv(_program, GL_LINK_STATUS, &linkResult);
    if (!linkResult) {
        GLint logLength;
        glGetProgramiv(_program, GL_INFO_LOG_LENGTH, &logLength);
        
        if (logLength) {
            
            char *infoLog = malloc(sizeof(char) *logLength);
            glGetProgramInfoLog(_program, logLength, NULL, infoLog);
            NSLog(@"Program Link Shaders Error:%@", [NSString stringWithUTF8String:infoLog]);
            free(infoLog);
        }
    } else {
        glDeleteShader(vShader);
        glDeleteShader(fShader);
    }
}

- (void)userProgram {
    glUseProgram(_program);
}

@end
