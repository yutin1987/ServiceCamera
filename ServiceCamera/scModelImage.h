//
//  scModelImage.h
//  ServiceCamera
//
//  Created by Justin on 13/3/9.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "scModelDB.h"

@interface scModelImage : scModelDB

-(NSInteger)add:(UIImage *)img mood:(NSInteger)mood;

-(void)setNote:(NSString *)node pid:(NSInteger)pid;

-(NSNumber*)count;

-(NSArray*)fetch;
-(NSArray*)fetchAll;

-(void)hide:(NSInteger)pid;
-(void)show:(NSInteger)pid;

-(NSDictionary*)get:(NSInteger)pid;
-(void)del:(NSInteger)pid;

-(void)clean;

@end
