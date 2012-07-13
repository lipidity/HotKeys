//
//  HotKeys.m
//  HotKeys
//
//  Created by Ankur Kothari on 21/03/08.
//  Copyright 2008 Ankur Kothari. All rights reserved.
//

#import "tbv.h"
#import "Functions.h"
#import <unistd.h>
#import <fcntl.h>

// add help menu; should open html file (which I need to write)
// save btn should be disabled if no changes made

static BOOL needToStart = NO;

BOOL g(void);
BOOL w2(NSString *p);

@implementation tbv

#pragma mark IO

- (void)awakeFromNib {
	[self setDataSource:self];
	[self setDelegate:self];

	[NSApp setDelegate:self];

	NSWindow *win = [self window];
	[win center];
	[fp center];
	
	l = [[NSUserDefaults standardUserDefaults] stringForKey:@"HotKeysFile"];
	[self setAutosaveName:@"t"];
	[self setAutosaveTableColumns:YES];

	asc = YES;
	h = [[NSMutableArray alloc] init];
	[self rv:nil];
	
	[win setRepresentedFilename:l];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tsk:) name:NSTaskDidTerminateNotification object:nil];

	if(g()) {
		[self s];
	} else {
		[self t:nil];
		needToStart = YES;
	}

//	if(![self highlightedTableColumn]) // autosave highlighted column?
	[self tableView:self didClickTableColumn:[self tableColumnWithIdentifier:@"cat"]];

	[self setTarget:self];
	[self setDoubleAction:@selector(e:)];
}

- (BOOL)r4:(NSString *)p {
	// save selection
	unsigned b4 = [h count];
	NSEnumerator *e = [[h objectsAtIndexes:[self selectedRowIndexes]] objectEnumerator];

	[h removeAllObjects];

	int r; FILE *f;
	const char *q = [p fileSystemRepresentation];

	if((r = open(q, O_CREAT, S_IRUSR | S_IWUSR)) <= 0 || (f = fopen(q, "r")) == NULL) {
		NSRunAlertPanel([NSString stringWithFormat:@"The document \"%@\" could not be %@ed. Y%@.", p, access(q, F_OK)?@"creat":@"open", @"ou do not have appropriate access privileges"], @"To view or change access privileges, select the file in the Finder and choose File > Get Info.", @"Quit", nil, nil);
		[NSApp terminate:nil];
	} else {
		close(r);
	}

	int c = 0, i = 0;
	char d[1025], j = 0;
	NSMutableString *s = [[NSMutableString alloc] initWithCapacity:256];

	flockfile(f);
	while((c = getc_unlocked(f)) != EOF) {
		if(c == cMini && !(i && d[i-1] == '\\')) {
			i = d[i] = 0;
			switch(j++) {
				case 0:
					if(strlen(d) != 1 || [s length]) { // this will get most non-hotkeys files
alert:					fclose(f);
						if([h count])
							[h removeAllObjects];
						[self reloadData];
						NSRunAlertPanel([NSString stringWithFormat:@"The file \"%@\" could not be imported.", [p lastPathComponent]], @"", @"OK", nil, nil);
						[s release];
						return NO;
					} else {
						[h addObject:[NSMutableDictionary dictionaryWithCapacity:7]];
						[[h lastObject] setObject:[NSNumber numberWithBool:(d[0] & 0x1)] forKey:@"ebl"];
					}
					break;
				case 1: {
					NSString *tmp = [[NSString alloc] initWithUTF8String:d];
					[s appendString:tmp];
					[tmp release];
					[[h lastObject] setObject:unesc(s) forKey:@"ttl"];
				}
					break;
				case 2: {
					NSString *tmp = [[NSString alloc] initWithUTF8String:d];
					[s appendString:tmp];
					[tmp release];
					[[h lastObject] setObject:unesc(s) forKey:@"cat"];
				}
					break;
				case 3: {
					NSString *tmp = [[NSString alloc] initWithUTF8String:d];
					[s appendString:tmp];
					[tmp release];
					[[h lastObject] setObject:unesc(s) forKey:@"cmd"];
				}
					break;
				case 4: {
					NSMutableDictionary *t = [h lastObject];
					unsigned int a = (unsigned int) strtoul(d, NULL, 10);
//					while((c = getc_unlocked(f)) != EOF && (c != cMain || (!i || d[i-1] == '\\')))
					while(((c = getc_unlocked(f)) != EOF) && (c != cMain)) // should be numbers only
						if(i < 1024) d[i++] = c; else goto alert;
					j = i = d[i] = 0;
					if(a) {
						unsigned short b = (unsigned short) strtoul(d, NULL, 10);
						[t setObject:[NSNumber numberWithUnsignedInt:a] forKey:@"mod"];
						[t setObject:[NSNumber numberWithUnsignedShort:b] forKey:@"kcd"];
						[t setObject:s4km(a, b)?:@"" forKey:@"hky"];
					} else
						[t setObject:@"" forKey:@"hky"];
				} break;
				default: goto alert;
			}
		} else if(i < 1023) {
			d[i++] = c;
		} else {
			d[i++] = c;
			i = d[i] = 0;
			NSString *tmp = [[NSString alloc] initWithUTF8String:d];
			[s appendString:tmp];
			[tmp release];
		}
	}
	funlockfile(f);
	fclose(f);
	[s release];

	if(![h count] && b4 && ![p isEqualToString:l]) {
		[self reloadData];
		NSRunAlertPanel([NSString stringWithFormat:@"The file \"%@\" did not contain any HotKeys.", [p lastPathComponent]], @"", @"OK", nil, nil, p);
		return NO;
	}

	// restore selection
	NSDictionary *k; unsigned int u;
	NSMutableIndexSet *t = [[NSMutableIndexSet alloc] init];
	while((k = [e nextObject]))
		if((u = [h indexOfObject:k]) != NSNotFound)
			[t addIndex:u];
	[self selectRowIndexes:t byExtendingSelection:NO];
	[t release];
	return YES;
}

