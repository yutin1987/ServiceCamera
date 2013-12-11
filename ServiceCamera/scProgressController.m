//
//  scProgressController.m
//  ServiceCamera
//
//  Created by Justin on 13/3/20.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "GAI.h"
#import "scProgressController.h"
#import <AVFoundation/AVFoundation.h>
#import "scModelImage.h"

@interface scProgressController ()

@end

@implementation scProgressController

typedef NS_ENUM(NSInteger, Alert) {
    AlertOutput = 1,
    AlertDone = 2
};

int previewIndex = 0;

NSString *docPath;

NSArray *temp;

UIImageView *player;
UIProgressView *progress;

- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (BOOL)shouldAutorotate { return YES; }

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docPath = [paths objectAtIndex:0];
    
    self.trackedViewName = @"Preview View";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect app = self.view.bounds;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:app];
    [bg setImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view addSubview:bg];
    
    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(app.size.width * 5 / 12, app.size.height / 2 - 15 , app.size.width * 2 / 12, 30)];
    [progress setProgress:0];
    //[progress setProgressImage:[[UIImage imageNamed:@"progress_track.png"] resizableImageWithCapInsets:UIEdgeInsetsZero]];
    [progress setTransform:CGAffineTransformMakeScale(4.0, 4.0)];
    [self.view addSubview:progress];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, app.size.height / 2 + 30, app.size.width, 30)];
    [msg setText:@"film converting..."];
    [msg setFont:[UIFont fontWithName:SCFont size:26]];
    [msg setBackgroundColor:[UIColor clearColor]];
    [msg setTextColor:[UIColor whiteColor]];
    [msg setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:msg];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - (SCBtnSize.width + 5), 5,
                                                               SCBtnSize.width, SCBtnSize.height)];
    [btn setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBreakPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self performSelectorInBackground:@selector(makePicture) withObject:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

- (void)setPictureProgress:(NSNumber*)val
{
    float per = [val floatValue];
    NSLog(@"picture progress:%f",per);
    
    [progress setProgress:per];
}

- (void)setVideoProgress:(NSNumber*)val
{
    float per = [val floatValue];
    NSLog(@"video progress:%f",per);
    
    [progress setProgress:per];
}

- (void)onBackPress
{
    [self performSegueWithIdentifier:@"listView" sender:nil];
}

- (void)onMaskPass:(UIControl*)mask
{
    [mask removeFromSuperview];
    [player removeFromSuperview];
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Output"
                                                     message:@"Output this journey into video?" // IMPORTANT
                                                    delegate:self
                                           cancelButtonTitle:@"NO"
                                           otherButtonTitles:@"YES", nil];
    [prompt setTag:AlertOutput];
    [prompt show];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)index{
    switch (alert.tag) {
        case AlertOutput:
            if (index==1) {
                [self performSelectorInBackground:@selector(makeVideo) withObject:nil];
                [self.tracker sendEventWithCategory:@"Preview" withAction:@"Output" withLabel:@"execute" withValue:0];
            }else{
                [self performSegueWithIdentifier:@"listView" sender:nil];
                [self.tracker sendEventWithCategory:@"Preview" withAction:@"Output" withLabel:@"overleap" withValue:0];
                [self.tracker sendEventWithCategory:@"View" withAction:@"List" withLabel:@"Preview" withValue:0];
            }
            break;
        case AlertDone:
            [self performSegueWithIdentifier:@"listView" sender:nil];
            [self.tracker sendEventWithCategory:@"View" withAction:@"List" withLabel:@"Preview" withValue:0];
            break;
    }
}

- (void)onBreakPress:(UIButton *)btn
{
    [self performSegueWithIdentifier:@"listView" sender:self];
    
    [self.tracker sendEventWithCategory:@"Preview" withAction:@"Break" withLabel:nil withValue:0];
    [self.tracker sendEventWithCategory:@"View" withAction:@"List" withLabel:@"Preview" withValue:0];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    [player setImage:[UIImage imageWithContentsOfFile:[temp objectAtIndex:previewIndex]]];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    if (flag!=true) {
        return;
    }
    
    previewIndex++;
    if (previewIndex >= [temp count]) {
        [self animation:[temp objectAtIndex:previewIndex-1] to:[temp objectAtIndex:0]];
        previewIndex = 0;
    }else{
        [self animation:[temp objectAtIndex:previewIndex-1] to:[temp objectAtIndex:previewIndex]];
    }
}

