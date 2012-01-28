/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import "DownloadObject.h"


NSString* kNoStatusString	= @"";
NSString* kCancelledString	= @"Cancelled";
NSString* kFinishedString	= @"Finished";

@implementation DownloadObject

- (id) init
{
	if(self = [super init])
	{
		[self setStatus: kDownloadStatusNone];
	}
	
	return self;
}

- (id) initWithURLDownload: (WebDownload*) download;
{
	if(self = [self init])
	{
		mURLDownload = [download retain];
		
		[self setURLRequest: [download request]];
	}
	
	return self;
}

- (void) dealloc
{
	[mURLRequest			release];
	[mURLDownload			release];
	[mURLResponse			release];
	[mFileName				release];
	[mDownloadedFilePath	release];
	[mDisplayName			release];
	[mURL					release];
	
	[super dealloc];
}

#pragma mark -


// URL download

- (WebDownload*) URLDownload
{
	return mURLDownload;
}


// URL request

- (void) setURLRequest: (NSURLRequest*) request
{
	// URLReques
	
	if(request != mURLRequest)
	{
		[request		retain];
		[mURLRequest	release];
		
		mURLRequest = request;
	}
	
	// URL
	[self setURL: [request URL]];
	
	// File name
	[mFileName release];
	mFileName = [[[[mURL absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding] retain];
	
	// Display name
	[self setDisplayName: [mFileName lastPathComponent]];
}


// URL response

- (void) setURLResponse: (NSURLResponse*) response
{
	if(response != mURLResponse)
	{
		[response		retain];
		[mURLResponse	release];
		
		mURLResponse = response;
	}
}


// URL

- (NSURL*) URL
{
	return mURL;
}

- (void) setURL: (NSURL*) URL
{
	if(URL != mURL)
	{
		[URL	retain];
		[mURL	release];
		
		mURL = URL;
	}
}


// File name

- (NSString *) fileName
{
	return mFileName;
}


// Display name

- (NSString*) displayName
{
	if(mDisplayName != nil)
	{
		return mDisplayName;
	}
	else
	{
		return [self fileName];
	}
}

- (void) setDisplayName: (NSString*) name
{
	if(name != mDisplayName)
	{
		[name			retain];
		[mDisplayName	release];
		
		mDisplayName = name;
	}
}


// Downloaded file path

- (NSString*) downloadedFilePath
{	
	return mDownloadedFilePath;
}

- (void) setDownloadedFilePath: (NSString*) path
{
	if(path != mDownloadedFilePath)
	{
		[path					retain];
		[mDownloadedFilePath	release];
		
		mDownloadedFilePath = path;
	}
}


// File type

- (NSString*) fileType
{
	NSString* fileType;
	
	fileType = [mFileName pathExtension]; 
	
	return fileType;
}


// Icon

- (NSImage*) icon
{
	NSImage*		icon;
	NSWorkspace*	workspace;
	
	workspace	= [NSWorkspace sharedWorkspace];
	icon		= [workspace iconForFileType: [self fileType]];
	
	return icon;
}


// Progress


- (float) bytesLoaded
{
	return mBytesLoaded;
}

- (void) setBytesLoaded: (float) bytes
{
	mBytesLoaded	= bytes;
	mExpectedLength	= [mURLResponse expectedContentLength];
}

- (int) percentComplete
{
	int percentComplete = (mBytesLoaded / (float) mExpectedLength) * 100.0;
	
	if(percentComplete < 0)
	{
		percentComplete = 0;
	}
	else if(percentComplete > 100)
	{
		percentComplete = 100;
	}
	
	return percentComplete;
}


// Status

- (NSString*) stringStatus
{
	NSString*	stringStatus	= nil;
	NSNumber*	fileSize		= nil;
	
	if(mStatus == kDownloadStatusDownloading)
	{
		if (mExpectedLength != NSURLResponseUnknownLength)
		{
			fileSize		= [NSNumber numberWithInt: (mExpectedLength / 1024)]; // kilobytes
			stringStatus	= [NSString stringWithFormat: @"%i%%", [self percentComplete]];
		}
		else
		{
			stringStatus = [NSString stringWithFormat: @"?%"];
		}
	}
	else
	{
		if(mStatus == kDownloadStatusNone)
		{
			stringStatus = kNoStatusString;
		}
		else if(mStatus == kDownloadStatusCancelled)
		{
			stringStatus = kCancelledString;
		}
		else if(mStatus == kDownloadStatusFinished)
		{
			stringStatus = kFinishedString;
		}
	}
	
	return stringStatus;
}

- (void) cancel
{
	[mURLDownload cancel];
	
	[self setStatus: kDownloadStatusCancelled];
}

- (DownloadStatus) status
{
	return mStatus;
}

- (void) setStatus: (DownloadStatus) newStatus
{
	mStatus = newStatus;
}


@end
