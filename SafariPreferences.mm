#import "SafariPreferences.h"

#define IS_iPAD ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)

@implementation SafariPreferences

+ (instancetype)sharedInstance
{
	static SafariPreferences *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, 
	^{
		sharedInstance = [[SafariPreferences alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	self = [super init];

	_preferences = [[HBPreferences alloc] initWithIdentifier: @"com.johnzaro.perfectsafariprefs"];
	[_preferences registerDefaults:
	@{
		@"enabled": @NO,
		@"addNewTabButton": @NO,
		@"showOpenTabsCount": @NO,
		@"colorize": @NO,
		@"fullScreen": @NO,
		@"showTabs": @NO,
		@"useTabOverview": @NO,
		@"showFullURL": @NO,
		@"backgroundPlayback": @NO
	}];

	_enabled = [_preferences boolForKey: @"enabled"];

	_addNewTabButton = [_preferences boolForKey: @"addNewTabButton"];
	_showOpenTabsCount = [_preferences boolForKey: @"showOpenTabsCount"];
	_colorize = [_preferences boolForKey: @"colorize"];
	_fullScreen = [_preferences boolForKey: @"fullScreen"];
	_showTabs = [_preferences boolForKey: @"showTabs"];
	_useTabOverview = [_preferences boolForKey: @"useTabOverview"];
	_showFullURL = [_preferences boolForKey: @"showFullURL"];
	_backgroundPlayback = [_preferences boolForKey: @"backgroundPlayback"];
	
	return self;
}

- (BOOL)enabled
{
	return _enabled;
}

- (BOOL)addNewTabButton
{
	return _addNewTabButton;
}

- (BOOL)showOpenTabsCount
{
	return _showOpenTabsCount;
}

- (BOOL)colorize
{
	return _colorize;
}

- (BOOL)fullScreen
{
	return _fullScreen;
}

- (BOOL)showTabs
{
	return _showTabs;
}

- (BOOL)useTabOverview
{
	return _useTabOverview;
}

- (BOOL)showFullURL
{
	return _showFullURL;
}

- (BOOL)backgroundPlayback
{
	return _backgroundPlayback;
}

- (BOOL)isIpad
{
	return IS_iPAD;
}

@end
