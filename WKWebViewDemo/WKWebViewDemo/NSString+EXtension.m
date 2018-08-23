
//
//  NSString+EXtension.m
//  WKWebViewDemo
//
//  Created by renwen on 2018/8/23.
//  Copyright © 2018年 Dainty. All rights reserved.
//

#import "NSString+EXtension.h"

@implementation NSString (EXtension)

    //计算缓存文件的大小
+ (NSUInteger) fileSizeAtPath:(NSString*) filePath{
        NSFileManager* manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:filePath]){
            

            
            return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
        }
        
        return 0;
    }
    

@end
