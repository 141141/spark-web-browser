//
//  AppDelegate.m
//  Spark
//
//  Copyright (c) 2014-2016 Jonathan Wukitsch / Insleep
//  This code is distributed under the terms and conditions of the GNU license.
//  You may copy, distribute and modify the software as long as you track changes/dates in source files. Any modifications to or software including (via compiler) GPL-licensed code must also be made available under the GPL along with build & install instructions.

#import "AppDelegate.h"
#import "WebKit/WebKit.h"
#import "NSUserDefaults+ColorSupport.h"
#import "Sparkle.framework/Headers/SUUpdater.h"

@interface AppDelegate () <NSTabViewDelegate>

@end

@implementation AppDelegate

@synthesize window;

#pragma mark - Declarations

// Search engine query strings
NSString *googleSearchString = @"https://www.google.com/search?q=%@";
NSString *bingSearchString = @"https://www.bing.com/search?q=%@";
NSString *yahooSearchString = @"https://search.yahoo.com/search?p=%@";
NSString *duckDuckGoSearchString = @"https://www.duckduckgo.com/%@";
NSString *askSearchString = @"http://www.ask.com/web?q=%@";
NSString *aolSearchString = @"https://search.aol.com/aol/search?q=%@";
NSString *customSearchString = nil;

// Search engine default homepages
NSString *googleDefaultURL = @"https://www.google.com/";
NSString *bingDefaultURL = @"https://www.bing.com/";
NSString *yahooDefaultURL = @"https://www.yahoo.com/";
NSString *duckDuckGoDefaultURL = @"https://www.duckduckgo.com/";
NSString *askDefaultURL = @"http://www.ask.com/";
NSString *aolDefaultURL = @"http://www.aol.com/";

// Strings for "Help" menu bar item
NSString *appIssuesURL = @"https://www.github.com/insleep/spark-web-browser/issues/new?title=Describe%20your%20feature%20request%20or%20bug%20report,%20succinctly&body=**Spark%20version:**%20%0A%20**Spark%20build:**%20%0A%20**Release%20channel:**%20%0A%20**macOS%20version:**%20%0A%0A%20**Description:**%20%0A%0A%20**Steps%20to%20reproduce:**%20%0A%0A%20**Expected%20results:**%20%0A%0A%20**Actual%20results:**%20";
NSString *appReleasesURL = @"https://www.github.com/insleep/spark-web-browser/releases/tag/%@/";

// Theme colors
NSColor *defaultColor = nil;
NSColor *rubyRedColor = nil;
NSColor *deepAquaColor = nil;
NSColor *midnightBlueColor = nil;
NSColor *redmondBlueColor = nil;
NSColor *leafGreenColor = nil;
NSColor *alloyOrangeColor = nil;
NSColor *canaryYellowColor = nil;
NSColor *darkGrayColor = nil;
NSData *customColorData = nil;

// General app setup
NSUserDefaults *defaults = nil; // Shortcut to [NSUserDefaults standardUserDefaults]
NSDictionary *infoDict = nil; // Spark Info.plist
NSDictionary *sv = nil; // macOS SystemVersion.plist
NSTask *task = nil; // NSTask used when switching release channels
NSMutableArray *args = nil; // Arguments used when switching release channels
NSTrackingArea *backBtnTrackingArea = nil; // Back button tracking area (used for hover effect)
NSTrackingArea *forwardBtnTrackingArea = nil; // Forward button tracking area (used for hover effect)
NSTrackingArea *reloadBtnTrackingArea = nil; // Reload button tracking area (used for hover effect)
NSTrackingArea *settingsBtnTrackingArea = nil; // Settings button tracking area (used for hover effect)
NSString *appVersion = nil; // Spark version number
NSString *buildNumber = nil; // Spark build number
NSString *macOSVersionString = nil; // macOS version number
NSString *macOSBuildString = nil; // macOS build number
NSString *macOSProductName = nil; // macOS product name
NSString *customMacOSProductName = nil; // Edited macOS product name
NSString *releaseChannel = nil; // Spark release channel
NSString *editedVersionString = nil; // Edited macOS version string
NSString *userAgent = nil; // Spark user agent, used when loading webpages
NSString *clippedTitle = nil; // Title used within the titleStatus string
NSString *suggestedFilename = nil; // Filename suggested when downloading files
NSString *clippedFilename = nil; // Suggested filename with ellipsis suffix
NSString *destinationFilename = nil; // Directory where downloaded files are stored
NSString *homeDirectory = nil; // User home directory
NSString *downloadLocation = nil; // Download location
NSString *downloadLocationEdited = nil; // Download location, edited to remove special characters
NSString *bytesReceivedFormatted = nil; // Bytes received (file download) (formatted)
NSString *expectedLengthFormatted = nil; // Expected length of file being downloaded (formatted)
long long expectedLength = 0; // Expected length of a file being downloaded
bool downloadOverride = NO; // Boolean for whether or not to download a file even if WebView can display it

// Objects related (somewhat) to loading webpages
NSString *searchString = nil; // String used when initiating a search query
NSString *homepageString = nil; // Current homepage chosen
NSString *urlString = nil; // Initial string to load a webpage from
NSString *editedURLString = nil; // Edited string to load a webpage from
NSString *capitalizedReleaseChannel = nil; // Spark release channel, including capital letters
NSString *uncapitalizedReleaseChannel = nil; // Spark release channel, not including capital letters
NSString *searchEngineChosen = nil; // Current search engine chosen
NSString *colorChosen = nil; // Current theme color stored in NSUserDefaults
NSString *urlToString = nil; // NSURL converted to a NSString, used when handling spark:// URL events
NSString *websiteURL = nil; // Current website URL, used when loading webpages
NSString *faviconURLString = nil; // URL for the service that retrieves favicons
NSURL *eventURL = nil; // Used when handling spark:// URL events
NSURL *faviconURL = nil; // NSURL converted from faviconURLString
NSURL *candidateURL = nil; // String value of addressBar as an NSURL
NSData *faviconData = nil; // Data retrieved from faviconURLString service
NSImage *websiteFavicon = nil; // Current website favicon, as an NSImage

#pragma mark - Pre-initializing

