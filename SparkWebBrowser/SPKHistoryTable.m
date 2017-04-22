//
//  SPKHistoryTable.m
//  Spark
//
//  Copyright (c) 2014-2017 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "SPKHistoryTable.h"
#import "SPKHistoryHandler.h"
#import "AppDelegate.h"

@implementation SPKHistoryTable

NSString *historyURL = nil;
NSArray *reversedHistoryArray = nil;
NSArray *reversedHistoryTitlesArray = nil;

- (void)awakeFromNib {
    SPKHistoryHandler *historyHandler = [[SPKHistoryHandler alloc] init];
    self.historyTitlesArray = [historyHandler getHistoryTitleItems];
    self.historyURLArray = [historyHandler getHistoryItems];
    
    [self.historyTableView setDataSource:self];
}

- (IBAction)doubleClickedTableViewCell:(id)sender {
    
    AppDelegate *appDelegate = (AppDelegate *)[[NSApplication sharedApplication] delegate];
    
    [[appDelegate.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", historyURL]]]];
}

- (IBAction)refreshHistoryBtnClicked:(id)sender {
    [self refreshHistoryContent];
}

- (void)refreshHistoryContent {
    SPKHistoryHandler *historyHandler = [[SPKHistoryHandler alloc] init];
    
    self.historyTitlesArray = [historyHandler getHistoryTitleItems];
    self.historyURLArray = [historyHandler getHistoryItems];
    [self.historyTableView reloadData];
    
    NSLog(@"History refreshed.");
}

- (void)resetTableView {
    [self.historyTitlesArray removeAllObjects];
    [self.historyURLArray removeAllObjects];
    [self.historyTableView reloadData];
}

- (id)tableView:(NSTableView *)historyTable objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    
    // Sort table items in descending order
    reversedHistoryArray = [[self.historyURLArray reverseObjectEnumerator] allObjects];
    reversedHistoryTitlesArray = [[self.historyTitlesArray reverseObjectEnumerator] allObjects];
    
    historyURL = [reversedHistoryArray objectAtIndex:rowIndex];
    return [reversedHistoryTitlesArray objectAtIndex:rowIndex];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.historyTitlesArray.count;
}

@end
