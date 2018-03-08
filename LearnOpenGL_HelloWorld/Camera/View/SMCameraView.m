//
//  SMCameraView.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/3/8.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMCameraView.h"
#import <OpenGLES/ES3/gl.h>
#import "SMShaderCompiler.h"

@interface SMCameraView()

@property (nonatomic, strong) SMShaderCompiler *compiler;

@end

@implementation SMCameraView {
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_context;
    GLuint _colorBuffer, _frameBuffer;
    
    CVOpenGLESTextureRef _lumaTexture; // Y
    CVOpenGLESTextureRef _chromaTexture; // UV
    CVOpenGLESTextureCacheRef _videoTextureCache;
}

#pragma mark - Initialization Functions

- (instancetype)init {
    if (self = [super init]) {
        
        [self setupLayer];
        [self setupContext];
        [self clearColorFrameBuffer];
        [self setupColorFrameBuffer];
        [self setupShaders];
    }
    return self;
}

#pragma mark - Public Functions

- (void)displayPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    
    if (pixelBuffer != NULL && _videoTextureCache) {
        
        [self clearTextures];
     
        GLsizei frameWidth = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
        GLsizei frameHeight = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
        
        // 通过CFTypeRef 可以知道使用哪种格式的颜色矩阵转换 YUV->RGB 因此处我们已经固定了格式 所以便不用其进行矩阵类型判断
//        CFTypeRef colorAttachement = CVBufferGetAttachment(pixelBuffer, kCVImageBufferYCbCrMatrixKey, NULL);
        
        // GL_TEXTURE0
        glActiveTexture(GL_TEXTURE0);
        CVReturn lumaTextureResult = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, frameWidth, frameHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &_lumaTexture);
        
        if (lumaTextureResult) {
            NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage Error For LumaTexture:%d", lumaTextureResult);
        }
        
        glBindSampler(CVOpenGLESTextureGetTarget(_lumaTexture), CVOpenGLESTextureGetName(_lumaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        // GL_TEXTURE1
        
        glActiveTexture(GL_TEXTURE1);
        CVReturn chromaTextureResult = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _videoTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_LUMINANCE, frameWidth, frameHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 1, &_chromaTexture);
        
        if (chromaTextureResult) {
            NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage Error For chromaTexture:%d", chromaTextureResult);
        }
        
        glBindSampler(CVOpenGLESTextureGetTarget(_chromaTexture), CVOpenGLESTextureGetName(_chromaTexture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        
        glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
        
        [self startRender];
    }
}

#pragma mark - Override Functions

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark - Private Functions

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer *)self.layer;
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_context];
}

- (void)clearColorFrameBuffer {
    if (_colorBuffer) {
        glDeleteRenderbuffers(1, &_colorBuffer);
        _colorBuffer = 0;
    }
    
    if (_frameBuffer) {
        glDeleteRenderbuffers(1, &_frameBuffer);
        _frameBuffer = 0;
    }
}

- (void)setupColorFrameBuffer {
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    
    glGenRenderbuffers(1, &_colorBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBuffer);
    
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupShaders {
    self.compiler = [[SMShaderCompiler alloc] initShaderCompilerWithVertex:@"SMCamera.fsh" fragment:@"SMCamera.vsh"];
}

- (void)clearTextures {
    if (_lumaTexture) {
        CFRelease(_lumaTexture);
        _lumaTexture = NULL;
    }
    
    if (_chromaTexture) {
        CFRelease(_chromaTexture);
        _chromaTexture = NULL;
    }
    
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)startRender {
    
    
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0, 0.0, 0.0, 1.0);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    
    
    
    
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}


@end
