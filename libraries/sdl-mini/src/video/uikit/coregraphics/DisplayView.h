/* 
 Flashback for iPhone - Flashback interpreter
 Copyright (C) 2009 Stuart Carnie
 See gpl.txt for license information.
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <UIKit/UIKit.h>
#import "UIKitDisplayView.h"
#import <QuartzCore/QuartzCore.h>

@interface DisplayView : UIView<DisplayViewSurface> {
	void				*_pixels;
	BOOL				_paused;
	DisplayEffect		_displayEffect;
    CADisplayLink		*_displayLink;
}

- (void)setPaused:(BOOL)value;

- (id)initWithFrame:(CGRect)frame displaySize:(CGSize)displaySize;

#ifdef __cplusplus
extern "C" 
#endif
void UpdateScreen(void);

@end

#ifdef __cplusplus
extern "C" 
#endif
UIView* CreateCGDisplayView(int width, int height);
