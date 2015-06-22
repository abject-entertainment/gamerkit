//
//  CharacterViewController.m
//  gamerkit
//
//  Created by Benjamin Taggart on 5/27/15.
//  Copyright (c) 2015 Abject Entertainment. All rights reserved.
//

#import "CharacterViewController.h"
#import "Character.h"
#import "PagesController.h"

@interface CharacterViewController ()
{
	Character *_character;
	BOOL _loaded;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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

- (BOOL)webView:(UIWebView *)inWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	BOOL result = YES;
	if ([request.URL.scheme caseInsensitiveCompare:@"gamerstoolkit"] == NSOrderedSame)
	{
		NSArray *params = nil;
		NSMutableArray *paramValues = nil;
		NSString *method = [NSString stringWithFormat:@"%@:", request.URL.host];
		if (request.URL.query)
		{
			params = [request.URL.query componentsSeparatedByString:@"&"];
			if (params.count > 0) paramValues = [NSMutableArray arrayWithCapacity:params.count];
			
			for (int i = 0; i < params.count; ++i)
			{
				NSString *param = [params objectAtIndex:i];
				NSUInteger split = [param rangeOfString:@"="].location;
				if (split != NSNotFound)
				{
					[paramValues addObject:[param substringFromIndex:split+1]];
				}
			}
		}
		
		if ([method caseInsensitiveCompare:@"chooseToken"] == NSOrderedSame)
		{
			// choose token
		}
		else
		{
			NSLog(@"Unrecognized method invocation: '%@'", method);
		}
		/*
		SEL sel = NSSelectorFromString(selector);
		NSMethodSignature *msig = [targetObj methodSignatureForSelector:sel];
		if (msig)
		{
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature:msig];
			[inv setTarget:targetObj];
			[inv setSelector:sel];
			[inv setArgument:&self atIndex:2];
			for (int i = 0; i < paramValues.count; ++i)
			{
				id param = [paramValues objectAtIndex:i];
				[inv setArgument:&param atIndex:i+3];
			}
			[inv invoke];
			
			if ([msig methodReturnLength] == sizeof(id))
			{
				id retVal = nil;
				[inv getReturnValue:&retVal];
				
				if (retVal != nil)
				{
					if ([retVal isKindOfClass:[NSString class]])
					{
						[self.content loadHTMLString:retVal baseURL:nil];
					}
					else if ([retVal isKindOfClass:[NSURL class]])
					{
						[self.content loadRequest:[NSURLRequest requestWithURL:retVal]];
					}
				}
			}
		} */
		
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


@end
