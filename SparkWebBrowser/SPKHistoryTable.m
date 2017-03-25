//
//  SPKHistoryTable.m
//  Spark
//
//  Copyright (c) 2014-2017 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "AppDelegate.h"
#import "SPKHistoryTable.h"
#import "SPKHistoryHandler.h"

@interface SPKHistoryTable ()

@property (nonatomic) NSMutableArray *historyTitlesArray;
@property (nonatomic) NSMutableArray *historyURLArray;

@end

@implementation SPKHistoryTable

- (id)init {
    if(self = [super init]) {
        
        SPKHistoryHandler *historyHandler = [[SPKHistoryHandler alloc] init];
        self.historyTitlesArray = [historyHandler getHistoryTitleItems];
        self.historyURLArray = [historyHandler getHistoryItems];
    }
    
    return self;
}

- (IBAction)doubleClickedTableViewCell:(id)sender {
    
    AppDelegate *appDelegate = [[AppDelegate alloc] init];
    
    NSLog(@"DOUBLE CLICKED");
    [[appDelegate.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://tesla.com/"]]]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.historyTitlesArray.count;
}

- (id)tableView:(NSTableView *)historyTable objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex {
    
    return [self.historyTitlesArray objectAtIndex:rowIndex];
}

@end
