//
//  WebViewHandler.m
//  Spark Web Browser
//
//  Created by Jonathan Wukitsch on 5/7/16.
//  Copyright © 2016 Insleep. All rights reserved.
//

#import "WebViewHandler.h"

@implementation WebViewHandler

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

// TODO: move AppDelegate code over here

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
    
    NSString *chars = [theEvent characters];
    BOOL status = NO;
    
    if ([theEvent modifierFlags] & NSCommandKeyMask){
        
        if ([chars isEqualTo:@"a"]){
            [self selectAll:nil];
            status = YES;
        }
        
        if ([chars isEqualTo:@"c"]){
            [self copy:nil];
            status = YES;
        }
        
        if ([chars isEqualTo:@"v"]){
            [self paste:nil];
            status = YES;
        }
        
        if ([chars isEqualTo:@"x"]){
            [self cut:nil];
            status = YES;
        }
    }
    
    if (status)
        return YES;
    
    return [super performKeyEquivalent:theEvent];
}

@end
