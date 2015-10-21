//
//  CharacterViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "CharacterViewController.h"
#import "Character.h"
#import "CharacterListController.h"
#import "DismissSegue.h"
#import "Token.h"
#import "DiceView.h"

@interface CharacterViewController ()
{
	Character *_character;
	BOOL _loaded;
	NSString *_cachedRollNotation;
}

@end

@implementation CharacterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_loaded = YES;
	
	if (_character)
	{ [self setCharacter:_character]; }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCharacter:(Character *)character {
	_character = character;
	if (_loaded)
	{
		_titleText.title = character.name;
		NSString *html = [character HTMLString:character.editSheet];
		NSLog(@"%@", html);
		[self.content loadData:[html dataUsingEncoding:NSUTF8StringEncoding] MIMEType:@"application/xml" textEncodingName:@"utf8" baseURL:[character baseURL]];
	}
}

- (NSDictionary*)parseURLQueryString:(NSString*)q
{
	NSArray *parts = [q componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:parts.count];
	
	for (NSString* part in parts) {
		NSArray *pair = [part componentsSeparatedByString:@"="];
		
		if (pair.count > 1)
		{
			id obj = [params objectForKey:pair[0]];
			if ([obj isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray*)obj addObject:pair[1]];
			}
			else if (obj)
			{
				[params setObject:[NSMutableArray arrayWithObjects:obj, pair[1], nil] forKey:pair[0]];
			}
			else
			{
				[params setObject:pair[1] forKey:pair[0]];
			}
		}
	}
	return params;
}

- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	BOOL result = YES;
	if ([request.URL.scheme caseInsensitiveCompare:@"gamerstoolkit"] == NSOrderedSame)
	{
		NSString *method = request.URL.host;
		NSDictionary *params = [self parseURLQueryString:request.URL.query];

		if ([method caseInsensitiveCompare:@"chooseToken"] == NSOrderedSame)
		{
			// choose token
			[TokenListController selectTokenForDelegate:self];
		}
		else if ([method caseInsensitiveCompare:@"prepDieRoll"] == NSOrderedSame)
		{
			NSString *notation = [params objectForKey:@"notation"];
			if (notation)
			{
				_cachedRollNotation = notation;
			}
		}
		else if ([method caseInsensitiveCompare:@"dieRoll"] == NSOrderedSame)
		{
			NSString *notation = [params objectForKey:@"notation"];
			if (notation)
			{
				NSString *result = [DiceView doNotationRoll:notation];
				[self displayRollResult:result];
			}
		}
		else
		{
			NSLog(@"Unrecognized method invocation: '%@'", method);
		}
		
		result = NO;
	}
	else if ([request.URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame ||
			 [request.URL.scheme caseInsensitiveCompare:@"https"] == NSOrderedSame ||
			 [request.URL.scheme caseInsensitiveCompare:@"file"] == NSOrderedSame)
	{
		result = YES;
	}
	else if ([[UIApplication sharedApplication] canOpenURL:request.URL])
	{
		[[UIApplication sharedApplication] openURL:request.URL];
		result = NO;
	}
	
	return result;
}

- (IBAction)roll:(id)sender
{
	if (_cachedRollNotation)
	{
		[self displayRollResult:[DiceView doNotationRoll:_cachedRollNotation]];
	}
}

- (void)displayRollResult:(NSString*)result
{
	UIAlertController *av = [UIAlertController alertControllerWithTitle:@"DiceRoll" message:[NSString stringWithFormat:@"Result: %@", result] preferredStyle:UIAlertControllerStyleAlert];
	[self presentViewController:av animated:YES completion:nil];
}

- (void)tokenWasSelected:(Token *)token
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Token" message:@"Are you sure you want to change this character's token?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[_content stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"SetImageData(\"Token\", \"%@\");", [token imageDataBase64]]];
	}]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)saveCharacter
{
	[_character saveFromWebView:_content];
	if ([self.presentingViewController isKindOfClass:[CharacterListController class]])
	{
		[(CharacterListController *)self.presentingViewController refreshData];
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue isKindOfClass:[DismissSegue class]])
	{
		[self saveCharacter];
	}
}


@end
