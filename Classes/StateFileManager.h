//  Created by Simon Toens on 07.03.15
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

/**
 * Handles the details of where and how states are stored.
 */
@interface StateFileManager : NSObject

- (instancetype)init;

/**
 * Returns YES if a state file exists for the given state name, NO otherwise.
 */
- (BOOL)stateFileExistsForStateName:(NSString *)stateName;

/**
 * Returns YES if the given state name does not contain any problematic characters, NO otherwise.
 */
- (BOOL)isValidStateName:(NSString *)stateName;

/**
 * Returns an array of all persisted State instances.
 */
- (NSArray *)loadStates;

/**
 * Returns a State instance for the specified stateName, nil if it does not exist.
 */
- (State *)loadState:(NSString *)stateName;

/**
 * Returns a new State instance with only path set, intended to be populated and saved.
 */
- (State *)newState:(NSString *)stateName;

/**
 * Saves meta information about the specified state (but not the state itself, that is handled
 * by the core emulator).
 */
- (void)saveState:(State *)state;

/**
 * Saves the specified configuration only.
 */
- (void)saveConfig:(NSString *)configName forState:(State *)state;

/**
 * Deletes the specified state.
 */
- (void)deleteState:(State *)state;

@end
