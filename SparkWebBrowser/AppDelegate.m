//
//  AppDelegate.m
//  Spark Web Browser
//
//  Copyright (c) 2016 Jonathan Wukitsch / InsleepTech
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

@interface AppDelegate () <NSTabViewDelegate>

@end

@implementation AppDelegate

@synthesize window;

// Declarations -- defined within the class for easy changes / scalability in the future

NSUserDefaults *defaults = nil;

// Search engine string declarations
NSString *googleSearchString = @"https://www.google.com/search?q=%@&gws_rd=ssl";
NSString *bingSearchString = @"https://www.bing.com/search?q=%@";
NSString *yahooSearchString = @"https://search.yahoo.com/search?p=%@";
NSString *duckDuckGoSearchString = @"https://www.duckduckgo.com/%@";
NSString *askSearchString = @"http://www.ask.com/web?q=%@";
NSString *aolSearchString = @"http://search.aol.com/aol/search?q=%@";

NSColor *defaultColor = nil;
NSColor *redColor = nil;
NSColor *aquaColor = nil;
NSColor *orangeColor = nil;
NSColor *darkGrayColor = nil;

+ (void)initialize {
    defaultColor = [NSColor colorWithRed:216.0f/255.0f green:216.0f/255.0f blue:216.0f/255.0f alpha:1.0f];
    redColor = [NSColor colorWithRed:0.773f green:0.231f blue:0.212f alpha:1.0f];
    aquaColor = [NSColor colorWithRed:46.0f/255.0f green:133.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
    orangeColor = [NSColor colorWithRed:200.0f/255.0f green:80.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
    darkGrayColor = [NSColor colorWithRed:44.0f/255.0f green:44.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

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
     // Shortcut for later
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary]; // Load Info.plist
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from Info.plist
    NSString *buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // Fetch the build number from Info.plist
    NSDictionary *sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"]; // Load SystemVersion.plist
    NSString *versionString = [sv objectForKey:@"ProductVersion"]; // Get macOS version
    NSString *buildString = [sv objectForKey:@"ProductBuildVersion"]; // Get macOS build number
    NSString *productName = [sv objectForKey:@"ProductName"]; // Get macOS product name (either OS X / macOS)
    NSString *channelVer = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"currentReleaseChannel"]]; // Get current release channel
    
    NSString *editedVersionString = [versionString stringByReplacingOccurrencesOfString:@"." withString:@"_"]; // Replace dots in version string with underscores
    NSString *userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel %@ %@) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.89 Safari/537.36", productName, editedVersionString]; // Set user agent respective to the version of OS X / macOS the user is running
    
    if([defaults objectForKey:@"currentReleaseChannel"] == nil) {
        // No release channel is set -- revert to default
        [defaults setObject:@"stable" forKey:@"currentReleaseChannel"];
    }
    
    if([defaults integerForKey:@"releaseChannelIndex"] == (int)nil) {
        // No release channel index is set -- revert to default
        [defaults setInteger:0 forKey:@"releaseChannelIndex"];
    }
    
    [self.releaseChannelPicker selectItemAtIndex:[defaults integerForKey:@"releaseChannelIndex"]];
    
    if([defaults objectForKey:@"currentSearchEngine"] == nil) {
        // No search engine is set -- revert to default
        [defaults setObject:@"Google" forKey:@"currentSearchEngine"];
    }
    
    if([defaults integerForKey:@"searchEngineIndex"] == (int)nil) {
        // No search engine index is set -- revert to default
        [defaults setInteger:0 forKey:@"searchEngineIndex"];
    }
    
    [self.searchEnginePicker selectItemAtIndex:[defaults integerForKey:@"searchEngineIndex"]];
    
    if([defaults objectForKey:@"currentColor"] == nil) {
        // No top bar color is set -- revert to default
        [defaults setObject:@"Google" forKey:@"currentColor"];
    }
    
    if([defaults integerForKey:@"colorIndex"] == (int)nil) {
        // No top bar color index is set -- revert to default
        [defaults setInteger:0 forKey:@"colorIndex"];
    }
    
    [self.topBarColorPicker selectItemAtIndex:[defaults integerForKey:@"colorIndex"]];
    
    // Interface setup
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
    self.currentVersion.stringValue = [NSString stringWithFormat:@"%@.%@ (%@ channel) (64-bit)", appVersion, buildNumber, channelVer];
    self.aboutWindow.backgroundColor = [NSColor whiteColor];
    self.settingsWindow.backgroundColor = [NSColor whiteColor];
    
    // Get key value from NSUserDefaults and set top bar color
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"] || [defaults objectForKey:@"currentColor"] == nil) {
        
        // Set top bar color to default
        self.window.backgroundColor = defaultColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Red"]) {
        
        // Set top bar color to red
        self.window.backgroundColor = redColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Aqua"]) {
        
        // Set top bar color to aqua
        self.window.backgroundColor = aquaColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Orange"]) {
        
        // Set top bar color to orange
        self.window.backgroundColor = orangeColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        // Set top bar color to dark gray
        self.window.backgroundColor = darkGrayColor;
        
    }
    
    // Homepage checking
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
    
    // Check if checkbox is checked
    if([defaults boolForKey:@"setHomepageEngine"] == YES) {
        self.basedOnEngineBtn.state = NSOnState;
    } else {
        self.basedOnEngineBtn.state = NSOffState;
    }
}

