//
//  NSStringAdditions.m
//  RPG Toolkit
//
//  Created by Benjamin Taggart on 8/28/10.
//  Copyright 2010 Abject Entertainment. All rights reserved.
//

#import "Base64.h"

static char base64EncodingTable[64] = {
	'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
	'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
	'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
	'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
};

@implementation NSString (NSStringAdditions)

+ (NSString *) base64StringFromData: (NSData *)data length: (NSUInteger)length {
	NSUInteger lentext = [data length];
	if (lentext < 1) return @"";
	
	char *outbuf = malloc(((lentext+2)/3)*4); // turn 3 bytes into 4 chars
	
	if ( !outbuf ) return nil;
	
	const unsigned char *raw = [data bytes];
	
	int inp = 0;
	int outp = 0;
	NSUInteger do_now = lentext - (lentext%3);
	
	for ( outp = 0, inp = 0; inp < do_now; inp += 3 )
	{
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		outbuf[outp++] = base64EncodingTable[raw[inp+2] & 0x3F];
	}
	
	if ( do_now < lentext )
	{
		unsigned char tmpbuf[3] = {0,0,0};
		int left = lentext%3;
		for ( int i=0; i < left; i++ )
		{
			tmpbuf[i] = raw[do_now+i];
		}
		raw = tmpbuf;
		inp = 0;
		outbuf[outp++] = base64EncodingTable[(raw[inp] & 0xFC) >> 2];
		outbuf[outp++] = base64EncodingTable[((raw[inp] & 0x03) << 4) | ((raw[inp+1] & 0xF0) >> 4)];
		if ( left == 2 ) outbuf[outp++] = base64EncodingTable[((raw[inp+1] & 0x0F) << 2) | ((raw[inp+2] & 0xC0) >> 6)];
		else outbuf[outp++] = '=';
		outbuf[outp++] = '=';
	}
	
	NSString *ret = [[NSString alloc] initWithBytes:outbuf length:outp encoding:NSASCIIStringEncoding];
	free(outbuf);
	
	return ret;
}
@end


@implementation NSData (NSDataAdditions)

+ (NSData *) base64DataFromString: (const char *)string 
{
	const char *txt = string;
	char slot = 0;
	int index = 0;
	unsigned long len = strlen(string);

	NSMutableData *data = [NSMutableData dataWithCapacity:len];
	unsigned char output[3] = {0,0,0};
	BOOL bDone = NO;
	
	while (index < len) 
	{
		char ch = txt[index++];
		if ((ch >= 'A') && (ch <= 'Z'))
			ch = ch - 'A';
		else if ((ch >= 'a') && (ch <= 'z'))
			ch = ch - 'a' + 26;
		else if ((ch >= '0') && (ch <= '9'))
			ch = ch - '0' + 52;
		else if (ch == '+')
			ch = 62;
		else if (ch == '/')
			ch = 63;
		else if (ch == '=')
		{
			bDone = YES;
			ch = 0;
		}
		else
			continue;
		
		switch (slot) {
			case 0:
				output[0] = ch << 2;
				slot = 1;
				break;
			case 1:
				output[0] |= ((ch & 0x30) >> 4);
				output[1] = ((ch & 0x0F) << 4);
				slot = 2;
				break;
			case 2:
				output[1] |= ((ch & 0x3C) >> 2);
				output[2] = ((ch & 0x03) << 6);
				slot = 3;
				break;
			case 3:
				output[2] |= (ch & 0x3F);
				[data appendBytes:&output[0] length:3];
				slot = 0;
				if (bDone) break;
				break;
		}
	}
	return data;
}
	
@end