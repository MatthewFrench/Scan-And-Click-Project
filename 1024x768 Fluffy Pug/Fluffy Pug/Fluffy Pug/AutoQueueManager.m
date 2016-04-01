//
//  AutoQueueManager.m
//  Fluffy Pug
//
//  Created by Matthew French on 6/13/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "AutoQueueManager.h"
#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>

AutoQueueManager::AutoQueueManager() {
    growButton = makeImageDataFrom([[NSBundle mainBundle] pathForResource:@"Resources/Auto Queue Images/Grow Button" ofType:@"png"]);
    
    actionClick = mach_absolute_time();
}
void AutoQueueManager::processLogic() {
    
    if (foundGrowButton) {
        clickLocation(growButtonLocation.x, growButtonLocation.y);
        foundGrowButton = false;
    }
    
    /*
    if (getTimeInMilliseconds(mach_absolute_time() - actionClick) >= 1000) {
        if (foundReportedButton) {
            tapMouseLeft(reportedButtonLocation.x+10, reportedButtonLocation.y+10);
            actionClick = mach_absolute_time();
            foundReportedButton = false;
        }
        
                if (foundPlayButton)  {
                    currentStep = STEP_2;
                    clickLocation(playButtonLocation.x, playButtonLocation.y);
                    actionClick = mach_absolute_time();
                                        }
                }
     */
}
void AutoQueueManager::clickLocation(int x, int y) {
    doubleTapMouseLeft(x + 10, y+10);
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 2000.0), dispatch_get_main_queue(), ^{ // one
    //    floatTapMouseLeft(x + 10, y+10);
    //});
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC / 60.0), dispatch_get_main_queue(), ^{ // one
    //dispatch_async(dispatch_get_main_queue(), ^{
        moveMouse(0, 0);
    });
}
bool AutoQueueManager::processDetection(ImageData data, const CGRect* rects, size_t num_rects) {

    __block volatile bool fireLogic = false;
    
    //dispatch_group_t dispatchGroup = dispatch_group_create();
    
    if (scanForGrowButton) {
        NSLog(@"Scanning for growbutton");
        //dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
        //dispatch_group_async(dispatchGroup, queue, ^{
            
            
            
            int xStart = 0;
            int yStart = 0;
            int xEnd = data.imageWidth;
            int yEnd = data.imageHeight;
            
            for (int x = xStart; x < xEnd; x++) {
                for (int y = yStart; y < yEnd; y++) {
                    if (getImageAtPixelPercentageOptimizedExact(getPixel2(data, x, y), x, y, data.imageWidth, data.imageHeight, growButton, 0.7) >=  0.7) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            foundGrowButton = true;
                            growButtonLocation.x = x;
                            growButtonLocation.y = y;
                            NSLog(@"Found grow button at %d, %d", x, y);
                        });
                        fireLogic = true;
                        x = xEnd;
                        y = yEnd;
                    }
                }
            }
            
            
            
            
            
            /*
            
            float returnPercentage = 0.0;
            Position returnPosition;
            int xStart = 0;
            int yStart = 0;
            int xEnd = data.imageWidth - growButton.imageWidth;
            int yEnd = data.imageHeight - growButton.imageHeight;
            CGRect search = CGRectMake(xStart, yStart, xEnd - xStart, yEnd-yStart);
            //size_t intersectRectsNum;
            //CGRect* intersectSearch = getIntersectionRectangles(search, rects, num_rects, intersectRectsNum);
            //NSLog(@"Doing comparison: %d, %d", growButton.imageWidth, growButton.imageHeight);
            //NSLog(@"Screen size: %d, %d", data.imageWidth, data.imageHeight);
            //detectExactImageToImageToRectangle(growButton, data, search, returnPercentage, returnPosition, 0.83, true);
            //detectExactImageToImageToRectangles(step1_PlayButton, data, intersectSearch, intersectRectsNum, returnPercentage, returnPosition, 0.83, true);
            
            ////NSLog(@"Play button percentage: %f", returnPercentage);
            
            if (returnPercentage >= 0.3) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundGrowButton = true;
                    growButtonLocation = returnPosition;
                });
                fireLogic = true;
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    foundGrowButton = false;
                });
            }*/
            
        //});
    }
    return true;
}