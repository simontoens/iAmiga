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

#import "DisplayView.h"
#import <QuartzCore/QuartzCore.h>

static DisplayView* sharedView;
static BOOL newFrame = NO;

void UpdateScreen() {
	//[sharedView performSelectorOnMainThread:@selector(updateScreen) withObject:nil waitUntilDone:NO];
    newFrame = YES;
}

UIView* CreateCGDisplayView(int width, int height) {
	return [[DisplayView alloc] initWithFrame:CGRectMake(0, 0, width, height) displaySize:CGSizeMake(width, height)];
}

@interface DisplayView() 

- (void)drawView:(CADisplayLink *)displayLink;

@end

@implementation DisplayView

const int kBytesPerPixel			= 2;
const int kBitsPerComponent			= 5;
const unsigned int kFormat			= kCGBitmapByteOrder16Little | kCGImageAlphaNoneSkipFirst;
CGContextRef				context;


- (id)initWithFrame:(CGRect)frame displaySize:(CGSize)displaySize {
    if (self = [super initWithFrame:frame]) {
		sharedView = [self retain];
        self.opaque = YES;
		
		
		// create indexed color palette
		CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
		
		_pixels = malloc(displaySize.width * displaySize.height * 2);
		context = CGBitmapContextCreate(_pixels, 
										displaySize.width, displaySize.height, kBitsPerComponent, 
										displaySize.width * kBytesPerPixel, rgbColorSpace, kFormat);
		
		CFRelease(rgbColorSpace);
        
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawView:)];
        _displayLink.preferredFramesPerSecond = 2.0;
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (BOOL)paused {
	return _displayLink.paused;
}

- (void)setPaused:(BOOL)value {
	_displayLink.paused = value;
}

extern CGContextRef context;

- (void)drawView:(CADisplayLink *)displayLink {
    if (!newFrame)
        return;
    
    newFrame = NO;
	CALayer *layer = self.layer;
	CGImageRef image = CGBitmapContextCreateImage(context);
	layer.contents = (id)image;
	layer.contentsRect = CGRectMake(0.0, 0.0, 1.0, 1.0);
	CFRelease(image);
}

- (void)dealloc {
	free(_pixels);
    [super dealloc];
}

@synthesize pixels=_pixels, paused=_paused, displayEffect=_displayEffect;
@end
