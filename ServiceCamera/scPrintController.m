//
//  scPrintController.m
//  ServiceCamera
//
//  Created by Justin on 13/4/4.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "GAI.h"
#import "configs.h"
#import "scModelImage.h"
#import "scPrintController.h"
#import <QuartzCore/QuartzCore.h>

@interface scPrintController ()

@end

@implementation scPrintController

UIProgressView *progress;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIColor *bg = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view setBackgroundColor:bg];
    
    self.trackedViewName = @"Print View";
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect app = self.view.bounds;
    
    progress = [[UIProgressView alloc] initWithFrame:CGRectMake(app.size.width * 5 / 12, app.size.height / 2 - 15 , app.size.width * 2 / 12, 30)];
    [progress setProgress:0];
    [progress setTransform:CGAffineTransformMakeScale(4.0, 4.0)];
    [self.view addSubview:progress];
    
    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(0, app.size.height / 2 + 30, app.size.width, 30)];
    [msg setText:@"print..."];
    [msg setFont:[UIFont fontWithName:SCFont size:26]];
    [msg setBackgroundColor:[UIColor clearColor]];
    [msg setTextColor:[UIColor whiteColor]];
    [msg setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:msg];
    
    [self performSelectorInBackground:@selector(makePrint) withObject:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProgress:(NSNumber*)val
{
    float per = [val floatValue];
    [progress setProgress:per];
}

- (void)onDone
{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Donw"
                                                     message:nil
                                                    delegate:self
                                           cancelButtonTitle:nil
                                           otherButtonTitles:@"OK", nil];
    [prompt show];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)index{
    [self performSegueWithIdentifier:@"listView" sender:nil];
    
    [self.tracker sendEventWithCategory:@"Print" withAction:@"Done" withLabel:nil withValue:0];
}