+ (void)initialize {
    defaults = [NSUserDefaults standardUserDefaults]; // Set up NSUserDefaults
    
    // Set up theme colors
    defaultColor = [NSColor colorWithRed:192.0f/255.0f green:192.0f/255.0f blue:192.0f/255.0f alpha:1.0f];
    rubyRedColor = [NSColor colorWithRed:0.773f green:0.231f blue:0.212f alpha:1.0f];
    deepAquaColor = [NSColor colorWithRed:46.0f/255.0f green:133.0f/255.0f blue:162.0f/255.0f alpha:1.0f];
    midnightBlueColor = [NSColor colorWithRed:26.0f/255.0f green:68.0f/255.0f blue:97.0f/255.0f alpha:1.0f];
    redmondBlueColor = [NSColor colorWithRed:16.0f/255.0f green:101.0f/255.0f blue:207.0f/255.0f alpha:1.0f];
    leafGreenColor = [NSColor colorWithRed:8.0f/255.0f green:157.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    alloyOrangeColor = [NSColor colorWithRed:200.0f/255.0f green:80.0f/255.0f blue:1.0f/255.0f alpha:1.0f];
    canaryYellowColor = [NSColor colorWithRed:253.0f/255.0f green:193.0f/255.0f blue:53.0f/255.0f alpha:1.0f];
    darkGrayColor = [NSColor colorWithRed:44.0f/255.0f green:44.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
    
    if([defaults objectForKey:@"currentReleaseChannel"] == nil) { // This is called in applicationDidFinishLaunching as well, but calling it here ensures it's properly set
        // No release channel is set -- revert to default
        NSLog(@"Error: no release channel is set. Setting now...");
        
        [defaults setObject:[NSString stringWithFormat:@"stable"] forKey:@"currentReleaseChannel"];
    }
    
    homeDirectory = NSHomeDirectory(); // Retrieve user home directory
    infoDict = [[NSBundle mainBundle] infoDictionary]; // Load Info.plist
    appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // Fetch the version number from Info.plist
    buildNumber = [infoDict objectForKey:@"CFBundleVersion"]; // Fetch the build number from Info.plist
    sv = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"]; // Load SystemVersion.plist
    macOSVersionString = [sv objectForKey:@"ProductVersion"]; // Get macOS version
    macOSBuildString = [sv objectForKey:@"ProductBuildVersion"]; // Get macOS build number
    macOSProductName = [sv objectForKey:@"ProductName"]; // Get macOS product name
    
    if([[NSProcessInfo processInfo] operatingSystemVersion].minorVersion < 12) { // Check whether or not user is running macOS 10.12 or later
        customMacOSProductName = @"OS X";
    } else {
        customMacOSProductName = @"macOS";
    }
    
    releaseChannel = [NSString stringWithFormat:@"%@", [defaults objectForKey:@"currentReleaseChannel"]]; // Get current release channel
    editedVersionString = [macOSVersionString stringByReplacingOccurrencesOfString:@"." withString:@"_"]; // Replace dots in version string with underscores
    userAgent = [NSString stringWithFormat:@"Mozilla/5.0 (Macintosh; Intel %@ %@) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.75 Safari/537.36 Spark/%@.%@", macOSProductName, editedVersionString, appVersion, buildNumber]; // Set user agent respective to the current versions of Spark and macOS
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    // Register for URL events
    
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

#pragma mark - Application initializing

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Finish initializing
    
    // Used for debugging purposes
    // NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    // [defaults removePersistentDomainForName:appDomain];
    
    // Set up WebView
    [self.webView setPolicyDelegate:(id<WebPolicyDelegate>)self];
    [self.webView setDownloadDelegate:(id<WebDownloadDelegate>)self];
    [self.webView setCustomUserAgent:userAgent];
    
    // NSUserDefaults key value checking
    if([defaults objectForKey:@"currentReleaseChannel"] == nil) {
        // No release channel is set -- revert to default
        NSLog(@"Error: no release channel is set. Setting now...");
        
        [defaults setObject:[NSString stringWithFormat:@"stable"] forKey:@"currentReleaseChannel"];
    }
    
    if([defaults objectForKey:@"releaseChannelIndex"] == nil) {
        // No release channel index is set -- revert to default
        NSLog(@"Error: no release channel index is set. Setting now...");
        
        [defaults setInteger:0 forKey:@"releaseChannelIndex"];
    }
    
    [self.releaseChannelPicker selectItemAtIndex:[defaults integerForKey:@"releaseChannelIndex"]];
    
    if([defaults objectForKey:@"currentSearchEngine"] == nil) {
        // No search engine is set -- revert to default
        NSLog(@"Error: no search engine is set. Setting now...");
        
        [defaults setObject:[NSString stringWithFormat:@"Google"] forKey:@"currentSearchEngine"];
    }
    
    if([defaults objectForKey:@"searchEngineIndex"] == nil) {
        // No search engine index is set -- revert to default
        NSLog(@"Error: no search engine index is set. Setting now...");
        
        [defaults setInteger:0 forKey:@"searchEngineIndex"];
    }
    
    [self.searchEnginePicker selectItemAtIndex:[defaults integerForKey:@"searchEngineIndex"]];
    
    if([defaults objectForKey:@"customSearchEngine"] == nil) {
        // A custom search engine is not set
        NSLog(@"Error: the value of \"customSearchEngine\" is nil. Setting now...");
        
        [defaults setObject:@"" forKey:@"customSearchEngine"];
        self.customSearchEngineField.hidden = YES;
        self.customSearchEngineSaveBtn.hidden = YES;
    }
    
    if([defaults objectForKey:@"currentColor"] == nil) {
        // No theme color is set -- revert to default
        NSLog(@"Error: no theme color is set. Setting now...");
        
        [defaults setObject:@"Default" forKey:@"currentColor"];
    }
    
    [self.topBarColorPicker selectItemWithTitle:[defaults objectForKey:@"currentColor"]];
    
    if([defaults objectForKey:@"currentDownloadLocation"] == nil) {
        // No download location is set -- revert to default
        NSLog(@"Error: no download location is set. Setting now...");
        
        [defaults setObject:[NSString stringWithFormat:@"%@/Downloads/", homeDirectory] forKey:@"currentDownloadLocation"];
    }
    
    [self.downloadLocTextField setStringValue:[defaults objectForKey:@"currentDownloadLocation"]];
    
    if([defaults objectForKey:@"startupWithLastSession"] == nil) {
        // No startup settings exist -- revert to default
        
        [defaults setBool:NO forKey:@"startupWithLastSession"];
        self.lastSessionRadioBtn.state = NSOffState;
        self.homepageRadioBtn.state = NSOnState;
    }
    
    // Check which radio button should be on (startup settings)
    if([defaults boolForKey:@"startupWithLastSession"] == YES) {
        self.lastSessionRadioBtn.state = NSOnState;
        self.homepageRadioBtn.state = NSOffState;
    } else {
        self.lastSessionRadioBtn.state = NSOffState;
        self.homepageRadioBtn.state = NSOnState;
    }
    
    // Homepage checking
    if([defaults objectForKey:@"userHomepage"] == nil || [[defaults objectForKey:@"userHomepage"] isEqual: @""]) {
        // Homepage is not set
        NSLog(@"Error: homepage is not set. Setting now...");
        
        // Default homepage
        [self setHomepageWithString:googleDefaultURL];
        
        if([defaults boolForKey:@"startupWithLastSession"] == NO) {
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [defaults valueForKey:@"userHomepage"]]]]];
        } else {
            if([defaults objectForKey:@"lastSession"] == nil || [[defaults objectForKey:@"lastSession"] isEqual: @""]) {
                [defaults setObject:[NSString stringWithFormat:@"%@", [defaults objectForKey:@"userHomepage"]] forKey:@"lastSession"];
            }
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [defaults valueForKey:@"lastSession"]]]]];
        }
        
    } else {
        // Homepage is set
        NSLog(@"Homepage is set. Continuing...");
        
        // User-set homepage
        self.homepageTextField.stringValue = [NSString stringWithFormat:@"%@", [defaults valueForKey:@"userHomepage"]];
        
        if([defaults boolForKey:@"startupWithLastSession"] == NO) {
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [defaults valueForKey:@"userHomepage"]]]]];
        } else {
            if([defaults objectForKey:@"lastSession"] == nil || [[defaults objectForKey:@"lastSession"] isEqual: @""]) {
                [defaults setObject:[NSString stringWithFormat:@"%@", [defaults objectForKey:@"userHomepage"]] forKey:@"lastSession"];
            }
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [defaults valueForKey:@"lastSession"]]]]];
        }
    }
    
    // Check if checkbox should be checked (setHomepageBtn)
    if([defaults boolForKey:@"setHomepageEngine"] == YES) {
        self.homepageBasedOnSearchEngineBtn.state = NSOnState;
        self.homepageTextField.enabled = NO;
        self.setHomepageBtn.enabled = NO;
    } else {
        self.homepageBasedOnSearchEngineBtn.state = NSOffState;
        self.homepageTextField.enabled = YES;
        self.setHomepageBtn.enabled = YES;
    }
    
    if([[defaults objectForKey:@"currentReleaseChannel"] isEqual: @"dev"]) { // Create fallback from "dev" channel for those migrating from previous versions
        NSLog(@"Resetting release channel to \"nightly\"");
        
        [defaults setObject:@"nightly" forKey:@"currentReleaseChannel"];
        [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"https://insleep.tech/spark/appcast-dev.xml"]];
    }
    
    if([[defaults objectForKey:@"currentReleaseChannel"] isEqual: @"stable"]) {
        [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"https://insleep.tech/spark/appcast.xml"]];
    } else if([[defaults objectForKey:@"currentReleaseChannel"] isEqual: @"beta"]) {
        [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"https://insleep.tech/spark/appcast-beta.xml"]];
    } else if([[defaults objectForKey:@"currentReleaseChannel"] isEqual: @"nightly"]) {
        [[SUUpdater sharedUpdater] setFeedURL:[NSURL URLWithString:@"https://insleep.tech/spark/appcast-dev.xml"]];
    }
    
    self.faviconImage.hidden = YES;
    self.loadingIndicator.hidden = NO;
    
    [self.loadingIndicator startAnimation:self];
    
    // Set strings
    self.currentVersion.stringValue = [NSString stringWithFormat:@"Version %@.%@", appVersion, buildNumber];
    self.currentReleaseChannel.stringValue = [NSString stringWithFormat:@"%@ release channel", [releaseChannel capitalizedString]];
    
    // Window setup
    self.aboutWindow.backgroundColor = [NSColor whiteColor];
    self.errorWindow.backgroundColor = [NSColor whiteColor];
    self.popupWindow.backgroundColor = [NSColor whiteColor];
    self.settingsWindow.backgroundColor = [NSColor whiteColor];
    self.configWindow.backgroundColor = [NSColor whiteColor];
    
    // Check experimental configuration settings
    [self checkExperimentalConfig:nil];
    
    // Set up tracking areas
    backBtnTrackingArea = [[NSTrackingArea alloc] initWithRect:[self.backBtn bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    forwardBtnTrackingArea = [[NSTrackingArea alloc] initWithRect:[self.forwardBtn bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    reloadBtnTrackingArea = [[NSTrackingArea alloc] initWithRect:[self.reloadBtn bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    settingsBtnTrackingArea = [[NSTrackingArea alloc] initWithRect:[self.settingsBtn bounds] options:NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways owner:self userInfo:nil];
    
    [self.backBtn addTrackingArea:backBtnTrackingArea];
    [self.forwardBtn addTrackingArea:forwardBtnTrackingArea];
    [self.reloadBtn addTrackingArea:reloadBtnTrackingArea];
    [self.settingsBtn addTrackingArea:settingsBtnTrackingArea];
    
    // Check whether or not a custom search engine is in use
    if([[defaults objectForKey:@"customSearchEngine"] isEqual: @""]) {
        self.customSearchEngineField.hidden = YES;
        self.customSearchEngineSaveBtn.hidden = YES;
    }
    
    // Check whether or not WebKit developer menus are enabled
    if([defaults boolForKey:@"WebKitDeveloperExtras"] != YES) {
        [defaults setBool:YES forKey:@"WebKitDeveloperExtras"]; // Turn on developer menus
    }
    
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Navy Blue"]) { // Create fallback from "Navy Blue" -> "Midnight Blue" for those migrating from previous versions
        NSLog(@"Resetting theme color to \"Midnight Blue\"");
        
        [defaults setObject:[NSString stringWithFormat:@"Midnight Blue"] forKey:@"currentColor"];
    }
    
    // Get key value from NSUserDefaults and set theme color
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to default color
        self.window.backgroundColor = defaultColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Ruby Red"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Ruby Red
        self.window.backgroundColor = rubyRedColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Deep Aqua"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Deep Aqua
        self.window.backgroundColor = deepAquaColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Midnight Blue"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Midnight Blue
        self.window.backgroundColor = midnightBlueColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Redmond Blue"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Redmond Blue
        self.window.backgroundColor = redmondBlueColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Leaf Green"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Leaf Green
        self.window.backgroundColor = leafGreenColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Alloy Orange"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Alloy Orange
        self.window.backgroundColor = alloyOrangeColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Canary Yellow"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Canary Yellow
        self.window.backgroundColor = canaryYellowColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to dark gray
        self.window.backgroundColor = darkGrayColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([defaults objectForKey:@"customColor"] != nil) {
        
        self.customColorWell.hidden = NO;
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
        // Set window color to a custom color
        self.window.backgroundColor = [defaults colorForKey:@"customColor"];
    }
    
    if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Custom"]) {
        self.customSearchEngineField.stringValue = [defaults objectForKey:@"customSearchEngine"];
        
        self.homepageBasedOnSearchEngineBtn.state = NSOffState;
        self.homepageBasedOnSearchEngineBtn.enabled = NO;
        self.customSearchEngineField.hidden = NO;
        self.customSearchEngineSaveBtn.hidden = NO;
        self.homepageTextField.enabled = YES;
        self.setHomepageBtn.enabled = YES;
    } else {
        if([defaults boolForKey:@"setHomepageEngine"] == YES) {
            self.homepageBasedOnSearchEngineBtn.state = NSOnState;
            self.homepageBasedOnSearchEngineBtn.enabled = YES;
            self.setHomepageBtn.enabled = NO;
            self.homepageTextField.enabled = NO;
        }
        
        self.customSearchEngineField.hidden = YES;
        self.customSearchEngineSaveBtn.hidden = YES;
    }
}

#pragma mark - IBActions

- (IBAction)setCustomColor:(id)sender {
    // Set window color to a custom color
    self.window.backgroundColor = self.customColorWell.color;
    
    [defaults setColor:self.customColorWell.color forKey:@"customColor"];
}

- (IBAction)reportIssueAboutWindow:(id)sender {
    
    [self.aboutWindow close];
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:appIssuesURL]]];
    self.addressBar.stringValue = appIssuesURL;
}

