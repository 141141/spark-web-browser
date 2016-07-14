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

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];

}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    NSString *urlToString = [url absoluteString];
    if([urlToString isEqual: @"spark://about"]) {
        NSLog(@"spark://about loaded");
        [self.titleStatus setStringValue:@"About Spark"];
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-about" ofType:@"html"] isDirectory:NO]]];
        self.addressBar.stringValue = @"spark://about";
    } else if([urlToString isEqual: @"spark://updates"]) {
        NSLog(@"spark://updates loaded");
        [self.titleStatus setStringValue:@"Updates"];
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-about" ofType:@"html"] isDirectory:NO]]];
        self.addressBar.stringValue = @"spark://updates";
    }

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Initialize
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from Info.plist
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // Fetch the build number from Info.plist
    NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    NSString *versionString = [sv objectForKey:@"ProductVersion"];
    NSString *buildString = [sv objectForKey:@"ProductBuildVersion"];
    NSString *productName = [sv objectForKey:@"ProductName"];
    
    // Should be dynamic/user-set at some point
    NSString *userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel %@ 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36", productName];
    
    NSString *channelVer = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"currentReleaseChannel"]];
    
    if([defaults objectForKey:@"currentReleaseChannel"] == nil) {
        // No release channel is set -- revert to default
        [defaults setObject:@"stable" forKey:@"currentReleaseChannel"];
    }
    
    if([defaults integerForKey:@"releaseChannelIndex"] == nil) {
        // No release channel index is set -- revert to default
        [defaults setInteger:0 forKey:@"releaseChannelIndex"];
    }
    
    [self.releaseChannelPicker selectItemAtIndex:[defaults integerForKey:@"releaseChannelIndex"]];
    
    if([defaults objectForKey:@"currentSearchEngine"] == nil) {
        // No release channel is set -- revert to default
        [defaults setObject:@"Google" forKey:@"currentSearchEngine"];
    }
    
    if([defaults integerForKey:@"searchEngineIndex"] == nil) {
        // No release channel index is set -- revert to default
        [defaults setInteger:0 forKey:@"searchEngineIndex"];
    }
    
    [self.searchEnginePicker selectItemAtIndex:[defaults integerForKey:@"searchEngineIndex"]];
    
    window.titleVisibility = NSWindowTitleHidden; // For future purposes
    [self.webView setCustomUserAgent: userAgent];
    self.userAgentField.stringValue = userAgent;
    if(versionString.doubleValue > 10.11) { // Detect whether or not user is running macOS 10.12 or higher
        self.osVersionField.stringValue = [NSString stringWithFormat: @"macOS %@ (%@)", versionString, buildString];
    } else {
        self.osVersionField.stringValue = [NSString stringWithFormat: @"OS X %@ (%@)", versionString, buildString];
    }
    self.ntNotSupported.hidden = YES;
    self.faviconImage.hidden = YES;
    self.loadingIndicator.hidden = NO;
    [self.loadingIndicator startAnimation:self];
    self.currentVersion.stringValue = [NSString stringWithFormat:@"%@-%@ (%@ channel) (64-bit)", appVersion, buildNumber, channelVer];
    self.window.backgroundColor = [NSColor colorWithRed:0.773 green:0.231 blue:0.212 alpha:1]; // Title bar color in RGB
    self.aboutWindow.backgroundColor = [NSColor whiteColor];
    self.settingsWindow.backgroundColor = [NSColor whiteColor];
    
    // Homepage -- this should be user-set at some point
    if([defaults objectForKey:@"userHomepage"] == nil) {
        // Homepage is not set
        
        // Default homepage
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.google.com/?gws_rd=ssl"]]];
        self.homepageTextField.stringValue = [NSString stringWithFormat:@"https://www.google.com/?gws_rd=ssl"];
    } else {
        // Homepage is set
        
        // User-set homepage
        self.homepageTextField.stringValue = [NSString stringWithFormat:@"%@", [defaults valueForKey:@"userHomepage"]];
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [defaults valueForKey:@"userHomepage"]]]]];
    }
}
- (IBAction)setSearchEngine:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *searchEngineChosen = [NSString stringWithFormat:@"%@", self.searchEnginePicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", searchEngineChosen] forKey:@"currentSearchEngine"];
    [defaults setInteger:self.searchEnginePicker.indexOfSelectedItem forKey:@"searchEngineIndex"];
    
    if([searchEngineChosen isEqual: @"Google"]) {
        NSLog(@"Google");
    } else if([searchEngineChosen isEqual: @"Bing"]) {
        NSLog(@"Bing");
    } else if([searchEngineChosen isEqual: @"Yahoo!"]) {
        NSLog(@"Yahoo!");
    }
    
}

