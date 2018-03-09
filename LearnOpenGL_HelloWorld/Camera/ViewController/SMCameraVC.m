//
//  SMCameraVC.m
//  LearnOpenGL_HelloWorld
//
//  Created by Douqu on 2018/3/8.
//  Copyright © 2018年 Samueler. All rights reserved.
//

#import "SMCameraVC.h"
#import <AVFoundation/AVFoundation.h>
#import "SMCameraView.h"

@interface SMCameraVC () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) SMCameraView *cameraView;

@end

@implementation SMCameraVC

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCameraView];
    [self setupCaptureSession];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.captureSession startRunning];
}

#pragma mark - Private Functions

- (void)setupCameraView {
    [self.view addSubview:self.cameraView];
}

- (void)setupCaptureSession {
    self.captureSession = [[AVCaptureSession alloc] init];
    
    [self.captureSession beginConfiguration];
    
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    
    AVCaptureDevice *cameraDevice = nil;
    NSArray *captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in captureDevices) {
        if ([device position] == AVCaptureDevicePositionFront) {
            cameraDevice = device;
        }
    }
    
    if (!cameraDevice) {
        NSLog(@"Camera Device Not Found!");
        return;
    }
    
    NSError *error = nil;
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:cameraDevice error:&error];
    if ([self.captureSession canAddInput:_videoInput]) {
        [self.captureSession addInput:_videoInput];
    }
    
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoOutput setAlwaysDiscardsLateVideoFrames:NO];
    [_videoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    // luma=[0,255] chroma=[1,255]
    [_videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    
    if ([self.captureSession canAddOutput:_videoOutput]) {
        [self.captureSession addOutput:_videoOutput];
    }
    
    [self.captureSession commitConfiguration];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (![self.captureSession isRunning]) return;
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    [self.cameraView displayPixelBuffer:pixelBuffer];
}

#pragma mark - Lazy Load

- (SMCameraView *)cameraView {
    if (!_cameraView) {
        _cameraView = [[SMCameraView alloc] initWithFrame:self.view.bounds];
    }
    return _cameraView;
}

@end
