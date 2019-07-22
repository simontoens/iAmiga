//
//  FakeEMUBrowser.h
//  iUAETestsTests
//
//  Created by Simon Toens on 7/17/19.
//  Copyright © 2019 Simon Toens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMUBrowser.h"

@implementation EMUBrowser

- (NSArray *)getAdfFileInfos {
    return nil;
}
- (NSArray *)getFileInfosForExtensions:(NSArray *)extensions {
    return nil;
}
- (EMUFileInfo *)getFileInfoForFileName:(NSString *)fileName {
    return nil;
}
- (NSArray *)getFileInfosForFileNames:(NSArray *)fileName {
    return nil;
}

@end
