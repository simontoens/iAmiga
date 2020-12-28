/*
 Frodo, Commodore 64 emulator for the iPhone
 Copyright (C) 2007, 2008 Stuart Carnie
 See gpl.txt for license information.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "EMUBrowser.h"
#import "EMUFileInfo.h"

@implementation EMUBrowser

- (NSArray *)getAdfFileInfos {
    return [self getFileInfosForExtensions:@[@"adf", @"ADF"]];
}

- (NSArray *)getFileInfosForExtensions:(NSArray *)extensions {
    return [self getFileInfosWithFileNameFilter:nil extensions:extensions];
}

- (EMUFileInfo *)getFileInfoForFileName:(NSString *)fileName {
    NSArray *fileInfos = [self getFileInfosForFileNames:@[fileName]];
    return [fileInfos count] == 0 ? nil : [fileInfos objectAtIndex:0];
}

- (NSArray *)getFileInfosForFileNames:(NSArray *)fileNames {
    NSMutableArray *extensions = [NSMutableArray arrayWithCapacity:[fileNames count]];
    for (NSString *fileName in fileNames) {
        [extensions addObject:fileName.pathExtension];
    }
    return [self getFileInfosWithFileNameFilter:fileNames extensions:extensions];
}

- (NSArray *)getFileInfosWithFileNameFilter:(NSArray *)fileNameFilters extensions:(NSArray *)extensions {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *documentFileInfos = [self getFileInfosInDirectory:documentsDirectory fileNameFilter:fileNameFilters extensions:extensions];
    
    NSArray *bundleFileInfos = [self getFileInfosInDirectory:[[NSBundle mainBundle] bundlePath] fileNameFilter:fileNameFilters extensions:extensions];
    
    NSMutableArray *fileInfos = [[[NSMutableArray alloc] initWithCapacity:[documentFileInfos count] + [bundleFileInfos count]] autorelease];
    [fileInfos addObjectsFromArray:documentFileInfos];
    [fileInfos addObjectsFromArray:bundleFileInfos];
    return fileInfos;
}

- (NSArray *)getFileInfosInDirectory:(NSString *)directory fileNameFilter:(NSArray *)fileNameFilters extensions:(NSArray *)extensions {
    NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager] enumeratorAtPath:directory];
    NSArray *relativeFilePaths = [[direnum allObjects] pathsMatchingExtensions:extensions];
    NSMutableArray *fileInfos = [[[NSMutableArray alloc] initWithCapacity:[relativeFilePaths count]] autorelease];
    for (NSString *relativeFilePath in relativeFilePaths) {
        NSString *filePath = [directory stringByAppendingPathComponent:relativeFilePath];
        EMUFileInfo *fileInfo = [[[EMUFileInfo alloc] initFromPath:filePath] autorelease];
        if (fileNameFilters) {
            NSString *fileName = [relativeFilePath lastPathComponent];
            if ([fileNameFilters containsObject:fileName]) {
                if ([filePath rangeOfString:@".Trash"].location == NSNotFound) {
                    [fileInfos addObject:fileInfo];
                }
            }
        } else {
            if ([filePath rangeOfString:@".Trash"].location == NSNotFound) {
                [fileInfos addObject:fileInfo];
            }
        }
    }
    return fileInfos;
}

@end
