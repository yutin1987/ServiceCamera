//
//  scModelImage.m
//  ServiceCamera
//
//  Created by Justin on 13/3/9.
//  Copyright (c) 2013年 Yutin. All rights reserved.
//
#import "configs.h"
#import "scModelImage.h"

@implementation scModelImage

NSString *docPath;

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docPath = [paths objectAtIndex:0];
    }
    return self;
}

- (void)show:(NSInteger)pid
{
    if([db executeUpdate:@"UPDATE `imgs` SET `hide` = 0 WHERE `pid` = ?", [NSNumber numberWithInt:pid]])
    {
        NSLog(@"Show Img OK!");
    }else{
        NSLog(@"Could not show img data: %@", [db lastErrorMessage]);
    }
}

-(void)hide:(NSInteger)pid
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
    if(![db executeUpdate:@"DROP TABLE `imgs`"])
    {
        NSLog(@"Could not clean table: %@", [db lastErrorMessage]);
    }
}

-(NSInteger)add:(UIImage *)img mood:(NSInteger)mood
{
    
    if([db executeUpdate:@"INSERT INTO `imgs` (`mood`, `hide`) VALUES (?, 0)", [NSNumber numberWithInt:mood]])
    {
        NSInteger pid = [db lastInsertRowId];
        NSString *path = [docPath stringByAppendingPathComponent:[[NSString alloc] initWithFormat:SCFileOriginal, pid]];
        NSData *data = [NSData dataWithData:UIImageJPEGRepresentation(img, 1)];
        [data writeToFile:path atomically:YES];
        
        NSLog(@"Insert Img OK!");
    }else{
        NSLog(@"Could not insert data: %@", [db lastErrorMessage]);
    }
    
    return [db lastInsertRowId];
}

-(void)del:(NSInteger)pid
{
    if([db executeUpdate:@"DELETE FROM `imgs` WHERE `pid` = ?", [NSNumber numberWithInt:pid]])
    {
        NSLog(@"Del Img OK!");
    }else{
        NSLog(@"Could not del img data: %@", [db lastErrorMessage]);
    }
}

-(void)setNote:(NSString *)note pid:(NSInteger)pid
{   
    if([db executeUpdate:@"UPDATE `imgs` SET `note` = ? WHERE `pid` = ?", note,[NSNumber numberWithInt:pid]])
    {
        NSLog(@"Set Note Img OK!");
    }else{
        NSLog(@"Could not set idea img data: %@", [db lastErrorMessage]);
    }
}

-(NSDictionary*)get:(NSInteger)pid
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM `imgs` WHERE `pid` = ?", [NSNumber numberWithInt:pid]];
    
    NSDictionary *_item;
    
    [rs next];
    
    int r_pid = [rs intForColumn:@"pid"];
    int r_mood = [rs intForColumn:@"mood"];
    int r_hide = [rs intForColumn:@"hide"];
    NSString *r_note = [rs stringForColumn:@"note"];
    
    NSString *original_path = [docPath stringByAppendingPathComponent: [[NSString alloc] initWithFormat:SCFileOriginal,  r_pid]];
    
    _item = [NSDictionary dictionaryWithObjectsAndKeys:
             [NSNumber numberWithInt:r_pid], @"pid",
             [NSNumber numberWithInt:r_mood], @"mood",
             [NSNumber numberWithInt:r_hide], @"hide",
             original_path, @"original",
             r_note, @"note",
             nil];
    
    [rs close];
    
    return _item;
}

-(NSNumber*)count
{
    FMResultSet *rs = [db executeQuery:@"SELECT COUNT(*) as `count` FROM `imgs`"];
    
    [rs next];
    
    int count = [rs intForColumn:@"count"];
    
    [rs close];
    
    return [NSNumber numberWithInt:count];
}

-(NSArray*)fetchAll
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM `imgs`"];
    
    NSMutableArray *_item = [NSMutableArray arrayWithCapacity:0];
    
    while ([rs next]) {
        int r_pid = [rs intForColumn:@"pid"];
        int r_mood = [rs intForColumn:@"mood"];
        int r_hide = [rs intForColumn:@"hide"];
        NSString *r_note = [rs stringForColumn:@"note"];
        
        NSString *original_path = [docPath stringByAppendingPathComponent: [[NSString alloc] initWithFormat:SCFileOriginal,  r_pid]];
        
        [_item addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:r_pid], @"pid",
                           [NSNumber numberWithInt:r_mood], @"mood",
                           [NSNumber numberWithInt:r_hide], @"hide",
                           original_path, @"original",
                           r_note, @"note",
                           nil]];
    }
    
    [rs close];
    
    return _item;
}

-(NSArray*)fetch
{
    FMResultSet *rs = [db executeQuery:@"SELECT * FROM `imgs` WHERE `hide` = 0"];
    
    NSMutableArray *_item = [NSMutableArray arrayWithCapacity:0];
    
    while ([rs next]) {
        int r_pid = [rs intForColumn:@"pid"];
        int r_mood = [rs intForColumn:@"mood"];
        NSString *r_note = [rs stringForColumn:@"note"];
        
        NSString *original_path = [docPath stringByAppendingPathComponent: [[NSString alloc] initWithFormat:SCFileOriginal,  r_pid]];
        
        [_item addObject: [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSNumber numberWithInt:r_pid], @"pid",
                           [NSNumber numberWithInt:r_mood], @"mood",
                           original_path, @"original",
                           r_note, @"note",
                           nil]];
    }
    
    [rs close];
    
    return _item;
}

@end
