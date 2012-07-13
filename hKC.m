#import <Cocoa/Cocoa.h>
#import "tbv.h"
#import "Functions.h"

@implementation hKC : NSTextField

- (BOOL) textShouldBeginEditing:(NSText *)t {
	NSBeep();
	[self flagsChanged:nil];
	return NO;
}

- (void) flagsChanged:(NSEvent *)e {
	[self setStringValue:[NSPrefPaneUtils stringForModifiers:[e modifierFlags]]];
	int g = _CGSDefaultConnection();
	CGSSetGlobalHotKeyOperatingMode(g, CGSGlobalHotKeyDisable);
	BOOL c = YES;
	do {
		e = [NSApp nextEventMatchingMask:NSFlagsChangedMask|NSKeyDownMask|NSLeftMouseDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:10.0] inMode:NSDefaultRunLoopMode dequeue:YES];
		switch ([e type]) {
			case NSFlagsChanged:
				[self setStringValue:[NSPrefPaneUtils stringForModifiers:[e modifierFlags]]];
				break;
			case NSKeyDown: {
				c = NO;
				unsigned short k = [e keyCode];
				if ([e modifierFlags] & (NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask)) {
					M = [e modifierFlags];
					K = k;
//				} else if(k == 51 || k == 117) { // Delete (<) or Delete (>)
//					M = 0; K = 0;
				} else if (k == 48 || k == 53) { // Esc is 53, Tab is 48
					if ([e modifierFlags] & NSShiftKeyMask) {
					   [[self window] selectKeyViewPrecedingView:self];
						goto fin;
					}
				} else {
					NSBeep();
					c = YES;
				}
				break;
			}
			case NSLeftMouseDown:
				[NSApp postEvent:e atStart:YES]; // fall through
			default:
				c = NO;
		}
	} while (c);
	[[self window] selectKeyViewFollowingView:self];
fin:
	CGSSetGlobalHotKeyOperatingMode(g, CGSGlobalHotKeyEnable);
	NSString *t = M ? s4km(M,K) : @"";
	[self setStringValue:t];
}

@end
