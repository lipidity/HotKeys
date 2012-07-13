#import "Functions.h"
#import <Carbon/Carbon.h>

const char *esc(NSString *o) {
	NSMutableString *s = [[o mutableCopy] autorelease]; NSRange r = NSMakeRange(0, [s length]);
	if([s replaceOccurrencesOfString:sMini withString:rMini options:NSLiteralSearch range:r])
		r.length = [s length];
	[s replaceOccurrencesOfString:sMain withString:rMain options:NSLiteralSearch range:r];
	return [s UTF8String];
}
NSString *unesc(NSMutableString *s) {
	NSRange r = NSMakeRange(0, [s length]);
	if([s replaceOccurrencesOfString:rMini withString:sMini options:NSLiteralSearch range:r])
		r.length = [s length];
	[s replaceOccurrencesOfString:rMain withString:sMain options:NSLiteralSearch range:r];
	NSString *t = [s copy];
	[s setString:@""];
	return [t autorelease];
}
