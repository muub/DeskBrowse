/*
*****************************
The DeskBrowse source code is the legal property of its developers, Joel Levin and Ian Elseth
*****************************
*/

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


typedef enum
{
    kDownloadStatusNone = 0,
	kDownloadStatusDownloading,
	kDownloadStatusCancelled,
	kDownloadStatusFinished,
} DownloadStatus;


extern NSString* kNoStatusString;
extern NSString* kCancelledString;
extern NSString* kFinishedString;


@interface DownloadObject : NSObject
{
	WebDownload*	mURLDownload;
	
	NSURL*			mURL;
	NSURLRequest*	mURLRequest;
	NSURLResponse*	mURLResponse;
	NSString*		mFileName;
	NSString*		mDownloadedFilePath;
	NSString*		mDisplayName;
	
	DownloadStatus	mStatus;
	
	float			mBytesLoaded;
	float			mExpectedLength;
}

- (id) initWithURLDownload: (WebDownload*) download;
- (WebDownload*) URLDownload;

- (void) setURLRequest: (NSURLRequest*) request;

- (NSString*) fileName;
- (NSString*) displayName;
- (void) setDisplayName: (NSString*) name;
- (NSString*) downloadedFilePath;
- (void) setDownloadedFilePath: (NSString*) path;
- (NSURL*) URL;
- (void) setURL: (NSURL*) URL;
- (NSString*) fileType;
- (NSImage*) icon;

- (void) setURLResponse: (NSURLResponse*) response;
- (float) bytesLoaded;
- (void) setBytesLoaded: (float) bytes;
- (int) percentComplete;

- (NSString *)stringStatus;
- (void) cancel;
- (DownloadStatus) status;
- (void) setStatus: (DownloadStatus) newStatus;


@end