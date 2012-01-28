#import "SystemProfiler.h"


@implementation SystemProfiler

+ (NSString *)serialNumber {
	NSString *result = @"";
	mach_port_t masterPort;
	kern_return_t kr = noErr;
	io_registry_entry_t entry;
	CFDataRef propData;
	CFTypeRef prop;
	CFTypeID propID;
	UInt8 *data;
	unsigned int i, bufSize;
	char *s, *t;
	char firstPart[64], secondPart[64];
	
	kr = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (kr == noErr) {
		entry = IORegistryGetRootEntry(masterPort);
		if (entry != MACH_PORT_NULL) {
			prop = IORegistryEntrySearchCFProperty(entry, kIODeviceTreePlane, CFSTR("serial-number"), NULL, kIORegistryIterateRecursively);
			propID = CFGetTypeID(prop);
			if (propID == CFDataGetTypeID()) {
				propData = (CFDataRef)prop;
				bufSize = CFDataGetLength(propData);
				if (bufSize > 0) {
					data = (UInt8 *)CFDataGetBytePtr(propData);
					if (data) {
						i = 0;
						s = data;
						t = firstPart;
						while (i < bufSize) {
							i++;
							if (*s != '\0') {
								*t++ = *s++;
							} else {
								break;
							}
						}
						*t = '\0';
						
						while ((i < bufSize) && (*s == '\0')) {
							i++;
							s++;
						}
						
						t = secondPart;
						while (i < bufSize) {
							i++;
							if (*s != '\0') {
								*t++ = *s++;
							} else {
								break;
							}
						}
						*t = '\0';
						result = [NSString stringWithFormat:@"%s%s", secondPart, firstPart];
					}
				}
			}
		}
		mach_port_deallocate(mach_task_self(), masterPort);
	}
	return(result);
}

@end
