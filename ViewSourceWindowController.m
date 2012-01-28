/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "ViewSourceWindowController.h"

static int coloring = 0;

@implementation ViewSourceWindowController

- (id) initWithWindowNibName: (NSString*) windowNibName {
	
	if(self = [super initWithWindowNibName: windowNibName])
	{
		if (![NSBundle loadNibNamed: windowNibName owner: self])
		{
			NSLog(@"Failed to load nib: %@", windowNibName);
		}
	}
	
	return self;
}

- (void)dealloc {
	[sourceCode release];
	[super dealloc];
}

- (IBAction) showWindow: (id) sender
{
	if(sourceCode && sourceView)
	{
		[sourceView setFont:[NSFont fontWithName:@"Monaco" size:9.0]];
		[sourceView setString:sourceCode];
		[[sourceView textStorage] setDelegate:self];
		
		[status setHidden:NO];
		[status startAnimation:nil];
		
		[ThreadWorker workOn:self
				withSelector:@selector(doColorSyntax) 
				  withObject:nil
			  didEndSelector:@selector(coloringDone:)];
		
		//[self doColorSyntax];
	}
	
	[super showWindow: sender];
}

//	Feel free to change the style of this method as you like, since you made the class
- (IBAction)saveCode:(id)sender {
	NSSavePanel* savePanel = [NSSavePanel savePanel];	
	[savePanel beginSheetForDirectory: nil file: nil modalForWindow: [self window] modalDelegate: self didEndSelector: @selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

//	Feel free to change the style of this method as you like, since you made the class
- (void) savePanelDidEnd: (NSSavePanel*) sheet returnCode: (int) returnCode contextInfo: (void*) contextInfo
{
	if (sheet != nil && returnCode == NSOKButton)
	{
		NSString* filePath = [sheet filename];
		
		if (filePath != nil)
		{
			[sourceCode writeToFile: filePath atomically:YES];
		}
	}
}

- (IBAction)refreshTheSourceCode:(id)sender {
	//
}

- (void)setSourceCode:(NSString *)aStr { 
	[sourceCode release];
	[aStr retain];
	sourceCode = aStr;
	
	if(sourceCode && sourceView)
	{
		[sourceView setString:sourceCode];
	}
}

- (NSString *)sourceCode {
	return sourceCode;
}

- (void)doColorSyntax {
	if (coloring == 0) {
		coloring = 1;
	} else {
		return;
	}
	
	NSDictionary *defaultColorAtts  = [NSDictionary dictionaryWithObject:[NSColor blueColor] forKey:@"color"];
    NSDictionary *commentColorAtts  = [NSDictionary dictionaryWithObject:[NSColor grayColor] forKey:@"color"];
    NSDictionary *codeColorAtts     = [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:@"color"];
    
    NSString *source = [sourceView string];
    NSScanner *scanner = [NSScanner scannerWithString: source];
   
	NSRange range = NSMakeRange(0, [source length]);
		
    [[sourceView textStorage] removeAttribute:NSForegroundColorAttributeName range:range];
    
    int ixLeft, ixRight;
    NSDictionary *attsToUse;
    NSString *tagType;
    NSString *tagTypeLong;
	
    while (![scanner isAtEnd])
    {
        // Find next < character
        [scanner scanUpToString: @"<" intoString: nil];
        ixLeft = [scanner scanLocation];
		ixRight = [scanner scanLocation];
        
        if ((ixLeft+3) <= [source length]) {
            tagTypeLong = [source substringWithRange:NSMakeRange(ixLeft, 3)];
            tagType = [source substringWithRange:NSMakeRange(ixLeft, 2)];
        } else {
            tagTypeLong = @"";
            tagType = @"";
        }
        
        if ([tagTypeLong isEqualToString: @"<!-"]) {
            attsToUse = commentColorAtts;
            
            if (![scanner scanUpToString: @"->" intoString: nil])
                break;
            
            ixRight = [scanner scanLocation] + 2;
        } else if ([tagType isEqualToString: @"<%"]) {
            attsToUse = codeColorAtts;
            
            if (![scanner scanUpToString: @"%>" intoString: nil])
                break;
            
            ixRight = [scanner scanLocation] + 2;
        } else if ([tagType isEqualToString: @"<?"]) {
            attsToUse = codeColorAtts;
            
            if (![scanner scanUpToString: @"?>" intoString: nil])
                break;
            
            ixRight = [scanner scanLocation] + 2;
        } else {
            attsToUse = defaultColorAtts;
            
            if (![scanner scanUpToString: @">" intoString: nil]) {
                break;
			}
            
            ixRight = [scanner scanLocation] + 1;
        }
        
        if (ixRight > [source length])
            ixRight --;
        
        // Set the color style for everything between the found < and > characters (and the < and > characters themselves)
        //[[sourceView layoutManager] addTemporaryAttributes: attsToUse forCharacterRange: NSMakeRange(ixLeft, ixRight - ixLeft) ];
		[[sourceView textStorage] addAttribute:NSForegroundColorAttributeName value:[attsToUse objectForKey:@"color"] range:NSMakeRange(ixLeft, ixRight - ixLeft)];
    }
}

- (void)textStorageDidProcessEditing:(NSNotification *)notification {
	if (coloring == 0) {
		[status setHidden:NO];
		[ThreadWorker workOn:self
				withSelector:@selector(doColorSyntax) 
				  withObject:nil
			  didEndSelector:@selector(coloringDone:)];
	}
}

- (void)setTitle:(NSString *)title {
	[[sourceView window] setTitle:title];
}

- (void)coloringDone:(ThreadWorker *)tw {
	coloring = 0;
	
	[status setHidden:YES];
}

@end
