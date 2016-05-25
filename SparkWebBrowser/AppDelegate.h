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
@property (assign, nonatomic) IBOutlet NSTextField *stillLoading;
@property (assign, nonatomic) IBOutlet NSTextField *currentVersion;
@property (assign, nonatomic) IBOutlet NSImageView *securePageIndicator;
@property (assign, nonatomic) IBOutlet NSPanel *aboutWindow;
@property (assign, nonatomic) IBOutlet NSTextField *userAgentField;
@property (assign, nonatomic) IBOutlet NSTextField *osVersionField;

// Methods
- (IBAction)newTab:(id)sender;

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame;

@end
