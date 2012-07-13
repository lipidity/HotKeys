//
//  main.m
//  HotKeys
//
//  Created by Ankur Kothari on 21/03/08.
//  Copyright Ankur Kothari 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

int main(int argc, char *argv[]) {
{
	NSAutoreleasePool *l = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	[def registerDefaults:[NSDictionary dictionaryWithObject:[[NSBundle mainBundle] pathForResource:@"portable" ofType:@"hotkeys"]?:[@"~/.hotkeys" stringByExpandingTildeInPath] forKey:@"HotKeysFile"]];
	ProcessSerialNumber p;
	if(!GetCurrentProcess(&p)) {
		NSDictionary *d = (NSDictionary*)ProcessInformationCopyDictionary(&p, kProcessDictionaryIncludeAllInformationMask);
		long long t = [[d objectForKey:@"ParentPSN"] longLongValue];
		[d release];
		p.highLongOfPSN = (t >> 32); p.lowLongOfPSN = (t << 32) >> 32;
		d = (NSDictionary*)ProcessInformationCopyDictionary(&p, kProcessDictionaryIncludeAllInformationMask);
		if([[d objectForKey:@"CFBundleIdentifier"] isEqualToString:@"com.apple.loginwindow"]) {
			[NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] pathForResource:@"HotKeysAgent" ofType:nil] arguments:[NSArray arrayWithObject:[[NSUserDefaults standardUserDefaults] stringForKey:@"HotKeysFile"]]];
			return 0;
		}
		[d release];
	}
	[l release];
}
	return NSApplicationMain(argc, (const char **)argv);
}
