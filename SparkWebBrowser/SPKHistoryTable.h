//
//  SPKHistoryTable.h
//  Spark
//
//  Created by Jonathan Wukitsch on 3/24/17.
//  Copyright © 2017 Insleep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SPKHistoryTable : NSObject <NSTableViewDataSource>

@property (assign, nonatomic) IBOutlet NSTableView *historyTable;

@end
