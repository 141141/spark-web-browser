//
//  AppDelegate.h
//  Spark Web Browser
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

// Declarations
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;
@property (assign) IBOutlet NSTextField *addressBar;
@property (assign) IBOutlet NSTextField *titleStatus;
@property (strong) IBOutlet NSTextField *ntNotSupported;
@property (strong) IBOutlet NSTextField *stillLoading;
@property (strong) IBOutlet NSTextField *currentVersion;
@property (strong) IBOutlet NSImageView *securePageIndicator;

// Methods
- (IBAction)newTab:(id)sender;
- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame;
- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame;

@end
