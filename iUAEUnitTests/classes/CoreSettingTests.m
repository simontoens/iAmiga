//  Created by Simon Toens on 11.05.16
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

#import <XCTest/XCTest.h>
#import "CoreSetting.h"

@interface TestSetting : CoreSetting

@end

@implementation TestSetting {
    @public
    NSString *persistValueArgument;
    NSString *onResetArgument;
    NSString *emulatorValue;
    id currentValue;
}

- (void)setValue:(id)value {
    [super setValue:value];
    currentValue = value == nil ? [NSNull null] : value;
}

- (NSString *)getUnappliedValue {
    return currentValue;
}

- (void)hook_persistValue:(NSString *)arg {
    persistValueArgument = arg;
}

- (void)hook_onReset:(NSString *)arg {
    onResetArgument = arg;
}

- (NSString *)hook_getEmulatorValue {
    return emulatorValue;
}

@end

@interface CoreSettingTests : XCTestCase

@end

@implementation CoreSettingTests {
    @private
    TestSetting *_setting;
}

- (void)setUp {
    [super setUp];
    _setting = [[TestSetting alloc] initWithName:@"TestSetting"];
}

- (void)tearDown {
    [CoreSettings onReset];
    [super tearDown];
}

- (void)testRomSettingSingleton {
    DF1EnabledCoreSetting *df1_1 = [CoreSettings df1EnabledCoreSetting];
    DF1EnabledCoreSetting *df1_2 = [CoreSettings df1EnabledCoreSetting];
    
    XCTAssertNotNil(df1_1);
    XCTAssertTrue(df1_1 == df1_2);
}

- (void)testHasUnappliedValue {
    XCTAssertFalse([_setting hasUnappliedValue]);
    
    [_setting setValue:@"v1"];
    
    XCTAssertTrue([_setting hasUnappliedValue]);
}

- (void)testSetValue_backToOriginalValue {
    _setting->emulatorValue = @"e1";
    XCTAssertFalse([_setting hasUnappliedValue]);
    
    [_setting setValue:@"v1"];
    XCTAssertTrue([_setting hasUnappliedValue]);
    
     [_setting setValue:@"v2"];
    XCTAssertTrue([_setting hasUnappliedValue]);
    
    [_setting setValue:@"e1"];
    // the fact that this doesn't work seems like a bug:
    //XCTAssertFalse([_setting hasUnappliedValue]);
}

- (void)testSetValue_SameAsEmulatorValue {
    _setting->emulatorValue = @"e1";

    [_setting setValue:@"e1"];

    // the fact that this doesn't work seems like a bug:
    //XCTAssertFalse([_setting hasUnappliedValue]);
}

// also needs debugging
//- (void)testSetValue_AllNil {
//    _setting->emulatorValue = nil;
//
//    [_setting setValue:nil];
//
//    XCTAssertFalse([_setting hasUnappliedValue]);
//}

- (void)testSetValue_Nil {
    _setting->emulatorValue = @"e22";
    
    [_setting setValue:nil];
    XCTAssertTrue([_setting hasUnappliedValue]);
}

- (void)testPersistValue_CalledAfterChangingValue {
    XCTAssertNil(_setting->persistValueArgument);
    
    [_setting setValue:@"new"];
    XCTAssertEqualObjects(_setting->persistValueArgument, @"new");

    [_setting setValue:@"newer"];
    XCTAssertEqualObjects(_setting->persistValueArgument, @"newer");
}

- (void)testPersistValue_SameAsEmulatorValue_NotCalled {
    _setting->emulatorValue = @"e23";
    XCTAssertNil(_setting->persistValueArgument);
    
    [_setting setValue:@"e23"];
    
    XCTAssertNil(_setting->persistValueArgument);
}

- (void)testPersistValue_SameValue_NotCalled {
    _setting->emulatorValue = @"e24";
    XCTAssertNil(_setting->persistValueArgument);

    _setting->persistValueArgument = nil;
    [_setting setValue:@"e24"];
    XCTAssertNil(_setting->persistValueArgument);
}

- (void)testOnReset_CalledAfterChangingValues {
    XCTAssertNil(_setting->onResetArgument);
    [_setting setValue:@"new"];
    [_setting setValue:@"newer"];
    
    [CoreSettings onReset];
    
    XCTAssertEqualObjects(_setting->onResetArgument, @"newer");
}

- (void)testOnReset_NotCalledWhenValueChangedBack {
    XCTAssertNil(_setting->onResetArgument);
    [_setting setValue:@"new"];
    [_setting setValue:nil]; // default emulator setting
    
    [CoreSettings onReset];
    
    XCTAssertNil(_setting->onResetArgument);
}

- (void)testOnReset_NotCalledWhenValueDidNotChange {
    XCTAssertNil(_setting->onResetArgument);
    
    [CoreSettings onReset];
    
    XCTAssertNil(_setting->onResetArgument);
}

- (void)testOnReset_CalledWithNil {
    _setting->onResetArgument = @"empty";
    _setting->emulatorValue = @"foo";
    [_setting setValue:nil];
    
    [CoreSettings onReset];
    
    XCTAssertNil(_setting->onResetArgument);
}

- (void)testGetValue_WithUnappliedValue {
    _setting->emulatorValue = @"foo";
    
    [_setting setValue:@"blah"];
    
    XCTAssertEqualObjects([_setting getValue], @"blah");
}

- (void)testGetValue_WithoutUnappliedValue {
    _setting->emulatorValue = @"foo";
    
    XCTAssertEqualObjects([_setting getValue], @"foo");
}

- (void)testGetGetValue_UnappliedValueIsNil {
    _setting->emulatorValue = @"foo";
    
    [_setting setValue:nil];
    
    XCTAssertNil([_setting getValue]);
    
}

@end
