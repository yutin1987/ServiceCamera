//
//  scDB.m
//  ServiceCamera
//
//  Created by Justin on 13/2/28.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//

#import "scDB.h"

@implementation scDB

@synthesize db;

-(id) init
{
    NSLog(@"init");
    NSURL *appUrl = [[[NSFileManager defaultManager]
                      URLsForDirectory:NSDocumentDirectory
                      inDomains:NSUserDomainMask] lastObject];
    NSString *dbPath = [[appUrl path] stringByAppendingPathComponent:@"service.db3"];
    db = [FMDatabase databaseWithPath:dbPath];
    
    if (![db open]) {
        NSLog(@"Could not open db");
    }
    
    if(![db executeUpdate:@"CREATE TABLE IF NOT EXISTS imgs (pid integer primary key asc autoincrement, mood integer, new integer, hide integer)"])
    {
        NSLog(@"Could not create table: %@", [db lastErrorMessage]);
    }
    
    return self;
}

-(void)hide:(int)pid
{
    if([db executeUpdate:@"UPDATE `imgs` SET `hide` = 1 WHERE `pid` = ?", [NSNumber numberWithInt:pid]])
    {
        NSLog(@"Hide Img OK!");
    }else{
        NSLog(@"Could not hide img data: %@", [db lastErrorMessage]);
    }
}

-(void)clean
{
    if(![db executeUpdate:@"DROP TABLE imgs"])
    {
        NSLog(@"Could not clean table: %@", [db lastErrorMessage]);
    }
}

-(int)addImg:(int)mood
{
    if([db executeUpdate:@"INSERT INTO `imgs` (`mood`, `new`) VALUES (?, 0)", [NSNumber numberWithInt:mood]])
    {
        NSLog(@"Insert Img OK!");
    }else{
        NSLog(@"Could not insert data: %@", [db lastErrorMessage]);
    }
    
    return [db lastInsertRowId];
}

-(void)newImg:(int)pid
{
    if([db executeUpdate:@"UPDATE `imgs` SET `new` = 1 WHERE `pid` = ?", [NSNumber numberWithInt:pid]])
    {
        NSLog(@"Set New Img OK!");
    }else{
        NSLog(@"Could not set new img data: %@", [db lastErrorMessage]);
    }
}

-(NSMutableArray*)fetchImg
{
    NSMutableArray *_item = [NSMutableArray arrayWithCapacity:0];
    
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM imgs"];
    
    while ([rs next]) {
        
        int r_pid = [rs intForColumn:@"pid"];
        int r_mood = [rs intForColumn:@"mood"];
        int r_new = [rs intForColumn:@"new"];
            
        [_item addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:r_pid], @"pid",
                          [NSNumber numberWithInt:r_mood], @"mood",
                          [NSNumber numberWithInt:r_new], @"new",
                          nil]];
    }
    
    [rs close];
    
    return _item;
}

@end
