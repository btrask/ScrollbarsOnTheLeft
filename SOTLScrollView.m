/* Copyright (c) 2009, Ben Trask
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * The names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY BEN TRASK ''AS IS'' AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL BEN TRASK BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */
#import "SOTLScrollView.h"

// Other Sources
#import "SOTLAdditions.h"

static void (*SOTLNSScrollViewTile)(id, SEL);
static id (*SOTLNSScrollViewInitWithCoder)(id, SEL, NSCoder *);

static void SOTLApplyToScrollView(id scrollView) {
	if([scrollView respondsToSelector:@selector(tile)]) [scrollView tile];
}

@interface NSScrollView(SOTLAdditions)

- (BOOL)SOTL_scrollerVisible:(NSScroller *)scroller;

@end

@implementation SOTLScrollView

#pragma mark +NSObject

+ (void)load
{
	if(floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_5) return;
	SOTLNSScrollViewTile = (void (*)(id, SEL))[NSScrollView SOTL_useImplementationFromClass:self forSelector:@selector(tile)];
	SOTLNSScrollViewInitWithCoder = (id (*)(id, SEL, NSCoder *))[NSClassFromString(@"NSScrollView") SOTL_useImplementationFromClass:self forSelector:@selector(initWithCoder:)];
	for(id const scrollView in [NSApp SOTL_viewsOfClass:NSClassFromString(@"NSScrollView")]) SOTLApplyToScrollView(scrollView);
}

#pragma mark -NSScrollView

- (void)tile
{
	SOTLNSScrollViewTile(self, _cmd);

	if([self SOTL_isPartOfWebView]) return;

	NSScroller *const vertScroller = [self verticalScroller];
	if(![self SOTL_scrollerVisible:vertScroller]) return;
	NSClipView *const content = [self contentView];
	CGFloat borderThickness = 0;
	switch([self borderType]) {
		case NSLineBorder: borderThickness = 1; break;
		case NSBezelBorder: borderThickness = 1; break;
		case NSGrooveBorder: borderThickness = 2; break;
	}
	[vertScroller setFrameOrigin:NSMakePoint(NSMinX([self bounds]) + borderThickness, NSMinY([vertScroller frame]))];
	[content setFrameOrigin:NSMakePoint(NSMinX([content frame]) + NSWidth([vertScroller frame]), NSMinY([content frame]))];

	if([self hasVerticalRuler]) {
		NSRulerView *const ruler = [self verticalRulerView];
		[ruler setFrameOrigin:NSMakePoint(NSMinX([ruler frame]) + NSWidth([vertScroller frame]), NSMinY([ruler frame]))];
	}

	NSScroller *const horzScroller = [self horizontalScroller];
	if([self SOTL_scrollerVisible:horzScroller]) {
		[horzScroller setFrameOrigin:NSMakePoint(NSMinX([horzScroller frame]) + NSWidth([vertScroller frame]), NSMinY([horzScroller frame]))];
	}

	id const document = [self documentView];
	if(![document respondsToSelector:@selector(headerView)] || ![document respondsToSelector:@selector(cornerView)]) return;
	NSClipView *const header = (NSClipView *)[[document headerView] superview];
	NSView *const corner = [document cornerView];
	if([header superview] != self || [corner superview] != self) return;
	[corner setFrameOrigin:NSMakePoint(NSMinX([self bounds]) + borderThickness, NSMinY([corner frame]))];
	[header setFrameOrigin:NSMakePoint(NSMinX([header frame]) + NSWidth([vertScroller frame]), NSMinY([header frame]))];
}

#pragma mark -<NSCoding>

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = SOTLNSScrollViewInitWithCoder(self, _cmd, aDecoder))) {
		SOTLApplyToScrollView(self);
	}
	return self;
}

@end

@implementation NSScrollView(SOTLAdditions)

- (BOOL)SOTL_scrollerVisible:(NSScroller *)scroller
{
	if(!scroller) return NO;
	if([self verticalScroller] == scroller && ![self hasVerticalScroller]) return NO;
	if([self horizontalScroller] == scroller && ![self hasHorizontalScroller]) return NO;
	if(![self autohidesScrollers]) return YES;
	return ![scroller isHidden] && [scroller superview];
}

@end
