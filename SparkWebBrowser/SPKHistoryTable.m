//
//  SPKHistoryTable.m
//  Spark
//
//  Created by Jonathan Wukitsch on 3/24/17.
//  Copyright © 2017 Insleep. All rights reserved.
//

#import "SPKHistoryTable.h"
#import "SPKHistoryHandler.h"

@interface SPKHistoryTable ()

@property (nonatomic) NSMutableArray *historyURLArray;

@end

@implementation SPKHistoryTable

- (id)init {
    if(self = [super init]) {
        
        //SPKHistoryHandler *historyHandler = [[SPKHistoryHandler alloc] init];
        self.historyURLArray = [NSMutableArray array];
        [self.historyURLArray addObject:@"test"];
    }
    
    return self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 5;
}

- (id)tableView:(NSTableView *)historyTable objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    //SPKHistoryHandler *historyHandler = [[SPKHistoryHandler alloc] init];
    NSObject *obj = self.historyURLArray[row];
    NSString *identifier = tableColumn.identifier;
    return [obj valueForKey:identifier];
}

- (void)add {
    //SPKHistoryHandler *historyHandler = [[SPKHistoryHandler alloc] init];
    //self.historyURLArray = [historyHandler getHistoryItems];
    //[self.historyURLArray addObject:@"test"];
    //[self.historyTable reloadData];
}

@end
