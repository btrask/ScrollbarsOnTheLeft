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
#import "SOTLClipView.h"

// Other Sources
#import "SOTLAdditions.h"

static void (*SOTLNSClipViewSetCopiesOnScroll)(id, SEL, BOOL);
static id (*SOTLNSClipViewInitWithFrame)(id, SEL, NSRect);
static id (*SOTLNSClipViewInitWithCoder)(id, SEL, NSCoder *);

static void SOTLApplyToClipView(id clipView)
{
	if([clipView respondsToSelector:@selector(copiesOnScroll)] && [clipView respondsToSelector:@selector(setCopiesOnScroll:)]) {
		[clipView setCopiesOnScroll:[clipView copiesOnScroll]];
	}
}

@implementation SOTLClipView

#pragma mark +NSObject

+ (void)load
{
	if(floor(NSAppKitVersionNumber) <= NSAppKitVersionNumber10_5) return;
	SOTLNSClipViewSetCopiesOnScroll = (void (*)(id, SEL, BOOL))[NSClassFromString(@"NSClipView") SOTL_useImplementationFromClass:self forSelector:@selector(setCopiesOnScroll:)];
	SOTLNSClipViewInitWithFrame = (id (*)(id, SEL, NSRect))[NSClassFromString(@"NSClipView") SOTL_useImplementationFromClass:self forSelector:@selector(initWithFrame:)];
	SOTLNSClipViewInitWithCoder = (id (*)(id, SEL, NSCoder *))[NSClassFromString(@"NSClipView") SOTL_useImplementationFromClass:self forSelector:@selector(initWithCoder:)];
	for(id const clipView in [NSApp SOTL_viewsOfClass:NSClassFromString(@"NSClipView")]) SOTLApplyToClipView(clipView);
}

#pragma mark -NSClipView

- (void)setCopiesOnScroll:(BOOL)flag
{
	SOTLNSClipViewSetCopiesOnScroll(self, _cmd, [self SOTL_isPartOfWebView] ? flag : NO);
}

#pragma mark -NSView

- (id)initWithFrame:(NSRect)r
{
	if((self = SOTLNSClipViewInitWithFrame(self, _cmd, r))) {
		SOTLApplyToClipView(self);
	}
	return self;
}

#pragma mark -<NSCoding>

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if((self = SOTLNSClipViewInitWithCoder(self, _cmd, aDecoder))) {
		SOTLApplyToClipView(self);
	}
	return self;
}

@end
