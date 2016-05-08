//
//  AppDelegate.m
//  Spark Web Browser
//

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

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
        // This is not finished -- nothing happens when you visit spark://about (yet)
        NSLog(@"Secure Spark page loaded");
        self.securePageIndicator.hidden = NO;
        self.securePageIndicator.toolTip = @"You are viewing a secure Spark page.";
        [self.titleStatus setStringValue:@"About Spark"];
        self.stillLoading.hidden = YES;
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // fetch the version number from info.plist
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // fetch the build number from info.plist
    window.titleVisibility = NSWindowTitleHidden; // for future purposes
    [self.webView setCustomUserAgent: @"Mozilla/5.0 (Macintosh; Intel Mac OS X) SparkWebBrowser/2.2.0.20806 (KHTML, like Gecko)"]; // static for now, will fix later
    self.ntNotSupported.hidden = YES;
    self.securePageIndicator.hidden = YES;
    self.stillLoading.hidden = NO;
    self.currentVersion.stringValue = [NSString stringWithFormat:@"%@.%@", appVersion, buildNumber];
    self.window.backgroundColor = [NSColor colorWithRed:0.773 green:0.231 blue:0.212 alpha:1]; // title bar color in RGB
    self.aboutWindow.backgroundColor = [NSColor whiteColor];
    
    self.addressBar.action = @selector(takeStringURLFrom:);
}

- (IBAction)newTab:(id)sender {
    /*
    // No support for tabs in Spark -- display a label
    _ntNotSupported.hidden = NO;
    
    // Timer to only display the label for 2 seconds
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        _ntNotSupported.hidden = YES;
    });*/
    NSViewController *viewController = [[NSViewController alloc] initWithNibName: @"WebView" bundle: nil];
    [self.viewControllers addObject: viewController];
    
    WebView *webView = viewController.view;
    
    NSTabView *tabView = self.tabView;
    TabViewItem *item = [[TabViewItem alloc] initWithIdentifier: nil];
    [item setLabel: @"title"];
    [item setWebView: webView];
    
    NSView *view = item.view;
    webView.frame = view.bounds;
    webView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [view addSubview: webView];
    
    [tabView insertTabViewItem: item atIndex: [tabView numberOfTabViewItems]];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        [self.addressBar setStringValue:url];
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        [self.titleStatus setStringValue:title];
        self.stillLoading.hidden = YES;
    }
}

@end