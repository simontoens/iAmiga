//  Created by Simon Toens on 22.08.16
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
#import "CoreSettingGroup.h"

@interface TestGroup : NSObject <CoreSettingGroup> @end
@interface TestGroupMember : CoreSetting <CoreSettingGroupMember> @end

@implementation TestGroupMember {
    @public
    NSString *persistValueArgument;
    NSString *onResetArgument;
    NSString *emulatorValue;
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

- (Class)getGroup {
    return TestGroup.self;
}

@end

NSMutableDictionary *groupMemberToValue;
NSUInteger onResetAfterMembersNumCalls;

@implementation TestGroup

- (void)onResetAfterMembers:(NSSet *)groupMembers {
    for (CoreSetting *setting in groupMembers) {
        [groupMemberToValue setObject:[setting getValue] forKey:setting];
    }
    onResetAfterMembersNumCalls++;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return self;
}

@end


@interface CoreSettingGroupTests : XCTestCase

@end

@implementation CoreSettingGroupTests {
    @private
    TestGroupMember *_setting1;
    TestGroupMember *_setting2;
    TestGroupMember *_setting3;
}

- (void)setUp {
    [super setUp];
    _setting1 = [[TestGroupMember alloc] initWithName:@"m1"];
    _setting2 = [[TestGroupMember alloc] initWithName:@"m2"];
    _setting3 = [[TestGroupMember alloc] initWithName:@"m3"];
    groupMemberToValue = [[NSMutableDictionary alloc] init];
    onResetAfterMembersNumCalls = 0;
}

- (void)testSingleSettingModified {
    [_setting1 setValue:@"v"];
    
    [CoreSettings onReset];

    XCTAssertEqual(onResetAfterMembersNumCalls, 1);
    XCTAssertEqual([groupMemberToValue count], 1);
    XCTAssertEqualObjects([[groupMemberToValue keyEnumerator] nextObject], _setting1);
}

- (void)testTwoSettingsModified {
    [_setting1 setValue:@"v1"];
    [_setting3 setValue:@"v2"];
    
    [CoreSettings onReset];
    
    XCTAssertEqual(onResetAfterMembersNumCalls, 1);
    XCTAssertEqual([groupMemberToValue count], 2);
    NSSet *expected = [NSSet setWithObjects:_setting1, _setting3, nil];
    XCTAssertEqualObjects([NSSet setWithArray:[groupMemberToValue allKeys]], expected);
}

- (void)testSettingsModifiedAndReset {
    [_setting1 setValue:@"v1"];
    [_setting2 setValue:@"v2"];
    [_setting3 setValue:@"v3"];
    [_setting3 setValue:nil]; // reset value back to original value
    
    [CoreSettings onReset];
    
    XCTAssertEqual(onResetAfterMembersNumCalls, 1);
    XCTAssertEqual([groupMemberToValue count], 2);
    NSSet *expected = [NSSet setWithObjects:_setting1, _setting2, nil];
    XCTAssertEqualObjects([NSSet setWithArray:[groupMemberToValue allKeys]], expected);
}

- (void)testNoGroupCallbackWhenNoSettingModification {
    [CoreSettings onReset];
    
    XCTAssertEqual(onResetAfterMembersNumCalls, 0);
}

- (void)testSettingValueOnCallback {
    [_setting1 setValue:@"v1"];
    
    [CoreSettings onReset];
    
    XCTAssertEqual([groupMemberToValue count], 1);
    XCTAssertEqualObjects([[groupMemberToValue objectEnumerator] nextObject], @"v1");
}

@end
