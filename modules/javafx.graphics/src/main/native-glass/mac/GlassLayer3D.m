/*
 * Copyright (c) 2012, 2024, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

#import "GlassLayer3D.h"
#import "GlassMacros.h"
#import "GlassScreen.h"

//#define VERBOSE
#ifndef VERBOSE
    #define LOG(MSG, ...)
#else
    #define LOG(MSG, ...) GLASS_LOG(MSG, ## __VA_ARGS__);
#endif

@implementation GlassLayer3D

static NSArray *allModes = nil;

- (id)initWithSharedContext:(CGLContextObj)ctx
           andClientContext:(CGLContextObj)clCtx
           mtlQueuePtr:(long)mtlCommandQueuePtr
             withHiDPIAware:(BOOL)HiDPIAware
             withIsSwPipe:(BOOL)isSwPipe
{
    LOG("GlassLayer3D initWithSharedContext]");
    self = [super init];
    if (self != nil)
    {
        if (mtlCommandQueuePtr != 0l) { // MTL
            layer = mtlLayer = [[GlassLayerMTL3D alloc] init:mtlCommandQueuePtr withIsSwPipe:isSwPipe];
            [self addSublayer:mtlLayer];
            self->isMTL = YES;
        } else {
            layer = cglLayer = [[GlassLayerCGL3D alloc] initWithSharedContext:ctx andClientContext:clCtx withHiDPIAware:HiDPIAware withIsSwPipe:isSwPipe];
            [self addSublayer:cglLayer];
            self->isMTL = NO;
        }
        //self->_painterOffscreen = [[GlassCGLOffscreen alloc] initWithContext:clCtx andIsSwPipe:isSwPipe];
        //self->_glassOffscreen = [[GlassCGLOffscreen alloc] initWithContext:ctx andIsSwPipe:isSwPipe];
        //[self->_glassOffscreen setLayer:self];
        LOG("   GlassLayer3D context: %p", ctx);

        [self setAutoresizingMask:(kCALayerWidthSizable|kCALayerHeightSizable)];
        [self setContentsGravity:kCAGravityTopLeft];

        // Initially the view is not in any window yet, so using the
        // screens[0]'s scale is a good starting point (this is most probably
        // the notebook's main LCD display which is HiDPI-capable).
        // Note that mainScreen is the screen with the current app bar focus
        // in Mavericks and later OS so it will likely not match the screen
        // we initially show windows on if an app is started from an external
        // monitor.
        [self notifyScaleFactorChanged:GetScreenScaleFactor([[NSScreen screens] objectAtIndex:0])];

        [self setMasksToBounds:YES];
        [self setNeedsDisplayOnBoundsChange:YES];
        [self setAnchorPoint:CGPointMake(0.0f, 0.0f)];

        if (allModes == nil) {
            allModes = [[NSArray arrayWithObjects:NSDefaultRunLoopMode,
                                                  NSEventTrackingRunLoopMode,
                                                  NSModalPanelRunLoopMode, nil] retain];
        }
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)notifyScaleFactorChanged:(CGFloat)scale
{
    if (self->isMTL) {
        [mtlLayer notifyScaleFactorChanged:scale];
    } else {
        [cglLayer notifyScaleFactorChanged:scale];
    }
    /*if (self->isHiDPIAware) {
        if ([self respondsToSelector:@selector(setContentsScale:)]) {
            [self setContentsScale: scale];
        }
    }*/
}

- (void)flush
{
    if (self->isMTL) {
        [mtlLayer flush];
    } else {
        [cglLayer flush];
    }
    /*[(GlassCGLOffscreen*)_glassOffscreen blitFromOffscreen:(GlassCGLOffscreen*)_painterOffscreen];
    if ([NSThread isMainThread]) {
        [[self->_glassOffscreen getLayer] setNeedsDisplay];
    } else {
        [[self->_glassOffscreen getLayer] performSelectorOnMainThread:@selector(setNeedsDisplay)
                                                           withObject:nil
                                                        waitUntilDone:NO
                                                                modes:allModes];
    }*/
}

// TODO: Again we need common OffScreen
- (GlassMTLOffscreen*)getMTLPainterOffscreen
{
    return [mtlLayer getPainterOffscreen];
}

- (GlassCGLOffscreen*)getCGLPainterOffscreen
{
    return [cglLayer getPainterOffscreen];
}

- (void)setMTLDrawableSize:(CGSize)bounds
{
    [mtlLayer setMTLDrawableSize:bounds];
}

- (void) updateOffscreenTexture:(void*)pixels
                     layerWidth:(int)width
                     layerHeight:(int)height
{
    [mtlLayer updateOffscreenTexture:pixels layerWidth: width layerHeight:height];
}

/*- (GlassCGLOffscreen*)getGlassOffscreen
{
    return self->_glassOffscreen;
}

- (void)hostOffscreen:(GlassCGLOffscreen*)offscreen
{
    [self->_glassOffscreen release];
    self->_glassOffscreen = [offscreen retain];
    [self->_glassOffscreen setLayer:self];
}*/

@end