- (void)animation:(NSString *)from to:(NSString *)to
{
    CABasicAnimation *anime = [CABasicAnimation animationWithKeyPath:@"contents"];
    [anime setDuration:SCVideoTrans];
    [anime setBeginTime:CACurrentMediaTime()+SCVideoStay];
    [anime setDelegate:self];
    [anime setFromValue:(id)[UIImage imageWithContentsOfFile:from].CGImage];
    [anime setToValue:(id)[UIImage imageWithContentsOfFile:to].CGImage];
    [player.layer addAnimation:anime forKey:@"animateContents"];
}

- (void)makePicture
{
    CGRect appFrame = self.view.bounds;
    
    [self performSelectorOnMainThread:@selector(setPictureProgress:) withObject:[NSNumber numberWithFloat:0] waitUntilDone:NO];
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *title = [user stringForKey:@"title"];
    NSString *describe = [user stringForKey:@"describe"];
    
    scModelImage *images = [[scModelImage alloc] init];
    
    NSArray *list = [images fetch];
    
    NSMutableArray *_list = [NSMutableArray arrayWithCapacity:0];
    
    // Title
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCPicSize.width, SCPicSize.height)];
    [titleView setBackgroundColor:[UIColor blackColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCPicSize.width/6, 0, SCPicSize.width * 2/3, SCPicSize.height * 2/3)];
    [titleLabel setText:title];
    [titleLabel setFont:[UIFont fontWithName:SCFont size:32]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setNumberOfLines:0];
    [titleView addSubview:titleLabel];
    
    UILabel *describeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCPicSize.width/6, SCPicSize.height * 1/3,
                                                                       SCPicSize.width * 2/3, SCPicSize.height * 2/3)];
    [describeLabel setText:describe];
    [describeLabel setFont:[UIFont fontWithName:SCFont size:22]];
    [describeLabel setBackgroundColor:[UIColor clearColor]];
    [describeLabel setTextColor:[UIColor whiteColor]];
    [describeLabel setTextAlignment:NSTextAlignmentCenter];
    [describeLabel setNumberOfLines:0];
    [titleView addSubview:describeLabel];
    
    UIGraphicsBeginImageContextWithOptions(titleView.bounds.size, titleView.opaque, 0.0);
    [titleView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *titleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSString *path = [docPath stringByAppendingPathComponent: [[NSString alloc] initWithFormat:SCFileOutput,  0]];
    NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(titleImage, 1)];
    [data writeToFile:path atomically:YES];
    
    [_list addObject:path];
    
    for (NSDictionary *item in list) {
        int pid = [[item objectForKey:@"pid"] intValue];
        int mood = [[item objectForKey:@"mood"] intValue];
        NSString *original = [item objectForKey:@"original"];
        NSString *note = [item objectForKey:@"note"];
        
        // Picture
        UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCPicSize.width, SCPicSize.height)];
        
        
        UIImageView *picture = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCPicSize.width, SCPicSize.height)];
        [picture setImage:[UIImage imageWithContentsOfFile:original]];
        [tempView addSubview:picture];
        
        UIImageView *moodView = [[UIImageView alloc] initWithFrame:CGRectMake(SCPicSize.width - SCMoodSize.width - 10, 10,
                                                                              SCMoodSize.width, SCMoodSize.height)];
        [moodView setImage:[UIImage imageNamed: [NSString stringWithFormat:SCFileMood,  mood]]];
        [tempView addSubview:moodView];
        
        
        if (note && note.length > 0) {
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, tempView.bounds.size.height - SCNoteSize.height,
                                                                      tempView.bounds.size.width, SCNoteSize.height)];
            [text setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8f]];
            [text setTextColor:[UIColor whiteColor]];
            [text setText:note];
            [text setTextAlignment:NSTextAlignmentCenter];
            [text setFont:[UIFont fontWithName:SCFont size:SCNoteTextSize]];
            [tempView addSubview:text];
        }
        
        UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, tempView.opaque, 0.0);
        [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *tempPicture = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        NSString *path = [docPath stringByAppendingPathComponent: [[NSString alloc] initWithFormat:SCFileOutput,  pid]];
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(tempPicture, 1)];
        [data writeToFile:path atomically:YES];
        
        [_list addObject:path];
        
        [self performSelectorOnMainThread:@selector(setPictureProgress:) withObject:[NSNumber numberWithFloat:(float)_list.count / (float)list.count] waitUntilDone:NO];
    }
    
    [self performSelectorOnMainThread:@selector(setPictureProgress:) withObject:[NSNumber numberWithFloat:1] waitUntilDone:NO];
    
    temp = _list;
    
    player = [[UIImageView alloc] initWithFrame:appFrame];
    [player setImage:[UIImage imageWithContentsOfFile:[temp objectAtIndex:0]]];
    [self.view addSubview:player];
    
    previewIndex = 1;
    [self animation:[temp objectAtIndex:0] to:[temp objectAtIndex:1]];
    
    UIControl *mask = [[UIControl alloc] initWithFrame:appFrame];
    [mask addTarget:self action:@selector(onMaskPass:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:mask];
}