- (IBAction)closeDownloadingView:(id)sender {
    
    self.downloadProgressIndicator.hidden = YES;
    self.bytesDownloadedText.hidden = YES;
    self.downloadingViewBg.hidden = YES;
    self.fileDownloadingText.hidden = YES;
    self.closeDownloadingViewBtn.hidden = YES;
    self.fileDownloadStatusIcon.hidden = YES;
}

- (IBAction)saveCustomSearchEngine:(id)sender {
    
    if([self.customSearchEngineField.stringValue isEqual: @""] || [self.customSearchEngineField.stringValue isEqual: nil]) {
        // Text field is empty
        NSLog(@"Error: custom search engine text field is empty.");
        
        self.errorPanelTitle.stringValue = @"Error";
        self.errorPanelText.stringValue = [NSString stringWithFormat:@"An error occurred: you did not enter any text. Please enter a valid URL and try again."];
        self.errorWindow.isVisible = YES;
        [self.errorWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        
    } else if([self.customSearchEngineField.stringValue hasPrefix:@"http://"] || [self.customSearchEngineField.stringValue hasPrefix:@"https://"]) {
        [self saveCustomSearchEngineText:self];
    } else {
        // String is not a URL
        NSLog(@"Error: custom search engine text field does not contain a URL.");
        
        self.errorPanelTitle.stringValue = @"Error";
        self.errorPanelText.stringValue = [NSString stringWithFormat:@"An error occurred: the text you entered is not a valid URL. Please enter a valid URL and try again."];
        self.errorWindow.isVisible = YES;
        [self.errorWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (IBAction)savePage:(id)sender {
    
    downloadOverride = YES;
    NSLog(@"Downloads overridden. Starting download...");
    [[self.webView mainFrame] reload];
}

- (IBAction)lastSessionRadioBtnSelected:(id)sender {
    
    NSLog(@"Startup setting changed: now starting with last session.");
    
    [defaults setBool:YES forKey:@"startupWithLastSession"];
    self.lastSessionRadioBtn.state = NSOnState;
    self.homepageRadioBtn.state = NSOffState;
}

- (IBAction)homepageRadioBtnSelected:(id)sender {
    
    NSLog(@"Startup setting changed: now starting with homepage.");
    
    [defaults setBool:NO forKey:@"startupWithLastSession"];
    self.homepageRadioBtn.state = NSOnState;
    self.lastSessionRadioBtn.state = NSOffState;
}

- (IBAction)setReleaseChannelBtnClicked:(id)sender {
    
    task = [[NSTask alloc] init];
    args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep %d; open \"%@\"", 0, [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction)useAboutPage:(id)sender {
    
    if(self.useAboutPageBtn.state == NSOnState) {
        NSLog(@"Now using spark://about webpage.");
        
        [defaults setBool:YES forKey:@"useSparkAboutPage"];
    } else {
        NSLog(@"Now using Spark About window.");
        
        [defaults setBool:NO forKey:@"useSparkAboutPage"];
    }
}

- (IBAction)openAboutWindow:(id)sender {
    
    if([defaults boolForKey:@"useSparkAboutPage"] == YES) {
        
        NSLog(@"Loading spark-about.html...");
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-about" ofType:@"html"] isDirectory:NO]]];
        
        self.addressBar.stringValue = @"spark://about";
    } else {
        NSLog(@"Opening About window...");
        
        self.aboutWindow.isVisible = YES;
        [self.aboutWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (IBAction)setTopBarColor:(id)sender {
    
    NSLog(@"Setting theme color...");
    
    colorChosen = [NSString stringWithFormat:@"%@", self.topBarColorPicker.titleOfSelectedItem];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", colorChosen] forKey:@"currentColor"];
    
    if([[defaults objectForKey:@"currentColor"] isEqual: @"Default"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to default color
        self.window.backgroundColor = defaultColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Ruby Red"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Ruby Red
        self.window.backgroundColor = rubyRedColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Deep Aqua"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Deep Aqua
        self.window.backgroundColor = deepAquaColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Midnight Blue"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Midnight Blue
        self.window.backgroundColor = midnightBlueColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Redmond Blue"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Redmond Blue
        self.window.backgroundColor = redmondBlueColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Leaf Green"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Leaf Green
        self.window.backgroundColor = leafGreenColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Alloy Orange"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Alloy Orange
        self.window.backgroundColor = alloyOrangeColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Canary Yellow"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to Canary Yellow
        self.window.backgroundColor = canaryYellowColor;
        
        // Still set color in NSColorWell in case user wants it later
        self.customColorWell.color = [defaults colorForKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Dark Gray"]) {
        
        self.customColorWell.hidden = YES;
        
        // Set window color to dark gray
        self.window.backgroundColor = darkGrayColor;
        
        // Still store color in NSColorWell in case user wants it later
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
        
    } else if([[defaults objectForKey:@"currentColor"] isEqual: @"Custom"]) {
        
        self.customColorWell.hidden = NO;
        
        // Set window color to a custom color
        self.window.backgroundColor = self.customColorWell.color;
        
        [defaults setColor:self.customColorWell.color forKey:@"customColor"];
    }
}

- (IBAction)startSettingHomepageBasedOnSearchEngine:(id)sender {
    
    if([self.homepageBasedOnSearchEngineBtn state] == NSOnState) {
        // On
        
        [defaults setBool:YES forKey:@"setHomepageEngine"];
        self.homepageTextField.enabled = NO;
        self.setHomepageBtn.enabled = NO;
        [self setHomepageBasedOnSearchEngine:self];
        
    } else if([self.homepageBasedOnSearchEngineBtn state] == NSOffState) {
        // Off
        
        [defaults setBool:NO forKey:@"setHomepageEngine"];
        self.homepageTextField.enabled = YES;
        self.setHomepageBtn.enabled = YES;
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
    
    if(![self.searchEnginePicker.titleOfSelectedItem isEqual: @"Custom"]) {
        NSLog(@"Setting search engine...");
        
        searchEngineChosen = [NSString stringWithFormat:@"%@", self.searchEnginePicker.titleOfSelectedItem];
        
        [defaults setObject:[NSString stringWithFormat:@"%@", searchEngineChosen] forKey:@"currentSearchEngine"];
        [defaults setInteger:self.searchEnginePicker.indexOfSelectedItem forKey:@"searchEngineIndex"];
        
        self.customSearchEngineField.hidden = YES;
        self.customSearchEngineSaveBtn.hidden = YES;
        
        if([defaults boolForKey:@"setHomepageEngine"] == YES) {
            self.homepageBasedOnSearchEngineBtn.state = NSOnState;
            self.homepageBasedOnSearchEngineBtn.enabled = YES;
            self.setHomepageBtn.enabled = NO;
            self.homepageTextField.enabled = NO;
        } else {
            self.homepageBasedOnSearchEngineBtn.state = NSOffState;
            self.homepageBasedOnSearchEngineBtn.enabled = YES;
            self.setHomepageBtn.enabled = YES;
            self.homepageTextField.enabled = YES;
        }
        
    } else if([self.searchEnginePicker.titleOfSelectedItem isEqual:@"Custom"]) {
        
        self.customSearchEngineField.stringValue = [defaults objectForKey:@"customSearchEngine"];
        
        if([defaults objectForKey:@"customSearchEngine"] != nil) {
            if([[defaults objectForKey:@"customSearchEngine"] hasPrefix:@"http://"] || [[defaults objectForKey:@"customSearchEngine"]  hasPrefix:@"https://"]) {
                [self saveCustomSearchEngineText:self];
                [defaults setBool:NO forKey:@"setHomepageEngine"];
                self.homepageBasedOnSearchEngineBtn.state = NSOffState;
                self.homepageBasedOnSearchEngineBtn.enabled = NO;
                self.homepageTextField.enabled = YES;
                self.setHomepageBtn.enabled = YES;
            }
        }
        
        self.customSearchEngineField.hidden = NO;
        self.customSearchEngineSaveBtn.hidden = NO;
    }
    
    // Check whether or not to override homepage
    if([defaults boolForKey:@"setHomepageEngine"] == YES) {
        
        NSLog(@"Setting homepage based on search engine");
        
        [self setHomepageBasedOnSearchEngine:self];
    }
}

- (IBAction)initWebpageLoad:(id)sender {
    
    candidateURL = [NSURL URLWithString:self.addressBar.stringValue]; // String value of addressBar converted to an NSURL
    
    searchString = self.addressBar.stringValue; // String value of addressBar
    
    if([searchString hasPrefix:@"https://"]) {
        
        if(candidateURL && candidateURL.scheme && candidateURL.host) {
            
            NSLog(@"URL is valid. Loading HTTPS webpage...");
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:candidateURL]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", searchString];
        }
        
    } else if([searchString hasPrefix:@"http://"]) {
        
        if(candidateURL && candidateURL.scheme && candidateURL.host) {
            
            NSLog(@"URL is valid. Loading HTTP webpage...");
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:candidateURL]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", searchString];
            
            /*NSCachedURLResponse *urlResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) urlResponse.response;
            NSInteger statusCode = httpResponse.statusCode;
            if (statusCode > 399) {
                NSError *error = [NSError errorWithDomain:@"HTTP Error" code:httpResponse.statusCode userInfo:@{@"response":httpResponse}];
                // Forward the error to webView:didFailLoadWithError: or other
            }
            else {
                // No HTTP error
            }*/
        }
        
    } else if([searchString hasPrefix:@"file://"]) {
        NSLog(@"file:// prefix");
    } else if([searchString hasPrefix:@"spark://"]) {
        
        NSLog(@"spark:// prefix");
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:candidateURL]];
        self.addressBar.stringValue = [NSString stringWithFormat:@"%@", searchString];
    } else {
        
        NSLog(@"User has initiated a search. Fetching search engine...");
        
        if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
            
            // Google search initiated
            
            NSLog(@"Search engine found: Google");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:googleSearchString, searchString];
            
            // Replace special characters
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
            
            // Bing search initiated
            
            NSLog(@"Search engine found: Bing");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:bingSearchString, searchString];
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
            
            // Yahoo! search initiated
            
            NSLog(@"Search engine found: Yahoo!");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:yahooSearchString, searchString];
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
            
            // DuckDuckGo search initiated
            
            NSLog(@"Search engine found: DuckDuckGo");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:duckDuckGoSearchString, searchString];
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Ask"]) {
            
            // Ask search initiated
            
            NSLog(@"Search engine found: Ask");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:askSearchString, searchString];
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"AOL"]) {
            
            // AOL search initiated
            
            NSLog(@"Search engine found: AOL");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:aolSearchString, searchString];
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Custom"]) {
            
            // Search with custom engine initiated
            
            NSLog(@"Search engine found: Custom");
            
            searchString = [searchString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            
            urlString = [NSString stringWithFormat:[defaults objectForKey:@"customSearchEngine"], searchString];
            editedURLString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", editedURLString]]]];
            self.addressBar.stringValue = [NSString stringWithFormat:@"%@", editedURLString];
            
        }
        
        [defaults setObject:[NSString stringWithFormat:@"%@", self.addressBar.stringValue] forKey:@"lastSession"];
    }
}

