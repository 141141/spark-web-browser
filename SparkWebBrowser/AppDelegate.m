//
//  AppDelegate.m
//  Spark
//
//  Copyright (c) 2014-2016 Jonathan Wukitsch / InsleepTech
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "AppDelegate.h"
#import "WebKit/WebKit.h"

@interface AppDelegate () <NSTabViewDelegate>

@end

@implementation AppDelegate

@synthesize window;

// Declarations -- defined within the entire class for easy changes / scalability in the future

// Search engine query strings
NSString *googleSearchString = @"https://www.google.com/search?q=%@&gws_rd=ssl";
NSString *bingSearchString = @"https://www.bing.com/search?q=%@";
NSString *yahooSearchString = @"https://search.yahoo.com/search?p=%@";
NSString *duckDuckGoSearchString = @"https://www.duckduckgo.com/%@";
NSString *askSearchString = @"http://www.ask.com/web?q=%@";
NSString *aolSearchString = @"http://search.aol.com/aol/search?q=%@";

// Custom search string -- set via NSUserDefaults later on
NSString *customSearchString = nil;

// Search engine default homepages
NSString *googleDefaultURL = @"https://www.google.com/?gws_rd=ssl";
NSString *bingDefaultURL = @"https://www.bing.com/";
NSString *yahooDefaultURL = @"https://www.yahoo.com/";
NSString *duckDuckGoDefaultURL = @"https://www.duckduckgo.com/";
NSString *askDefaultURL = @"http://www.ask.com/";
NSString *aolDefaultURL = @"http://www.aol.com/";

// Strings for "Help" menu bar item
NSString *appIssuesURL = @"https://www.github.com/insleep/spark-web-browser/issues/";
NSString *appReleasesURL = @"https://www.github.com/insleep/spark-web-browser/releases/tag/%@/";

// Theme Colors
NSColor *defaultColor = nil;
NSColor *rubyRedColor = nil;
NSColor *deepAquaColor = nil;
NSColor *redmondBlueColor = nil;
NSColor *leafGreenColor = nil;
NSColor *alloyOrangeColor = nil;
NSColor *darkGrayColor = nil;

// General app setup
NSUserDefaults *defaults = nil;
NSDictionary *infoDict = nil;
NSDictionary *sv = nil;
NSString *appVersion = nil;
NSString *buildNumber = nil;
NSString *versionString = nil;
NSString *buildString = nil;
NSString *productName = nil;
NSString *channelVer = nil;
NSString *editedVersionString = nil;
NSString *userAgent = nil;
NSAlert *alert = nil;

// Objects related (somewhat) to loading webpages
NSString *searchString = nil;
NSString *homepageString = nil;
NSString *urlAddress = nil;
NSString *editedURLString = nil;
NSString *capitalizedReleaseChannel = nil;
NSString *uncapitalizedReleaseChannel = nil;
NSString *searchEngineChosen = nil;
NSString *colorChosen = nil;
NSString *urlToString = nil;
NSString *websiteURL = nil;
NSString *faviconURLString = nil;
NSURL *eventURL = nil;
NSURL *faviconURL = nil;
NSData *faviconData = nil;
NSImage *websiteFavicon = nil;


