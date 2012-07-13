#import <Cocoa/Cocoa.h>

#define sMini @","
#define rMini @"\\,"
#define sMain @"\n"
#define rMain @"\\\n"
#define cMini ','
#define cMain '\n'

NSString *s4c( const unsigned short k );
const char *esc(NSString *o);
NSString *unesc(NSMutableString *o);

#define s4km(o,k) [NSPrefPaneUtils stringForVirtualKey:(k) modifiers:(o)]

@interface NSPrefPaneUtils : NSObject {}
+ (id)stringForModifiers:(unsigned int)fp8;
+ (id)stringForVirtualKey:(unsigned int)fp8 modifiers:(unsigned int)fp12;
@end

typedef enum {
	CGSGlobalHotKeyEnable = 0,
	CGSGlobalHotKeyDisable = 1,
} CGSGlobalHotKeyOperatingMode;
extern int _CGSDefaultConnection(void);
extern CGError CGSSetGlobalHotKeyOperatingMode(int connection, CGSGlobalHotKeyOperatingMode mode);
