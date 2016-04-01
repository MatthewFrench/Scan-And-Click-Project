//
//  AppDelegate.h
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <time.h>
#include <CoreGraphics/CoreGraphics.h>
#import <IOSurface/IOSurfaceBase.h>
#import <IOKit/IOKitLib.h>
#import <IOSurface/IOSurface.h>
#import "AutoQueueManager.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, AVCaptureVideoDataOutputSampleBufferDelegate> {
    
    //NSTimer* timer;
    @public AutoQueueManager* autoQueueManager;
    //AVCaptureScreenInput *input;
    
    //AVCaptureSession *mSession;
    

@public IBOutlet NSButton* autoQueueCheckbox;
    CGDisplayStreamRef stream;
    
    volatile bool runAutoQueue;
    
    dispatch_source_t timer;
    
    @public uint64_t uiUpdateTime;
    
    @public dispatch_queue_t aiThread, detectionThread;
    
    int processedDecision;
}
@property (strong) id activity;
@property (weak) IBOutlet NSWindow *window, *window2;

- (IBAction) runAutoQueueButton:(id)sender;

@end