#pragma mark Data handling

- (IBAction)rv:(id)n { // revert to saved
	if([self r4:l])
		[[self window] setDocumentEdited:NO];
	[self r];
}

- (IBAction)i:(id)n { // import
	NSOpenPanel *s = [[NSOpenPanel alloc] init];
	[s beginSheetForDirectory:nil file:nil types:nil modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(o:::) contextInfo:nil];
}

- (void)o:(NSOpenPanel *)s :(int)r :(void *)c { // import cb
	if(r == NSOKButton)
		[self application:nil openFile:[s filename]];
	[s release];
}

- (BOOL)application:(NSApplication *)p openFile:(NSString *)f { // importer
	NSArray *a = [h copy];
	BOOL r;

	if((r = [self r4:f]))
		[[self window] setDocumentEdited:YES];
/*	else
		[h removeAllObjects]; */ // h is empty when -r4: returns NO

	[h addObjectsFromArray:a];
	[a release];

	[self r];

	return r;
}

- (IBAction)x:(id)n { // export
	NSSavePanel *s = [[NSSavePanel alloc] init];
	[s beginSheetForDirectory:nil file:@"Untitled.hotkeys" modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(p:::) contextInfo:nil];
}

- (void)p:(NSSavePanel *)s :(int)r :(void *)c { // export cb
	if(r == NSOKButton)
		w2([s filename]);
	[s release];
}

- (IBAction)a:(id)n { // add
	[self _e:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"ebl", @"", @"ttl", @"", @"cat", @"", @"cmd", @"", @"hky", nil] :-1];
}

- (void)delete:(id)n { // delete
	NSIndexSet *s = [self selectedRowIndexes];
	[self deselectAll:nil];
	[h removeObjectsAtIndexes:s];
	[self reloadData];
	[[self window] setDocumentEdited:YES];
}

- (IBAction)e:(id)u { // edit
	int r;
	if((r = [self clickedRow]) >= 0 || ((!u || [u tag] == 12) && (r = [self selectedRow]) >= 0))
		[self _e:[h objectAtIndex:r] :r];
}

