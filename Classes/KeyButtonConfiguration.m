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

#import "KeyButtonConfiguration.h"

static const int kInitialValue = -1;

@implementation KeyButtonConfiguration

static NSString *const kUnassignedKeyName = @"<none>";
static NSString *const kDefaultGroupName = @"default";

- (instancetype)init {
    if (self = [super init]) {
        _key = kInitialValue;
        _keyName = [kUnassignedKeyName retain];
        _groupName = [kDefaultGroupName retain];
        _showOutline = YES;
        _enabled = YES;
    }
    return self;
}

- (void)dealloc {
    [_keyName release];
    [_groupName release];
    [super dealloc];
}

- (BOOL)hasConfiguredKey {
    return _key != kInitialValue;
}

- (void)toggleShowOutline {
    _showOutline = !_showOutline;
}

- (void)toggleEnabled {
    _enabled = !_enabled;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Position: %@ Size: %@ Key: %i Key Name: %@",
            NSStringFromCGPoint(_position),
            NSStringFromCGSize(_size),
            _key,
            _keyName];
}

- (KeyButtonConfiguration *)clone {
    KeyButtonConfiguration *clone = [[[KeyButtonConfiguration alloc] init] autorelease];
    clone.position = _position;
    clone.size = _size;
    clone.key = _key;
    clone.keyName = [_keyName copy];
    clone.groupName = [_groupName copy];
    clone.showOutline = _showOutline;
    clone.enabled = _enabled;
    return clone;
}

+ (NSString *)serializeToJSON:(NSArray<KeyButtonConfiguration *> *)keyButtonConfigurations
{
    NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:[keyButtonConfigurations count]];
    for (KeyButtonConfiguration *cfg in keyButtonConfigurations) {
        [dicts addObject:[cfg toDict]];
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicts options:0 error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSArray<KeyButtonConfiguration *> *)deserializeFromJSON:(NSString *)json
{
    if (!json) {
        return @[];
    }
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    NSArray *dicts = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSMutableArray *keyButtonConfigurations = [[[NSMutableArray alloc] initWithCapacity:[dicts count]] autorelease];
    for (NSDictionary *dict in dicts) {
        KeyButtonConfiguration *cfg = [KeyButtonConfiguration fromDict:dict];
        [keyButtonConfigurations addObject:cfg];
    }
    return keyButtonConfigurations;

}

NSString *const kPositionAttrName = @"position";
NSString *const kSizeAttrName = @"size";
NSString *const kKeyAttrName = @"key";
NSString *const kKeyNameAttrName = @"keyname";
NSString *const kGroupNameAttrName = @"groupname";
NSString *const kShowOutlineAttrName = @"showoutline";
NSString *const kEnabledAttrName = @"enabled";

- (NSDictionary *)toDict {
    return @{kPositionAttrName : NSStringFromCGPoint(self.position),
                 kSizeAttrName : NSStringFromCGSize(self.size),
                  kKeyAttrName : @(self.key),
              kKeyNameAttrName : self.keyName,
            kGroupNameAttrName : self.groupName,
          kShowOutlineAttrName : @(self.showOutline),
              kEnabledAttrName : @(self.enabled)};
}

+ (KeyButtonConfiguration *)fromDict:(NSDictionary *)dict
{
    KeyButtonConfiguration *cfg = [[[KeyButtonConfiguration alloc] init] autorelease];
    cfg.position = CGPointFromString([dict objectForKey:kPositionAttrName]);
    cfg.size = CGSizeFromString([dict objectForKey:kSizeAttrName]);
    cfg.key = (SDLKey)[[dict objectForKey:kKeyAttrName] intValue];
    cfg.keyName = [dict objectForKey:kKeyNameAttrName];
    cfg.groupName = [dict objectForKey:kGroupNameAttrName];
    cfg.showOutline = [[dict objectForKey:kShowOutlineAttrName] boolValue];
    cfg.enabled = [[dict objectForKey:kEnabledAttrName] boolValue];
    return cfg;
}

- (id)copyWithZone:(NSZone*)zone {
    return [self retain];
}

@end
