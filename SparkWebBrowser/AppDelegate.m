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
    
    // Handle spark:// URL events
    
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; // Shortcut for later
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary]; // Load Info.plist
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from Info.plist
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // Fetch the build number from Info.plist
    NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"]; // Load SystemVersion.plist
    NSString *versionString = [sv objectForKey:@"ProductVersion"]; // Get macOS version
    NSString *buildString = [sv objectForKey:@"ProductBuildVersion"]; // Get macOS build number
    NSString *productName = [sv objectForKey:@"ProductName"]; // Get macOS product name (OS X / macOS)
    NSString *channelVer = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"currentReleaseChannel"]]; // Get current release channel
    
    // Should be dynamic/user-set at some point
    NSString *userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel %@ 10_12_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.106 Safari/537.36", productName];
    
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
        // No search index is set -- revert to default
        [defaults setObject:@"Google" forKey:@"currentSearchEngine"];
    }
    
    if([defaults integerForKey:@"searchEngineIndex"] == nil) {
        // No search engine index is set -- revert to default
        [defaults setInteger:0 forKey:@"searchEngineIndex"];
    }
    
    [self.searchEnginePicker selectItemAtIndex:[defaults integerForKey:@"searchEngineIndex"]];
    
    if([defaults objectForKey:@"currentColor"] == nil) {
        // No top bar color is set -- revert to default
        [defaults setObject:@"Google" forKey:@"currentColor"];
    }
    
    if([defaults integerForKey:@"colorIndex"] == nil) {
        // No top bar color index is set -- revert to default
        [defaults setInteger:0 forKey:@"colorIndex"];
    }
    
    [self.topBarColorPicker selectItemAtIndex:[defaults integerForKey:@"colorIndex"]];
    
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
    self.aboutWindow.backgroundColor = [NSColor whiteColor];
    self.settingsWindow.backgroundColor = [NSColor whiteColor];
    
    
    
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
- (IBAction)setTopBarColor:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *colorChosen = [NSString stringWithFormat:@"%@", self.topBarColorPicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", colorChosen] forKey:@"currentColor"];
    [defaults setInteger:self.topBarColorPicker.indexOfSelectedItem forKey:@"colorIndex"];
    
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"]) {
        
        // Set top bar color to default
        
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Red"]) {
        
        // Set top bar color to red
        self.window.backgroundColor = [NSColor colorWithRed:0.773f green:0.231f blue:0.212f alpha:1.0f]; // Title bar color in RGB
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Blue"]) {
        
        // Set top bar color to blue
        self.window.backgroundColor = [NSColor colorWithRed:46.0f/255.0f green:133.0f/255.0f blue:162.0f/255.0f alpha:1.0f]; // Title bar color in RGB
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Orange"]) {
        
        // Set top bar color to orange
        self.window.backgroundColor = [NSColor colorWithRed:200.0f/255.0f green:80.0f/255.0f blue:1.0f/255.0f alpha:1.0f]; // Title bar color in RGB
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        // Set top bar color to dark gray
        self.window.backgroundColor = [NSColor colorWithRed:81.0f/255.0f green:81.0f/255.0f blue:81.0f/255.0f alpha:1.0f]; // Title bar color in RGB
        
    }

    
}

- (IBAction)viewReleaseNotes:(id)sender {
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.github.com/insleep/spark-web-browser/releases/tag/0.3"]]];
    self.addressBar.stringValue = @"https://www.github.com/insleep/spark-web-browser/releases/tag/0.3";
}


- (IBAction)reportIssue:(id)sender {
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.github.com/insleep/spark-web-browser/issues/"]]];
    self.addressBar.stringValue = @"https://www.github.com/insleep/spark-web-browser/issues/";
}

- (IBAction)setSearchEngine:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *searchEngineChosen = [NSString stringWithFormat:@"%@", self.searchEnginePicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", searchEngineChosen] forKey:@"currentSearchEngine"];
    [defaults setInteger:self.searchEnginePicker.indexOfSelectedItem forKey:@"searchEngineIndex"];
    
    if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
        
        // Set homepage to Google
        [self setHomepageFunc:@"https://www.google.com/?gws_rd=ssl"];
        self.homepageTextField.stringValue = @"https://www.google.com/?gws_rd=ssl";
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
        
        // Set homepage to Bing
        [self setHomepageFunc:@"https://www.bing.com/"];
        self.homepageTextField.stringValue = @"https://www.bing.com/";
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
        
        // Set homepage to Yahoo!
        [self setHomepageFunc:@"https://www.yahoo.com/"];
        self.homepageTextField.stringValue = @"https://www.yahoo.com/";
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
        
        // Set homepage to DuckDuckGo
        [self setHomepageFunc:@"https://www.duckduckgo.com/"];
        self.homepageTextField.stringValue = @"https://www.duckduckgo.com/";
        
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
            
            // Google search initiated
            
            NSLog(@"User has initiated a Google search.");
            
            NSString *urlAddress = [NSString stringWithFormat:@"https://www.google.com/search?q=%@&gws_rd=ssl", searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
            
            // Bing search initiated
            
            NSLog(@"User has initiated a Bing search.");
            
            NSString *urlAddress = [NSString stringWithFormat:@"https://www.bing.com/search?q=%@", searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
            
            // Yahoo! search initiated
            
            NSLog(@"User has initiated a Yahoo! search.");
            
            NSString *urlAddress = [NSString stringWithFormat:@"https://search.yahoo.com/search?p=%@", searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
            
            // DuckDuckGo search initiated
            
            NSLog(@"User has initiated a DuckDuckGo search.");
            
            NSString *urlAddress = [NSString stringWithFormat:@"https://www.duckduckgo.com/%@", searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
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

- (void)setHomepageFunc:(NSString *)homepageToSet {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"Setting homepage...");
    
    [defaults setObject:[NSString stringWithFormat:@"%@", homepageToSet] forKey:@"userHomepage"];
}

- (IBAction)setHomepage:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(self.homepageTextField.stringValue == nil || [self.homepageTextField.stringValue isEqual:@""]) {
        // Homepage is not set -- revert to default
        
        [defaults setObject:@"https://www.google.com/?gws_rd=ssl" forKey:@"userHomepage"];
        self.homepageTextField.stringValue = @"https://www.google.com/?gws_rd=ssl";
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
        
        // Use Google to get website favicons
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