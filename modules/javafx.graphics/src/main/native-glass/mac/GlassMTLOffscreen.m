/*
 * Copyright (c) 2012, 2017, Oracle and/or its affiliates. All rights reserved.
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



#import "GlassMTLOffscreen.h"

#import "GlassMTLFrameBufferObject.h"
//#import "GlassPBuffer.h"

//#define VERBOSE
#ifndef VERBOSE
    #define LOG(MSG, ...)
#else
    #define LOG(MSG, ...) GLASS_LOG(MSG, ## __VA_ARGS__);
#endif

// @interface GlassOffscreen ()
// - (void)setContext;
// - (void)unsetContext;
// @end

@implementation GlassMTLOffscreen

- (id)initWithContext:(NSObject*)device
            andIsSwPipe:(BOOL)isSwPipe;
{
    self = [super init];
    if (self != nil)
    {
        {
            self->_fbo = [[GlassMTLFrameBufferObject alloc] init];
            if (self->_fbo == nil)
            {
                // TODO: implement PBuffer if needed
                //self->_fbo = [[GlassPBuffer alloc] init];
            }
            [(GlassMTLFrameBufferObject*)self->_fbo setIsSwPipe:(BOOL)isSwPipe];
        }
    }
    return self;
}

- (CGLContextObj)getCtx;
{
    return nil;
}

- (void)dealloc
{
    {
        [(NSObject*)self->_fbo release];
        self->_fbo = NULL;
    }

    [super dealloc];
}

- (unsigned int)getWidth
{
    return [self->_fbo width];
}

- (unsigned int)getHeight
{
    return [self->_fbo height];
}

- (void)unbind{
    //no-op in case of MTL
}

- (jlong)getFBO
{
    //NSLog(@"Glass fbo = %@", [self->_fbo texture]);
    return ptr_to_jlong((void *)[self->_fbo texture]);

    //return [self->_fbo fbo];
}

- (void)bindForWidth:(unsigned int)width andHeight:(unsigned int)height
{
    //NSLog(@"GlassMTLOffscreen -------- w x h : %d x %d", width, height);
    [self->_fbo bindForWidth:width andHeight:height];
}

- (id<MTLTexture>)getTexture
{
    return [self->_fbo texture];
}

- (void)blitForWidth:(unsigned int)width andHeight:(unsigned int)height
{
    {
        [self->_fbo blitForWidth:width andHeight:height];
    }
}

- (unsigned char)isDirty
{
    // no-op in case of MTL
    return 0;
}

// TODO: MTL: This just creates another texture and doesn't do any blit
- (void)blitFromOffscreen:(GlassOffscreen*) other_offscreen
{
    {
        [(GlassMTLFrameBufferObject*)self->_fbo blitFromFBO:(GlassMTLFrameBufferObject*)other_offscreen->offScreen->_fbo];
    }
}

@end