- (void)_e:(NSDictionary *)d :(int)row {
	[eT setStringValue:[d objectForKey:@"ttl"]];
	[eC setStringValue:[d objectForKey:@"cat"]];
	[eD setStringValue:[d objectForKey:@"cmd"]];
	[eH setStringValue:[d objectForKey:@"hky"]];
	eH->M = [[d objectForKey:@"mod"] unsignedIntValue];
	eH->K = [[d objectForKey:@"kcd"] unsignedShortValue];
	NSWindow *w = [eT window];
	[w makeFirstResponder:eT];
	[NSApp beginSheet:w modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(c:::) contextInfo:[[NSNumber alloc] initWithInt:row]];
}

- (IBAction)c:(id)s { // save / cancel editing sheet
	[NSApp endSheet:[eT window] returnCode:[s tag]];
}

- (void)c:(NSWindow *)w :(int)rV :(void *)c { // edit cb
	[w close];
	if(rV) {
		NSDictionary *d = [[NSDictionary alloc] initWithObjectsAndKeys:[eT stringValue], @"ttl", [eC stringValue], @"cat", [eD stringValue], @"cmd", [eH stringValue], @"hky", [NSNumber numberWithUnsignedInt:eH->M], @"mod", [NSNumber numberWithUnsignedShort:eH->K], @"kcd", nil];
		int r = [(NSNumber *)c intValue];
		[(NSNumber *)c release];
		if (r < 0) {
			NSMutableDictionary *new = [d mutableCopy];
			[new setObject:[NSNumber numberWithBool:YES] forKey:@"ebl"];
			[h addObject:new];
			[self noteNumberOfRowsChanged];
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:([h count] - 1u)] byExtendingSelection:NO];
		} else {
			NSMutableDictionary *orig = [h objectAtIndex:r];
			[orig setValuesForKeysWithDictionary:d];
		}
		[d release];
		[[self window] setDocumentEdited:YES];
		[self r];
	}
}

- (IBAction)p:(id)n { // prune
	NSEnumerator *e = [[h objectsAtIndexes:[self selectedRowIndexes]] objectEnumerator];
	unsigned c = [h count];
	NSSet *s = [NSSet setWithArray:h];
	[h removeAllObjects];
	[h addObjectsFromArray:[s allObjects]];
	[self reloadData];
	if(c != [h count])
		[[self window] setDocumentEdited:YES];
	NSDictionary *k; NSMutableIndexSet *t = [[NSMutableIndexSet alloc] init];
	while((k = [e nextObject]))
		[t addIndex:[h indexOfObject:k]];
	[self selectRowIndexes:t byExtendingSelection:NO];
	[t release];
	[self scrollRowToVisible:[self selectedRow]];	
}

- (IBAction)sv:(id)n { // save
	if(w2(l))
		[[self window] setDocumentEdited:NO];
	if(X || needToStart) {
		if(g())
			[self s];
		else {
			if(X)
				needToStart = YES;
			[self t:nil];
		}
	}
}

#pragma mark Agent

- (IBAction)t:(id)u { // start / stop
	if(X || !u) {
		ProcessSerialNumber p = {0, kNoProcess};
		while(procNotFound != GetNextProcess(&p)) {
			CFStringRef n = NULL;
			CopyProcessName(&p, &n);
			if([@"HotKeysAgent" isEqualToString:(NSString *)n]) {
				pid_t i;
				GetProcessPID(&p, &i);
				kill(i, SIGKILL);
				CFRelease(n);
				break;
			}
			CFRelease(n);
		}
		X = NO; [[self window] setTitle:@"HotKeys (stopped)"];
		[ss setTitle:@"Start"];
	} else {
		if([[self window] isDocumentEdited])
			NSBeginAlertSheet(@"Do you want to save the changes you made to your hotkeys?", @"Save", @"Don't save", @"Cancel", [self window], self, @selector(sh:::), NULL, nil, @"Changes you have made will not become active until you save."); // todo: need better msg
		else
			[self s];
	}
}

- (void)sh:(NSWindow *)s :(int)r :(void *)c { // "starting, save?" cb
	if(r == NSAlertDefaultReturn)
		[self sv:nil];
	if(r >= 0)
		[self s];
}

