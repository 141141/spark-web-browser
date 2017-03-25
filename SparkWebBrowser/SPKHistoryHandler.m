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
    
    [defaults setObject:nil forKey:@"storedHistoryArray"];
    [defaults setObject:nil forKey:@"storedHistoryTitlesArray"];
    
    [historyTable resetTableView];
    
    NSLog(@"History cleared.");
    
    appDelegate.popupWindowTitle.stringValue = @"Clear History and Restart?";
    appDelegate.popupWindowText.stringValue = [NSString stringWithFormat:@"This action cannot be undone. Are you sure you want to clear your history? A browser restart is required for this to take effect."];
    appDelegate.popupWindowBtn1.title = @"Clear History";
    appDelegate.popupWindowBtn2.title = @"Restart Later";
    appDelegate.popupWindowBtn1.action = @selector(clearHistoryBtnClicked);
    appDelegate.popupWindow.isVisible = YES;
    [appDelegate.popupWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)clearHistoryBtnClicked {
    // Do nothing - this method is in AppDelegate.m. This is only here to silence Xcode warnings.
}

- (NSMutableArray *)getHistoryItems {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *currentHistoryArray = nil; // Mutable array for history URLs
    
    if([defaults objectForKey:@"storedHistoryArray"] == nil) {
        
        NSLog(@"StoredHistoryArray: nil");
        
        currentHistoryArray = [NSMutableArray array];
        
    } else {
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
        currentHistoryTitlesArray = [[defaults objectForKey:@"storedHistoryTitlesArray"] mutableCopy];
    }
    
    return currentHistoryTitlesArray;
}

@end
