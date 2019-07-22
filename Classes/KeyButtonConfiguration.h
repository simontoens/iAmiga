//  Created by Simon Toens on 10.10.15
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

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "SDL.h"

@interface KeyButtonConfiguration : NSObject <NSCopying>

@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) SDLKey key;
@property (nonatomic, strong) NSString *keyName;
@property (nonatomic, strong) NSString *groupName;
@property (nonatomic, assign) BOOL showOutline;
@property (nonatomic, assign) BOOL enabled;

- (BOOL)hasConfiguredKey;

- (void)toggleShowOutline;
- (void)toggleEnabled;

- (KeyButtonConfiguration *)clone;

+ (NSString *)serializeToJSON:(NSArray<KeyButtonConfiguration *> *)keyButtonConfigurations;
+ (NSArray<KeyButtonConfiguration *> *)deserializeFromJSON:(NSString *)json;

@end
