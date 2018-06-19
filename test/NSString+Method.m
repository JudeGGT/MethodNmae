//
//  NSString+Method.m
//  test
//
//  Created by ggt on 2018/6/17.
//  Copyright © 2018年 ggt. All rights reserved.
//

#import "NSString+Method.h"

@implementation NSString (Method)

- (void)foundMethodName {

    NSString *replace = [self stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    NSArray *globalMethodNameArray = [replace resultArrayWithPatter:@"[-|+].*;"];
    for (NSTextCheckingResult *result in globalMethodNameArray) {
        if (result.range.length) {
            NSString *globalMethodNameString = [replace substringWithRange:result.range];
            globalMethodNameString = [globalMethodNameString stringByReplacingOccurrencesOfString:@";" withString:@";\n"];
            NSArray *globalMethodArray = [globalMethodNameString resultArrayWithPatter:@"[-|+].*;"];
            [self placeMethodWithArray:globalMethodArray string:globalMethodNameString];
        }
    }
}

/**
 方法名没有换行
 */
- (void)placeMethodWithArray:(NSArray *)globalMethodNameArray string:(NSString *)placeString {
    
    for (NSTextCheckingResult *globalMethodNameResult in globalMethodNameArray) {
        if (globalMethodNameResult.range.length) {
            NSString *globalMethodNameString = [placeString substringWithRange:globalMethodNameResult.range];
            NSArray *simpleMethodNameArray = [globalMethodNameString resultArrayWithPatter:@"\\).*;"];
            for (NSTextCheckingResult *simpleMethodNameResult in simpleMethodNameArray) {
                if (simpleMethodNameResult.range.length) {
                    NSString *methodNameString = [globalMethodNameString substringWithRange:simpleMethodNameResult.range];
                    methodNameString = [methodNameString stringByReplacingOccurrencesOfString:@")" withString:@""];
                    methodNameString = [methodNameString stringByReplacingOccurrencesOfString:@";" withString:@""];
                    NSArray *methodNameArray = [methodNameString resultArrayWithPatter:@".*[:\\(| : \\(|: \\(]"];
                    if (methodNameArray.count) {
                        NSArray *subStringArray = [methodNameString componentsSeparatedByString:@" "];
                        for (NSString *string in subStringArray) {
                            NSArray *resultArray = [string resultArrayWithPatter:@".*[:\\(| : \\(|: \\(]"];
                            for (NSTextCheckingResult *result in resultArray) {
                                if (result.range.length) {
                                    NSString *str = [string substringWithRange:result.range];
                                    str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
                                    str = [str stringByReplacingOccurrencesOfString:@"(" withString:@""];
                                    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
                                    NSLog(@"%@", str);
                                    [self saveDataWithString:str];
                                }
                            }
                        }
                    } else {
                        NSString *str = [methodNameString copy];
                        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
                        NSLog(@"%@", str);
                        [self saveDataWithString:str];
                    }
                }
            }
        }
    }
}

- (void)saveDataWithString:(NSString *)str {

//    NSString *defineString = [self defineWithString:str];
    NSString *defineString = @"";
    NSMutableString *mutableString = [NSMutableString string];
    NSString *string = [self readFile];
    if (string.length) {
        [mutableString appendString:string];
    }
    if (defineString.length) {
        [mutableString appendFormat:@"#define %@ ", defineString];
    }
    if (str.length) {
        [mutableString appendFormat:@"%@\n", str];
        NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/Method.txt"];
        NSData *data = [mutableString dataUsingEncoding:NSUTF8StringEncoding];
        if ([data writeToFile:filePath atomically:YES]) {
//            NSLog(@"文件写入成功");
        } else {
//            NSLog(@"文件写入失败");
        }
    }
}

- (NSString *)defineWithString:(NSString *)string {
    
    NSArray *array = @[@"A", @"B", @"C", @"D", @"E", @"F"];
    NSMutableString *mutableString = [NSMutableString string];
    int count = (int)array.count;
    for (int i = 0; i < 8; i++) {
        NSInteger random_count = arc4random_uniform(count);
        if (random_count < array.count) {
            NSString *string = array[random_count];
            [mutableString appendString:string];
        }
    }
    
    return mutableString;
}

- (NSString *)readFile {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/Method.txt"];
    if (![fm fileExistsAtPath:filePath]) {
        BOOL isSuccess = [fm createFileAtPath:filePath contents:nil attributes:nil];
        NSLog(@"%@", isSuccess ? @"创建文件成功" : @"创建文件失败");
        return @"";
    } else {
        NSData *data = [fm contentsAtPath:filePath];
        NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        string = string.length ? string : @"";
        return string;
    }
}

- (NSArray *)resultArrayWithPatter:(NSString *)patter {
    
    NSRegularExpression *regular = [[NSRegularExpression alloc] initWithPattern:patter options:0 error:nil];
    return [regular matchesInString:self options:0 range:NSMakeRange(0, self.length)];
}

@end
