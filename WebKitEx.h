#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

// =================================
// Private WebKit Classes/Categories
// =================================

@interface NSURL (WebNSURLExtras)

+ (id)_web_URLWithUserTypedString:(id)fp8;
- (id)_web_userVisibleString;
- (id)_web_hostString;

@end

@interface WebCoreStatistics : NSObject {}

+ (id)statistics;
+ (void)emptyCache;
+ (void)setCacheDisabled:(BOOL)fp8;
+ (int)javaScriptObjectsCount;
+ (int)javaScriptInterpretersCount;
+ (int)javaScriptNoGCAllowedObjectsCount;
+ (int)javaScriptReferencedObjectsCount;
+ (id)javaScriptRootObjectClasses;
+ (void)garbageCollectJavaScriptObjects;
+ (BOOL)shouldPrintExceptions;
+ (void)setShouldPrintExceptions:(BOOL)fp8;

@end

@interface WebKitStatistics : NSObject {}

+ (int)webViewCount;
+ (int)frameCount;
+ (int)dataSourceCount;
+ (int)viewCount;
+ (int)bridgeCount;
+ (int)HTMLRepresentationCount;

@end

@interface WebView (WebPendingPublic)
- (void)setMainFrameURL:(id)fp8;
- (id)mainFrameURL;
- (BOOL)isLoading;
- (id)mainFrameTitle;
- (id)mainFrameIcon;
- (void)setDrawsBackground:(BOOL)fp8;
- (BOOL)drawsBackground;
- (void)toggleSmartInsertDelete:(id)fp8;
- (void)toggleContinuousSpellChecking:(id)fp8;
- (BOOL)isContinuousGrammarCheckingEnabled;
- (void)setContinuousGrammarCheckingEnabled:(BOOL)fp8;
- (void)toggleContinuousGrammarChecking:(id)fp8;
@end

