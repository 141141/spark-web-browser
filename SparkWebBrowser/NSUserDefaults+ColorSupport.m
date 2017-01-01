//
//  NSUserDefaults+ColorSupport.m
//  Spark
//
//  Copyright (c) 2014-2017 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "NSUserDefaults+ColorSupport.h"

@implementation NSUserDefaults(colorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey {
    NSData *theData = [NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey {
    NSColor *theColor = nil;
    NSData *theData = [self dataForKey:aKey];
    if (theData != nil)
        theColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end
