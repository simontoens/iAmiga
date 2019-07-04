//  Created by Simon Toens on 08.03.15
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

#import "State.h"

@implementation State {
    NSString *_imagePath;
    UIImage *_image;
    NSDate *_modificationDate;
    NSString *_formattedModificationDate;
    NSMutableDictionary *_configNameToConfigContent;
}

@dynamic modificationDate, image;

- (instancetype)initWithName:(NSString *)name path:(NSString *)path modificationDate:(NSDate *)modificationDate imagePath:(NSString *)imagePath {
    if (self = [super init]) {
        _name = [name retain];
        _path = [path retain];
        _modificationDate = [modificationDate retain];
        _imagePath = [imagePath retain];
        _configNameToConfigContent = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_name release];
    [_path release];
    [_modificationDate release];
    [_imagePath release];
    [_formattedModificationDate release];
    [_image release];
    [_configNameToConfigContent release];
    [super dealloc];
}

- (UIImage *)image {
    if (!_image && _imagePath) {
        NSData *imageBytes = [NSData dataWithContentsOfFile:_imagePath];
        _image = [[UIImage imageWithData:imageBytes] retain];
    }
    return _image;
}

- (void)setImage:(UIImage *)image {
    if (image != _image) {
        [_image release];
        _image = [image retain];
    }
}

- (void)addConfigContent:(NSString *)configContent withName:(NSString *)configName {
    [_configNameToConfigContent setObject:configContent forKey:configName];
}

- (NSString *)getConfigContentWithName:(NSString *)configName {
    return [_configNameToConfigContent objectForKey:configName];
}

- (NSArray *)getAllConfigNames {
    return _configNameToConfigContent.allKeys;
}

- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (![other isKindOfClass:[self class]]) {
        return NO;
    }
    return [_name isEqualToString:((State *)other)->_name];
}

- (NSUInteger)hash {
    return [_name hash];
}

- (NSString *)modificationDate {
    if (!_formattedModificationDate) {
        NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        _formattedModificationDate = [[dateFormatter stringFromDate:_modificationDate] retain];
    }
    return _formattedModificationDate;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@", _name, _path];
}

@end
