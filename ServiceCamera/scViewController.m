//
//  scViewController.m
//  ServiceCamera
//
//  Created by Justin on 13/2/17.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "GAI.h"
#import "configs.h"
#import "scViewController.h"
#import "scModelImage.h"

#import <QuartzCore/QuartzCore.h>

@interface scViewController ()

@end

NSUserDefaults *user;

UILabel *titleLabel;
UIScrollView *waterfallView;
UIButton *btnActive;

@implementation scViewController

int pid;

int describeLine;

typedef NS_ENUM(NSInteger, Break) {
    BreakTitle   = 1,
    BreakNote    = 2
};

typedef NS_ENUM(NSUInteger, AlertViewTag){
    AlertViewTagClear = 1,
    AlertViewTagDel = 2
};

- (NSUInteger)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (BOOL)shouldAutorotate { return YES; }

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.trackedViewName = @"List View";
    
    user = [NSUserDefaults standardUserDefaults];
}

- (void)viewDidAppear:(BOOL)animated
{
    CGRect fullScreen = [[UIScreen mainScreen] bounds];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, fullScreen.size.height, fullScreen.size.width)];
    [bg setImage:[UIImage imageNamed:@"background.jpg"]];
    [self.view addSubview:bg];
    
    waterfallView = [[UIScrollView alloc] initWithFrame: CGRectMake(0, 0, fullScreen.size.height, fullScreen.size.width)];
    [waterfallView setShowsHorizontalScrollIndicator:NO];
    [waterfallView setShowsVerticalScrollIndicator:NO];
    [waterfallView setScrollsToTop:NO];
    [waterfallView setDelegate:self];
    [self.view addSubview: waterfallView];
    
    [self drawWaterfall];
    
    UIButton *cameraBtn = [[UIButton alloc] initWithFrame:CGRectMake( 5, 0, SCBtnSwitchSize.width, SCBtnSwitchSize.height)];
    [cameraBtn setImage:[UIImage imageNamed:@"btn_camera.png"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(onCameraPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    
    NSStringFromSelector(@selector(onClearPress:));
    
    NSArray *menu = [NSArray arrayWithObjects:
                     [NSDictionary dictionaryWithObjectsAndKeys: @"btn_cleaner.png", @"img", [NSValue valueWithPointer:@selector(onClearPress:)], @"action", nil],
                     [NSDictionary dictionaryWithObjectsAndKeys: @"btn_print.png", @"img", [NSValue valueWithPointer:@selector(onPrintPress:)], @"action", nil],
                     [NSDictionary dictionaryWithObjectsAndKeys: @"btn_preview.png", @"img", [NSValue valueWithPointer:@selector(onPlayPress:)], @"action", nil],
                     nil];
    
    for (int i=0; i<menu.count; i++) {
        NSDictionary *item = [menu objectAtIndex:i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake((5 + SCBtnSize.width) * i + 5, fullScreen.size.width - SCBtnSize.height - 5,
                                                                   SCBtnSize.width, SCBtnSize.height)];
        [btn setImage:[UIImage imageNamed:[item objectForKey:@"img"]] forState:UIControlStateNormal];
        [btn addTarget:self action:[[item objectForKey:@"action"] pointerValue] forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)drawWaterfall
{   
    [waterfallView.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    
    CGRect picFrame = CGRectMake(SCThumbMargin + 20, 30, SCThumbSize.width, SCThumbSize.height * 2);
    
    scModelImage *images = [[scModelImage alloc]init];
    NSArray *imgs = [images fetchAll];
    
    int moodTotal = 0;
    for (NSDictionary *item in imgs){
        int pid = [[item objectForKey:@"pid"] intValue];
        int mood = [[item objectForKey:@"mood"] intValue];
        int hide = [[item objectForKey:@"hide"] intValue];
        NSString *original = [item objectForKey:@"original"];
        NSString *note = [item objectForKey:@"note"];
        
        moodTotal += mood;
        
        picFrame.origin.x += SCThumbSize.width + SCThumbMargin;
        
        UIView *picView = [[UIView alloc] initWithFrame:picFrame];
        [picView setTag:pid];
        [waterfallView addSubview:picView];
        
        float scale = (SCThumbSize.height - SCThumbPadding*2) / SCPicSize.height;
        
        
        UIView *imgMask = [[UIImageView alloc] initWithFrame:CGRectMake(SCThumbPadding, SCThumbPadding,
                                                                        SCThumbSize.width - SCThumbPadding*2,
                                                                        SCThumbSize.height - SCThumbPadding*2)];
        [imgMask.layer setMasksToBounds:YES];
        [imgMask.layer setCornerRadius:SCThumbRadius];
        [picView addSubview:imgMask];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(((SCThumbSize.width - SCThumbPadding*2) - SCPicSize.width * scale) / 2,
                                                                             0,
                                                                             SCPicSize.width * scale,
                                                                             SCPicSize.height * scale)];
        [imgView setImage:[UIImage imageWithContentsOfFile:original]];
        [imgView.layer setMasksToBounds:YES];
        [imgView.layer setCornerRadius:SCThumbRadius];
        [imgMask addSubview:imgView];
        
        UIImageView *frameView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCThumbSize.width, SCThumbSize.height)];
        [frameView setImage:[UIImage imageNamed:@"list_frame.png"]];
        [frameView setTag:pid];
        [frameView setUserInteractionEnabled:YES];
        [picView addSubview:frameView];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                              initWithTarget:self action:@selector(handleSingleTap:)];
        singleTapGestureRecognizer.numberOfTapsRequired = 1;
        [singleTapGestureRecognizer requireGestureRecognizerToFail: doubleTapGestureRecognizer];
        
        [frameView addGestureRecognizer:doubleTapGestureRecognizer];
        [frameView addGestureRecognizer:singleTapGestureRecognizer];
        
        UIImageView *moodView = [[UIImageView alloc] initWithFrame:CGRectMake(SCThumbSize.width - SCMoodSize.width - SCThumbSize.width*1/20, SCThumbSize.height*1/20,
                                                                              SCMoodSize.width, SCMoodSize.height)];
        NSString *moodName = [[NSString alloc] initWithFormat:SCFileMood,  mood];
        [moodView setImage:[UIImage imageNamed:moodName]];
        [picView addSubview:moodView];
        
        if(hide){
            UIButton *hideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCThumbSize.width, SCThumbSize.height)];
            [hideBtn setImage:[UIImage imageNamed:@"list_hide.png"] forState:UIControlStateNormal];
            [hideBtn addTarget:self action:@selector(onShowPress:) forControlEvents:UIControlEventTouchUpInside];
            [picView addSubview:hideBtn];
        }
        
        UIButton *btnNote = [[UIButton alloc] init];
        [btnNote addTarget:self action:@selector(onNotePress:) forControlEvents:UIControlEventTouchUpInside];
        if (note && note.length > 0) {
            [btnNote setFrame:CGRectMake(0, SCThumbSize.height * 4/5, SCThumbSize.width, SCThumbSize.height)];
            [btnNote setImage:[UIImage imageNamed:@"list_note.png"] forState:UIControlStateNormal];
            [picView insertSubview:btnNote atIndex:0];
            
            UILabel *noteText = [[UILabel alloc] initWithFrame:CGRectMake(SCThumbTextPadding, SCThumbSize.height,
                                                                          SCThumbSize.width - SCThumbTextPadding*2, SCThumbSize.height * 2/3)];
            [noteText setText:note];
            [noteText setFont:[UIFont fontWithName:SCFont size:20]];
            [noteText setBackgroundColor:[UIColor clearColor]];
            [noteText setTextColor:[UIColor whiteColor]];
            [noteText setNumberOfLines:3];
            [picView addSubview:noteText];
        }else{
            [btnNote setFrame:CGRectMake(SCThumbSize.width - SCPenSize.width * 4/3, SCThumbSize.height - 8, SCPenSize.width, SCPenSize.height)];
            [btnNote setImage:[UIImage imageNamed:@"btn_pen.png"] forState:UIControlStateNormal];
            [picView addSubview:btnNote];
        }
        
        [waterfallView addSubview:picView];
    }
    
    [waterfallView setContentSize:CGSizeMake((SCThumbSize.width + SCThumbMargin) * (imgs.count+1) + SCThumbMargin + 20,
                                             [[UIScreen mainScreen] bounds].size.width)];
    
    // Title PicView
    UIView *picView = [[UIView alloc] initWithFrame:CGRectMake(SCThumbMargin + 20, 30, SCThumbSize.width, SCThumbSize.height)];
    
    UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCThumbSize.width, SCThumbSize.height)];
    [titleBtn setImage:[UIImage imageNamed:@"list_title.png"] forState:UIControlStateNormal];
    [titleBtn addTarget:self action:@selector(onTitlePress:) forControlEvents:UIControlEventTouchUpInside];
    [picView addSubview:titleBtn];
    
    if(imgs.count>0)
    {
        int mood = round(moodTotal / imgs.count);
        UIImageView *moodView = [[UIImageView alloc] initWithFrame:CGRectMake(-SCMoodSize.width*1/3, SCThumbSize.height - SCMoodSize.height*2/3,
                                                                              SCMoodSize.width, SCMoodSize.height)];
        NSString *moodName = [[NSString alloc] initWithFormat:@"mood_%d.png",  mood];
        [moodView setImage:[UIImage imageNamed:moodName]];
        [picView addSubview:moodView];
    }
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCThumbTextPadding, SCThumbSize.height*1/10, SCThumbSize.width - SCThumbTextPadding*2, SCThumbSize.height * 1/2)];
    [titleLabel setText:[user stringForKey:@"title"]];
    [titleLabel setFont:[UIFont fontWithName:SCFont size:20]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setNumberOfLines:2];
    [picView addSubview:titleLabel];
    
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCThumbSize.width*1/2, SCThumbSize.height*3/5, SCThumbSize.width*1/2, SCThumbTitle * 1.2)];
    [countLabel setText:[NSString stringWithFormat:@"%d", [imgs count]]];
    [countLabel setNumberOfLines:1];
    [countLabel setFont:[UIFont fontWithName:SCFont size:SCThumbTitle]];
    [countLabel setTextColor:[UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]];
    [countLabel setBackgroundColor:[UIColor clearColor]];
    [picView addSubview:countLabel];
    
    [waterfallView addSubview:picView];
}

