//
//  SPKHistoryTable.h
//  Spark
//
//  Copyright (c) 2014-2017 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import <Cocoa/Cocoa.h>

@interface SPKHistoryTable : NSObject <NSTableViewDataSource>

@property (assign, nonatomic) IBOutlet NSTableView *historyTableView;
@property (nonatomic) NSMutableArray *historyTitlesArray;
@property (nonatomic) NSMutableArray *historyURLArray;

- (IBAction)refreshHistoryBtnClicked:(id)sender;

- (void)refreshHistoryContent;
- (void)resetTableView;

@end
