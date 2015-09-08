// Originally created by Insleep on GitHub
// Feel free to alter this to your liking

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

@implementation AppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initialize app
    _ntNotSupported.hidden = YES;
    _stillLoading.hidden = NO;
}

- (IBAction)newTab:(id)sender {
    
    // Display a label for 2 seconds saying that new tab is not available at the moment but will be implemented soon
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

    // Report feedback only for the main frame.
    if (frame == [sender mainFrame]){
        [_titleStatus setStringValue:title];
       // [[sender window] setTitle:title];
        _stillLoading.hidden = YES;
    }
}

@end