- (void)handleSingleTap:(UIGestureRecognizer*) sender
{
    UIView *view = sender.view;
    
    scModelImage *image = [[scModelImage alloc] init];
    [image hide:view.tag];
    UIButton *hideBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 132, 133)];
    [hideBtn setImage:[UIImage imageNamed:@"list_hide.png"] forState:UIControlStateNormal];
    [hideBtn addTarget:self action:@selector(onShowPress:) forControlEvents:UIControlEventTouchUpInside];
    [view.superview addSubview:hideBtn];
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Single" withLabel:@"Hide" withValue:[NSNumber numberWithInt:sender.view.tag]];
}

- (void)handleDoubleTap:(UIGestureRecognizer*) sender
{
    CGRect app = self.view.bounds;
    
    scModelImage *images = [[scModelImage alloc]init];
    NSDictionary *item = [images get:sender.view.tag];
    
    UIView *overView = [[UIView alloc] initWithFrame:app];
    [self.view addSubview:overView];
    
    UIImageView *picture = [[UIImageView alloc] initWithFrame:app];
    [picture setImage:[UIImage imageWithContentsOfFile:[item objectForKey:@"original"]]];
    [overView addSubview:picture];
    
    NSArray *menu = [NSArray arrayWithObjects:
                     [NSDictionary dictionaryWithObjectsAndKeys: @"btn_back.png", @"img", [NSValue valueWithPointer:@selector(onBreakPress:)], @"action", nil],
                     [NSDictionary dictionaryWithObjectsAndKeys: @"btn_delete.png", @"img", [NSValue valueWithPointer:@selector(onDelPress:)], @"action", nil],
                     nil];
    
    for (int i=0; i<menu.count; i++) {
        NSDictionary *item = [menu objectAtIndex:i];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - (SCBtnSize.width + 5) * (i + 1), 5,
                                                                   SCBtnSize.width, SCBtnSize.height)];
        [btn setImage:[UIImage imageNamed:[item objectForKey:@"img"]] forState:UIControlStateNormal];
        [btn addTarget:self action:[[item objectForKey:@"action"] pointerValue] forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:sender.view.tag];
        [overView addSubview:btn];
    }
    
    NSString *note = [item objectForKey:@"note"];
    if (note && note.length > 0) {
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(0, app.size.height - SCNoteSize.height,
                                                                        app.size.width, SCNoteSize.height)];
        [text setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.8f]];
        [text setTextColor:[UIColor whiteColor]];
        [text setText:note];
        [text setTextAlignment:NSTextAlignmentCenter];
        [text setFont:[UIFont fontWithName:SCFont size:SCNoteTextSize]];
        [overView addSubview:text];
    }
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Single" withLabel:@"Fullscreen" withValue:[NSNumber numberWithInt:sender.view.tag]];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
}

