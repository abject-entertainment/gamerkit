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
#import <JavaScriptCore/JavaScriptCore.h>

@interface CharacterViewController ()
{
	Character *_character;
	ContentObjectAction _currentAction;
	BOOL _loaded;
	NSString *_cachedRollNotation;
}

@end

#define NEW_TOKEN_HANDLER @"gamerkit.char.requestNewToken"
#define SAVE_HANDLER @"gamerkit.char.requestSave"

@implementation CharacterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (_content == nil)
	{
		WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
		config.userContentController = [[WKUserContentController alloc] init];
		
		_content = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) configuration:config];
		[self.view addSubview:_content];
		
		[config.userContentController addScriptMessageHandler:self name:NEW_TOKEN_HANDLER];
		[config.userContentController addScriptMessageHandler:self name:SAVE_HANDLER];
		
		if (_character)
		{ [self displayCharacter:_character withAction:_currentAction]; }
	}
	
	_loaded = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
	if (_content)
	{
		[_content.configuration.userContentController removeScriptMessageHandlerForName:NEW_TOKEN_HANDLER];
		[_content.configuration.userContentController removeScriptMessageHandlerForName:SAVE_HANDLER];
		_content = nil;
	}
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
	}
}

- (void)displayCharacter:(Character *)character withAction:(ContentObjectAction)action
{
	[self setContentObject:character];
	_currentAction = action;

	if (_content)
	{
		if (_toggleButton)
		{
			if (_currentAction == ContentObjectActionWebView)
			{
				[_toggleButton setTitle:@"Play"];
			}
			else
			{
				[_toggleButton setTitle:@"Edit"];
			}
		}
		
		ContentTransformResult *result = [_character applyTransformForAction:action];
		if (result.succeeded)
		{
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
			NSString *docsPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Core"];
			NSString *tempFile = [docsPath stringByAppendingPathComponent:@".GTCHARTEMP.html"];
			
			[result.html writeToFile:tempFile atomically:YES encoding:NSUTF8StringEncoding error:nil];
			
			[self.content loadFileURL:[NSURL fileURLWithPath:tempFile] allowingReadAccessToURL:[NSURL fileURLWithPath:docsPath]];
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

- (void)tokenWasSelected:(Token *)token
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Change Token" message:@"Are you sure you want to change this character's token?" preferredStyle:UIAlertControllerStyleAlert];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
		
	}]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
		NSData *data = UIImageJPEGRepresentation(token.image, 0.85f);
		NSString *base64data = [data base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength | NSDataBase64EncodingEndLineWithLineFeed];
		[_content evaluateJavaScript:[NSString stringWithFormat:@"updateExpectedToken(\"%@\");", base64data] completionHandler:nil];
	}]];
	[self presentViewController:alert animated:YES completion:nil];
}

- (void)toggleEdit:(id)sender
{
	if (_currentAction == ContentObjectActionWebView)
	{
		[self displayCharacter:_character withAction:ContentObjectActionReadOnlyWebView];
	}
	else
	{
		[self displayCharacter:_character withAction:ContentObjectActionWebView];
	}
}

- (void)characterActions:(id)sender
{
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

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
	if ([message.name compare:NEW_TOKEN_HANDLER] == NSOrderedSame)
	{
		[TokenListController selectTokenForDelegate:self];
	}
	else if ([message.name compare:SAVE_HANDLER] == NSOrderedSame)
	{
#warning <<AE>> Implement save character
	}
}

@end