- (IBAction)setReleaseChannel:(id)sender {
    
    NSLog(@"Setting release channel...");
    
    capitalizedReleaseChannel = [NSString stringWithFormat:@"%@", self.releaseChannelPicker.titleOfSelectedItem];
    uncapitalizedReleaseChannel = [capitalizedReleaseChannel lowercaseString];
    
    [defaults setObject:[NSString stringWithFormat:@"%@", uncapitalizedReleaseChannel] forKey:@"currentReleaseChannel"];
    [defaults setInteger:self.releaseChannelPicker.indexOfSelectedItem forKey:@"releaseChannelIndex"];
    
    self.popupWindowText.stringValue = [NSString stringWithFormat:@"Spark release channel will be set to: %@.\n\nA browser restart is required for this to take effect.", uncapitalizedReleaseChannel];
    self.popupWindow.isVisible = YES;
    [self.popupWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (IBAction)setHomepage:(id)sender {
    
    if(self.homepageTextField.stringValue == nil || [self.homepageTextField.stringValue isEqual:@""]) {
        // Homepage is not set -- revert to default
        
        [self setHomepageWithString:googleDefaultURL];
    } else {
        
        homepageString = self.homepageTextField.stringValue;
        
        [self setHomepageWithString:homepageString];
    }
}

- (IBAction)setDownloadLocation:(id)sender {
    
    // Show an 'Open' dialog box allowing save folder selection.
    NSOpenPanel *open = [NSOpenPanel openPanel];
    [open setCanChooseFiles:NO];
    [open setAllowsMultipleSelection:NO];
    [open setCanChooseDirectories:YES];
    [open setCanCreateDirectories:YES];
    [open setTitle:@"Select Download Location"];
    [open setPrompt:@"Select"];
    [open runModal];
    
    if(NSFileHandlingPanelOKButton) {
        downloadLocation = [[NSString stringWithFormat:@"%@", [open URL]] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        downloadLocationEdited = [downloadLocation stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
        
        [defaults setObject:downloadLocationEdited forKey:@"currentDownloadLocation"];
        [self.downloadLocTextField setStringValue:[defaults objectForKey:@"currentDownloadLocation"]];
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

#pragma mark - Various methods

- (void)checkExperimentalConfig:(id)sender {
    
    // Check if checkbox should be checked (spark://config - "Use spark://about webpage")
    if([defaults boolForKey:@"useSparkAboutPage"] == YES) {
        self.useAboutPageBtn.state = NSOnState;
    } else {
        self.useAboutPageBtn.state = NSOffState;
    }
}

- (void)saveCustomSearchEngineText:(id)sender {
    
    if([self.customSearchEngineField.stringValue containsString:@"\%@"]) {
        
        NSLog(@"Saving custom search engine...");
        
        customSearchString = [NSString stringWithFormat:@"%@", self.customSearchEngineField.stringValue];
        
        [defaults setObject:[NSString stringWithFormat:@"Custom"] forKey:@"currentSearchEngine"];
        [defaults setObject:[NSString stringWithFormat:@"%@", customSearchString] forKey:@"customSearchEngine"];
        [defaults setInteger:self.searchEnginePicker.indexOfSelectedItem forKey:@"searchEngineIndex"];
        
        if([defaults boolForKey:@"setHomepageEngine"] == YES) {
            
            [defaults setBool:NO forKey:@"setHomepageEngine"];
            self.homepageBasedOnSearchEngineBtn.state = NSOffState;
            self.homepageBasedOnSearchEngineBtn.enabled = NO;
            self.homepageTextField.enabled = YES;
            self.setHomepageBtn.enabled = YES;
        } else {
            self.homepageBasedOnSearchEngineBtn.state = NSOffState;
            self.homepageBasedOnSearchEngineBtn.enabled = NO;
            self.homepageTextField.enabled = YES;
            self.setHomepageBtn.enabled = YES;
        }
        
    } else {
        // Text field does not contain query text.
        NSLog(@"Error: custom search engine text field does not contain query text.");
        
        self.errorPanelTitle.stringValue = @"Error";
        self.errorPanelText.stringValue = [NSString stringWithFormat:@"An error occurred: the text you entered is not a valid URL. Please enter a valid URL and try again."];
        self.errorWindow.isVisible = YES;
        [self.errorWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)setHomepageBasedOnSearchEngine:(id)sender {
    if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Google"]) {
        
        // Set homepage to Google
        [self setHomepageWithString:googleDefaultURL];
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Bing"]) {
        
        // Set homepage to Bing
        [self setHomepageWithString:bingDefaultURL];
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Yahoo!"]) {
        
        // Set homepage to Yahoo!
        [self setHomepageWithString:yahooDefaultURL];
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"DuckDuckGo"]) {
        
        // Set homepage to DuckDuckGo
        [self setHomepageWithString:duckDuckGoDefaultURL];
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"Ask"]) {
        
        // Set homepage to Ask
        [self setHomepageWithString:askDefaultURL];
        
    } else if([[defaults objectForKey:@"currentSearchEngine"] isEqual: @"AOL"]) {
        
        // Set homepage to AOL
        [self setHomepageWithString:aolDefaultURL];
    }
}

- (void)setHomepageWithString:(NSString *)homepageToSet {
    
    if([homepageToSet hasPrefix:@"https://"] || [homepageToSet hasPrefix:@"http://"]) { // Valid address
        NSLog(@"Setting homepage...");
        [defaults setObject:[NSString stringWithFormat:@"%@", homepageToSet] forKey:@"userHomepage"];
        self.homepageTextField.stringValue = [defaults objectForKey:@"userHomepage"];
    } else { // Invalid address
        NSLog(@"Homepage not set: invalid web address.");
        [self setHomepageWithString:googleDefaultURL];
    }
}

- (void)settingsMenuClicked:(id)sender {
    [[self.settingsPopupBtn cell] performClickWithFrame:[sender frame] inView:[sender superview]];
}

#pragma mark - URL event handling

- (void)handleGetURLEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    // Handle spark:// URL events
    
    eventURL = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    urlToString = [eventURL absoluteString];
    if([urlToString isEqual: @"spark://about"] || [urlToString isEqual: @"spark://spark"]) {
        // spark://about || spark://spark called
        
        if([defaults boolForKey:@"useSparkAboutPage"] == YES) {
            
            NSLog(@"spark://about || spark://spark called. Loading spark-about.html...");
            
            [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-about" ofType:@"html"] isDirectory:NO]]];
            
            self.addressBar.stringValue = @"spark://about";
        } else {
            NSLog(@"spark://about || spark://spark called. Opening About window...");
            
            self.aboutWindow.isVisible = YES;
            [self.aboutWindow makeKeyAndOrderFront:nil];
            [NSApp activateIgnoringOtherApps:YES];
        }
        
    } else if([urlToString isEqual: @"spark://version"] || [urlToString isEqual:@"spark://currentversion"]) {
        // spark://version || spark://currentversion called
        
        NSLog(@"spark://version || spark://currentversion called. Loading spark-version.html...");
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-version" ofType:@"html"] isDirectory:NO]]];
        
        self.addressBar.stringValue = @"spark://version";
        
    } else if([urlToString isEqual: @"spark://prefs"] || [urlToString isEqual: @"spark://preferences"] || [urlToString isEqual: @"spark://settings"]) {
        // spark://prefs || spark://preferences || spark://settings called
        
        NSLog(@"spark://prefs || spark://preferences || spark://settings called. Loading...");
        
        self.settingsWindow.isVisible = YES;
        [self.settingsWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        
        self.addressBar.stringValue = self.webView.mainFrameURL;
        
    } else if([urlToString isEqual: @"spark://config"]) {
        // spark://config called
        
        NSLog(@"spark://config called. Opening Configuration window...");
        
        self.configWindow.isVisible = YES;
        [self.configWindow makeKeyAndOrderFront:nil];
        [NSApp activateIgnoringOtherApps:YES];
        
        self.addressBar.stringValue = self.webView.mainFrameURL;
        
    } else if([urlToString isEqual: @"spark://quit"]) {
        // spark://quit called
        
        NSLog(@"spark://quit called. Quitting...");
        
        [[NSApplication sharedApplication] terminate:nil];
        
    } else if([urlToString isEqual: @"spark://restart"]) {
        // spark://restart called
        
        NSLog(@"spark://restart called. Restarting...");
        
        task = [[NSTask alloc] init];
        args = [NSMutableArray array];
        [args addObject:@"-c"];
        [args addObject:[NSString stringWithFormat:@"sleep %d; open \"%@\"", 0, [[NSBundle mainBundle] bundlePath]]];
        [task setLaunchPath:@"/bin/sh"];
        [task setArguments:args];
        [task launch];
        
        [[NSApplication sharedApplication] terminate:nil];
        
    } else if([urlToString isEqual: @"spark://refresh"] || [urlToString isEqual: @"spark://reload"]) {
        // spark://refresh || spark://reload called
        
        NSLog(@"spark://refresh || spark://reload called. Refreshing webpage...");
        
        [[self.webView mainFrame] reload];
        
        self.addressBar.stringValue = self.webView.mainFrameURL;
        
    } else if([urlToString isEqual: @"spark://back"] || [urlToString isEqual: @"spark://goback"] || [urlToString isEqual: @"spark://previouspage"]) {
        // spark://back || spark://goback || spark://previouspage called
        
        NSLog(@"spark://back || spark://goback || spark://previouspage called. Loading...");
        
        [self.webView goBack:nil];
        
        self.addressBar.stringValue = self.webView.mainFrameURL;
        
    } else if([urlToString isEqual: @"spark://forward"] || [urlToString isEqual: @"spark://goforward"] || [urlToString isEqual: @"spark://nextpage"]) {
        // spark://forward || spark://goforward || spark://nextpage called
        
        NSLog(@"spark://forward || spark://goforward || spark://nextpage called. Loading...");
        
        [self.webView goForward:nil];
        
        self.addressBar.stringValue = self.webView.mainFrameURL;
        
    } else if([urlToString isEqual: @"spark://newtab"] || [urlToString isEqual: @"spark://addtab"]) {
        // spark://newtab || spark://addtab called
        
        NSLog(@"spark://newtab || spark://addtab called. Loading...");
        
        [self newTab:nil];
        
        self.addressBar.stringValue = self.webView.mainFrameURL;
        
    } else if([urlToString isEqual: @"spark://urls"] || [urlToString isEqual: @"spark://spark-urls"]) {
        // spark://urls || spark://spark-urls called
        
        NSLog(@"spark://urls || spark://spark-urls called. Loading spark-urls.html...");
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-urls" ofType:@"html"] isDirectory:NO]]];
        
        self.addressBar.stringValue = @"spark://urls";
        
    } else if([urlToString isEqual: @"spark://checkforupdates"] || [urlToString isEqual: @"spark://update"] || [urlToString isEqual:@"spark://updates"]) {
        // spark://checkforupdates || spark://update || spark://updates called
        
        NSLog(@"spark://checkforupdates || spark://update || spark://updates called. Checking for updates...");
        
        [[SUUpdater sharedUpdater] checkForUpdates:nil];
        
    } else if([urlToString isEqual: @"spark://reportissue"] || [urlToString isEqual: @"spark://reportanissue"] || [urlToString isEqual: @"spark://issue"] || [urlToString isEqual: @"spark://issues"]) {
        // spark://reportissue || spark://reportanissue || spark://issue || spark://issues called
        
        NSLog(@"spark://reportissue || spark://reportanissue || spark://issue || spark://issues called. Loading...");
        
        [self reportIssue:nil];
        
    } else if([urlToString isEqual: @"spark://releasenotes"]) {
        // spark://releasenotes called
        
        NSLog(@"spark://releasenotes called. Loading...");
        
        [self viewReleaseNotes:nil];
        
    } else if([urlToString hasPrefix: @"spark://"] || [urlToString hasPrefix: @"spark:"]) {
        // Invalid spark:// URL
        
        NSLog(@"Error: invalid spark:// URL. Loading spark-invalid-url.html...");
        
        [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]                                                                           pathForResource:@"spark-invalid-url" ofType:@"html"] isDirectory:NO]]];
        
        self.addressBar.stringValue = searchString;
        
        self.titleStatus.stringValue = [NSString stringWithFormat:@"%@ is not available", searchString];
    }
}

- (void)mouseEntered:(NSEvent *)theEvent {
    // Mouse entered tracking area
    
    if([[theEvent trackingArea] isEqual:backBtnTrackingArea]) {
        [[self.backBtn cell] setBackgroundColor:[NSColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
    } else if([[theEvent trackingArea] isEqual:forwardBtnTrackingArea]) {
        [[self.forwardBtn cell] setBackgroundColor:[NSColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
    } else if([[theEvent trackingArea] isEqual:reloadBtnTrackingArea]) {
        [[self.reloadBtn cell] setBackgroundColor:[NSColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
    } else if([[theEvent trackingArea] isEqual:settingsBtnTrackingArea]) {
        [[self.settingsBtn cell] setBackgroundColor:[NSColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    // Mouse exited tracking area
    
    [[self.backBtn cell] setBackgroundColor:[NSColor whiteColor]];
    [[self.forwardBtn cell] setBackgroundColor:[NSColor whiteColor]];
    [[self.reloadBtn cell] setBackgroundColor:[NSColor whiteColor]];
    [[self.settingsBtn cell] setBackgroundColor:[NSColor whiteColor]];
}

#pragma mark - WebView download handling

- (void)webView:(WebView *)sender decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    if([[sender class] canShowMIMEType:type]) {
        if(downloadOverride == YES) {
            // Download file anyway, even if WebView can display it
            [listener download];
            
            // Reset downloadOverride
            downloadOverride = NO;
        } else {
            // WebView says it can show these files
            [listener use];
        }
    } else {
        // WebView can't display these files -- start a download
        [listener download];
    }
}

- (void)downloadDidBegin:(NSURLDownload *)download {
    NSLog(@"File download started.");
    
    // Don't show loading indicator during this time
    [self.loadingIndicator stopAnimation:self];
    self.loadingIndicator.hidden = YES;
    self.faviconImage.hidden = NO;
    
    // Show downloads view
    self.downloadProgressIndicator.hidden = NO;
    self.bytesDownloadedText.hidden = NO;
    self.downloadingViewBg.hidden = NO;
    self.fileDownloadingText.hidden = NO;
    self.closeDownloadingViewBtn.hidden = NO;
    self.fileDownloadStatusIcon.hidden = YES;
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(unsigned)length {
    NSLog(@"%@", [NSString stringWithFormat:@"Downloading file data: %@", bytesReceivedFormatted]);
    self.bytesReceived = self.bytesReceived + length;
    
    if(expectedLength != NSURLResponseUnknownLength) {
        
        // If the expected content length is available, display percent complete.
        double percentComplete = (self.bytesReceived / (float)expectedLength) * 100.0;
        [self.downloadProgressIndicator setDoubleValue:percentComplete];
        
        bytesReceivedFormatted = [NSByteCountFormatter stringFromByteCount:self.bytesReceived countStyle:NSByteCountFormatterCountStyleFile];
        expectedLengthFormatted = [NSByteCountFormatter stringFromByteCount:expectedLength countStyle:NSByteCountFormatterCountStyleFile];
        
        [self.bytesDownloadedText setStringValue:[NSString stringWithFormat:@"%@/%@", bytesReceivedFormatted, expectedLengthFormatted]];
        
        const int clipLength = 20;
        if([suggestedFilename length] > clipLength) {
            clippedFilename = [NSString stringWithFormat:@"%@...", [suggestedFilename substringToIndex:clipLength]];
            self.fileDownloadingText.stringValue = [NSString stringWithFormat:@"%@", clippedFilename];
        } else {
            self.fileDownloadingText.stringValue = [NSString stringWithFormat:@"%@", suggestedFilename];
        }
    } else {
        // If the expected content length is unknown, log the process and update the indicators without a known length.
        NSLog(@"Bytes received: %ld", self.bytesReceived);
        [self.bytesDownloadedText setStringValue:[NSString stringWithFormat:@"%ld/%ld bytes", self.bytesReceived, self.bytesReceived]];
    }
    
    if([self.downloadProgressIndicator doubleValue] == 100 || self.bytesReceived == expectedLength) {
        // File download complete
        
        NSLog(@"File download complete.");
        
        if([self.fileDownloadingText.stringValue isEqual: @"Downloading file..."]) {
            self.fileDownloadingText.stringValue = @"Download complete.";
        }
        
        [self.downloadProgressIndicator stopAnimation:self];
        self.downloadProgressIndicator.doubleValue = 0;
        [self.loadingIndicator stopAnimation:self];
        self.reloadBtn.image = [NSImage imageNamed:NSImageNameRefreshTemplate];
        self.loadingIndicator.hidden = YES;
        self.faviconImage.hidden = NO;
        self.fileDownloadStatusIcon.hidden = NO;
        
        // Bounce dock icon to let user know that the download is complete
        [NSApp requestUserAttention:NSInformationalRequest];
    }
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response {
    suggestedFilename = [response suggestedFilename];
    
    // Reset the progress, this might be called multiple times.
    // bytesReceived is an instance variable defined elsewhere.
    self.bytesReceived = 0;
    
    // Store the response to use later.
    expectedLength = [response expectedContentLength];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error {
    // File download failed
    
    NSLog(@"File download failed! Error: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [self.bytesDownloadedText setStringValue:@"Download Failed"];
    
    self.errorPanelTitle.stringValue = @"Error Downloading File";
    self.errorPanelText.stringValue = [NSString stringWithFormat:@"An error occurred while downloading the file you requested.\n\nError: %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]];
    self.errorWindow.isVisible = YES;
    [self.errorWindow makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename {
    
    // For future option to ask where to save each file before downloading
    /*if(downloadOverride == YES) {
     NSSavePanel *panel = [NSSavePanel savePanel];
     
     if([panel runModalForDirectory:nil file:suggestedFilename] == NSFileHandlingPanelCancelButton) {
     // If the user doesn't want to save, cancel the download.
     [download cancel];
     downloadOverride = NO;
     } else {
     // Set the destination to save to.
     [download setDestination:[panel filename] allowOverwrite:YES];
     downloadOverride = NO;
     }
     } else {
     destinationFilename = [NSString stringWithFormat:@"%@%@", [defaults objectForKey:@"currentDownloadLocation"], suggestedFilename];
     
     [download setDestination:destinationFilename allowOverwrite:NO];
     }*/
    
    destinationFilename = [NSString stringWithFormat:@"%@%@", [defaults objectForKey:@"currentDownloadLocation"], suggestedFilename];
    
    [download setDestination:destinationFilename allowOverwrite:NO];
}

#pragma mark - WebView loading-related methods

- (void)webView:(WebView *)sender decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener {
    
    NSLog(@"Website is attempting to open a new tab/window. Loading webpage...");
    
    [[self.webView mainFrame] loadRequest:[NSURLRequest requestWithURL:request.URL]];
    self.addressBar.stringValue = [NSString stringWithFormat:@"%@", request.URL];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    
    // Only report feedback for the main frame.
    if(frame == [sender mainFrame]) {
        websiteURL = [[[[frame provisionalDataSource] request] URL] absoluteString];
        self.reloadBtn.image = [NSImage imageNamed:NSImageNameStopProgressTemplate];
        [self.addressBar setStringValue:websiteURL];
        self.faviconImage.hidden = YES;
        self.loadingIndicator.hidden = NO;
        [self.loadingIndicator startAnimation:self];
        
        // Use Google to get website favicons
        // In the future, the app should be able to detect a favicon.ico instead of relying on a service to get favicons
        faviconURLString = [NSString stringWithFormat:@"https://www.google.com/s2/favicons?domain=%@", websiteURL];
        faviconURL = [NSURL URLWithString:faviconURLString];
        faviconData = [NSData dataWithContentsOfURL:faviconURL];
        websiteFavicon = [[NSImage alloc] initWithData:faviconData];
        self.faviconImage.image = websiteFavicon;
    }
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    // Only report feedback for the main frame.
    if(frame == [sender mainFrame]) {
        [self.loadingIndicator stopAnimation:self];
        self.reloadBtn.image = [NSImage imageNamed:NSImageNameRefreshTemplate];
        self.loadingIndicator.hidden = YES;
        self.faviconImage.hidden = NO;
        
        if([self.addressBar.stringValue hasPrefix: @"spark:"]) { // Check whether or not a spark: page is being loaded
            self.faviconImage.image = [NSImage imageNamed:@"favicon.ico"];
        }
        
        if(self.faviconImage.image == nil) { // Check whether or not a favicon image exists for the current webpage
            self.faviconImage.image = [NSImage imageNamed:@"defaultfavicon"];
        }
        
        // Set values for use on spark:// pages
        
        // Shared resources
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-currentVersion').innerHTML = '%@';", appVersion]];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-currentBuild').innerHTML = '%@';", buildNumber]];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-currentReleaseChannel').innerHTML = '%@';", releaseChannel]];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-userAgent').innerHTML = '%@';", userAgent]];
        
        // spark://version resources
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-operatingSystemName').innerHTML = '%@';", customMacOSProductName]];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-operatingSystemVersion').innerHTML = '%@';", macOSVersionString]];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('sparkWebBrowser-operatingSystemBuild').innerHTML = '%@';", macOSBuildString]];
    }
}

- (void)webView:(WebView *)sender didReceiveTitle:(NSString *)title forFrame:(WebFrame *)frame {
    
    clippedTitle = title;
    
    // Only report feedback for the main frame.
    if(frame == [sender mainFrame]) {
        
        const int clipLength = 25;
        if([title length] > clipLength) {
            clippedTitle = [NSString stringWithFormat:@"%@...", [title substringToIndex:clipLength]];
        }
        
        [self.titleStatus setStringValue:clippedTitle]; // Set titleStatus to clipped title
        self.titleStatus.toolTip = title; // Set tooltip to unclipped title
    }
}

#pragma mark - Miscellaneous methods

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end
