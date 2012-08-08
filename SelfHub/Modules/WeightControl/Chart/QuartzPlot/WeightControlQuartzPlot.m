//
//  WeightControlTestClass.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 17.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlQuartzPlot.h"

#define TEST_OPENGL YES


@implementation WeightControlQuartzPlot

@synthesize delegateWeight, scrollView, contentView, xAxis, yAxis, pointerView, pointerScroller, zoomerView, normWeightLabel, aimWeightLabel, glContentView;

- (id)initWithFrame:(CGRect)frame andDelegate:(WeightControl *)_delegate
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.delegateWeight = _delegate;
        
        float contentViewWidthInit = 320.0f;
        if([delegateWeight.weightData count] > 0){
            NSTimeInterval firstDateInt = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
            NSTimeInterval lastDateInt = [[[delegateWeight.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970];
            contentViewWidthInit = ((lastDateInt-firstDateInt) / (24*60*60)) * 50.0;
            if(contentViewWidthInit<160.0){
                contentViewWidthInit = 320.0;
            }else{
                contentViewWidthInit += 320;
            };
        };
        
        if(TEST_OPENGL){
            glContentView = [[WeightControlQuartzPlotGLES alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
            [self addSubview:glContentView];
            NSLog(@"content scale factor: %.1f", glContentView.layer.contentsScale);
            return self;
        };

        
        // Initialization code
        scrollView = [[WeightControlPlotScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        yAxis = [[WeightControlVerticalAxisView alloc] initWithFrame:CGRectMake(0.0, 0.0, 33.0, frame.size.height)];
        [yAxis setBackgroundColor:[UIColor whiteColor]];
        xAxis = [[WeightControlHorizontalAxisView alloc] initWithFrame:CGRectMake(0.0, frame.size.height-22.5, contentViewWidthInit, 15.0)];
        xAxis.isZooming = NO;
        [xAxis setBackgroundColor:[UIColor whiteColor]];
        
        
        contentView = [[WeightControlQuartzPlotContent alloc] initWithFrame:CGRectMake(0.0, 0.0, contentViewWidthInit, frame.size.height)];
        contentView.delegate = self;
        [contentView setBackgroundColor:[UIColor whiteColor]];
        contentView.delegateWeight = _delegate;
        contentView.weightGraphYAxisView = yAxis;
        contentView.weightGraphXAxisView = xAxis;
        
        scrollView.delegate = contentView;
        scrollView.minimumZoomScale = 0.25f;
        scrollView.maximumZoomScale = 4.0f;
        scrollView.contentSize = contentView.frame.size;
        scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        [scrollView setScrollEnabled:YES];
        
        [scrollView addSubview:contentView];
        
        pointerView = [[WeightControlQuartzPlotPointer alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height - xAxis.frame.size.height)];
        pointerView.delegate = self;
        
        pointerScroller = [[WeightControlQuartzPlotPointerScrolerView alloc] initWithFrame:pointerView.frame];
        pointerScroller.delegate = self;
        
        zoomerView = [[WeightControlQuartzPlotZoomer alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        zoomerView.delegate = self;
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        
        
        
        //Aim and norm weight labels
        normWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-40.0, 0.0, 40.0, 14.0)];
        aimWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-40.0, 0.0, 40.0, 14.0)];
        normWeightLabel.text = @"norm";
        normWeightLabel.font = [UIFont systemFontOfSize:14.0];
        normWeightLabel.textColor = [UIColor orangeColor];
        normWeightLabel.backgroundColor = [UIColor clearColor];
        normWeightLabel.textAlignment = UITextAlignmentRight;
        aimWeightLabel.text = @"aim";
        aimWeightLabel.font = [UIFont systemFontOfSize:14.0];
        aimWeightLabel.textColor = [UIColor greenColor];
        aimWeightLabel.backgroundColor = [UIColor clearColor];
        aimWeightLabel.textAlignment = UITextAlignmentRight;
        //[self updateAimAndNormLabelsPosition];

        
        [self addSubview:scrollView];
        [self addSubview:xAxis];
        [self addSubview:yAxis];
        [self addSubview:pointerView];
        [self addSubview:pointerScroller];
        [self addSubview:zoomerView];
        [self addSubview:normWeightLabel];
        [self addSubview:aimWeightLabel];
        
        lastContentOffset = 0.0;
        lastPointerX = 0.0;
        
        //[scrollView setContentOffset:CGPointMake(0, 0)];
        if([delegateWeight.weightData count]>0 && scrollView.contentSize.width>320.0){
            NSDate *showDate = [[[delegateWeight weightData] lastObject] objectForKey:@"date"];
            if([[NSDate date] timeIntervalSince1970] < [showDate timeIntervalSince1970]){
                showDate = [NSDate date];
            };
            [self scrollToDate:showDate];
        }else{
            [scrollView setContentOffset:CGPointMake(0.0, 0.0)];
        }
        
    }
    return self;
}

- (void)dealloc{
    delegateWeight = nil;
    [scrollView release];
    [contentView release];
    [glContentView release];
    [xAxis release];
    [yAxis release];
    [pointerView release];
    [pointerScroller release];
    [zoomerView release];
    [normWeightLabel release];
    [aimWeightLabel release];
    
    [super dealloc];
}

- (void)redrawPlot{
    [contentView performUpdatePlot];
    [self updateAimAndNormLabelsPosition];
};

- (void)testPixel{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentScaleFactor);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageView *testImg = [[UIImageView alloc] initWithImage:image];
    //testImg.contentScaleFactor = 8.0;
    //[self.superview.superview addSubview:testImg];
    [testImg release];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender{
    CGPoint tapPoint = [sender locationInView:self];
    CGPoint zoomTapPoint = [self convertPoint:tapPoint toView:zoomerView];
    if([zoomerView pointInside:zoomTapPoint withEvent:nil]){
        //NSLog(@"tapped at zoom view: %.0fx%.0f", zoomTapPoint.x, zoomTapPoint.y);
        return;
    };
    
    if(pointerView.alpha<0.1){
        [self showPointerForContentViewPoint:[sender locationInView:contentView].x atPosition:[sender locationInView:pointerView].x];
    }else{
        [self hidePointer];
    };
    
    if(zoomerView.alpha<0.1){
        [zoomerView showZoomView];
    };
};

- (void)showPointerForContentViewPoint:(CGFloat)xContentView atPosition:(CGFloat)xPointer{
    NSTimeInterval tappedTimeInt = [contentView getTimeIntervalSince1970ForX:xContentView];
    NSTimeInterval testedTimeInt;
    NSDictionary *oneRecord;
    float w1, w2, tappedWeight = 0.0, tappedTrend = 0.0;
    int i;
    
    lastContentX = xContentView;
    lastPointerX = xPointer;
    lastContentOffset = [scrollView contentOffset].x;
    
    if([delegateWeight.weightData count]==0 || tappedTimeInt < [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970] ||
       tappedTimeInt > [[[delegateWeight.weightData lastObject] objectForKey:@"date"] timeIntervalSince1970]){  // if pointer out of bounds
        pointerView.curTimeInt = [contentView getTimeIntervalSince1970ForX:lastContentOffset+xPointer];
        [pointerView showPointerAtWeightPoint:CGPointMake(xPointer, [contentView convertWeightToY:0.0]) andTrendPoint:CGPointMake(xPointer, [contentView convertWeightToY:0.0])];
        [pointerScroller showPointerScrollViewAtXCoord:xPointer];
        return;
    };
    
    if([delegateWeight.weightData count]==1){
        tappedWeight = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"weight"] floatValue];
        tappedTrend = [[[delegateWeight.weightData objectAtIndex:0] objectForKey:@"trend"] floatValue];
    }else{
        for(i=0;i<[delegateWeight.weightData count]-1;i++){
            oneRecord = [delegateWeight.weightData objectAtIndex:i];
            testedTimeInt = [[oneRecord objectForKey:@"date"] timeIntervalSince1970];
            NSDictionary *nextRecord = [delegateWeight.weightData objectAtIndex:i+1];
            NSTimeInterval nextTimeInt = [[nextRecord objectForKey:@"date"] timeIntervalSince1970];
            if(tappedTimeInt>=testedTimeInt && tappedTimeInt<=nextTimeInt){
                if(i<[delegateWeight.weightData count]-1){
                    w1 = [[oneRecord objectForKey:@"weight"] floatValue];
                    w2 = [[nextRecord objectForKey:@"weight"] floatValue];
                    tappedWeight = w1 + (((tappedTimeInt - testedTimeInt) * (w2 - w1)) / (nextTimeInt - testedTimeInt));
                    w1 = [[oneRecord objectForKey:@"trend"] floatValue];
                    w2 = [[nextRecord objectForKey:@"trend"] floatValue];
                    tappedTrend = w1 + (((tappedTimeInt - testedTimeInt) * (w2 - w1)) / (nextTimeInt - testedTimeInt));
                    break;
                };
            };
        };
    };
    
    
    pointerView.curTimeInt = [contentView getTimeIntervalSince1970ForX:xContentView];
    [pointerView showPointerAtWeightPoint:CGPointMake(xPointer, [contentView convertWeightToY:tappedWeight]) andTrendPoint:CGPointMake(xPointer, [contentView convertWeightToY:tappedTrend])];
    [pointerScroller showPointerScrollViewAtXCoord:xPointer];
};

