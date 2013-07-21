//
//  scMoodController.m
//  ServiceCamera
//
//  Created by Justin on 13/3/5.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "GAI.h"
#import "configs.h"
#import "scMoodController.h"
#import "scCameraController.h"
#import "scModelImage.h"

@interface scMoodController ()

@end

@implementation scMoodController

@synthesize image;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.trackedViewName = @"Mood View";
}
     
- (void)viewDidAppear:(BOOL)animated
{
    
    CGRect appFrame = self.view.bounds;
    
    CGSize moodSize = CGSizeMake(51, 51);
    
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView setFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    [imgView setImage:image];
    
    [self.view addSubview:imgView];
    
    UIView *toolbar = [[UIView alloc] initWithFrame: CGRectMake(appFrame.size.width - 60, 0, 60, appFrame.size.height)];
    
    for(int i = 0;i < 5;i = i + 1)
    {
        UIButton *mood = [[UIButton alloc] init];
        mood.tag = i+1;
        [mood setFrame: CGRectMake( (toolbar.bounds.size.width - moodSize.width) / 2, i*(moodSize.height+1) + 3, moodSize.width, moodSize.height)];
        NSString *iconName;
        iconName = [[NSString alloc] initWithFormat:@"mood_%d.png",  i+1];
        [mood setImage:[UIImage imageNamed: iconName] forState:UIControlStateNormal];
        iconName = [[NSString alloc] initWithFormat:@"mood_%d_over.png",  i+1];
        [mood setImage:[UIImage imageNamed: iconName] forState:UIControlStateSelected];
        [mood addTarget:self action:@selector(onSavePass:) forControlEvents:UIControlEventTouchUpInside];
        [toolbar addSubview:mood];
    }
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    [cancelBtn setFrame: CGRectMake( (toolbar.bounds.size.width - 40) / 2, (appFrame.size.height - 50), 40, 40)];
    [cancelBtn setImage:[UIImage imageNamed: @"btn_cancel.png"] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(onCancelPass:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:cancelBtn];
    
    [self.view addSubview:toolbar];
    
    scModelImage *images = [[scModelImage alloc] init];
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 60, 20)];
    [count setText:[NSString stringWithFormat:@"%d/25", [[images count] intValue]+1]];
    [count setFont:[UIFont fontWithName:SCFont size:20]];
    [count setBackgroundColor:[UIColor clearColor]];
    [count setTextColor:[UIColor whiteColor]];
    [self.view addSubview:count];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    image = nil;
}

- (void)onSavePass:(id)sender
{
    scModelImage *images = [[scModelImage alloc] init];
    
    UIButton* btn = sender;
    [images add:image mood:btn.tag];
    
    if ([[images count] intValue] < 25) {
        [self performSegueWithIdentifier:@"cameraView" sender:self];
        [self.tracker sendEventWithCategory:@"View" withAction:@"Camera" withLabel:@"Mood" withValue:0];
    }else{
        [self performSegueWithIdentifier:@"listView" sender:self];
        [self.tracker sendEventWithCategory:@"View" withAction:@"List" withLabel:@"Mood" withValue:0];
    }
    
    [self.tracker sendEventWithCategory:@"Camera" withAction:@"Mood" withLabel:@"Save" withValue:[NSNumber numberWithInt:btn.tag]];
}

-(void)onCancelPass:(id)sender
{
    [self performSegueWithIdentifier:@"cameraView" sender:self];
    
    [self.tracker sendEventWithCategory:@"Camera" withAction:@"Mood" withLabel:@"Cancel" withValue:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