+ (void)initialize {
    defaults = [NSUserDefaults standardUserDefaults]; // Set up NSUserDefaults
    
    // Set up theme colors
    defaultColor = [NSColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
    rubyRedColor = [NSColor colorWithRed:0.773f green:0.231f blue:0.212f alpha:1.0f];
    deepAquaColor = [NSColor colorWithRed:46.0f/255.0f green:133.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
    redmondBlueColor = [NSColor colorWithRed:16.0f/255.0f green:101.0f/255.0f blue:207.0f/255.0f alpha:1.0f];
    leafGreenColor = [NSColor colorWithRed:8.0f/255.0f green:157.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    alloyOrangeColor = [NSColor colorWithRed:200.0f/255.0f green:80.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
    darkGrayColor = [NSColor colorWithRed:44.0f/255.0f green:44.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
    
    infoDict = [[NSBundle mainBundle] infoDictionary]; // Load Info.plist
    appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from Info.plist
    buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // Fetch the build number from Info.plist
    sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"]; // Load SystemVersion.plist
    versionString = [sv objectForKey:@"ProductVersion"]; // Get macOS version
    buildString = [sv objectForKey:@"ProductBuildVersion"]; // Get macOS build number
    productName = [sv objectForKey:@"ProductName"]; // Get macOS product name (either OS X / macOS)
    channelVer = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"currentReleaseChannel"]]; // Get current release channel
    editedVersionString = [versionString stringByReplacingOccurrencesOfString:@"." withString:@"_"]; // Replace dots in version string with underscores
    userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel %@ %@) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/53.0.2785.89 Safari/537.36", productName, editedVersionString]; // Set user agent respective to the version of OS X / macOS the user is running
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

-(void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    
    // Register for URL events
    
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self
                           andSelector:@selector(handleGetURLEvent:withReplyEvent:)
                         forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    
    // Handle spark:// URL events
    
    eventURL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    urlToString = [eventURL absoluteString];
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
    
    // Finish initializing
    
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
        
        // Set window color to default color
        self.window.backgroundColor = defaultColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Ruby Red"]) {
        
        // Set window color to Ruby Red
        self.window.backgroundColor = rubyRedColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Deep Aqua"]) {
        
        // Set window color to Deep Aqua
        self.window.backgroundColor = deepAquaColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Redmond Blue"]) {
        
        // Set window color to Redmond Blue
        self.window.backgroundColor = redmondBlueColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Leaf Green"]) {
        
        // Set window color to Leaf Green
        self.window.backgroundColor = leafGreenColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Alloy Orange"]) {
        
        // Set window color to Alloy Orange
        self.window.backgroundColor = alloyOrangeColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        // Set window color to dark gray
        self.window.backgroundColor = darkGrayColor;
        
    }
    
    
    // Homepage checking
    if([defaults objectForKey:@"userHomepage"] == nil) {
        // Homepage is not set
        
        // Default homepage
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:googleDefaultURL]]];
        self.homepageTextField.stringValue = [NSString stringWithFormat:@"%@", googleDefaultURL];
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
    
    colorChosen = [NSString stringWithFormat:@"%@", self.topBarColorPicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", colorChosen] forKey:@"currentColor"];
    [defaults setInteger:self.topBarColorPicker.indexOfSelectedItem forKey:@"colorIndex"];
    
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"]) {
        
        // Set window color to default color
        self.window.backgroundColor = defaultColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Ruby Red"]) {
        
        // Set window color to Ruby Red
        self.window.backgroundColor = rubyRedColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Deep Aqua"]) {
        
        // Set window color to Deep Aqua
        self.window.backgroundColor = deepAquaColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Redmond Blue"]) {
        
        // Set window color to Redmond Blue
        self.window.backgroundColor = redmondBlueColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Leaf Green"]) {
        
        // Set window color to Leaf Green
        self.window.backgroundColor = leafGreenColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Alloy Orange"]) {
        
        // Set window color to Alloy Orange
        self.window.backgroundColor = alloyOrangeColor;
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        // Set window color to dark gray
        self.window.backgroundColor = darkGrayColor;
        
    }
}

- (IBAction)setHomepageEngine:(id)sender {
    
    if([self.basedOnEngineBtn state] == NSOnState) {
        // On
        
        [defaults setBool:YES forKey:@"setHomepageEngine"];
        
    } else if([self.basedOnEngineBtn state] == NSOffState) {
        // Off
        
        [defaults setBool:NO forKey:@"setHomepageEngine"];
    }
}


- (IBAction)viewReleaseNotes:(id)sender {
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:appReleasesURL, appVersion]]]];
    self.addressBar.stringValue = [NSString stringWithFormat:appReleasesURL, appVersion];
}


- (IBAction)reportIssue:(id)sender {
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appIssuesURL]]];
    self.addressBar.stringValue = appIssuesURL;
}

- (IBAction)setSearchEngine:(id)sender {
    
    searchEngineChosen = [NSString stringWithFormat:@"%@", self.searchEnginePicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", searchEngineChosen] forKey:@"currentSearchEngine"];
    [defaults setInteger:self.searchEnginePicker.indexOfSelectedItem forKey:@"searchEngineIndex"];
    
    // Check whether or not to override homepage
    if([defaults boolForKey:@"setHomepageEngine"] == YES) {
        
        NSLog(@"Setting homepage based on search engine");
        
        if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
            
            // Set homepage to Google
            [self setHomepageFunc:googleDefaultURL];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
            
            // Set homepage to Bing
            [self setHomepageFunc:bingDefaultURL];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
            
            // Set homepage to Yahoo!
            [self setHomepageFunc:yahooDefaultURL];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
            
            // Set homepage to DuckDuckGo
            [self setHomepageFunc:duckDuckGoDefaultURL];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Ask"]) {
            
            // Set homepage to Ask
            [self setHomepageFunc:askDefaultURL];
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"AOL"]) {
            
            // Set homepage to AOL
            [self setHomepageFunc:aolDefaultURL];
        }
    }
}