- (void)s {
	NSString *path = [[NSBundle mainBundle] pathForResource:@"HotKeysAgent" ofType:nil];
	[self t:nil];
	if(path) {
		[NSTask launchedTaskWithLaunchPath:path arguments:[NSArray arrayWithObject:l]];
		[[self window] setTitle:@"HotKeys"];
		[ss setTitle:@"Stop"];
		X = YES;
		needToStart = NO;
	}  // else Agent is missing. todo: Show error msg?
}

- (void)tsk:(NSNotification *)notif {
	int e = [[notif object] terminationStatus];
    if((e & 0xF0) && (e = e & ~0xF0) < 3) {
		NSString *err[3] = {
			[@"y" stringByAppendingString:@"ou do not have appropriate access privileges"],
			@"the HotKeys file could not be parsed",
			@"there are no enabled HotKeys"};
		NSString *msg[3] = {
			@"To view or change access privileges, select the file in the Finder and choose File > Get Info.",
			@"",
			@""};
		int r = NSRunCriticalAlertPanel([NSString stringWithFormat:@"Your HotKeys failed to start because %@.", err[e]], msg[e], e?@"Save and Restart":@"", e?@"Stop":@"", @""); // todo: better msgs and btns
		if(e && r == NSAlertDefaultReturn)
			[self sv:nil];
		else
			[self t:nil];
	} else if(e != 9) {
		X = NO; [[self window] setTitle:@"HotKeys (stopped)"];
		[ss setTitle:@"Start"];
	}
}

#pragma mark Cocoa stuff

- (BOOL)validateMenuItem:(NSMenuItem *)i {
	switch([i tag]) {
		case 12: return ([self numberOfSelectedRows] == 1) && ![[self window] attachedSheet];
		case 13: return [[self window] isDocumentEdited];
		case 14: return (X || g());
		case 15: return ![[self window] attachedSheet];
		default: return YES;
	}
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if([[self window] isDocumentEdited]) {
		NSBeginAlertSheet(@"Do you want to save the changes you made to your hotkeys?", @"Save", @"Don't Save", @"Cancel", [self window], self, @selector(q:::), NULL, nil, @"Your changes will be lost if you don't save them.");
		return NSTerminateLater;
	} else return NSTerminateNow;
}

- (void)q:(NSWindow *)w :(int)r :(void *)c {
	if(r == NSAlertDefaultReturn)
		[self sv:nil];
	[NSApp replyToApplicationShouldTerminate:(r >= 0)];
}

- (BOOL)windowShouldClose:(id)sender { [NSApp terminate:nil]; return NO; }

- (void)performFindPanelAction:(id)u {
	BOOL next = YES;
	switch([u tag]) {
		case NSFindPanelActionSetFindString:
			find = [u stringValue];
			break;
		case NSFindPanelActionPrevious:
			next = NO; // no break;
		case NSFindPanelActionNext: {
			if(![find length]) goto show;
			NSArray *a = [h filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"ttl contains[cd] %@ OR cat contains[cd] %@ OR cmd contains[cd] %@", find, find, find]];
			if([a count]) {
				NSEnumerator *e = next?[a objectEnumerator]:[a reverseObjectEnumerator]; id z;
				int i, idx = [self selectedRow];
				if(idx < 0) idx = 0;
				while((z = [e nextObject])) {
					i = [h indexOfObject:z];
					if((next && i > idx) || (!next && i < idx)) { // todo: optimize
						[fst setStringValue:@""];
						[self selectRowIndexes:[NSIndexSet indexSetWithIndex:i] byExtendingSelection:NO];
						return [self scrollRowToVisible:i];
					}
				}
			}
			[fst setStringValue:@"Not found"];
			NSBeep();
			break;
		}
		case NSFindPanelActionShowFindPanel:
show:		[fp makeKeyAndOrderFront:nil];
			[[[fp contentView] viewWithTag:NSFindPanelActionSetFindString] selectText:nil];
//			break;
			// todo: other find stuff?
	}
}

- (void)centerSelectionInVisibleArea:(id)s {
	[self scrollRowToVisible:[self selectedRow]];
}

