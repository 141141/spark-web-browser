//
//  SPKHistoryHandler.m
//  Spark
//
//  Copyright (c) 2014-2017 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "SPKHistoryHandler.h"
#import "SPKHistoryTable.h"
#import "AppDelegate.h"

@implementation SPKHistoryHandler

- (void)addHistoryItem:(NSString *)historyURLString withHistoryTitle:(NSString *)historyTitle {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *currentHistoryArray = nil; // Mutable array for history URLs
    NSMutableArray *currentHistoryTitlesArray = nil; // Mutable array for history page titles
    
    if([defaults objectForKey:@"storedHistoryArray"] == nil) {
        
        NSLog(@"StoredHistoryArray: nil");
        
        currentHistoryArray = [NSMutableArray array];
        currentHistoryTitlesArray = [NSMutableArray array];
        
        [currentHistoryArray addObject:historyURLString];
        [currentHistoryTitlesArray addObject:historyTitle];
        
        [defaults setObject:currentHistoryArray forKey:@"storedHistoryArray"];
        [defaults setObject:currentHistoryTitlesArray forKey:@"storedHistoryTitlesArray"];
        
    } else {
        
        // StoredHistoryArray exists
        
        currentHistoryArray = [[defaults objectForKey:@"storedHistoryArray"] mutableCopy];
        currentHistoryTitlesArray = [[defaults objectForKey:@"storedHistoryTitlesArray"] mutableCopy];
        
        [currentHistoryArray addObject:historyURLString];
        [currentHistoryTitlesArray addObject:historyTitle];
        
        [defaults setObject:currentHistoryArray forKey:@"storedHistoryArray"];
        [defaults setObject:currentHistoryTitlesArray forKey:@"storedHistoryTitlesArray"];
    }
}

- (void)clearHistory {
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    SPKHistoryTable *historyTable = [[SPKHistoryTable alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Clearing history...");
    
    [defaults setObject:nil forKey:@"storedHistoryArray"]; // Clear URLs array
    [defaults setObject:nil forKey:@"storedHistoryTitlesArray"]; // Clear titles array
    
    [historyTable resetTableView];
    [historyTable refreshHistoryContent];
    
    NSLog(@"History cleared.");
    
    // Display a checkmark after history is cleared
    appDelegate.historyClearedIcon.hidden = NO;
    appDelegate.historyClearedIcon2.hidden = NO;
    
    // Timer to display the checkmark for 2 seconds
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
        appDelegate.historyClearedIcon.hidden = YES;
        appDelegate.historyClearedIcon2.hidden = YES;
    });
}

- (NSMutableArray *)getHistoryItems {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *currentHistoryArray = nil; // Mutable array for history URLs
    
    if([defaults objectForKey:@"storedHistoryArray"] == nil) {
        
        NSLog(@"StoredHistoryArray: nil");
        
        currentHistoryArray = [NSMutableArray array];
        
    } else {
        // StoredHistoryArray exists
        currentHistoryArray = [[defaults objectForKey:@"storedHistoryArray"] mutableCopy];
    }
    
    return currentHistoryArray;
}

- (NSMutableArray *)getHistoryTitleItems {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *currentHistoryTitlesArray = nil; // Mutable array for history URL titles
    
    if([defaults objectForKey:@"storedHistoryTitlesArray"] == nil) {
        
        NSLog(@"StoredHistoryTitlesArray: nil");
        
        currentHistoryTitlesArray = [NSMutableArray array];
        
    } else {
        // StoredHistoryTitlesArray exists
        currentHistoryTitlesArray = [[defaults objectForKey:@"storedHistoryTitlesArray"] mutableCopy];
    }
    
    return currentHistoryTitlesArray;
}

@end
