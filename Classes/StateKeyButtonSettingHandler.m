//
//  StateKeyButtonSettingHandler.m
//  iUAE
//
//  Created by Simon Toens on 9/30/19.
//

#import "KeyButtonConfiguration.h"
#import "StateKeyButtonSettingHandler.h"

static NSString *const kKeyButtonsConfigName = @"keybuttons";

@implementation StateKeyButtonSettingHandler {
    State *_state;
    StateFileManager *_stateFileManager;
    NSArray<KeyButtonConfiguration *> *_currentValue;
}

- (id)initWithState:(State *)state stateFileManager:(StateFileManager *)stateFileManager {
    if (self = [super init]) {
        _state = [state retain];
        _stateFileManager = [stateFileManager retain];
        _currentValue = nil;
    }
    return self;
}

- (NSArray<KeyButtonConfiguration *> *)value {
    return _currentValue;
}

- (id)loadSettingValue {
    NSString *json = [_state getConfigContentWithName:kKeyButtonsConfigName];
    if (!json) {
        // the state we're loading doesn't have an associate key buttons config,
        // so make an empty one here
        json = [KeyButtonConfiguration serializeToJSON:@[]];
    }
    [_currentValue release];
    _currentValue = [[KeyButtonConfiguration deserializeFromJSON:json] retain];
    return _currentValue;
}

- (void)saveSettingValue:(id)value {
    [_currentValue release];
    _currentValue = [value retain];
    NSString *json = [KeyButtonConfiguration serializeToJSON:_currentValue];
    [_state addConfigContent:json withName:kKeyButtonsConfigName];
    [_stateFileManager saveConfig:kKeyButtonsConfigName forState:_state];
}

- (void)dealloc {
    [_state release];
    [_stateFileManager release];
    [_currentValue release];
    [super dealloc];
}

@end
