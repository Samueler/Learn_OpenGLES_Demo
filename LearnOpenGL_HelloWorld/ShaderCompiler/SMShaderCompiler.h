//
//  SMShaderCompiler.h
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/16.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>

@interface SMShaderCompiler : NSObject

@property (nonatomic, assign) GLuint program;

- (instancetype)initShaderCompilerWithVertex:(NSString *)VertexFileName fragment:(NSString *)fragmentFileName;

- (void)userProgram;

@end