- (void)updatePointerDuringScrolling{
    if(pointerView.alpha < 0.1) return;
    
    float offsetPointer = [scrollView contentOffset].x - lastContentOffset;
    //NSLog(@"lastContentPoint = %.0f", offsetPointer);
    
    lastContentX += offsetPointer;
    [self showPointerForContentViewPoint:lastContentX atPosition:lastPointerX];
};

- (void)updatePointerDuringSelfScrolling:(float)curPointX{
    [self showPointerForContentViewPoint:lastContentOffset+curPointX atPosition:curPointX];
};

- (void)showZoomer{
    [zoomerView showZoomView];
}

- (void)hidePointer{
    [pointerView hidePointerView];
    [pointerScroller hidePointerScrollView];
};

- (void)hideZoomer{
    [zoomerView hideZoomView];
};

- (float)getWeightByY:(float)yCoord{
    return [contentView convertYToWeight:yCoord];
};

- (float)getTimeIntervalByX:(float)xCoord{
    return [contentView getTimeIntervalSince1970ForX:xCoord];
};

- (void)zoomIn{
    [contentView zoomContentByFactor:2.0];
};

- (void)zoomOut{
    [contentView zoomContentByFactor:0.5];
};

- (void)scrollToDate:(NSDate *)needDate{
    NSTimeInterval timeInterval = [needDate timeIntervalSince1970];
    float xCoord = [contentView getXCoordForTimeIntervalSince1970:timeInterval];
    
    if(xCoord > (self.frame.size.width / 2)) xCoord -= (self.frame.size.width / 2);
    
    [scrollView setContentOffset:CGPointMake(xCoord, 0.0)];
};

- (void)updateAimAndNormLabelsPosition{
    [contentView updateXYRangesValues];
    
    CGPoint curCentr = aimWeightLabel.center;
    float curWeight;
    if(delegateWeight.aimWeight && !isnan([delegateWeight.aimWeight floatValue])){
        curWeight = [delegateWeight.aimWeight floatValue];
        curCentr = CGPointMake(curCentr.x, [contentView convertWeightToY:curWeight]+contentView.frame.origin.y-aimWeightLabel.frame.size.height/2);
    }else{
        curCentr = CGPointMake(curCentr.x, -50);
    };
    aimWeightLabel.center = curCentr;
    
    curCentr = normWeightLabel.center;
    if(delegateWeight.normalWeight && !isnan([delegateWeight.normalWeight floatValue])){
        curWeight = [delegateWeight.normalWeight floatValue];
        curCentr = CGPointMake(curCentr.x, [contentView convertWeightToY:curWeight]+contentView.frame.origin.y-normWeightLabel.frame.size.height/2);
    }else{
        curCentr = CGPointMake(curCentr.x, -50);
    };
    normWeightLabel.center = curCentr;
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