- (IBAction)setTopBarColor:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *colorChosen = [NSString stringWithFormat:@"%@", self.topBarColorPicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", colorChosen] forKey:@"currentColor"];
    [defaults setInteger:self.topBarColorPicker.indexOfSelectedItem forKey:@"colorIndex"];
    
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"]) {
        
        // Set top bar color to default
        self.window.backgroundColor = defaultColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Red"]) {
        
        // Set top bar color to red
        self.window.backgroundColor = redColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Aqua"]) {
        
        // Set top bar color to aqua
        self.window.backgroundColor = aquaColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Orange"]) {
        
        // Set top bar color to orange
        self.window.backgroundColor = orangeColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        // Set top bar color to dark gray
        self.window.backgroundColor = darkGrayColor;
        
    }
}

- (IBAction)setHomepageEngine:(id)sender {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([self.basedOnEngineBtn state] == NSOnState) {
        // On
        
        [defaults setBool:YES forKey:@"setHomepageEngine"];
        
    } else if([self.basedOnEngineBtn state] == NSOffState) {
        // Off
        
        [defaults setBool:NO forKey:@"setHomepageEngine"];
    }
}


- (IBAction)viewReleaseNotes:(id)sender {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary]; // Load Info.plist
    NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from Info.plist
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://www.github.com/insleep/spark-web-browser/releases/tag/%@/", appVersion]]]];
    self.addressBar.stringValue = [NSString stringWithFormat:@"https://www.github.com/insleep/spark-web-browser/releases/tag/%@/", appVersion];
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
    
    if([defaults boolForKey:@"setHomepageEngine"] == YES) {
        
        NSLog(@"Setting homepage based on search engine");
        
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
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Ask"]) {
            
            // Set homepage to Ask
            [self setHomepageFunc:@"http://ask.com/"];
            self.homepageTextField.stringValue = @"http://ask.com/";
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"AOL"]) {
            
            // Set homepage to AOL
            [self setHomepageFunc:@"http://aol.com/"];
            self.homepageTextField.stringValue = @"http://aol.com/";
        }
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
        NSLog(@"User has initiated a search. Fetching search engine...");
        
        NSString *searchString = self.addressBar.stringValue;
        
        if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
            
            // Google search initiated
            
            NSLog(@"Search engine found: Google");
            
            NSString *urlAddress = [NSString stringWithFormat:googleSearchString, searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
            
            // Bing search initiated
            
            NSLog(@"Search engine found: Bing");
            
            NSString *urlAddress = [NSString stringWithFormat:bingSearchString, searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
            
            // Yahoo! search initiated
            
            NSLog(@"Search engine found: Yahoo!");
            
            NSString *urlAddress = [NSString stringWithFormat:yahooSearchString, searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
            
            // DuckDuckGo search initiated
            
            NSLog(@"Search engine found: DuckDuckGo");
            
            NSString *urlAddress = [NSString stringWithFormat:duckDuckGoSearchString, searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Ask"]) {
            
            // Ask search initiated
            
            NSLog(@"Search engine found: Ask");
            
            NSString *urlAddress = [NSString stringWithFormat:askSearchString, searchString];
            NSString *editedUrlString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedUrlString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedUrlString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"AOL"]) {
            
            // AOL search initiated
            
            NSLog(@"Search engine found: AOL");
            
            NSString *urlAddress = [NSString stringWithFormat:aolSearchString, searchString];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"]) {
        self.ntNotSupported.textColor = [NSColor blackColor];
    } else {
        self.ntNotSupported.textColor = [NSColor whiteColor];
    }
    
    // No support for tabs in Spark -- display a label
    self.ntNotSupported.hidden = NO;
    
    // Timer to display the label for 2 seconds
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
        
        const int clipLength = 25;
        if([title length] > clipLength)
        {
            title = [NSString stringWithFormat:@"%@...", [title substringToIndex:clipLength]];
        }
        
        [self.titleStatus setStringValue:title];
        self.titleStatus.toolTip = title;
        [self.loadingIndicator stopAnimation:self];
        self.reloadBtn.image = [NSImage imageNamed: NSImageNameRefreshTemplate];
        self.loadingIndicator.hidden = YES;
        self.faviconImage.hidden = NO;
        
    }
}

@end