//
//  WeightControlGraphView.m
//  SelfHub
//
//  Created by Eugine Korobovsky on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WeightControlGraphView.h"

@implementation WeightControlGraphView

NSString *const kWeightLine	 = @"Data Line";
NSString *const kNormalLine	 = @"Normal Line";
NSString *const kAimLine	 = @"Aim Line";

@synthesize delegate, hostingView, fromDateGraph, toDateGraph;

- (id)init{
    self = [super init];
    if (self) {
    }
    
    return self;
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc{
    if(hostingView){
        [hostingView release];
    };
    
    [super dealloc];
};

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger)getIntegerDateComponent:(NSDate *)date byFormat:(NSString *)format{
    NSString *result;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    result = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    
    return [result integerValue];
}

- (void)createGraphLayer{
    if(hostingView) [hostingView release];
    
    hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    
    CPTGraph *graph = [[[CPTXYGraph alloc] initWithFrame:self.bounds] autorelease];
    hostingView.hostedGraph = graph;
    
    
    graph.plotAreaFrame.paddingTop	  = 10.0;
    graph.plotAreaFrame.paddingRight  = 0.0;
    graph.plotAreaFrame.paddingBottom = 20.0;
    graph.plotAreaFrame.paddingLeft	  = 20.0;
    
    //[self addSubview:hostingView];
    
    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.8];
    
    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:0.2] colorWithAlphaComponent:0.5];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate = self;
    //[plotSpace setScaleType:CPTScaleTypeDateTime forCoordinate:CPTCoordinateX];
    
    // Text styles
	CPTMutableTextStyle *xAxisTitleTextStyle = [CPTMutableTextStyle textStyle];
	xAxisTitleTextStyle.fontName = @"Helvetica-Bold";
	xAxisTitleTextStyle.fontSize = 12.0;
    xAxisTitleTextStyle.color = [CPTColor blackColor];
    CPTMutableTextStyle *xAxisLabelTextStyle = [CPTMutableTextStyle textStyle];
	xAxisLabelTextStyle.fontName = @"Helvetica";
	xAxisLabelTextStyle.fontSize = 10.0;
    xAxisLabelTextStyle.color = [CPTColor grayColor];
    
    //Label Formatters
    NSNumberFormatter *labelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
    labelFormatter.maximumFractionDigits = 1;
    
    NSDateFormatter *dateFormatter_day = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter_day.dateFormat = @"dd";
	CPTTimeFormatter *timeFormatter_day = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter_day] autorelease];
	timeFormatter_day.referenceDate = [[delegate.weightData objectAtIndex:0] objectForKey:@"date"];
    
    NSDateFormatter *dateFormatter_mounth = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter_mounth.dateFormat = @"MMM''yy";
	CPTTimeFormatter *timeFormatter_mounth = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter_mounth] autorelease];
	timeFormatter_mounth.referenceDate = [[delegate.weightData objectAtIndex:0] objectForKey:@"date"];
    
    // !!!!!!!!!!!! X axis !!!!!!!!!!!!!!
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x		  = axisSet.xAxis;
    x.axisConstraints = [CPTConstraints constraintWithLowerOffset:0.0f];
    //x.majorIntervalLength = CPTDecimalFromFloat(oneDay);
    x.majorGridLineStyle = majorGridLineStyle;
    x.minorGridLineStyle = minorGridLineStyle;
    x.tickDirection = CPTSignNone;
    x.labelingPolicy	 = CPTAxisLabelingPolicyLocationsProvided;
    //x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    //x.minorTicksPerInterval = 60*60*24;
    //x.majorIntervalLength = CPTDecimalFromFloat(60*60*24 * 30);
    
    x.labelFormatter	 = timeFormatter_mounth;
    x.minorTickLabelFormatter = timeFormatter_day;
    x.labelOffset = 10;
    x.labelTextStyle = xAxisLabelTextStyle;
    x.labelAlignment = CPTAlignmentLeft;
    x.minorTickLabelOffset = 0;
    x.minorTickLabelTextStyle = xAxisLabelTextStyle;
    
    
    // X-axis line
    CPTMutableLineStyle *xAxisLineStyle = [CPTMutableLineStyle lineStyle];
	xAxisLineStyle.lineWidth = 1.0;
    x.axisLineStyle = xAxisLineStyle;
    // X-Axis arrow  
    CPTLineCap *xAxisCap = [[CPTLineCap alloc] init];
    xAxisCap.lineStyle = x.axisLineStyle;
    xAxisCap.lineCapType = CPTLineCapTypeSolidArrow;
    xAxisCap.size = CGSizeMake(5.0, 15.0);
    xAxisCap.fill = [CPTFill fillWithColor:x.axisLineStyle.lineColor];
    x.axisLineCapMax = xAxisCap;
    [xAxisCap release];
    
    // X-axis title
    x.title = @"date";
    x.titleTextStyle = xAxisTitleTextStyle;
    x.titleOffset = 12.0;
    
    // X-axis minor and major locations
    NSMutableSet *minorTickLocations = [NSMutableSet set];
    NSMutableSet *majorTickLocations = [NSMutableSet set];
    NSUInteger i, tickLength = 1;
    int curMonth = [self getIntegerDateComponent:[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] byFormat:@"MM"];
    //if(daysBetweenDates>21 && daysBetweenDates<150){
    //    tickLength = 7;
    //};
    //if(daysBetweenDates>=150){
    //    tickLength = INT32_MAX;
    //};
    //if(daysBetweenDates<=31 && [self getIntegerDateComponent:fromDate byFormat:@"MM"] == [self getIntegerDateComponent:toDate byFormat:@"MM"]){
    //    [majorTickLocations addObject:[NSDecimalNumber numberWithFloat:startTimeInterval]];
    //}
    NSTimeInterval oneDay = 60 * 60 * 24;
    NSUInteger totalDays = [[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSinceDate:[[delegate.weightData objectAtIndex:0] objectForKey:@"date"]] / oneDay;
    totalDays += 365;
	for (i=0; i <= totalDays; i ++ ) {
        NSTimeInterval curInt = oneDay*i;
        NSTimeInterval realDateInterval = [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970] + oneDay*i;
        NSDate *realDate = [NSDate dateWithTimeIntervalSince1970:realDateInterval];
        //NSLog(@"Real day: %d", [self getIntegerDateComponent:realDate byFormat:@"dd"]);
		if([self getIntegerDateComponent:realDate byFormat:@"dd"] % tickLength == 0){
            [minorTickLocations addObject:[NSDecimalNumber numberWithFloat:curInt]];
        }
        
        if([self getIntegerDateComponent:realDate byFormat:@"MM"] != curMonth){
            [majorTickLocations addObject:[NSDecimalNumber numberWithFloat:curInt]];
            curMonth = [self getIntegerDateComponent:realDate byFormat:@"MM"];
        };
	};
    x.minorTickLocations = minorTickLocations;
    x.majorTickLocations = majorTickLocations;
    
    // !!!!!!!!!!!! Y axis !!!!!!!!!!!!!!
    CPTXYAxis *y = axisSet.yAxis;
    y.axisConstraints = [CPTConstraints constraintWithLowerOffset:5.0f];
    y.labelingPolicy	 = CPTAxisLabelingPolicyAutomatic;
    y.majorGridLineStyle = minorGridLineStyle;
    y.minorGridLineStyle = minorGridLineStyle;
    y.labelFormatter	 = labelFormatter;
    y.title		  = @"weight";
    y.titleOffset = 0.0;
    y.tickDirection = CPTSignNone;
    
    
    // Y-axis line
    CPTMutableLineStyle *yAxisLineStyle = [CPTMutableLineStyle lineStyle];
	yAxisLineStyle.lineWidth = 1.0;
    y.axisLineStyle = xAxisLineStyle;
    
    // Y-axis arrow  
    CPTLineCap *yAxisCap = [[CPTLineCap alloc] init];
    yAxisCap.lineStyle = x.axisLineStyle;
    yAxisCap.lineCapType = CPTLineCapTypeSolidArrow;
    yAxisCap.size = CGSizeMake(5.0, 15.0);
    yAxisCap.fill = [CPTFill fillWithColor:y.axisLineStyle.lineColor];
    y.axisLineCapMax = yAxisCap;
    [yAxisCap release];
    
    // Y-axis text styles
	CPTMutableTextStyle *yAxisTitleTextStyle = [CPTMutableTextStyle textStyle];
	yAxisTitleTextStyle.fontName = @"Helvetica-Bold";
	yAxisTitleTextStyle.fontSize = 12.0;
    yAxisTitleTextStyle.color = [CPTColor blackColor];
    CPTMutableTextStyle *yAxisLabelTextStyle = [CPTMutableTextStyle textStyle];
	yAxisLabelTextStyle.fontName = @"Helvetica";
	yAxisLabelTextStyle.fontSize = 10.0;
    yAxisLabelTextStyle.color = [CPTColor grayColor];
    
    // Y-axis title
    y.title = @"Kg";
    y.titleTextStyle = yAxisTitleTextStyle;
    y.titleOffset = 6.0;
    //y.titleLocation = CPTDecimalFromInt(110);
    
    // Y-axis labels
    y.labelingPolicy = CPTAxisLabelingPolicyAutomatic;
    y.labelFormatter = labelFormatter;
    y.labelTextStyle = yAxisLabelTextStyle;
    y.minorTickLabelFormatter = labelFormatter;
    y.minorTickLabelTextStyle = yAxisLabelTextStyle;
    
    
    
    // Setting graph lines
    // Ideal weight line
	CPTScatterPlot *normalLinePlot = [[[CPTScatterPlot alloc] init] autorelease];
	normalLinePlot.identifier = kNormalLine;
	CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth = 1.0;
	lineStyle.lineColor = [CPTColor blueColor];
	lineStyle.dashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInteger:10], [NSNumber numberWithInteger:6], nil];
	normalLinePlot.dataLineStyle = lineStyle;
	normalLinePlot.dataSource = self;
	[graph addPlot:normalLinePlot];
    
    // Setup a style for the annotation
	CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
	hitAnnotationTextStyle.color	= [CPTColor blueColor];
	hitAnnotationTextStyle.fontSize = 10.0f;
	hitAnnotationTextStyle.fontName = @"Helvetica";
	// Determine point of annotation @"norm" in plot coordinates
	//NSNumber *anchorX = [NSNumber numberWithFloat:startTimeInterval];
	//NSNumber *anchorY = [NSNumber numberWithFloat:[delegate.normalWeight floatValue]];
	NSArray *anchorPoint = [NSArray arrayWithObjects:0, 0, nil];
	// Add annotation
	NSString *normAnnotationString = @"norm";
	CPTTextLayer *textLayer = [[[CPTTextLayer alloc] initWithText:normAnnotationString style:hitAnnotationTextStyle] autorelease];
	normLineAnnotation			  = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:normalLinePlot.plotSpace anchorPlotPoint:anchorPoint];
	normLineAnnotation.contentLayer = textLayer;
	normLineAnnotation.displacement = CGPointMake(14.0f, 5.0f);
    [graph.plotAreaFrame.plotArea addAnnotation:normLineAnnotation];
    [normLineAnnotation release];
    
    
    
    
    // Data line
	CPTScatterPlot *linePlot = [[[CPTScatterPlot alloc] init] autorelease];
    linePlot.identifier = kWeightLine;
	lineStyle = [CPTMutableLineStyle lineStyle];
	lineStyle.lineWidth			 = 1.5;
	lineStyle.lineColor			 = [CPTColor orangeColor];
	linePlot.dataLineStyle = lineStyle;
    
	linePlot.dataSource = self;
	[graph addPlot:linePlot];
    
    // Add plot symbols
	CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
	symbolLineStyle.lineColor = [CPTColor orangeColor];
	CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
	plotSymbol.fill		 = [CPTFill fillWithColor:[CPTColor orangeColor]];
	plotSymbol.lineStyle = symbolLineStyle;
	plotSymbol.size		 = CGSizeMake(5.0, 5.0);
	linePlot.plotSymbol	 = plotSymbol;
    
    //Add points labels
    CPTMutableTextStyle *pointLabelStyle = [CPTMutableTextStyle textStyle];
	pointLabelStyle.color	 = [CPTColor grayColor];
	pointLabelStyle.fontSize	 = 10.0;
    //if(daysBetweenDates<=14){
    //    linePlot.labelTextStyle	 = pointLabelStyle;
    //};
    
    [self addSubview:hostingView];


};

