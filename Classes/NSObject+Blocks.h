//
//  NSObject+Blocks.h
//  iAmiga
//
//  Created by Stuart Carnie on 6/23/11.
//  Copyright 2011 Manomio LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject(Blocks)

- (void)performCodeBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delayInSeconds;
    
@end
