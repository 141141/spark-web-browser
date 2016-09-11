//
//  NSUserDefaults+ColorSupport.h
//  Spark
//
//  Created by Jonathan Wukitsch on 9/10/16.
//  Copyright © 2016 Insleep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults(myColorSupport)

- (void)setColor:(NSColor *)aColor forKey:(NSString *)aKey;
- (NSColor *)colorForKey:(NSString *)aKey;

@end
