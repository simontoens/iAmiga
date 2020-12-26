//
//  ImageUtils.m
//  Common
//
//  Created by Dan Ginsburg on 6/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import "esUtil.h"

///
//	Load a 24-bit PNG file
//
char*  esLoadPNG ( const char *fileName, kRETexturePixelFormat desiredFormat, int *width, int *height )
{
	NSString *filePath = [NSString stringWithUTF8String: fileName];
	NSString *path = [[NSBundle mainBundle] pathForResource: filePath ofType:@"png"];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
	
	CGImageRef CGImage = image.CGImage;
    
    *width = (int) CGImageGetWidth(CGImage);
    *height = (int) CGImageGetHeight(CGImage);
	CGFloat POTWide = *width, POTHigh = *height;
	
	CGImageAlphaInfo info = CGImageGetAlphaInfo(CGImage);
	BOOL hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	size_t bpp = CGImageGetBitsPerComponent(CGImage);
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(CGImage);
	
	// actual format
	kRETexturePixelFormat pixelFormat = kRETexturePixelFormat_RGBA8888;
	if(colorSpace) {
		if(hasAlpha || bpp >= 8)
			pixelFormat = kRETexturePixelFormat_RGBA8888;
		else {
			pixelFormat = kRETexturePixelFormat_RGB565;
		}
	} else {
		// NOTE: No colorspace means a mask image
		// pixelFormat = kCCTexture2DPixelFormat_A8;
	}
	
	CGContextRef context = nil;
	void *data = nil;
	
	switch(pixelFormat) {          
		case kRETexturePixelFormat_RGBA8888:
		case kRETexturePixelFormat_RGBA4444:
		case kRETexturePixelFormat_RGB5A1:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(POTHigh * POTWide * 4);
			info = hasAlpha ? kCGImageAlphaPremultipliedLast : kCGImageAlphaNoneSkipLast; 
			context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, 4 * POTWide, colorSpace, info | kCGBitmapByteOrder32Big);				
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kRETexturePixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = malloc(POTHigh * POTWide * 4);
			info = kCGImageAlphaNoneSkipLast;
			context = CGBitmapContextCreate(data, POTWide, POTHigh, 8, 4 * POTWide, colorSpace, info | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}

	CGContextClearRect(context, CGRectMake(0, 0, POTWide, POTHigh));
	CGContextTranslateCTM(context, 0, POTHigh - *height);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(CGImage), CGImageGetHeight(CGImage)), CGImage);
	
	// Repack the pixel data into the right format
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	if(desiredFormat == kRETexturePixelFormat_RGB565) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	else if (desiredFormat == kRETexturePixelFormat_RGBA4444) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRGGGGBBBBAAAA"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 4) << 0); // A
		
		
		free(data);
		data = tempData;
		
	}
	else if (desiredFormat == kRETexturePixelFormat_RGB5A1) {
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGBBBBBA"
		tempData = malloc(POTHigh * POTWide * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(unsigned int i = 0; i < POTWide * POTHigh; ++i, ++inPixel32)
			*outPixel16++ = 
			((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | // R
			((((*inPixel32 >> 8) & 0xFF) >> 3) << 6) | // G
			((((*inPixel32 >> 16) & 0xFF) >> 3) << 1) | // B
			((((*inPixel32 >> 24) & 0xFF) >> 7) << 0); // A
		
		
		free(data);
		data = tempData;
	}
	
    CGContextRelease(context);
	
	[image release];
    [texData release];
	
	return data;    
}