/* Button Press */

- (void)onDelPress:(UIButton*)btn
{
    btnActive = btn;
    
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Delete"
                                                     message:@"Delete this picture?" // IMPORTANT
                                                    delegate:self
                                           cancelButtonTitle:@"NO"
                                           otherButtonTitles:@"YES", nil];
    [prompt setTag:AlertViewTagDel];
    [prompt show];
}

- (void)onTitlePress:(UIButton*)btn
{
    CGRect app = self.view.bounds;
    
    UIView *overView = [[UIView alloc] initWithFrame:app];
    [overView setTag:btn.superview.tag];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:app];
    [bg setImage:[UIImage imageNamed:@"background.jpg"]];
    [overView addSubview:bg];
    
    UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, app.size.width - (SCBtnSize.width+5)*2 - 5, SCInputTextSize.height)];
    [text setClearButtonMode:YES];
    [text setAdjustsFontSizeToFitWidth:YES];
    [text setText:[user objectForKey:@"title"]];
    [text setFont:[UIFont fontWithName:SCFont size:26]];
    [text setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [text setBackground:[UIImage imageNamed:@"text_mid.png"]];
    UIImageView *text_left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_left.png"]];
    [text_left setFrame:CGRectMake(0, 0, SCInputTextSize.width, SCInputTextSize.height)];
    [text setLeftView: text_left];
    [text setLeftViewMode:UITextFieldViewModeAlways];
    UIImageView *text_right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_right.png"]];
    [text_right setFrame:CGRectMake(0, 0, SCInputTextSize.width, SCInputTextSize.height)];
    [text setRightView: text_right];
    [text setRightViewMode:UITextFieldViewModeAlways];
    [text becomeFirstResponder];
    [overView addSubview:text];
    
    UIView *describeBg = [[UIView alloc] initWithFrame:CGRectMake(5, 5 + SCBtnSize.height + 3, app.size.width - 10, SCInputDescribeSize.height)];
    [describeBg setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"describe_mid.png"]]];
    UIImageView *describeLeft = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCInputDescribeSize.width, SCInputDescribeSize.height)];
    [describeLeft setImage:[UIImage imageNamed:@"describe_left.png"]];
    [describeBg addSubview:describeLeft];
    UIImageView *describeRight = [[UIImageView alloc] initWithFrame:CGRectMake(describeBg.bounds.size.width - SCInputDescribeSize.width, 0,
                                                                               SCInputDescribeSize.width, SCInputDescribeSize.height)];
    [describeRight setImage:[UIImage imageNamed:@"describe_right.png"]];
    [describeBg addSubview:describeRight];
    [overView addSubview:describeBg];
    
    UITextView *describe = [[UITextView alloc] initWithFrame:CGRectMake(5 + 10, 5 + SCBtnSize.height + 3 + 5,
                                                                        app.size.width - 10 - 40, SCInputDescribeSize.height - 20)];
    [describe setFont:[UIFont fontWithName:SCFont size:22]];
    [describe setText:[user objectForKey:@"describe"]];
    [describe setBackgroundColor:[UIColor clearColor]];
    [describe setTextAlignment:NSTextAlignmentLeft];
    [overView addSubview:describe];
    
    UIButton *ok = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - SCBtnSize.width - 5, 5, SCBtnSize.width, SCBtnSize.height)];
    [ok setImage:[UIImage imageNamed:@"btn_ok.png"] forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(onSaveTitlePress:) forControlEvents:UIControlEventTouchUpInside];
    [overView addSubview:ok];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - (SCBtnSize.width+5) * 2, 5, SCBtnSize.width, SCBtnSize.height)];
    [cancel setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(onBreakPress:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTag:BreakTitle];
    [overView addSubview:cancel];
    
    [self.view addSubview:overView];
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Title" withLabel:@"Enter" withValue:0];
}

