//
//  TabViewItem.m
//  Spark
//
//  Created by Jonathan Wukitsch on 5/8/16.
//  Copyright © 2016 Insleep. All rights reserved.
//

#import "TabViewItem.h"

@implementation TabViewItem
- (void) dealloc
{
    self.webView = nil;
    //[super dealloc]; // Provided by the compiler.
}
@end