- (void)r { // reload
	NSEnumerator *e = [[h objectsAtIndexes:[self selectedRowIndexes]] objectEnumerator];
	int focused = [self selectedRow];
	NSDictionary *fc = nil;
	if (focused > 0)
		fc = [h	objectAtIndex:focused];
	[h sortUsingDescriptors:[self sortDescriptors]];
	NSDictionary *k; NSMutableIndexSet *t = [[NSMutableIndexSet alloc] init];
	while((k = [e nextObject]))
		[t addIndex:[h indexOfObject:k]];
	[self reloadData];
	[self selectRowIndexes:t byExtendingSelection:NO];
	if (fc)
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:[h indexOfObject:fc]] byExtendingSelection:YES];
	[t release];
	[self scrollRowToVisible:[self selectedRow]];
}

- (int)numberOfRowsInTableView:(NSTableView *)t { return [h count]; }

- (id)tableView:(NSTableView *)t objectValueForTableColumn:(NSTableColumn *)c row:(int)r {
	NSString *i = [c identifier]; id obj = [[h objectAtIndex:r] objectForKey:i]; unsigned int idx;
	return (!([i isEqualToString:@"ebl"] || [i isEqualToString:@"hky"]) && ((idx = [obj rangeOfString:@"\n"].location) != NSNotFound)) ? [[obj substringToIndex:idx] stringByAppendingString:@"..."] : obj;
}
- (void)tableView:(NSTableView *)t setObjectValue:(id)b forTableColumn:(NSTableColumn *)c row:(int)r {
	// only for 'ebl'; others with -e: sheet
	[[h objectAtIndex:r] setObject:b forKey:[c identifier]];
	[[self window] setDocumentEdited:YES];
	[self r];
}

- (void)tableView:(NSTableView *)t didClickTableColumn:(NSTableColumn *)c {
	NSString *i = [c identifier];
	if([i isEqualToString:@"hky"]) return;
	NSTableColumn *o = [t highlightedTableColumn];
	asc = (o == c) ? !asc : YES;
    [t setIndicatorImage:nil inTableColumn:o];
    [t setHighlightedTableColumn:c];
    [t setIndicatorImage:[NSImage imageNamed:(asc)? @"NSAscendingSortIndicator" : @"NSDescendingSortIndicator"] inTableColumn:c];
	NSSortDescriptor *s = ([i isEqualToString:@"ebl"]) ? [[NSSortDescriptor alloc] initWithKey:@"ebl" ascending:asc] : [[NSSortDescriptor alloc] initWithKey:i ascending:asc selector:@selector(caseInsensitiveCompare:)];
	[self setSortDescriptors:[NSArray arrayWithObject:s]];
	[s release];
	[self r];
}

- (void)dealloc {
	[h release];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:nil];
	[super dealloc];
}

@end

BOOL w2(NSString *p) {
	const char *q = [p fileSystemRepresentation];
	FILE *f;
	if((f = fopen(q, "w")) == NULL) {
		NSRunAlertPanel([NSString stringWithFormat:@"The document \"%@\" could not be %@ed. Y%@.", [p lastPathComponent], @"sav", @"ou do not have appropriate access privileges"], @"To view or change access privileges, select the file in the Finder and choose File > Get Info.", nil, nil, nil); // perhaps better diagnostic?
		return NO;
	}
	NSEnumerator *e = [h objectEnumerator]; NSDictionary *d;
	while((d = [e nextObject]))
		fprintf(f, "%d,%s,%s,%s,%u,%hu\n", ([[d objectForKey:@"ebl"] boolValue]), esc([d objectForKey:@"ttl"]), esc([d objectForKey:@"cat"]), esc([d objectForKey:@"cmd"]), [[d objectForKey:@"mod"] unsignedIntValue], [[d objectForKey:@"kcd"] unsignedShortValue]);
	fclose(f);
	return YES;
}

BOOL g() { // have active hotkeys
	unsigned i = 0; NSDictionary *d;
	while(i < [h count]) {
		d = [h objectAtIndex:i++];
		if([[d objectForKey:@"ebl"] boolValue] && [[d objectForKey:@"mod"] unsignedIntValue])
			return YES;
	}
	return NO;
}