- (void)showLastWeekGraph{
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSDate *nowDate = [NSDate date];
    NSDate *lastWeekDate = [NSDate dateWithTimeIntervalSince1970:[nowDate timeIntervalSince1970] - oneDay*7];
    [self showGraphFromDate:lastWeekDate toDate:nowDate];
    
};

- (void)showFullGraph{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
	[dateComponents setMonth:3];
	[dateComponents setDay:25];
	[dateComponents setYear:2012];
	[dateComponents setHour:12];
	[dateComponents setMinute:0];
	[dateComponents setSecond:0];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDate *refDate = [gregorian dateFromComponents:dateComponents];
    [dateComponents release];
	[gregorian release];

    [self showGraphFromDate:refDate toDate:[[delegate.weightData lastObject] objectForKey:@"date"]];
    
    //[self showGraphFromDate:[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] toDate:[[delegate.weightData lastObject] objectForKey:@"date"]];
};

- (void)showGraphFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    if([fromDate timeIntervalSince1970] >= [toDate timeIntervalSince1970]) return;
    
    if(fromDateGraph) [fromDateGraph release];
    if(toDateGraph) [toDateGraph release];
    
    fromDateGraph = [fromDate retain];
    toDateGraph = [toDate retain];
    
    // Calcing number of days between dates
    NSTimeInterval oneDay = 24 * 60 * 60;
    NSUInteger daysBetweenDates = (NSUInteger)([toDate timeIntervalSinceDate:fromDate] / oneDay);
    //NSLog(@"Days between two dates: %d", daysBetweenDates);
    
    // Initialization code
    CPTGraph *graph = hostingView.hostedGraph;
    //[graph removePlotWithIdentifier:kNormalLine];
    //[graph removePlotWithIdentifier:kWeightLine];
    //[graph removePlotWithIdentifier:kAimLine];
    
    
    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    
    //XAxisSettings
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x		  = axisSet.xAxis;
    
    double titleOffsetPlace = ((double)daysBetweenDates * (25.0f / 250.0f)) / 2.0f;
    x.titleLocation = CPTDecimalFromDouble(([toDate timeIntervalSince1970] - [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970]) - 
                                           oneDay*titleOffsetPlace);
    
    //Labels
    NSDateFormatter *dateFormatter_day = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter_day.dateFormat = @"dd";
	CPTTimeFormatter *timeFormatter_day = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter_day] autorelease];
	timeFormatter_day.referenceDate = [[delegate.weightData objectAtIndex:0] objectForKey:@"date"];
    
    NSDateFormatter *dateFormatter_mounth = [[[NSDateFormatter alloc] init] autorelease];
    dateFormatter_mounth.dateFormat = @"MMM''yy";
	CPTTimeFormatter *timeFormatter_mounth = [[[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter_mounth] autorelease];
	timeFormatter_mounth.referenceDate = [[delegate.weightData objectAtIndex:0] objectForKey:@"date"];
    
    x.labelFormatter	 = timeFormatter_mounth;
    x.minorTickLabelFormatter = timeFormatter_day;
    
    
    NSTimeInterval startTimeInterval = ([fromDate timeIntervalSince1970] - [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970]);
    //x.labelingPolicy = CPTAxisLabelingPolicyFixedInterval;
    //x.minorTicksPerInterval = oneDay;
    //x.majorIntervalLength = CPTDecimalFromFloat(oneDay * 30);
    
    /*NSMutableSet *minorTickLocations = [NSMutableSet set];
    NSMutableSet *majorTickLocations = [NSMutableSet set];
    NSUInteger i, tickLength = 1;
    int curMonth = [self getIntegerDateComponent:fromDate byFormat:@"MM"];
    if(daysBetweenDates>21 && daysBetweenDates<150){
        tickLength = 7;
    };
    if(daysBetweenDates>=150){
        tickLength = INT32_MAX;
    };
    if(daysBetweenDates<=31 && [self getIntegerDateComponent:fromDate byFormat:@"MM"] == [self getIntegerDateComponent:toDate byFormat:@"MM"]){
        [majorTickLocations addObject:[NSDecimalNumber numberWithFloat:startTimeInterval]];
    }
	for (i=0; i <= daysBetweenDates; i ++ ) {
        NSTimeInterval curInt = startTimeInterval + oneDay*i;
        NSTimeInterval realDateInterval = [fromDate timeIntervalSince1970] + oneDay*i;
        NSDate *realDate = [NSDate dateWithTimeIntervalSince1970:realDateInterval];
        NSLog(@"Real day: %d", [self getIntegerDateComponent:realDate byFormat:@"dd"]);
		if([self getIntegerDateComponent:realDate byFormat:@"dd"] % tickLength == 0){
            [minorTickLocations addObject:[NSDecimalNumber numberWithFloat:curInt]];
        }
    
        if([self getIntegerDateComponent:realDate byFormat:@"MM"] != curMonth){
            [majorTickLocations addObject:[NSDecimalNumber numberWithFloat:curInt]];
            curMonth = [self getIntegerDateComponent:realDate byFormat:@"MM"];
        };
	};
    x.minorTickLocations = minorTickLocations;
    x.majorTickLocations = majorTickLocations;*/
    
    
    NSNumber *anchorX = [NSNumber numberWithFloat:startTimeInterval];
	NSNumber *anchorY = [NSNumber numberWithFloat:[delegate.normalWeight floatValue]];
	NSArray *anchorPoint = [NSArray arrayWithObjects:anchorX, anchorY, nil];
    normLineAnnotation.anchorPlotPoint = anchorPoint;

    //Add points labels
    CPTMutableTextStyle *pointLabelStyle = [CPTMutableTextStyle textStyle];
	pointLabelStyle.color	 = [CPTColor grayColor];
	pointLabelStyle.fontSize	 = 10.0;
    if(daysBetweenDates<=14){
        [graph plotWithIdentifier:kWeightLine].labelTextStyle	 = pointLabelStyle;
    };
    ////////////////////
    
    [self updatePlotRanges];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([fromDate timeIntervalSinceDate:[[delegate.weightData objectAtIndex:0] objectForKey:@"date"]]) length:CPTDecimalFromFloat([toDate timeIntervalSinceDate:fromDate])];
    //x.visibleRange = plotSpace.xRange;
    
    //CPTXYAxis *y = axisSet.yAxis;
    //x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat([fromDate timeIntervalSinceDate:[[delegate.weightData objectAtIndex:0] objectForKey:@"date"]]) length:CPTDecimalFromFloat([toDate timeIntervalSinceDate:fromDate])];
	//y.visibleRange = yRange;
    
    //[hostingView removeFromSuperview];
    //[self addSubview:hostingView];
};

