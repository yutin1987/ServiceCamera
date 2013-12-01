//
//  scCameraController.m
//  ServiceCamera
//
//  Created by Justin on 13/3/5.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//
#import "GAI.h"
#import "scCameraController.h"
#import "configs.h"
#import "scMoodController.h"
#import "scModelImage.h"

@interface scCameraController ()

@end

@implementation scCameraController

UIImage *picture;

UIView *controlView;

id<GAITracker> tracker;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self setDelegate:self];
    
    [self setSourceType:UIImagePickerControllerSourceTypeCamera];
    [self setAllowsEditing:NO];
    [self setShowsCameraControls:NO];
    
    tracker = [[GAI sharedInstance] defaultTracker];
    [tracker sendView:@"Camera View"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{   
    controlView = [[UIView alloc] init];
    [controlView setTransform: CGAffineTransformMakeRotation(M_PI * 90 / 180)];
    [controlView setFrame:[[UIScreen mainScreen] applicationFrame]];
    CGSize controlSize = controlView.bounds.size;
    
    UIView *maskTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, controlSize.width, 17.33)];
    [maskTop setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [controlView addSubview:maskTop];
    
    UIView *maskBottom = [[UIView alloc] initWithFrame:CGRectMake(0, controlSize.height - 17.33, controlSize.width, 17.33)];
    [maskBottom setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [controlView addSubview:maskBottom];
    
    UIView *maskLeft = [[UIView alloc] initWithFrame:CGRectMake(70.25, 19.33, 1, controlSize.height - 19.33 * 2)];
    [maskLeft setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [controlView addSubview:maskLeft];
    
    UIView *maskRight = [[UIView alloc] initWithFrame:CGRectMake(428 - 70.25, 19.33, 1, controlSize.height - 19.33 * 2)];
    [maskRight setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    [controlView addSubview:maskRight];
    
    UIImageView *toolbar = [[UIImageView alloc] init];
    [toolbar setFrame: CGRectMake( controlSize.width - 65, 0, 65, controlSize.height)];
    [toolbar setImage:[UIImage imageNamed:@"camera_bar.png"]];
    [controlView addSubview:toolbar];
    
    UIButton *takepictureBtn = [[UIButton alloc] init];
    [takepictureBtn setFrame: CGRectMake( controlSize.width - 60, controlSize.height / 2 - 45, 60, 90)];
    [takepictureBtn setImage:[UIImage imageNamed:@"camera_take.png"] forState:UIControlStateNormal];
    [takepictureBtn setImage:[UIImage imageNamed:@"camera_take_over.png"] forState:UIControlStateSelected];
    [takepictureBtn addTarget:self action:@selector(onTakePicture:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:takepictureBtn];
    
    UIButton *cancel = [[UIButton alloc] init];
    [cancel setFrame: CGRectMake( 5, 0, 43, 27)];
    [cancel setImage:[UIImage imageNamed:@"btn_list.png"] forState:UIControlStateNormal];
    [cancel setImage:[UIImage imageNamed:@"btn_list_over.png"] forState:UIControlStateSelected];
    [cancel addTarget:self action:@selector(onCancelPass:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cancel];
    
    [self setCameraOverlayView:controlView];
    
    scModelImage *images = [[scModelImage alloc]init];
    switch ([[images count] intValue]) {
        case 24: [self showCountWarning:@"There is only one left"]; break;
        case 23: [self showCountWarning:@"There are two pictures left"]; break;
        case 22: [self showCountWarning:@"There are three pictures left"]; break;
    }
    
}

- (void) showCountWarning:(NSString*)message
{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:message
                                                     message:nil
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [prompt show];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [controlView removeFromSuperview];
    controlView = nil;
    picture = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"moodView"])
    {
        scMoodController *moodView = [segue destinationViewController];
        [moodView setImage:picture];
    }
}

- (void)onCancelPass:(id)sender
{
    [self performSegueWithIdentifier:@"listView" sender:self];
    
    [tracker sendEventWithCategory:@"View" withAction:@"List" withLabel:@"Camera" withValue:0];
}

- (void)onTakePicture:(id)sender
{
    [self takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{   
    // Scale
    CGContextRef ctx;
    CGImageRef cgimg;
    
    //UIImageOrientation ori = image.imageOrientation;
    
    [tracker sendEventWithCategory:@"Camera" withAction:@"TakePicture" withLabel:nil withValue:[NSNumber numberWithInt:image.imageOrientation]];
    
    image = [UIImage imageWithCGImage:image.CGImage];
    
    float scale = 480 / image.size.width;
    
    ctx = CGBitmapContextCreate(NULL, 480, 320,
                                CGImageGetBitsPerComponent(image.CGImage), 0,
                                CGImageGetColorSpace(image.CGImage),
                                CGImageGetBitmapInfo(image.CGImage));
    CGContextScaleCTM(ctx, scale, scale);
    
    CGContextDrawImage(ctx, CGRectMake(0, (320 - 358.8) / 2,image.size.width,image.size.height), image.CGImage);
    cgimg = CGBitmapContextCreateImage(ctx);
    image = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    if (self.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                    CGImageGetBitsPerComponent(image.CGImage), 0,
                                    CGImageGetColorSpace(image.CGImage),
                                    CGImageGetBitmapInfo(image.CGImage));
        CGContextTranslateCTM(ctx, 1, -1);
        CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
        
        cgimg = CGBitmapContextCreateImage(ctx);
        image = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
    }
    
    picture = [UIImage imageWithCGImage:cgimg];
    
    [self performSegueWithIdentifier:@"moodView" sender:self];
}

@end