@interface WebView (WebPrivate)
+ (id)_supportedMIMETypes;
+ (id)_supportedFileExtensions;
+ (BOOL)_viewClass:(Class *)fp8 andRepresentationClass:(Class *)fp12 forMIMEType:(id)fp16;
+ (void)_setAlwaysUseATSU:(BOOL)fp8;
+ (BOOL)canShowFile:(id)fp8;
+ (id)suggestedFileExtensionForMIMEType:(id)fp8;
+ (id)_MIMETypeForFile:(id)fp8;
+ (void)_unregisterViewClassAndRepresentationClassForMIMEType:(id)fp8;
+ (void)_registerViewClass:(Class)fp8 representationClass:(Class)fp12 forURLScheme:(id)fp16;
+ (id)_generatedMIMETypeForURLScheme:(id)fp8;
+ (BOOL)_representationExistsForURLScheme:(id)fp8;
+ (BOOL)_canHandleRequest:(id)fp8;
+ (id)_decodeData:(id)fp8;
+ (BOOL)automaticallyNotifiesObserversForKey:(id)fp8;
+ (void)_setShouldUseFontSmoothing:(BOOL)fp8;
+ (BOOL)_shouldUseFontSmoothing;
- (void)_close;
- (id)_createFrameNamed:(id)fp8 inParent:(id)fp12 allowsScrolling:(BOOL)fp16;
- (void)_finishedLoadingResourceFromDataSource:(id)fp8;
- (void)_mainReceivedBytesSoFar:(unsigned int)fp8 fromDataSource:(id)fp12 complete:(BOOL)fp16;
- (void)_receivedError:(id)fp8 fromDataSource:(id)fp12;
- (void)_mainReceivedError:(id)fp8 fromDataSource:(id)fp12 complete:(BOOL)fp16;
- (void)_downloadURL:(id)fp8;
- (void)_downloadURL:(id)fp8 toDirectory:(id)fp12;
- (BOOL)defersCallbacks;
- (void)setDefersCallbacks:(BOOL)fp8;
- (void)_setTopLevelFrameName:(id)fp8;
- (id)_findFrameInThisWindowNamed:(id)fp8 sourceFrame:(id)fp12;
- (id)_findFrameNamed:(id)fp8 sourceFrame:(id)fp12;
- (id)_openNewWindowWithRequest:(id)fp8;
- (id)_menuForElement:(id)fp8;
- (void)_mouseDidMoveOverElement:(id)fp8 modifierFlags:(unsigned int)fp12;
- (void)_goToItem:(id)fp8 withLoadType:(int)fp12;
- (void)_loadItem:(id)fp8;
- (void)_loadBackForwardListFromOtherView:(id)fp8;
- (void)_setFormDelegate:(id)fp8;
- (id)_formDelegate;
- (id)_settings;
- (void)_updateWebCoreSettingsFromPreferences:(id)fp8;
- (void)_preferencesChangedNotification:(id)fp8;
- (id)_frameLoadDelegateForwarder;
- (id)_resourceLoadDelegateForwarder;
- (void)_cacheResourceLoadDelegateImplementations;
- (struct _WebResourceDelegateImplementationCache)_resourceLoadDelegateImplementations;
- (id)_policyDelegateForwarder;
- (id)_UIDelegateForwarder;
- (id)_editingDelegateForwarder;
- (id)_frameForDataSource:(id)fp8 fromFrame:(id)fp12;
- (id)_frameForDataSource:(id)fp8;
- (id)_frameForView:(id)fp8 fromFrame:(id)fp12;
- (id)_frameForView:(id)fp8;
- (void)_closeWindow;
- (void)_pushPerformingProgrammaticFocus;
- (void)_popPerformingProgrammaticFocus;
- (BOOL)_isPerformingProgrammaticFocus;
- (void)_didChangeValueForKey:(id)fp8;
- (void)_willChangeValueForKey:(id)fp8;
- (void)_resetProgress;
- (void)_progressStarted:(id)fp8;
- (void)_finalProgressComplete;
- (void)_progressCompleted:(id)fp8;
- (void)_incrementProgressForConnectionDelegate:(id)fp8 response:(id)fp12;
- (void)_incrementProgressForConnectionDelegate:(id)fp8 data:(id)fp12;
- (void)_completeProgressForConnectionDelegate:(id)fp8;
- (id)_declaredKeys;
- (void)setObservationInfo:(void *)fp8;
- (void *)observationInfo;
- (void)_willChangeBackForwardKeys;
- (void)_didChangeBackForwardKeys;
- (void)_didStartProvisionalLoadForFrame:(id)fp8;
- (void)_didCommitLoadForFrame:(id)fp8;
- (void)_didFinishLoadForFrame:(id)fp8;
- (void)_didFailLoadWithError:(id)fp8 forFrame:(id)fp12;
- (void)_didFailProvisionalLoadWithError:(id)fp8 forFrame:(id)fp12;
- (void)_reloadForPluginChanges;
- (id)_cachedResponseForURL:(id)fp8;
- (void)_writeImageElement:(id)fp8 withPasteboardTypes:(id)fp12 toPasteboard:(id)fp16;
- (void)_writeLinkElement:(id)fp8 withPasteboardTypes:(id)fp12 toPasteboard:(id)fp16;
- (void)_setInitiatedDrag:(BOOL)fp8;
- (void)_addScrollerDashboardRegions:(id)fp8 from:(id)fp12;
- (void)_addScrollerDashboardRegions:(id)fp8;
- (id)_dashboardRegions;
- (void)_setDashboardBehavior:(int)fp8 to:(BOOL)fp12;
- (BOOL)_dashboardBehavior:(int)fp8;
- (void)handleAuthenticationForResource:(id)fp8 challenge:(id)fp12 fromDataSource:(id)fp16;

@end

@interface NSURLRequest (CertificateAllowing)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)flag forHost:(NSString*)host;
@end