- (void)updatePlotRanges{
    NSTimeInterval oneDay = 24 * 60 * 60;
    CPTGraph *graph = hostingView.hostedGraph;
    
    float minWeight = INFINITY;
    float maxWeight = 0.0f;
    float curWeight;
    for(NSDictionary *oneRec in delegate.weightData){
        curWeight = [[oneRec objectForKey:@"weight"] floatValue];
        if(curWeight < minWeight) minWeight = curWeight;
        if(curWeight > maxWeight) maxWeight = curWeight;
    };
    
    // Auto scale the plot space to fit the plot data
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    CPTMutablePlotRange *xRange = [[[CPTMutablePlotRange alloc] init] autorelease];
    CPTMutablePlotRange *yRange = [[[CPTMutablePlotRange alloc] init] autorelease];
    
    xRange.location = CPTDecimalFromFloat(0.0f/*startTimeInterval*/);
    xRange.length = CPTDecimalFromFloat([[[delegate.weightData lastObject] objectForKey:@"date"] timeIntervalSinceDate:[[delegate.weightData objectAtIndex:0] objectForKey:@"date"]] + oneDay * 365);
    
    float yRangeLocation = minWeight;
    float yRangeLength = maxWeight - minWeight;
    
    float deltaYRange = yRangeLocation - [delegate.normalWeight floatValue];
    if(deltaYRange > 0){
        yRangeLocation -= deltaYRange;
        yRangeLength += deltaYRange;
    };
    deltaYRange = (yRangeLocation + yRangeLength) - [delegate.normalWeight floatValue];
    if(deltaYRange < 0){
        yRangeLength -= deltaYRange;
    };
    
    yRange.location = CPTDecimalFromFloat(yRangeLocation);
    yRange.length = CPTDecimalFromFloat(yRangeLength);
    
    
    //CPTMutablePlotRange *myRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromInt(10) length:CPTDecimalFromInt(15)];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x = axisSet.xAxis;
    CPTXYAxis *y = axisSet.yAxis;
    
    //?????????
	//x.orthogonalCoordinateDecimal = yRange.location;
	//y.orthogonalCoordinateDecimal = xRange.location;
    
	//x.visibleRange = xRange;
	//y.visibleRange = yRange;
    
	//x.gridLinesRange = yRange;
    x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInt(0) length:CPTDecimalFromInt(200)];
	y.gridLinesRange = xRange;
    
	[xRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
	[yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
    
	plotSpace.xRange = xRange;
	plotSpace.yRange = yRange;
    
    y.titleLocation = yRange.end;
    x.titleLocation = xRange.end;

};


#pragma mark - CPTPlotDataSource delegate's functions

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot{
    return [delegate.weightData count];
};


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index{
    NSNumber *result;
    
    //return [NSNumber numberWithFloat:
    NSDate *curDate;
    NSTimeInterval timeInt;
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            curDate = [[delegate.weightData objectAtIndex:index] objectForKey:@"date"];
            timeInt = [curDate timeIntervalSince1970] - [[[delegate.weightData objectAtIndex:0] objectForKey:@"date"] timeIntervalSince1970];
            
            if(plot.identifier==kWeightLine){
                result = [NSNumber numberWithFloat:timeInt];
                NSLog(@"X-point: %.0f", timeInt);
            }else{
                result = [NSNumber numberWithFloat:timeInt];
            }
            
            break;
            
        case CPTScatterPlotFieldY:
            if(plot.identifier==kWeightLine){
                result = [NSNumber numberWithDouble:[[[delegate.weightData objectAtIndex:index] objectForKey:@"weight"] doubleValue]];
            }else if(plot.identifier==kNormalLine){
                result = [NSNumber numberWithFloat:[delegate.normalWeight floatValue]];
                //NSLog(@"Normal for index %d: %.0f", index, [result floatValue]);
            }else if(plot.identifier==kAimLine){
                result = [NSNumber numberWithFloat:[delegate.aimWeight floatValue]];
            };
            break;
            
        default:
            result = nil;
            break;
    }
    
    return result;
}

#pragma mark - CPTPlotSpaceDelegate functions

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
	// Impose a limit on how far user can scroll in x
    NSDate *firstDate = [[delegate.weightData objectAtIndex:0] objectForKey:@"date"];
    NSDate *lastDate = [[delegate.weightData lastObject] objectForKey:@"date"];
    NSTimeInterval oneDay = 60 * 60 *24;
	if ( coordinate == CPTCoordinateX ) {
		CPTPlotRange *maxRange			  = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat([lastDate timeIntervalSinceDate:firstDate] + oneDay * 30)];
		CPTMutablePlotRange *changedRange = [[newRange mutableCopy] autorelease];
		[changedRange shiftEndToFitInRange:maxRange];
		[changedRange shiftLocationToFitInRange:maxRange];
		newRange = changedRange;
	};
    
    if (coordinate == CPTCoordinateY){
        CPTPlotRange *maxRange			  = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(200.0f)];
		CPTMutablePlotRange *changedRange = [[newRange mutableCopy] autorelease];
		[changedRange shiftEndToFitInRange:maxRange];
		[changedRange shiftLocationToFitInRange:maxRange];
		newRange = changedRange;
    }
    
	return newRange;
}



@end