- (void)onShowPress:(UIButton*)btn
{
    scModelImage *image = [[scModelImage alloc] init];
    [image show:[btn superview].tag];
    [btn removeFromSuperview];
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Single" withLabel:@"Show" withValue:[NSNumber numberWithInt:[btn superview].tag]];
}

- (void)onNotePress:(UIButton*)btn
{
    CGRect app = self.view.bounds;
    
    scModelImage *images = [[scModelImage alloc]init];
    NSDictionary *item = [images get:btn.superview.tag];
    
    UIView *overView = [[UIView alloc] initWithFrame:app];
    [overView setTag:btn.superview.tag];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:app];
    [bg setImage:[UIImage imageNamed:@"background.jpg"]];
    [overView addSubview:bg];
    
    UITextField *text = [[UITextField alloc] initWithFrame:CGRectMake(10, 80, app.size.width - 20, SCInputTextSize.height)];
    [text setClearButtonMode:YES];
    [text setAdjustsFontSizeToFitWidth:YES];
    [text setText:[item objectForKey:@"note"]];
    [text setFont:[UIFont fontWithName:SCFont size:26]];
    [text setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [text setBackground:[UIImage imageNamed:@"text_mid.png"]];
    UIImageView *text_left = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_left.png"]];
    [text_left setFrame:CGRectMake(0, 0, SCInputTextSize.width, SCInputTextSize.height)];
    [text setLeftView: text_left];
    [text setLeftViewMode:UITextFieldViewModeAlways];
    UIImageView *text_right = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"text_right.png"]];
    [text_right setFrame:CGRectMake(0, 0, SCInputTextSize.width, SCInputTextSize.height)];
    [text setRightView: text_right];
    [text setRightViewMode:UITextFieldViewModeAlways];
    [text becomeFirstResponder];
    [overView addSubview:text];
    
    UIButton *ok = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - SCBtnSize.width - 5, 5, SCBtnSize.width, SCBtnSize.height)];
    [ok setImage:[UIImage imageNamed:@"btn_ok.png"] forState:UIControlStateNormal];
    [ok addTarget:self action:@selector(onSaveNotePress:) forControlEvents:UIControlEventTouchUpInside];
    [overView addSubview:ok];
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(app.size.width - (SCBtnSize.width+5) * 2, 5, SCBtnSize.width, SCBtnSize.height)];
    [cancel setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(onBreakPress:) forControlEvents:UIControlEventTouchUpInside];
    [cancel setTag:BreakNote];
    [overView addSubview:cancel];
    
    [self.view addSubview:overView];
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Note" withLabel:@"Enter" withValue:[NSNumber numberWithInt:btn.superview.tag]];
}

