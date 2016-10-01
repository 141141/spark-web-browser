//
//  AppDelegate.h
//  Spark
//
//  Copyright (c) 2014-2016 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// Declarations
@property (assign, nonatomic) IBOutlet NSWindow *window;
@property (assign, nonatomic) IBOutlet WebView *webView;
@property (assign, nonatomic) IBOutlet NSTextField *addressBar;
@property (assign, nonatomic) IBOutlet NSTextField *titleStatus;
@property (assign, nonatomic) IBOutlet NSTextField *ntNotSupported;
@property (assign, nonatomic) IBOutlet NSTextField *currentVersion;
@property (assign, nonatomic) IBOutlet NSPanel *aboutWindow;
@property (assign, nonatomic) IBOutlet NSTextField *userAgentField;
@property (assign, nonatomic) IBOutlet NSTextField *osVersionField;
@property (assign, nonatomic) IBOutlet NSProgressIndicator *loadingIndicator;
@property (assign, nonatomic) IBOutlet NSImageView *faviconImage;
@property (assign, nonatomic) IBOutlet NSTextField *homepageTextField;
@property (assign, nonatomic) IBOutlet NSButton *setHomepageBtn;
@property (assign, nonatomic) IBOutlet NSPopUpButton *releaseChannelPicker;
@property (assign, nonatomic) IBOutlet NSPanel *settingsWindow;
@property (assign, nonatomic) IBOutlet NSButton *reloadBtn;
@property (assign, nonatomic) IBOutlet NSTextField *ntBtnBackground;
@property (assign, nonatomic) IBOutlet NSButton *ntBtn;
@property (assign, nonatomic) IBOutlet NSPopUpButton *searchEnginePicker;
@property (assign, nonatomic) IBOutlet NSPopUpButton *topBarColorPicker;
@property (assign, nonatomic) IBOutlet NSButton *homepageBasedOnSearchEngineBtn;
@property (assign, nonatomic) IBOutlet NSTextField *tabBg;
@property (assign, nonatomic) IBOutlet NSTextField *topBarBg;
@property (assign, nonatomic) IBOutlet NSButton *backBtn;
@property (assign, nonatomic) IBOutlet NSButton *forwardBtn;
@property (assign, nonatomic) IBOutlet NSButton *settingsBtn;
@property (assign, nonatomic) IBOutlet NSPopUpButton *settingsPopupBtn;
@property (assign, nonatomic) IBOutlet NSColorWell *customColorWell;
@property (assign, nonatomic) IBOutlet NSTextField *sparkAboutTitleField;
@property (assign, nonatomic) IBOutlet NSProgressIndicator *downloadProgressIndicator;
@property (assign, nonatomic) IBOutlet NSTextField *downloadLocationField;

@property (nonatomic, assign) long bytesReceived;

// Methods
- (IBAction)newTab:(id)sender;
- (IBAction)setHomepage:(id)sender;
- (IBAction)setDownloadLocation:(id)sender;
- (IBAction)setReleaseChannel:(id)sender;
- (IBAction)initWebpageLoad:(id)sender;
- (IBAction)setSearchEngine:(id)sender;
- (IBAction)viewReleaseNotes:(id)sender;
- (IBAction)startSettingHomepageBasedOnSearchEngine:(id)sender;
- (IBAction)setTopBarColor:(id)sender;
- (IBAction)setCustomColor:(id)sender;
- (IBAction)reportIssueAboutWindow:(id)sender;
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame;
- (void)setHomepageWithString:(NSString *)homepageToSet;
- (void)settingsMenuClicked:(id)sender;
- (void)setHomepageBasedOnSearchEngine:(id)sender;

@end
