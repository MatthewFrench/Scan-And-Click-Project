//
//  AppDelegate.m
//  Fluffy Pug
//
//  Created by Matthew French on 5/25/15.
//  Copyright (c) 2015 Matthew French. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

dispatch_source_t CreateDispatchTimer(uint64_t intervalNanoseconds,
                                      uint64_t leewayNanoseconds,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                                     0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), intervalNanoseconds, leewayNanoseconds);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    uiUpdateTime = mach_absolute_time();
    aiThread = dispatch_get_main_queue();
    //dispatch_queue_create("AI Thread", DISPATCH_QUEUE_CONCURRENT);
    detectionThread = dispatch_get_main_queue();
    //dispatch_queue_create("Detection Thread", DISPATCH_QUEUE_CONCURRENT);
    GlobalSelf = self;
    
    [_window orderFront: nil];
    [_window2 setLevel: NSNormalWindowLevel];
    [NSApp activateIgnoringOtherApps:YES];
    
    
    [[NSProcessInfo processInfo] disableAutomaticTermination:@"Good Reason"];
    
    if ([[NSProcessInfo processInfo] respondsToSelector:@selector(beginActivityWithOptions:reason:)]) {
        self->_activity = [[NSProcessInfo processInfo] beginActivityWithOptions:0x00FFFFFF reason:@"receiving messages"];
    }
    
    autoQueueManager = new AutoQueueManager();
    
    CGDirectDisplayID display_id;
    display_id = CGMainDisplayID();
    
    CGDisplayModeRef mode = CGDisplayCopyDisplayMode(display_id);
    
    size_t pixelWidth = CGDisplayModeGetPixelWidth(mode);
    size_t pixelHeight = CGDisplayModeGetPixelHeight(mode);
    
    CGDisplayModeRelease(mode);
    
    //stream = CGDisplayStreamCreate(display_id, pixelWidth, pixelHeight, 'BGRA', NULL, handleStream);
    stream = CGDisplayStreamCreateWithDispatchQueue(display_id, pixelWidth, pixelHeight, 'BGRA',
                                                    (__bridge CFDictionaryRef)(@{(__bridge NSString *)kCGDisplayStreamQueueDepth : @1,  (__bridge NSString *)kCGDisplayStreamShowCursor: @NO,
                                                     (__bridge NSString*)kCGDisplayStreamMinimumFrameTime: @(5.0f/1.0f)})
                                                    , detectionThread, handleStream);
    
    lastTime = mach_absolute_time();
    CGDisplayStreamStart(stream);
    
    timer = CreateDispatchTimer(NSEC_PER_SEC/120, //30ull * NSEC_PER_SEC
                                0, //1ull * NSEC_PER_SEC
                                aiThread,
                                ^{ [self logic]; });
}
- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    CGDisplayStreamStop(stream);
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}
- (IBAction) runAutoQueueButton:(id)sender {
    if ([GlobalSelf->autoQueueCheckbox state] == NSOnState) {
        runAutoQueue = true;
    } else {
        runAutoQueue = false;
    }
}

uint64_t lastTime = 0;
int loops = 0;
int screenLoops = 0;
AppDelegate *GlobalSelf;

- (void) logic {
    if (runAutoQueue)
        autoQueueManager->processLogic();
}

void (^handleStream)(CGDisplayStreamFrameStatus, uint64_t, IOSurfaceRef, CGDisplayStreamUpdateRef) =  ^(CGDisplayStreamFrameStatus status,
                                                                                                        uint64_t displayTime,
                                                                                                        IOSurfaceRef frameSurface,
                                                                                                        CGDisplayStreamUpdateRef updateRef)
{
    @autoreleasepool {
        if (status != kCGDisplayStreamFrameStatusFrameComplete) return;
        
        //dispatch_async(GlobalSelf->aiThread, ^{
        screenLoops++;
        //});
        uint32_t aseed;
        IOSurfaceLock(frameSurface, kIOSurfaceLockReadOnly, &aseed);
        uint32_t width = (uint32_t)IOSurfaceGetWidth(frameSurface);
        uint32_t height = (uint32_t)IOSurfaceGetHeight(frameSurface);
        uint8_t * basePtr = (uint8_t*)IOSurfaceGetBaseAddress(frameSurface);
        
        
        
        struct ImageData imageData = makeImageData(basePtr, width, height);
        
        
        
        const CGRect * rects;
        
        size_t num_rects;
        
        rects = CGDisplayStreamUpdateGetRects(updateRef, kCGDisplayStreamUpdateDirtyRects, &num_rects);
        
        //NSLog(@"First pixel: %d, %d, %d, %d", basePtr[0], basePtr[1], basePtr[2], basePtr[3]);
        
        if (GlobalSelf->runAutoQueue)
            GlobalSelf->autoQueueManager->processDetection(imageData, rects, num_rects);
        
        
        [GlobalSelf logic];
        
        IOSurfaceUnlock(frameSurface, kIOSurfaceLockReadOnly, &aseed);
        
        
    }
};


@end
