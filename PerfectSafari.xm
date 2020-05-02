#import "PerfectSafari.h"
#import "SafariPreferences.h"
#import <Cephei/HBPreferences.h>
#import "SparkColourPickerUtils.h"

static SafariPreferences *preferences;

static UIColor *selectedColor;

%group colorizeGroup

	%hook _SFNavigationBar

	- (void)setTheme: (_SFBarTheme*)theme
	{
		_SFBarTheme* themeCopy = [%c(_SFBarTheme) themeWithTheme: theme];
		[themeCopy setValue: selectedColor forKey: @"_preferredControlsTintColor"];
		%orig(themeCopy);
	}

	- (void)_didUpdateEffectiveTheme
	{
		[[self effectiveTheme] setValue: selectedColor forKey: @"_textColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_secureTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_warningTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterSecureTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterWarningTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterAnnotationTextColor"];
		[[self effectiveTheme] setValue: selectedColor forKey: @"_platterProgressBarTintColor"];
		[[self effectiveTheme] setValue: [selectedColor colorWithAlphaComponent: 0.5] forKey: @"_platterPlaceholderTextColor"];

		%orig;
	}

	%end

	%hook _SFToolbar

	- (void)setTheme: (_SFBarTheme*)theme
	{
		_SFBarTheme* themeToUse = [%c(_SFBarTheme) themeWithTheme: theme];
		[themeToUse setValue: selectedColor forKey: @"_controlsTintColor"];
		%orig(themeToUse);
	}

	%end

	%hook TabBarItemView

	- (void)setActive: (BOOL)active
	{
		%orig;

		[UIView performWithoutAnimation:
		^{
			if(active) [(UILabel*)[self valueForKey: @"_titleLabel"] setAlpha: 1.0];
			else [(UILabel*)[self valueForKey: @"_titleLabel"] setAlpha: 0.8];

			[(UIVisualEffectView*)[self valueForKey: @"_contentEffectsView"] setEffect: nil];
		}];
	}

	- (void)updateTabBarStyle
	{
		%orig;

		dispatch_async(dispatch_get_main_queue(), 
		^{
			[(UILabel*)[self valueForKey: @"_titleLabel"] setTextColor: selectedColor];
			[(UIVisualEffectView*)[self valueForKey: @"_contentEffectsView"] setEffect: nil];
			[(UIVisualEffectView*)[self valueForKey: @"_closeButtonEffectsView"] setEffect: nil];
			[(UIButton*)[self valueForKey: @"_closeButton"] setTintColor: selectedColor];
		});
	}

	%end

%end

// enable full screen scroll

%group fullScreenGroup

	%hook BrowserController

	- (BOOL)fullScreenInPortrait
	{
		return YES;
	}

	%end

%end

// use tabs on iphone

%group showTabsGroup

	%hook BrowserController

	- (BOOL)_shouldShowTabBar
	{
		return YES;
	}

	- (BOOL)_shouldUseTabBar
	{
		return YES;
	}

	%end

%end

// use tab overview on iphone + set 2 tabs per row in tab overview

%group useTabOverviewGroup

	%hook BrowserController

	- (BOOL)_shouldUseTabOverview
	{
		return YES;
	}

	%end

	%hook TabOverview

	- (unsigned long long)_tabsPerRow
	{
		return 2;
	}

	- (BOOL)showsPrivateBrowsingButton // visual fix
	{
		return NO;
	}

	%end

 %end

// Show full URL in NavBar

%group showFullURLGroup

	%hook _SFNavigationBarItem

	- (void)setText: (NSString*)text textWhenExpanded: (NSString*)textWhenExpanded startIndex: (NSUInteger)startIndex
	{
		%orig(textWhenExpanded, textWhenExpanded, startIndex);
	}

	%end

%end

// Background Playback

%group backgroundPlaybackGroup

	%hook WKContentView

	- (void)_applicationWillResignActive: (id)arg
	{

	}

	- (void)_applicationDidEnterBackground
	{

	}

	%end

%end

void initPerfectSafari()
{
	@autoreleasepool
	{
		preferences = [SafariPreferences sharedInstance];

		if([preferences colorize])
		{
			NSDictionary *preferencesDictionary = [NSDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.johnzaro.perfectsafariprefs.colors.plist"];
			selectedColor = [SparkColourPickerUtils colourWithString: [preferencesDictionary objectForKey: @"selectedColor"] withFallback: @"#FF9400"];
			
			%init(colorizeGroup);
		} 
		if([preferences fullScreen]) %init(fullScreenGroup);
		if([preferences showTabs] && ![preferences isIpad]) %init(showTabsGroup);
		if([preferences useTabOverview] && ![preferences isIpad]) %init(useTabOverviewGroup);
		if([preferences showFullURL]) %init(showFullURLGroup);
		if([preferences backgroundPlayback]) %init(backgroundPlaybackGroup);
	}
}