#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <string.h>
#include <unistd.h>

enum {
	NSAlphaShiftKeyMask = 	1 << 16,
	NSShiftKeyMask = 		1 << 17,
	NSControlKeyMask = 		1 << 18,
	NSAlternateKeyMask = 	1 << 19,
	NSCommandKeyMask = 		1 << 20,
};

OSStatus h(EventHandlerCallRef n, EventRef e, void *a) {
	EventHotKeyID i;
	GetEventParameter(e, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(i), NULL, &i);
	system([[(NSMutableArray *)a objectAtIndex:(i.id)] fileSystemRepresentation]);
	return noErr;
}

/* return values
1: bad usage
0xF0: could not read from hotkeys-file
0xF1: bad argument in hotkeys file (ie. too long / short)
0xF2: no enabled hotkeys
*/

//	[NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDown handler:((void)^(NSEvent *e){})];

int main (int argc, const char *argv[]) {

	// allow only one HotKeysAgent at a time
	size_t l = 0;
	struct kinfo_proc *r;
	const int name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
	// `(sizeof(name) / sizeof(*name)) - 1` hard-coded as `3`
	if ( !sysctl((int *)name, 3, NULL, &l, NULL, 0) && (r = malloc(l)) != NULL ) {
		if ( sysctl((int *)name, 3, r, &l, NULL, 0) && r ) {
			free(r);
		} else {
			struct kinfo_proc *k = r;
			size_t c = l / sizeof(struct kinfo_proc);
			while(c--) {
				if( &(k->kp_proc) ) {
					if( (k->kp_proc.p_pid != getpid()) && (strncmp(k->kp_proc.p_comm, "HotKeysAgent", 16) == 0) ) {
						kill(k->kp_proc.p_pid, SIGKILL);
						break;
					}
				}
				k++;
			}
			free(r);
		}
	}

	NSMutableArray *a = [[NSMutableArray alloc] init];

	if (argc == 1) {
		fprintf(stderr, "Usage: %s file\n", argv[0]);
		return 1;
	} else {
		NSAutoreleasePool *p = [NSAutoreleasePool new];

		FILE *f;
		if ((f = fopen(argv[1], "r")) == NULL)
			return 0xF0;

		EventHotKeyRef rf; EventHotKeyID g = {0, 0};
		NSMutableString *s = [[NSMutableString alloc] init];

		int c, i = 0; char d[1025], j = 0;

		flockfile(f);
		while ((c = getc_unlocked(f) ) != EOF) { // reading file
			if (c == ',' && !(i && d[i-1] == '\\') ) {
				i = d[i] = 0;
				switch(j++) {
					case 0: // "enabled" section
						if (strlen(d) != 1 || [s length]) // should be just 0 or 1
							return 0xF1;
						else if ((d[0] & 0x1) == 0) {
							while((c = getc_unlocked(f)) != EOF && (c != '\n' || i == '\\'))
								i = c;
							j = i = 0;
						}
							break;
					case 3: { // "command line" section
						NSString *tmp = [[NSString alloc] initWithUTF8String:d];
						[s appendString:tmp];
						[tmp release];
						NSRange rng = NSMakeRange(0, [s length]);
						if ([s replaceOccurrencesOfString:@"\\, " withString:@", " options:NSLiteralSearch range:rng])
							rng.length = [s length];
						[s replaceOccurrencesOfString:@"\\\n" withString:@"\n" options:NSLiteralSearch range:rng];
						[a addObject:[[s copy] autorelease]];
						[s setString:@""];
						break;
					}
					case 4: { // "modifiers" and "keycodes" sections
						unsigned int m = 0, k = (unsigned int) strtoul(d, NULL, 10);
						if (k & NSShiftKeyMask) m |= shiftKey;
						if (k & NSCommandKeyMask) m |= cmdKey;
						if (k & NSControlKeyMask) m |= controlKey;
						if (k & NSAlternateKeyMask) m |= optionKey;
	//						while((c = getc_unlocked(f) ) != EOF && (c != '\n' || (!i || d[i-1] == '\\')))
						while ( ((c = getc_unlocked(f)) != EOF) && (c != '\n') ) // should be numbers only
							if (i < 1024) d[i++] = c; else return 0xF1;
						j = i = d[i] = 0;
						unsigned short b = (unsigned short) strtoul(d, NULL, 10);
						if (m) {
							RegisterEventHotKey(b, m, g, GetApplicationEventTarget(), 0, &rf);
							(g.id) ++;
						} else
							[a removeLastObject];
						break;
					}
						//					default: ;
				}
			} else if (i < 1023) {
				d[i++] = c;
			} else if(j == 2) {
				d[i++] = c;
				i = d[i] = 0;
				NSString *tmp = [[NSString alloc] initWithUTF8String:d];
				[s appendString:tmp];
				[tmp release];
			} else {
				return 0xF1;
			}
		}
		funlockfile(f);
		fclose(f);
		if (![a count])
			return 0xF2;
		[s release];
		[p release];
	}

	EventTypeSpec e = {kEventClassKeyboard, kEventHotKeyPressed};
	InstallApplicationEventHandler(&h, 1, &e, a, NULL);

	RunApplicationEventLoop();
	return 0;
}
