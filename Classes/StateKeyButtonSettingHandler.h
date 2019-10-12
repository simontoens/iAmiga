//
//  StateKeyButtonSettingHandler.h
//  iUAE
//
//  Created by Simon Toens on 9/30/19.
//

#import <Foundation/Foundation.h>
#import "Settings.h"
#import "State.h"
#import "StateFileManager.h"

@interface StateKeyButtonSettingHandler : NSObject <SettingHandler>

- (id)init __unavailable;

- (id)initWithState:(State *)state stateFileManager:(StateFileManager *)stateFileManager;

@property (nonatomic, readonly) NSString *value;

@end
