//
//  AppDelegate.m
//  Spark Web Browser v2.14
//

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize
    _ntNotSupported.hidden = YES;
    _stillLoading.hidden = NO;
}

- (IBAction)newTab:(id)sender {
    
    // Display a label for 2 seconds telling the user that there is no support for tabs in Spark
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
