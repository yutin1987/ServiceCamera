//
//  scOutputController.m
//  ServiceCamera
//
//  Created by Justin on 13/3/11.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "scOutputController.h"
#import "scProgressController.h"
#import "scModelImage.h"

@interface scOutputController ()

@end

@implementation scOutputController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    
    CGRect appFrame = self.view.bounds;
    CGSize appSize = self.view.bounds.size;
    CGFloat offset = 50;
    CGFloat pos = (appSize.width - offset) / 6;
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:appFrame];
    [bg setImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view addSubview:bg];
    
    UIButton *btn_back = [[UIButton alloc] init];
    [btn_back setFrame: CGRectMake( 5, appSize.height - 39 - 5, 43, 39)];
    [btn_back setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [btn_back setImage:[UIImage imageNamed:@"btn_back_over.png"] forState:UIControlStateSelected];
    [btn_back addTarget:self action:@selector(onBackPass:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn_back];
    
    NSArray *mood = [NSArray arrayWithObjects: @"mode_original.png", @"mode_concepts.png", @"mode_comparison.png",nil];
    
    for(int i = 0; i < [mood count]; i++)
    {
        NSString *item = [mood objectAtIndex:i];
        
        CGRect picFrame = CGRectMake(offset / 2 + pos * (i * 2 + 1) - 66, 56, 132, 165);
        
        UIView *picView = [[UIView alloc] initWithFrame:picFrame];
        
        CGRect moodFrame = CGRectMake(0, 0, 132.5, 26);
        UIImageView *modeView = [[UIImageView alloc] initWithFrame:moodFrame];
        [modeView setImage:[UIImage imageNamed:item]];
        [picView addSubview:modeView];
        
        CGRect frameFrame = CGRectMake(0, 32, 132, 133);
        UIImageView *frameView = [[UIImageView alloc] initWithFrame:frameFrame];
        [frameView setImage:[UIImage imageNamed:@"list_frame.png"]];
        [picView addSubview:frameView];
        
        CGRect btnPlayFrame = CGRectMake((picFrame.size.width - 43) / 2, (frameFrame.size.height - 46.5) / 2 + moodFrame.size.height, 43, 46.5);
        UIButton *btnPlay = [[UIButton alloc] initWithFrame:btnPlayFrame];
        [btnPlay setImage:[UIImage imageNamed:@"btn_save.png"] forState:UIControlStateNormal];
        [btnPlay addTarget:self action:@selector(onSavePass:) forControlEvents:UIControlEventTouchUpInside];
        [btnPlay setTag:i];
        [picView addSubview:btnPlay];
        
        [self.view addSubview:picView];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*
    if ([[segue identifier] isEqualToString:@"moodView"])
    {
        scProgressController *progressView = [segue destinationViewController];
        [progressView setTag:<#(NSInteger)#>];
    }
     */
}

- (void)onBackPass:(id)sender
{
    [self performSegueWithIdentifier:@"listView" sender:self];
}

-(void)onSavePass:(id)sender
{
    /*
    UIButton *btn = sender;
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    scModelVideo *video = [[scModelVideo alloc] initWithTitle:[user stringForKey:@"title"]];
    
    scModelImage *images = [[scModelImage alloc] init];
    [video setPicture:[images fetch]];
    [video setMode:btn.tag];
    [video output];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"Done!"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
