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

#import "GlassCGLOffscreen.h"

#import "GlassCGLFrameBufferObject.h"
//#import "GlassPBuffer.h"

//#define VERBOSE
#ifndef VERBOSE
    #define LOG(MSG, ...)
#else
    #define LOG(MSG, ...) GLASS_LOG(MSG, ## __VA_ARGS__);
#endif

@implementation GlassCGLOffscreen

- (id)initWithContext:(CGLContextObj)ctx
            andIsSwPipe:(BOOL)isSwPipe;
{
    self = [super init];
    if (self != nil)
    {
        self->_ctx = CGLRetainContext(ctx);

        [self setContext];
        {
            self->_fbo = [[GlassCGLFrameBufferObject alloc] init];
            if (self->_fbo == nil)
            {
                // TODO: implement PBuffer if needed
                //self->_fbo = [[GlassPBuffer alloc] init];
            }
            [(GlassCGLFrameBufferObject*)self->_fbo setIsSwPipe:(BOOL)isSwPipe];
        }
        [self unsetContext];
    }
    return self;
}

- (CGLContextObj)getContext;
{
    return self->_ctx;
}

- (void)dealloc
{
    [self setContext];
    {
        [(NSObject*)self->_fbo release];
        self->_fbo = NULL;
    }
    [self unsetContext];

    CGLReleaseContext(self->_ctx);
    self->_ctx = NULL;

    [super dealloc];
}

- (unsigned int)width
{
    return [self->_fbo width];
}

- (unsigned int)height
{
    return [self->_fbo height];
}

- (jlong)fbo
{
    return (jlong)[self->_fbo fbo];
}

- (void)setContext
{
    self->_ctxToRestore = CGLGetCurrentContext();
    CGLLockContext(self->_ctx);
    CGLSetCurrentContext(self->_ctx);
}

- (void)unsetContext
{
    CGLSetCurrentContext(self->_ctxToRestore);
    CGLUnlockContext(self->_ctx);
}

- (void)bindForWidth:(GLuint)width andHeight:(GLuint)height
{
    [self setContext];
    [self->_fbo bindForWidth:width andHeight:height];
}

- (void)unbind
{
    [self->_fbo unbind];
    [self unsetContext];
}

- (GLuint)texture
{
    return [self->_fbo texture];
}

- (void)blitForWidth:(GLuint)width andHeight:(GLuint)height
{
    {
#if 1
        glClearColor(self->_backgroundR, self->_backgroundG, self->_backgroundB, self->_backgroundA);
        glClear(GL_COLOR_BUFFER_BIT);
#else
        // for debugging, change clear color every 0.5 seconds
        static int counterFps = 0;
        static int counterColor = 0;
        counterFps++;
        if ((counterFps%(60/2)) == 0)
        {
            counterColor++;
        }
        switch (counterColor%3)
        {
            case 0:
                glClearColor(1.0f, 0.0f, 0.0f, 1.0f);
                break;
            case 1:
                glClearColor(0.0f, 1.0f, 0.0f, 1.0f);
                break;
            case 2:
                glClearColor(0.0f, 0.0f, 1.0f, 1.0f);
                break;
        }
        glClear(GL_COLOR_BUFFER_BIT);
#endif
        [self->_fbo blitForWidth:width andHeight:height];

        self->_dirty = GL_FALSE;
    }
}

- (GLboolean)isDirty
{
    return self->_dirty;
}

- (void)blitFromOffscreen:(GlassCGLOffscreen*)other_offscreen
{
    [self setContext];
    {
        [(GlassCGLFrameBufferObject*)self->_fbo blitFromFBO:(GlassCGLFrameBufferObject*)other_offscreen->_fbo];
        self->_dirty = GL_TRUE;
    }
    [self unsetContext];
}

@end