- (void)onSaveTitlePress:(UIButton *)btn
{
    UITextField *title;
    UITextView *describe;
    for (UIView *view in btn.superview.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            title = (UITextField *)view;
        }
        if ([view isKindOfClass:[UITextView class]]) {
            describe = (UITextView *)view;
        }
    }
    
    [user setObject:title.text forKey:@"title"];
    [user setObject:describe.text forKey:@"describe"];
    [user synchronize];
    
    [titleLabel setText:title.text];
    
    [btn.superview removeFromSuperview];
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Title" withLabel:@"Save" withValue:[NSNumber numberWithInt:title.text.length]];
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Title" withLabel:@"Describe" withValue:[NSNumber numberWithInt:describe.text.length]];
}

- (void)onSaveNotePress:(UIButton *)btn
{
    UITextField *input;
    for(UIView *view in btn.superview.subviews){
        if ([view isKindOfClass:[UITextField class]]) {
            input = (UITextField *)view;
        }
    }
    
    scModelImage *images = [[scModelImage alloc]init];
    [images setNote:input.text pid:btn.superview.tag];
    [self drawWaterfall];
    [btn.superview removeFromSuperview];
    
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Note" withLabel:@"Save" withValue:[NSNumber numberWithInt:input.text.length]];
}

- (void)onBreakPress:(UIButton *)btn
{
    [btn.superview removeFromSuperview];
    
    switch (btn.tag) {
        case BreakTitle:
            [self.tracker sendEventWithCategory:@"Editor" withAction:@"Title" withLabel:@"Break" withValue:0];
            break;
        case BreakNote:
            [self.tracker sendEventWithCategory:@"Editor" withAction:@"Note" withLabel:@"Break" withValue:[NSNumber numberWithInt:btn.superview.tag]];
            break;
    }
}

