//
//  SMHelloWorld.m
//  LearnOpenGL_HelloWorld
//
//  Created by Samueler on 2018/1/8.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMHelloWorld.h"
#import <OpenGLES/ES3/gl.h>
#import <GLKit/GLKit.h>

const float vertices[] = {
    -0.5, -0.5, 0,
    0.5, -0.5, 0,
    0.0,  0.5, 0
};

@interface SMHelloWorld () <GLKViewDelegate>

@property (nonatomic, strong) GLKView *glkView;

@property(nonatomic, strong) EAGLContext *context;

@property(nonatomic, assign) GLuint vShader;
@property(nonatomic, assign) GLuint fShader;
@property(nonatomic, assign) GLuint program;

@end

@implementation SMHelloWorld

- (void)loadView {
    
    [super loadView];
    
    self.view = self.glkView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupOpenGLContext];
    
    [self setupViewPort];
    
    [self setupShader];
    
    [self setupProgram];
    
    [self deleteShaders];
    
    [self setupBuffers];
}

- (void)setupOpenGLContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableColorFormatRGBA8888;
    view.delegate = self;
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupViewPort {
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (void)setupShader {
    self.vShader = [self createShader:GL_VERTEX_SHADER source:@"SMVertice.vsh"];
    self.fShader = [self createShader:GL_FRAGMENT_SHADER source:@"SMFragment.fsh"];
}

- (GLuint)createShader:(GLenum)shaderType source:(NSString *)sourceFileName {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:sourceFileName ofType:nil];
    NSError *error = nil;
    NSString *shaderString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"%@", error.localizedDescription);
    }
    
    const char *shaderUTF8 = [shaderString UTF8String];
    
    // 创建shader
    GLuint shader = glCreateShader(shaderType);
    
    // 绑定shader源码
    // 参数含义
    // shader: 指定将源码附加至哪个着色器
    // count:  字符串源码数组的个数
    // string: 字符串源码
    // length: 字符串源码的长度
    glShaderSource(shader, 1, &shaderUTF8, NULL);
    // 编译着色器
    glCompileShader(shader);
    
    // 获取编译着色器失败的相关消息
    int result;
    // 参数含义
    // shader: 需要查询的着色器
    // pname: 查询类别：GL_COMPILE_STATUS、GL_SHADER_TYPE、GL_DELETE_STATUS、GL_INFO_LOG_LENGTH、GL_SHADER_SOURCE_LENGTH
    // params: 返回查询对象的结果值
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
    // 着色器程序对象的生成
    self.program = glCreateProgram();
    // 将顶点着色器和片段着色器附加至着色器程序对象上
    glAttachShader(self.program, self.vShader);
    glAttachShader(self.program, self.fShader);
    // 开始讲着色器程序上的着色器链接
    glLinkProgram(self.program);
    
    int linkResult;
    // 获取着色器程序链接的状态
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

- (void)setupBuffers {
    GLuint VAO , VBO;
    
    glGenVertexArrays(1, &VAO);
    glBindVertexArray(0);
    
    // 参数含义:
    // GLsizei n: 生成多少个VBO对象
    // GLuint* buffers: 缓冲ID
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    // 参数含义：
    // target: 目标缓冲类型
    // size: 需要传输数据的大小
    // data: 需要复制的数据
    // usage: 显卡管理给定数据的方式
    // GL_STREAM_DRAW: 数据会改变较多
    // GL_STATIC_DRAW: 数据不会或几乎不会改变(因三角形的三个顶点固定不会改变，所以使用该类型)
    // GL_DYNAMIC_DRAW: 数据会每次绘制改变
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)setupRenderBuffers {
    
    glClearColor(1, 1, 1, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // 参数含义
    // indx: 顶点属性的位置
    // size: 顶点属性的大小
    // type: 顶点属性数据的类型
    // normalized: 是否希望数据被标准化 GL_TRUE会把所有数据映射为0至1， GL_FALSE将所有数据映射为-1至1
    // stride: 连续两个顶点属性之间的间隔
    // ptr: 数据在缓冲中起始位置的偏移量
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    
    // 启用顶点属性
    glEnableVertexAttribArray(0);
    
    // 开始渲染
    glUseProgram(self.program);
    
    // 参数含义
    // mode: 绘制的图元类型
    // first: 起始索引
    // count: 渲染的顶点数量
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self setupRenderBuffers];
}

#pragma mark - Lazy Load

- (GLKView *)glkView {
    if (!_glkView) {
        _glkView = [[GLKView alloc] initWithFrame:self.view.bounds];
    }
    return _glkView;
}

@end
