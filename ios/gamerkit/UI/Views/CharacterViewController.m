//
//  CharacterViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "CharacterViewController.h"
#import "ContentManager.h"
#import "ContentTransformResult.h"
#import "Character.h"
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
	
	if (_content == nil)
	{
		_content = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44)];
		[self.view addSubview:_content];
	}
	
	_loaded = YES;
	
	if (_character)
	{ [self setContentObject:_character]; }
	
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setContentObject:(ContentObject *)contentObject
{
	if ([contentObject isKindOfClass:Character.class])
	{
		[super setContentObject:contentObject];
		_character = (Character*)contentObject;
		if (_loaded)
		{
			ContentTransformResult *result = [_character applyTransformForAction:ContentObjectActionWebView];
			if (result.succeeded)
			{
				NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
				NSString *docsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Core"];
				NSString *tempFile = [docsPath stringByAppendingPathComponent:@".GTCHARTEMP.html"];
				
				[result.html writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
				
				[self.content loadFileURL:[NSURL fileURLWithPath:tempFile] allowingReadAccessToURL:[NSURL fileURLWithPath:docsPath]];
				
				//NSLog(@"%@", html);
				//NSURL *baseURL = [[ContentManager contentManager] baseURLForDisplayOfCharacter:_character];
				//NSLog(@"BASE URL: %@", [baseURL absoluteString]);
				//[self.content loadHTMLString:result.html baseURL:baseURL];
			}
		}
	}
}

- (NSDictionary*)parseURLQueryString:(NSString*)q
{
	NSArray *parts = [q componentsSeparatedByString:@"&"];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:parts.count];
	
	for (NSString* part in parts) {
		NSArray *pair = [part componentsSeparatedByString:@"="];
		NSString *key = pair[0];
		NSString *value = pair[1];
		value = [[value stringByReplacingOccurrencesOfString:@"+" withString:@" "] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		if (pair.count > 1)
		{
			id obj = [params objectForKey:key];
			if ([obj isKindOfClass:[NSMutableArray class]])
			{
				[(NSMutableArray*)obj addObject:value];
			}
			else if (obj)
			{
				[params setObject:[NSMutableArray arrayWithObjects:obj, value, nil] forKey:key];
			}
			else
			{
				[params setObject:value forKey:key];
			}
		}
	}
	return params;
}

-(void)contextIsRequestingNewToken:(ContentJSContext *)context
{
	[TokenListController selectTokenForDelegate:self];
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
	UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
		[av dismissViewControllerAnimated:YES completion:nil];
	}];
	[av addAction:ok];
	[self presentViewController:av animated:YES completion:nil];
}

- (void)tokenWasSelected:(Token *)token
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Token" message:@"Are you sure you want to change this character's token?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		[[ContentJSContext contentContext] provideToken:token];
	}]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)saveCharacter
{
#warning <<AE>> Implement save character
	if (_listController)
	{
		[_listController refreshData];
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
