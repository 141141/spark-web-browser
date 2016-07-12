//
//  AppDelegate.m
//  Spark Web Browser
//

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

@interface AppDelegate () <NSTabViewDelegate>

@end

@implementation AppDelegate

@synthesize window;

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSString *urlToString = [url absoluteString];
    if([urlToString isEqual: @"spark://about"]) {
        NSLog(@"spark://about loaded");
        [self.titleStatus setStringValue:@"About Spark"];
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-about" ofType:@"html"] isDirectory:NO]]];
        self.addressBar.stringValue = @"spark://about";
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from info.plist
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // Fetch the build number from info.plist
    NSString *versionString;
    NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    versionString = [sv objectForKey:@"ProductVersion"];
    NSString *userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel Mac OS X) SparkWebBrowser/%@.%@ (KHTML, like Gecko)", appVersion, buildNumber];
    
    // Should be dynamic/user-set at some point
    NSString *channelVer = @"dev";
    
    window.titleVisibility = NSWindowTitleHidden; // For future purposes
    [self.webView setCustomUserAgent: userAgent];
    self.userAgentField.stringValue = userAgent;
    if(versionString.doubleValue > 10.11) { // Detect whether or not user is running macOS 10.12 or higher
        self.osVersionField.stringValue = [NSString stringWithFormat: @"macOS %@", versionString];
    } else {
        self.osVersionField.stringValue = [NSString stringWithFormat: @"OS X %@", versionString];
    }
    self.ntNotSupported.hidden = YES;
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimation:self];
    self.currentVersion.stringValue = [NSString stringWithFormat:@"%@.%@ (%@ channel) (64-bit)", appVersion, buildNumber, channelVer];
    self.window.backgroundColor = [NSColor colorWithRed:0.773 green:0.231 blue:0.212 alpha:1]; // Title bar color in RGB
    self.aboutWindow.backgroundColor = [NSColor whiteColor];
    
    self.addressBar.action = @selector(takeStringURLFrom:);
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com"]]];
}

- (IBAction)newTab:(id)sender {
    
    // No support for tabs in Spark -- display a label
    _ntNotSupported.hidden = NO;
    
    // Timer to only display the label for 2 seconds
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _ntNotSupported.hidden = YES;
    });
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [self.addressBar setStringValue:url];
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimation:self];
        self.faviconImage.hidden = YES;
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        [self.titleStatus setStringValue:title];
        self.titleStatus.toolTip = title;
        [self.loadingIndicator stopAnimation:self];
        self.loadingIndicator.hidden = YES;
        self.faviconImage.hidden = NO;
    }
}

@end