//
//  scDB.h
//  ServiceCamera
//
//  Created by Justin on 13/2/28.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface scDB : NSObject

@property FMDatabase* db;

-(int)addImg:(int)mood;

-(void)newImg:(int)pid;

-(void)clean;

-(NSMutableArray*)fetchImg;

@end
