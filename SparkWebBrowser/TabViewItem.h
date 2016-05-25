//
//  TabViewItem.h
//  Spark
//
//  Created by Jonathan Wukitsch on 5/8/16.
//  Copyright © 2016 Insleep. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class WebView;

@interface TabViewItem : NSTabViewItem
@property (readwrite, assign, nonatomic) WebView *webView;
@end
