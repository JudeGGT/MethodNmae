//
//  main.m
//  test
//
//  Created by ggt on 2018/6/17.
//  Copyright © 2018年 ggt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import "NSString+Method.h"

void foundMethod(NSString *sourceCodeDir);
void createdFile(void);

NSString *gSourceCodeDir = nil;

#pragma mark - 主入口

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSArray<NSString *> *arguments = [[NSProcessInfo processInfo] arguments];
        if (!arguments || arguments.count <= 1) {
            printf("缺少工程目录参数\n");
            return 1;
        }
        if (arguments.count <= 2) {
            printf("缺少任务参数 -spamCodeOut or -handleXcassets or -deleteComments\n");
            return 1;
        }
        
        BOOL isDirectory = NO;
        BOOL needFoundMethod = NO;
        
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSInteger i = 1; i < arguments.count; i++) {
            NSString *argument = arguments[i];
            if (i == 1) {
                gSourceCodeDir = argument;
                if (![fm fileExistsAtPath:gSourceCodeDir isDirectory:&isDirectory]) {
                    printf("%s不存在\n", [gSourceCodeDir UTF8String]);
                    return 1;
                }
                if (!isDirectory) {
                    printf("%s不是目录\n", [gSourceCodeDir UTF8String]);
                    return 1;
                }
                continue;
            }
            if ([argument isEqualToString:@"-foundMethod"]) {
                needFoundMethod = YES;
            }
        }
        
        if (needFoundMethod) {
            // 查找方法
            @autoreleasepool{
                NSLog(@"正在查找方法");
                createdFile();
                foundMethod(gSourceCodeDir);
            }
            NSLog(@"查找方法完毕");
        }
    }
    return 0;
}

void foundMethod(NSString *sourceCodeDir) {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray<NSString *> *files = [fm contentsOfDirectoryAtPath:sourceCodeDir error:nil];
    BOOL isDirectory;
    
    for (NSString *filePath in files) {
        NSString *path = [sourceCodeDir stringByAppendingPathComponent:filePath];
        ///如果路径下的是文件夹，继续往下走,知道找到一个文件
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            foundMethod(path);
            continue;
        }
        NSString *fileName = filePath.lastPathComponent;
        ///mm文件先不管
        if ([fileName hasSuffix:@".h"]) {
            NSError *error;
            NSString *fileContent = [NSString stringWithContentsOfFile:[sourceCodeDir stringByAppendingPathComponent:filePath] encoding:NSUTF8StringEncoding error:&error];
//            fileContent = [fileContent stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            [fileContent foundMethodName];
        }
    }
}

void createdFile(void) {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/Method.txt"];
    NSLog(@"%@", filePath);
    if (![fm fileExistsAtPath:filePath]) {
        BOOL isSuccess = [fm createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"%@", isSuccess ? @"创建文件成功" : @"创建文件失败");
    }
}
