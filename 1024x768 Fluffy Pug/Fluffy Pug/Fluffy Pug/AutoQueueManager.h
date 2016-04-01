//
//  AutoQueueManager.h
//  Fluffy Pug
//
//  Created by Matthew French on 6/13/15.
//  Copyright © 2015 Matthew French. All rights reserved.
//

#import "Utility.h"
#import <time.h>
#import "InteractiveEvents.h"

const int STEP_1=0, STEP_2=1, STEP_3=2, STEP_4=3, STEP_5=4, STEP_6=5, STEP_7=6, STEP_8=7, STEP_9=8
, STEP_10=9, STEP_11=10, STEP_12=11;

class AutoQueueManager {
    //Image data to scan for
    ImageData growButton;
    
    //Variables shared between logic and detection theads
    //Tells detection what to look for when the screen changes
    volatile Boolean scanForGrowButton;
    
    //When the detection finds the button, it tells the Logic using these Logic thread variables
    Position growButtonLocation;
    Boolean foundGrowButton;
    
    //This is the current step the logic is on
    int currentStep;
    
    //double lastScreenScan, lastEndGameScan;
    //Position playButtonLocation;
    int reportedScanCurrentChunkX, reportedScanCurrentChunkY;
    
    uint64_t actionClick, scanReportedLastTime;

public:
    
    
    
    AutoQueueManager();
    bool processDetection(ImageData data, const CGRect* rects, size_t num_rects);
    void processLogic();
    void clickLocation(int x, int y);
};