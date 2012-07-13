//
//  HotKeys.h
//  HotKeys
//
//  Created by Ankur Kothari on 21/03/08.
//  Copyright 2008 Ankur Kothari. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSMutableArray *h;

@interface hKC : NSTextField {
	@public;
	unsigned int M;
	unsigned short K;
}
@end

@interface tbv : NSTableView <NSTableViewDataSource,NSTableViewDelegate,NSApplicationDelegate> {
	IBOutlet NSTextField *eT, *eC, *eD, *fst;
	IBOutlet hKC *eH;        // HotKey field
	IBOutlet NSMenuItem *ss; // start / stop agent
	IBOutlet NSPanel *fp;    // find panel
	NSString *l, *find;      // path to .hotkeys; find string
	BOOL asc, X;             // sort order; is agent running
}	
- (void)r; // reload data, sorting and maintaining selection

- (BOOL)r4:(NSString *)p; // read from file

- (IBAction)i:(id)n;  // import
- (IBAction)x:(id)n;  // export
- (IBAction)a:(id)n;  // add
- (IBAction)e:(id)s;  // edit
- (void)_e:(NSDictionary *)d :(int)row;

- (IBAction)p:(id)n;  // prune

- (IBAction)rv:(id)n; // revert to saved
- (IBAction)sv:(id)n; // save
- (IBAction)t:(id)n;  // agent stop or start

- (void)s; // run HotKeys agent

- (IBAction)c:(id)s; // save / cancel edit sheet
@end

/*
@interface NSOpenPanel (p)
-(id)_navView;
-(void)setShowsHiddenFiles:(BOOL)s;
@end
*/
