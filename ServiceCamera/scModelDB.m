//
//  scModelDB.m
//  ServiceCamera
//
//  Created by Justin on 13/3/11.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "configs.h"
#import "scModelDB.h"

@implementation scModelDB

-(id)init
{
    NSURL *appUrl = [[[NSFileManager defaultManager]
                      URLsForDirectory:NSDocumentDirectory
                      inDomains:NSUserDomainMask] lastObject];
    NSString *dbPath = [[appUrl path] stringByAppendingPathComponent:@"service.db3"];
    db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db");
    }
    
    if(![db executeUpdate:SCTableImgs])
    {
        NSLog(@"Could not create table: %@", [db lastErrorMessage]);
    }
    
    return self;
}

- (void)build
{
    NSLog(@"build database");
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    float ver = [user floatForKey:@"db_var"];
    if (ver < 1.4f) {
        [db executeUpdate:@"DROP TABLE `imgs`"];
        if(![db executeUpdate:SCTableImgs])
        {
            NSLog(@"Could not create table: %@", [db lastErrorMessage]);
        }
        [user setFloat:1.4f forKey:@"db_var"];
    }
    [user synchronize];
}

@end