- (void)onCameraPress:(UIButton *)btn
{
    scModelImage *images = [[scModelImage alloc]init];
    if([[images count] intValue] < 25){
        [self performSegueWithIdentifier:@"cameraView" sender:self];
        [self.tracker sendEventWithCategory:@"View" withAction:@"Camera" withLabel:@"List" withValue:0];
    }else{
        UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"The max photos are 25"
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:@"OK"
                                               otherButtonTitles:nil, nil];
        [prompt show];
        [self.tracker sendEventWithCategory:@"View" withAction:@"Over25" withLabel:@"List" withValue:0];
    }
}

- (void)onPlayPress:(UIButton *)btn
{
    [self performSegueWithIdentifier:@"progressView" sender:self];
    [self.tracker sendEventWithCategory:@"View" withAction:@"Play" withLabel:@"List" withValue:0];
}

- (void)onPrintPress:(UIButton *)btn
{
    [self performSegueWithIdentifier:@"printView" sender:self];
    [self.tracker sendEventWithCategory:@"View" withAction:@"Print" withLabel:@"List" withValue:0];
}

- (void)onClearPress:(UIButton *)btn
{
    UIAlertView *prompt = [[UIAlertView alloc] initWithTitle:@"Delete"
                                        message:@"Delete all pictures?" // IMPORTANT
                                       delegate:self
                              cancelButtonTitle:@"NO"
                              otherButtonTitles:@"YES", nil];
    [prompt setTag:AlertViewTagClear];
    [prompt show];
    
    scModelImage *images = [[scModelImage alloc]init];
    [self.tracker sendEventWithCategory:@"Editor" withAction:@"Clear" withLabel:@"Enter" withValue:[images count]];
}

/* Button Press End */

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)index{
    switch (alertView.tag) {
        case AlertViewTagClear:
            if (index==1) {
                scModelImage *images = [[scModelImage alloc] init];
                [images clean];
                
                [self viewDidDisappear:NO];
                [self viewDidAppear:NO];
                
                [self.tracker sendEventWithCategory:@"Editor" withAction:@"Clear" withLabel:@"Done" withValue:[images count]];
            }
            break;
        case AlertViewTagDel:
            if (index==1) {
                scModelImage *images = [[scModelImage alloc]init];
                [images del:btnActive.tag];
                [btnActive.superview removeFromSuperview];
                [self drawWaterfall];
                
                [self.tracker sendEventWithCategory:@"Editor" withAction:@"Single" withLabel:@"Del" withValue:[NSNumber numberWithInt:btnActive.tag]];
            }else{
                [self.tracker sendEventWithCategory:@"Editor" withAction:@"Single" withLabel:@"cancelDel" withValue:[NSNumber numberWithInt:btnActive.tag]];
            }
            break;
    }
}

@end
