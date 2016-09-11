//
//  NSUserDefaults+ColorSupport.m
//  Spark
//
//  Created by Jonathan Wukitsch on 9/10/16.
//  Copyright © 2016 Insleep. All rights reserved.
//

#import "NSUserDefaults+ColorSupport.h"

@implementation NSUserDefaults(myColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey
{
    NSData *theData = [NSArchiver archivedDataWithRootObject:aColor];
    [self setObject:theData forKey:aKey];
}

- (NSColor *)colorForKey:(NSString *)aKey
{
    NSColor *theColor = nil;
    NSData *theData = [self dataForKey:aKey];
    if (theData != nil)
        theColor = (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
    return theColor;
}

@end