- (void)makePrint
{
    const float PrintHeight = 900;
    
    const CGSize thumbSize = {SCThumbSize.width * SCPrintScale, SCThumbSize.height * SCPrintScale};
    const float thumbMargin = SCThumbMargin * SCPrintScale;
    const float thumbTop = 66;
    const CGSize moodSize = {SCMoodSize.width * SCPrintScale, SCMoodSize.height * SCPrintScale};
    
    [self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:0] waitUntilDone:NO];
    
    scModelImage *images = [[scModelImage alloc]init];
    NSArray *imgs = [images fetch];
    
    UIView *tempView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,(thumbMargin + thumbSize.width) * (imgs.count+1) + thumbMargin, PrintHeight)];
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"print_bg.png"]];
    [tempView setBackgroundColor:background];
    
    CGRect picFrame = CGRectMake(thumbMargin, thumbTop, thumbSize.width, thumbSize.height * 2);
    
    int moodTotal = 0;
    for (int i=0; i<imgs.count; i++){
        NSDictionary *item = [imgs objectAtIndex:i];
        int mood = [[item objectForKey:@"mood"] intValue];
        NSString *original = [item objectForKey:@"original"];
        NSString *note = [item objectForKey:@"note"];
        
        moodTotal += mood;
        
        picFrame.origin.x += thumbSize.width + thumbMargin;
        UIView *picView = [[UIView alloc] initWithFrame:picFrame];
        
        
        float thumbPadding = SCThumbPadding*SCPrintScale;
        
        float scale = (thumbSize.height - thumbPadding*2) / SCPicSize.height;
        
        
        UIView *imgMask = [[UIImageView alloc] initWithFrame:CGRectMake(thumbPadding, thumbPadding,
                                                                        thumbSize.width - thumbPadding*2,
                                                                        thumbSize.height - thumbPadding*2)];
        [imgMask.layer setMasksToBounds:YES];
        [imgMask.layer setCornerRadius:SCThumbRadius * SCPrintScale];
        [picView addSubview:imgMask];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(((thumbSize.width - thumbPadding*2) - SCPicSize.width * scale) / 2,
                                                                             0,
                                                                             SCPicSize.width * scale,
                                                                             SCPicSize.height * scale)];
        [imgView setImage:[UIImage imageWithContentsOfFile:original]];
        [imgView.layer setMasksToBounds:YES];
        [imgView.layer setCornerRadius:SCThumbRadius * SCPrintScale];
        [imgMask addSubview:imgView];
        
        UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
        [frameView setImage:[UIImage imageNamed:@"list_frame.png"]];
        [picView addSubview:frameView];
        
        UIImageView *moodView = [[UIImageView alloc] initWithFrame:CGRectMake(thumbSize.width - moodSize.width - thumbSize.width*1/20, thumbSize.height*1/20,
                                                                              moodSize.width, moodSize.height)];
        NSString *moodName = [[NSString alloc] initWithFormat:SCFileMood,  mood];
        [moodView setImage:[UIImage imageNamed:moodName]];
        [picView addSubview:moodView];
        
        if (note && note.length > 0) {
            UILabel *noteText = [[UILabel alloc] initWithFrame:CGRectMake(SCThumbTextPadding*SCPrintScale, thumbSize.height,
                                                                          thumbSize.width - SCThumbTextPadding*SCPrintScale*2, thumbSize.height * 2/3 * 2/3)];
            [noteText setText:note];
            [noteText setFont:[UIFont fontWithName:SCFont size:SCThumbNote*SCPrintScale*2/3]];
            [noteText setBackgroundColor:[UIColor clearColor]];
            [noteText setTextColor:[UIColor blackColor]];
            [noteText setNumberOfLines:3];
            [picView addSubview:noteText];
        }
        
        [tempView addSubview:picView];
        
        [self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:((float)i+1)/(imgs.count+1)] waitUntilDone:NO];
    }
    
    // Title PicView
    UIView *picView = [[UIView alloc] initWithFrame:CGRectMake(thumbMargin + 20, thumbTop, thumbSize.width, thumbSize.height)];
    
    UIImageView *titleBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, thumbSize.width, thumbSize.height)];
    [titleBg setImage:[UIImage imageNamed:@"list_title.png"]];
    [picView addSubview:titleBg];
    
    if(imgs.count>0)
    {
        int mood = round(moodTotal / imgs.count);
        UIImageView *moodView = [[UIImageView alloc] initWithFrame:CGRectMake(-moodSize.width*1/3, thumbSize.height - moodSize.height*2/3,
                                                                              moodSize.width, moodSize.height)];
        NSString *moodName = [[NSString alloc] initWithFormat:@"mood_%d.png",  mood];
        [moodView setImage:[UIImage imageNamed:moodName]];
        [picView addSubview:moodView];
    }
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(SCThumbTextPadding*SCPrintScale, thumbSize.height*1/10,
                                                               thumbSize.width - SCThumbTextPadding*SCPrintScale*2, thumbSize.height * 1/2)];
    [title setText:[user stringForKey:@"title"]];
    [title setFont:[UIFont fontWithName:SCFont size:SCThumbTitle * SCPrintScale]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setTextColor:[UIColor whiteColor]];
    [title setNumberOfLines:2];
    [picView addSubview:title];
    
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(thumbSize.width*1/2, thumbSize.height*3/5, thumbSize.width*1/2, SCThumbTitle * SCPrintScale * 1.2)];
    [count setText:[NSString stringWithFormat:@"%d", [imgs count]]];
    [count setNumberOfLines:1];
    [count setFont:[UIFont fontWithName:SCFont size:SCThumbTitle * SCPrintScale]];
    [count setTextColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]];
    [count setBackgroundColor:[UIColor clearColor]];
    [picView addSubview:count];
    
    [tempView addSubview:picView];
    
    UIGraphicsBeginImageContextWithOptions(tempView.bounds.size, tempView.opaque, 0.0);
    [tempView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *tempPicture = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(tempPicture, nil, nil, nil);
    
    [self performSelectorOnMainThread:@selector(setProgress:) withObject:[NSNumber numberWithFloat:1] waitUntilDone:NO];
    
    
    CGRect app = self.view.bounds;
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - (SCBtnSize.width + 5), 5,
                                                               SCBtnSize.width, SCBtnSize.height)];
    [btn setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBreakPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self onDone];
}

- (void)onBreakPress:(UIButton *)btn
{
    [self performSegueWithIdentifier:@"listView" sender:self];
    
    [self.tracker sendEventWithCategory:@"Print" withAction:@"Break" withLabel:nil withValue:0];
}

@end
