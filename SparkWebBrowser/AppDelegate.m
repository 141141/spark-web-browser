//
//  AppDelegate.m
//  Spark Web Browser
//

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // fetch the version number from info.plist
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // fetch the build number from info.plist
    
    _ntNotSupported.hidden = YES;
    _stillLoading.hidden = NO;
    _currentVersion.stringValue = [NSString stringWithFormat:@"Version %@ (build %@)", appVersion, buildNumber];
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
        [_addressBar setStringValue:url];
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame
{

    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]){
        [_titleStatus setStringValue:title];
        _stillLoading.hidden = YES;
    }
}

@end
