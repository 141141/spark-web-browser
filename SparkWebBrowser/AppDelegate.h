//
//  AppDelegate.h
//  Spark Web Browser
//

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
@property (assign, nonatomic) IBOutlet NSTextField *googleSearchField;

// Methods
- (IBAction)newTab:(id)sender;
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame;

@end
