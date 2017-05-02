//
//  FileManager.m
//  iOM
//
//  Created by JinYongHao on 8/11/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import "FileManager.h"
#import "DiscussRoomManager.h"

@implementation FileManager

+ (NSString *)GetDocumentsPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [documentPaths objectAtIndex:0];
    return documentsDir;
}

+ (NSFileHandle *)GetFileHandle:(NSString *)fileName
{
    NSFileHandle *readFile;
    readFile = [NSFileHandle fileHandleForReadingAtPath:fileName];
    return readFile;
}

+ (NSData *)GetDataFromFileHandle:(NSFileHandle *)fileHandle
{
    if (fileHandle == nil)
    {
        return nil;
    }
    NSData *fileData = [fileHandle readDataToEndOfFile];
    return fileData;
}

+ (NSData *)GetDataFromFilePath:(NSString *)filePath
{
    NSFileHandle *readFile = [FileManager GetFileHandle:filePath];
    if (readFile == nil)
    {
        return nil;
    }
    NSData *fileData = [readFile readDataToEndOfFile];
    return fileData;
}

+ (NSFileHandle *)WriteDataToFilePath:(NSString *)filePath fileData:(NSData *)fileData
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager createFileAtPath:filePath contents:fileData attributes:nil])
    {
        NSLog(@"write file: %@ failed", filePath);
        return nil;
    }
    NSFileHandle *readFile;
    readFile = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (readFile == nil)
    {
        NSLog(@"write file: %@", filePath);
        return nil;
    }
    NSLog(@"write file: %@ success", filePath);
    return readFile;
}

+ (NSString *)GetCacheFilePathWithFileName:(NSString *)fileName
{
    NSString *imageDirectory = [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"cache"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    return [imageDirectory stringByAppendingPathComponent:[[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"gga"]];
}

+ (unsigned int)GetFileSize:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
    UInt32 fileSize = (unsigned int)[attrs fileSize];
    return fileSize;
}

+ (BOOL)RenameFile:(NSString *)fromFilePath toFilePath:(NSString *)toFilePath
{
    NSError *error = NULL;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager moveItemAtPath:fromFilePath toPath:toFilePath error:&error];
    if (!result)
    {
        NSLog(@"rename file: %@ -> %@ failed", fromFilePath, toFilePath);
        return NO;
    }
    NSLog(@"rename file: %@ -> %@ success", fromFilePath, toFilePath);
    return YES;
}

+ (BOOL)DeleteFile:(NSString *)filePath
{
    NSError *error = NULL;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager removeItemAtPath:filePath error:&error];
    if (!result)
    {
        NSLog(@"delete file: %@ failed", filePath);
        return NO;
    }
    NSLog(@"delete file: %@ success", filePath);
    return YES;
}

+ (NSString *)GetLoginFilePath
{
    NSString *voiceDirectory = [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"login"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    return [voiceDirectory stringByAppendingPathComponent:[[@"login" stringByDeletingPathExtension] stringByAppendingPathExtension:@"log"]];
}

+ (NSString *)GetRegWorkTimeFilePath
{
    NSString *voiceDirectory = [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"RegWorkTime"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    return [voiceDirectory stringByAppendingPathComponent:[[@"RegWorkTime" stringByDeletingPathExtension] stringByAppendingPathExtension:@"log"]];
}

+ (void)RemoveFileWithPath:(NSString *)filePath
{
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error])
    {
        NSLog(@"remove file: %@ failed, error: %@", filePath, error);
        return;
    }
    NSLog(@"remove file: %@ success", filePath);
}

 + (void)RemoveAllProgramData
{
    BOOL ret;
    ret = [FileManager DeleteFile:[[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"cache"]];
    if (!ret)
        NSLog(@"Removing files in 'cache' FAILED.");
    ret = [FileManager DeleteFile:[[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"image"]];
    if (!ret)
        NSLog(@"Removing files in 'image' FAILED.");
    ret = [FileManager DeleteFile:[[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"voice"]];
    if (!ret)
        NSLog(@"Removing files in 'voice' FAILED.");
    
    [[DiscussRoomManager sharedInstance] deleteAllMessages];
    
    if (ret)
        NSLog(@"Cleaned Successfully");
}

+ (NSString *)GetVoiceFilePath:(NSString *)fileName
{
    NSString *voiceDirectory = [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"voice"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:voiceDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:voiceDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    return [voiceDirectory stringByAppendingPathComponent:[[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"gga"]];
}

+ (NSString *)GetImageFilePath:(NSString *)fileName
{
    NSString *imageDirectory = [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"image"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageDirectory])
        [[NSFileManager defaultManager] createDirectoryAtPath:imageDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    return [imageDirectory stringByAppendingPathComponent:[[fileName stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
}

+ (NSString *)GetDatabaseFilePath
{
    return [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"club_chatting.db"];
}

+ (void)WriteErrorData:(NSString *)errorData
{
    NSData *errors = [errorData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    NSString *errorDirectory = [[FileManager GetDocumentsPath] stringByAppendingPathComponent:@"error.log"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:errorDirectory])
    {
        [[NSFileManager defaultManager] createFileAtPath:errorDirectory contents:errors attributes:nil];
        return;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:errorDirectory];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:errors];
}

@end
