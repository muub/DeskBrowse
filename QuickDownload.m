/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "QuickDownload.h"


@implementation QuickDownload

- (void)awakeFromNib {
	[progressIndicator setMinValue:0];
    [progressIndicator setMaxValue:1.0];
	[self setFilename:@""];
}

- (void)setDownloading:(BOOL)downloading
{
    if (isDownloading != downloading) {
        isDownloading = downloading;
        if (isDownloading) {
            [progressIndicator setIndeterminate:YES];
            [progressIndicator startAnimation:self];
            [downloadCancelButton setKeyEquivalent:@"."];
            [downloadCancelButton setKeyEquivalentModifierMask:NSCommandKeyMask];
            [downloadCancelButton setTitle:@"Cancel"];
            [self setFilename:@""];
        } else {
            [progressIndicator setIndeterminate:NO];
            [progressIndicator setDoubleValue:0];
            [downloadCancelButton setKeyEquivalent:@"\r"];
            [downloadCancelButton setKeyEquivalentModifierMask:0];
            [downloadCancelButton setTitle:@"Download"];
            [download release];
            download = nil;
            receivedContentLength = 0;
        }
    }
}

- (void)setFilename:(NSString *)aString {
	[_filename release];
	_filename = [aString retain];
}

- (NSString *)filename {
	return _filename;
}

- (void)cancel
{
    [download cancel];
    [self setDownloading:NO];
}

- (void)open
{    
    if ([openButton state] == NSOnState) {
        [[NSWorkspace sharedWorkspace] openFile:[self filename]];
    }
}

- (IBAction)downloadOrCancel:(id)sender
{
    if (isDownloading) {
        [self cancel];
    } else {
        NSURL *URL = [URLFormatter formatAndReturnURLWithString: [URLField stringValue]];
        if (URL) {
            download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
        }
        if (!download) {
			NSAlert *unsp = [NSAlert alertWithMessageText:@"Invalid or unsupported URL"
											defaultButton:@"OK"
										  alternateButton:nil
											  otherButton:nil
								informativeTextWithFormat:@"The entered URL is either invalid or unsupported."];
			[unsp runModal];
			[URLField selectText:self];
        }
    }
}

#pragma mark NSURLDownloadDelegate methods

- (void)downloadDidBegin:(NSURLDownload *)download
{
    [self setDownloading:YES];
}

- (NSWindow *)downloadWindowForAuthenticationSheet:(WebDownload *)download
{
    //return [self window];
}

- (void)download:(NSURLDownload *)theDownload didReceiveResponse:(NSURLResponse *)response
{
    expectedContentLength = [response expectedContentLength];
	
    if (expectedContentLength > 0) {
        [progressIndicator setIndeterminate:NO];
        [progressIndicator setDoubleValue:0];
    }
}

- (void)download:(NSURLDownload *)theDownload decideDestinationWithSuggestedFilename:(NSString *)filename
{
    if ([[directoryMatrix selectedCell] tag] == 0) {
        NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop"] stringByAppendingPathComponent:filename];
        [download setDestination:path allowOverwrite:NO];
    } else {
        NSSavePanel *sp = [NSSavePanel savePanel];
		int returnCode = [sp runModalForDirectory:NSHomeDirectory() file:filename];
		if (returnCode == NSOKButton) {
			[download setDestination:[sp filename] allowOverwrite:YES];
		} else {
			[self cancel];
		}
    }
}

- (void)download:(NSURLDownload *)theDownload didReceiveDataOfLength:(unsigned)length
{
    if (expectedContentLength > 0) {
        receivedContentLength += length;
        [progressIndicator setDoubleValue:(double)receivedContentLength / (double)expectedContentLength];
    }
}

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType;
{
    return ([decodeButton state] == NSOnState);
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
    [self setFilename:path];
}

- (void)downloadDidFinish:(NSURLDownload *)theDownload
{
    [self setDownloading:NO];
    [self open];
}

- (void)download:(NSURLDownload *)theDownload didFailWithError:(NSError *)error
{
    [self setDownloading:NO];
	
    NSString *errorDescription = [error localizedDescription];
    if (!errorDescription) {
        errorDescription = @"An error occured during download.";
    }
    
	NSAlert *failed = [NSAlert alertWithMessageText:@"Download Failed"
									  defaultButton:@"OK"
									alternateButton:nil
										otherButton:nil
						  informativeTextWithFormat:[errorDescription capitalizedString]];
	[failed runModal];
	[URLField selectText:self];
}

@end