-(void)makeVideo
{
    [self performSelectorOnMainThread:@selector(setVideoProgress:) withObject:[NSNumber numberWithFloat:0] waitUntilDone:NO];
    
    [NSThread sleepForTimeInterval:0.01];
    
    // Set Video Path
    NSString *videoPath = [docPath stringByAppendingPathComponent:SCFileVideo];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath: videoPath]) {
        [fileManager removeItemAtPath: videoPath error:NULL];
    }
    
    NSError *error = nil;
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:
                                  [NSURL fileURLWithPath:videoPath] fileType:AVFileTypeMPEG4
                                                              error:&error];
    
    if(error) {
        NSLog(@"error creating AssetWriter: %@",[error description]);
    }
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   AVVideoCodecH264, AVVideoCodecKey,
                                   [NSNumber numberWithInt:SCPicSize.width], AVVideoWidthKey,
                                   [NSNumber numberWithInt:SCPicSize.height], AVVideoHeightKey,
                                   nil];
    
    AVAssetWriterInput* writerInput = [AVAssetWriterInput
                                       assetWriterInputWithMediaType:AVMediaTypeVideo
                                       outputSettings:videoSettings];
    
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    [attributes setObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_32ARGB] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:SCPicSize.width] forKey:(NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithUnsignedInt:SCPicSize.height] forKey:(NSString*)kCVPixelBufferHeightKey];
    
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [[AVAssetWriterInputPixelBufferAdaptor alloc] initWithAssetWriterInput:writerInput sourcePixelBufferAttributes:attributes];
    
    [videoWriter addInput:writerInput];
    
    // fixes all errors
    writerInput.expectsMediaDataInRealTime = YES;
    
    //Start a session:
    BOOL start = [videoWriter startWriting];
    NSLog(@"Session started? %d", start);
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    
    [NSThread sleepForTimeInterval:0.01];
    
    UIImage *nowPicture = [UIImage imageWithContentsOfFile:[temp objectAtIndex:0]] ;
    CVPixelBufferRef buffer = [self stayBuffer:[nowPicture CGImage]];
    BOOL result = [adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero];
    CVBufferRelease(buffer);
    
    if (result == NO) //failes on 3GS, but works on iphone 4
    {
        NSLog(@"failed to append buffer");
        NSLog(@"The error is %@", [videoWriter error]);
    }
    
    float transPer = 0.5 / (float)temp.count;
    for (int i=0; i<temp.count; i++) {
        NSString *nowPath = [temp objectAtIndex:i];
        do {
            [NSThread sleepForTimeInterval:0.01];
        } while(!adaptor.assetWriterInput.readyForMoreMediaData);
        [NSThread sleepForTimeInterval:1];
        
        NSLog(@"inside for loop %d %@ ",i, nowPath);
        
        float pos = i * SCVideoFrame * (SCVideoStay + SCVideoTrans) + (SCVideoStay * SCVideoFrame);
        
        UIImage *nowPicture = [UIImage imageWithContentsOfFile:nowPath] ;
        CVPixelBufferRef buffer = [self stayBuffer:[nowPicture CGImage]];
        [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(pos, SCVideoFrame)];
        CVBufferRelease(buffer);
        
        float itemPer = ((float)i+0.5)/(float)temp.count;
        [self performSelectorOnMainThread:@selector(setVideoProgress:) withObject:[NSNumber numberWithFloat:itemPer] waitUntilDone:NO];
        
        if (i<(temp.count-1)) {
            for (int j=0; j<SCVideoTrans * SCVideoFrame; j+=2) {
                do {
                    [NSThread sleepForTimeInterval:0.01];
                } while(!adaptor.assetWriterInput.readyForMoreMediaData);
                
                NSString *nextPath = [temp objectAtIndex:i+1];
                UIImage *nextPicture = [UIImage imageWithContentsOfFile:nextPath] ;
                
                CVPixelBufferRef buffer = [self transBuffer: j / (SCVideoTrans * SCVideoFrame) from:[nowPicture CGImage] to:[nextPicture CGImage]];
                [adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(pos + (j+1), SCVideoFrame)];
                CVBufferRelease(buffer);
                
                [self performSelectorOnMainThread:@selector(setVideoProgress:) withObject:[NSNumber numberWithFloat:itemPer + transPer * (((float)j+1) / (SCVideoTrans * SCVideoFrame)) - 0.1] waitUntilDone:NO];
            }
        }
        
        [self performSelectorOnMainThread:@selector(setVideoProgress:) withObject:[NSNumber numberWithFloat:((float)i+1)/(float)temp.count] waitUntilDone:NO];
    }
    
    //Finish the session:
    [writerInput markAsFinished];
    [self performSelectorOnMainThread:@selector(setVideoProgress:) withObject:[NSNumber numberWithFloat:0.90] waitUntilDone:NO];
    [videoWriter finishWritingWithCompletionHandler:^(){
        NSLog (@"finished writing");
        CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
        
        UISaveVideoAtPathToSavedPhotosAlbum(videoPath,nil,nil,nil);
        
        
        [self performSelectorOnMainThread:@selector(setVideoProgress:) withObject:[NSNumber numberWithFloat:1] waitUntilDone:NO];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Done!"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert setTag:AlertDone];
        [alert show];
    }];
    
    do {
        if (videoWriter.status == AVAssetWriterStatusFailed) {
            NSLog (@"Writer, error: %@", videoWriter.error);
        }else if (videoWriter.status == AVAssetWriterStatusWriting){
            NSLog (@"Writer, writing: %@", videoWriter.error);
        }
    } while (videoWriter.status == AVAssetWriterStatusWriting);

}

- (CVPixelBufferRef) stayBuffer: (CGImageRef) image
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                        CGImageGetHeight(image), kCVPixelFormatType_32ARGB, CFBridgingRetain(options),
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

- (CVPixelBufferRef) transBuffer:(float)percentage from:(CGImageRef)from to:(CGImageRef)to
{
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CVPixelBufferCreate(kCFAllocatorDefault, SCPicSize.width, SCPicSize.height, kCVPixelFormatType_32ARGB, CFBridgingRetain(options), &pxbuffer);
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(pxdata, SCPicSize.width, SCPicSize.height,
                                                 8, 4 * SCPicSize.width, rgbColorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrderDefault);
//    CGContextSetAlpha(context, percentage);
    CGContextDrawImage(context, CGRectMake(0, 0, SCPicSize.width, SCPicSize.height), to);
    
//    CGContextSetAlpha(context, 1 - percentage);
    CGContextDrawImage(context, CGRectMake(0, 0, SCPicSize.width, SCPicSize.height), from);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

@end
