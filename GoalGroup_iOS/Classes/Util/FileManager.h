//
//  FileManager.h
//  iOM
//
//  Created by JinYongHao on 8/11/14.
//  Copyright (c) 2014 Hexed Bits. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

+ (NSString *)GetDocumentsPath;
+ (NSFileHandle *)GetFileHandle:(NSString *)fileName;
+ (NSData *)GetDataFromFileHandle:(NSFileHandle *)fileHandle;
+ (NSData *)GetDataFromFilePath:(NSString *)filePath;
+ (NSFileHandle *)WriteDataToFilePath:(NSString *)fileName fileData:(NSData *)fileData;
+ (NSString *)GetCacheFilePathWithFileName:(NSString *)fileName;
+ (unsigned int)GetFileSize:(NSString *)fileName;
+ (BOOL)RenameFile:(NSString *)fromFilePath toFilePath:(NSString *)toFilePath;
+ (BOOL)DeleteFile:(NSString *)filePath;
+ (NSString *)GetLoginFilePath;
+ (NSString *)GetRegWorkTimeFilePath;
+ (void)RemoveFileWithPath:(NSString *)filePath;
+ (void)RemoveAllProgramData;
+ (NSString *)GetVoiceFilePath:(NSString *)fileName;
+ (NSString *)GetImageFilePath:(NSString *)fileName;
+ (NSString *)GetDatabaseFilePath;
+ (void)WriteErrorData:(NSString *)errorData;

@end
