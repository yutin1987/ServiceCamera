//
//  scModelDB.h
//  ServiceCamera
//
//  Created by Justin on 13/3/11.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface scModelDB : NSObject{
    @protected FMDatabase *db;
}

- (void)build;

@end