- (IBAction)initWebpageLoad:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *searchString = self.addressBar.stringValue;

    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:searchString]]];
    self.addressBar.stringValue = [NSString stringWithFormat:@"%@", searchString];
    
    if([searchString hasPrefix:@"https"]) {
        NSLog(@"HTTPS webpage loaded.");
    } else if([searchString hasPrefix:@"http"]) {
        NSLog(@"HTTP webpage loaded.");
    } else if([searchString hasPrefix:@"file"]) {
        NSLog(@"file:// prefix");
    } else {
        NSLog(@"User has initiated a search. Finding search engine...");
        
        NSString *searchString = self.addressBar.stringValue;
        
        if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
            
            NSLog(@"User has initiated a Google search.");
            
            NSString *urlAddress = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&gws_rd=ssl", searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
            
            NSLog(@"User has initiated a Bing search.");
            
            NSString *urlAddress = [NSString stringWithFormat:@"https://www.bing.com/search?q=%@", searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
            
            NSLog(@"User has initiated a Yahoo! search.");
            
        }
        
        
    }

}

- (IBAction)setReleaseChannel:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *capitalizedReleaseChannel = [NSString stringWithFormat:@"%@", self.releaseChannelPicker.titleOfSelectedItem];
    
    NSString *uncapitalizedReleaseChannel = [capitalizedReleaseChannel lowercaseString];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", uncapitalizedReleaseChannel] forKey:@"currentReleaseChannel"];
    [defaults setInteger:self.releaseChannelPicker.indexOfSelectedItem forKey:@"releaseChannelIndex"];
    
}

- (IBAction)setHomepage:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(self.homepageTextField.stringValue == nil || [self.homepageTextField.stringValue isEqual:@""]) {
        // Homepage is not set -- revert to default
        
        [defaults setObject:@"https://www.google.com/?gws_rd=ssl" forKey:@"userHomepage"];
        self.homepageTextField.stringValue = @"https://www.google.com/";
    } else {
        
        NSLog(@"Setting homepage...");
        
        NSString *homepageString = self.homepageTextField.stringValue;
        
        [defaults setObject:[NSString stringWithFormat:@"%@", homepageString] forKey:@"userHomepage"];
    }
}

- (IBAction)newTab:(id)sender {
    
    // No support for tabs in Spark -- display a label
    self.ntNotSupported.hidden = NO;
    
    // Timer to only display the label for 2 seconds
    int64_t delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.ntNotSupported.hidden = YES;
    });
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]) {
        NSString *url = [[[[frame provisionalDataSource] request] URL] absoluteString];
        self.reloadBtn.image = [NSImage imageNamed: NSImageNameStopProgressTemplate];
        [self.addressBar setStringValue:url];
        self.faviconImage.hidden = YES;
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimation:self];
        
        NSString *faviconURLString = [NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain=%@", url];
        NSURL *faviconURL=[NSURL URLWithString: faviconURLString];
        NSData *faviconData = [NSData dataWithContentsOfURL:faviconURL];
        NSImage *websiteFavicon = [[NSImage alloc] initWithData:faviconData];
        self.faviconImage.image = websiteFavicon;
        
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]) {
        
        [self.titleStatus setStringValue:title];
        self.titleStatus.toolTip = title;
        [self.loadingIndicator stopAnimation:self];
        self.reloadBtn.image = [NSImage imageNamed: NSImageNameRefreshTemplate];
        self.loadingIndicator.hidden = YES;
        self.faviconImage.hidden = NO;
        
    }
}

@end