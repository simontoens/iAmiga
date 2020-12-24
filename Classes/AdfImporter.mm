//  Created by Simon Toens on 25.03.15
//
//  iUAE is free software: you may copy, redistribute
//  and/or modify it under the terms of the GNU General Public License as
//  published by the Free Software Foundation, either version 2 of the
//  License, or (at your option) any later version.
//
//  This file is distributed in the hope that it will be useful, but
//  WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//  General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

#import "AdfImporter.h"
#import "ZipArchive.h"

static NSString *kAdfExtension = @"adf";
static NSString *kZipExtension = @"zip";
static NSString *kAdfsDirectoryName = @"downloadedadfs";

@implementation AdfImporter {
    @private
    NSFileManager *_fileManager;
    NSString *_adfsDirectory;
}

- (instancetype)init {
    if (self = [super init]) {
        _fileManager = [[NSFileManager defaultManager] retain];
        NSString *docunentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _adfsDirectory = [[docunentsDirectory stringByAppendingPathComponent:kAdfsDirectoryName] retain];
        [_fileManager createDirectoryAtPath:_adfsDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    return self;
}

- (void)dealloc {
    [_fileManager release];
    [_adfsDirectory release];
    [super dealloc];
}

# pragma mark - Public methods

- (BOOL)import:(NSString *)path {
    BOOL imported = NO;
    if ([self isAdf:path]) {
        imported = [self importAdf:path];
    } else if ([self isZip:path]) {
        imported = [self importZippedAdf:path];
    } else {
        imported = NO;
    }
    if (imported) {
        [_fileManager removeItemAtPath:path error:NULL];
    }
    return imported;
}

- (BOOL)isDownloadedAdf:(NSString *)path {
    NSString *directory = [path stringByDeletingLastPathComponent];
    return [directory isEqualToString:_adfsDirectory];
}

# pragma mark - Private methods

- (BOOL)importAdf:(NSString *)adfPath {
    NSString *adfFileName = [adfPath lastPathComponent];
    NSString *destPath = [_adfsDirectory stringByAppendingPathComponent:adfFileName];
    return [_fileManager copyItemAtPath:adfPath toPath:destPath error:NULL];
}

- (BOOL)importZippedAdf:(NSString *)zipPath {
    // this does not validate the zip content
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL unzipOk = [zipArchive UnzipOpenFile:zipPath];
    @try {
        unzipOk = unzipOk && [zipArchive UnzipFileTo:_adfsDirectory overWrite:YES];
    } @finally {
        [zipArchive UnzipCloseFile];
    }
    [zipArchive release];
    return unzipOk;
}

- (BOOL)isAdf:(NSString *)path {
    return [kAdfExtension caseInsensitiveCompare:path.pathExtension] == NSOrderedSame;
}

- (BOOL)isZip:(NSString *)path {
    return [kZipExtension caseInsensitiveCompare:path.pathExtension] == NSOrderedSame;
}

@end