- (IBAction)initWebpageLoad:(id)sender {
    
    searchString = self.addressBar.stringValue;
    
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
        
        if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
            
            // Google search initiated
            
            NSLog(@"Search engine found: Google");
            
            urlAddress = [NSString stringWithFormat:googleSearchString, searchString];
            editedURLString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
            
            // Bing search initiated
            
            NSLog(@"Search engine found: Bing");
            
            urlAddress = [NSString stringWithFormat:bingSearchString, searchString];
            editedURLString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
            
            // Yahoo! search initiated
            
            NSLog(@"Search engine found: Yahoo!");
            
            urlAddress = [NSString stringWithFormat:yahooSearchString, searchString];
            editedURLString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
            
            // DuckDuckGo search initiated
            
            NSLog(@"Search engine found: DuckDuckGo");
            
            urlAddress = [NSString stringWithFormat:duckDuckGoSearchString, searchString];
            editedURLString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Ask"]) {
            
            // Ask search initiated
            
            NSLog(@"Search engine found: Ask");
            
            urlAddress = [NSString stringWithFormat:askSearchString, searchString];
            editedURLString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"AOL"]) {
            
            // AOL search initiated
            
            NSLog(@"Search engine found: AOL");
            
            urlAddress = [NSString stringWithFormat:aolSearchString, searchString];
            editedURLString = [urlAddress stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        }
    }
}

- (IBAction)setReleaseChannel:(id)sender {
    
    NSLog(@"Setting release channel...");
    
    if([self.releaseChannelPicker.titleOfSelectedItem isEqual: @"Developer"]) {
        capitalizedReleaseChannel = @"Dev";
    } else {
        capitalizedReleaseChannel = [NSString stringWithFormat:@"%@", self.releaseChannelPicker.titleOfSelectedItem];
    }
    
    uncapitalizedReleaseChannel = [capitalizedReleaseChannel lowercaseString];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", uncapitalizedReleaseChannel] forKey:@"currentReleaseChannel"];
    [defaults setInteger:self.releaseChannelPicker.indexOfSelectedItem forKey:@"releaseChannelIndex"];
    
    alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Set Release Channel and Restart?"];
    [alert setInformativeText:[NSString stringWithFormat:@"Spark release channel will be set to: %@.\n\nA browser restart is required for this to take effect.", uncapitalizedReleaseChannel]];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Set Release Channel"];
    if(alert.runModal == NSAlertSecondButtonReturn) {
        NSTask *task = [[NSTask alloc] init];
        NSMutableArray *args = [NSMutableArray array];
        [args addObject:@"-c"];
        [args addObject:[NSString stringWithFormat:@"sleep %d; open \"%@\"", 0, [[NSBundle mainBundle] bundlePath]]];
        [task setLaunchPath:@"/bin/sh"];
        [task setArguments:args];
        [task launch];
        
        [[NSApplication sharedApplication] terminate:nil];
    }


}

- (void)setHomepageFunc:(NSString *)homepageToSet {
    
    
    if([homepageToSet hasPrefix:@"https://"] || [homepageToSet hasPrefix:@"http://"]) {
        NSLog(@"Setting homepage...");
        [defaults setObject:[NSString stringWithFormat:@"%@", homepageToSet] forKey:@"userHomepage"];
        self.homepageTextField.stringValue = [defaults objectForKey:@"userHomepage"];
    } else {
        NSLog(@"Homepage not set: invalid web address.");
        [self setHomepageFunc:googleDefaultURL];
    }
}

- (IBAction)setHomepage:(id)sender {
    
    if(self.homepageTextField.stringValue == nil || [self.homepageTextField.stringValue isEqual:@""]) {
        // Homepage is not set -- revert to default
        
        [self setHomepageFunc:googleDefaultURL];
    } else {
        
        homepageString = self.homepageTextField.stringValue;
        
        [self setHomepageFunc:homepageString];
    }
}

- (IBAction)newTab:(id)sender {
    
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
        websiteURL = [[[[frame provisionalDataSource] request] URL] absoluteString];
        self.reloadBtn.image = [NSImage imageNamed: NSImageNameStopProgressTemplate];
        [self.addressBar setStringValue:websiteURL];
        self.faviconImage.hidden = YES;
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimation:self];
        
        // Use Google to get website favicons
        faviconURLString = [NSString stringWithFormat:@"https://www.google.com/s2/favicons?domain=%@", websiteURL];
        faviconURL = [NSURL URLWithString: faviconURLString];
        faviconData = [NSData dataWithContentsOfURL:faviconURL];
        websiteFavicon = [[NSImage alloc] initWithData:faviconData];
        self.faviconImage.image = websiteFavicon;
        
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    // Only report feedback for the main frame.
    if (frame == [sender mainFrame]) {
        
        const int clipLength = 25;
        if([title length] > clipLength) {
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
