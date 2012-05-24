//
//  SaveWithBackup.mm
//  SaveWithBackup
//
//  Created by deVbug on 12. 5. 24..
//  Copyright 2012 deVbug All rights reserved.
//

#import "SaveWithBackup2.h"
#import "CodaPlugInsController.h"

#import "headers.h"

#import <objc/runtime.h>

#define BACKUP_DIR	@"/CodaSaveBackup/"


@implementation SaveWithBackup

- (id)initWithPlugInController:(CodaPlugInsController*)inController bundle:(NSBundle*)aBundle {
	if ((self = [super init]) != nil) {
		controller = inController;
		[controller registerActionWithTitle:NSLocalizedString(@"Save with Backup 2", @"Save with Backup 2") 
					  underSubmenuWithTitle:nil
									 target:self 
								   selector:@selector(safetySave:)
						  representedObject:nil
							  keyEquivalent:@"^$S"						// Ctrl + Shift + S
								 pluginName:@"SaveWithBackup2"];
	}
	return self;
}


- (NSString*)name {
	return @"SaveWithBackup2";
}

- (NSString *)getSite:(BOOL)isRemote {
	NSMutableString *str = [NSMutableString stringWithFormat:@""];
	
	if (!isRemote) {
		[str appendString:@"localstorage"];
		return str;
	}
	
	if ([controller apiVersion] < 2) return @"";
	
	CodaTextView *tview = [controller focusedTextView:self];
	if (tview == nil) return @"";
	
	if ([controller apiVersion] < 4) return @"";
	
	NSMutableString *temp = [NSMutableString stringWithFormat:@""];
	
	if ([tview siteNickname] != nil)
		[temp appendString:[tview siteNickname]];
	else if ([tview siteURL] != nil)
		[temp appendString:[tview siteURL]];
	else if ([tview siteLocalURL] != nil)
		[temp appendString:[tview siteLocalURL]];
	
	if ([temp length] == 0) {
		[str appendString:@"unknownstorage"];
	} else {
		[temp replaceOccurrencesOfString:@"/" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@":" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@";" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@"\t" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@"\r" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@"\n" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@"\a" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[temp replaceOccurrencesOfString:@"\f" withString:@"_" options:(NSStringCompareOptions)nil range:NSMakeRange(0, [temp length])];
		[str appendString:temp];
	}
	
	return str;
}

- (void)safetySave:(id)sender {
	if ([controller apiVersion] < 2) return;
	
	CodaTextView *tview = [controller focusedTextView:self];
	if (tview == nil) return;
	
	if ([controller apiVersion] < 4) {
		[tview save];
		return;
	}
	
	NSString *name = [[tview path] lastPathComponent];
	
	bool isRemote = YES;
	NSString *temp = @"~";
	NSMutableString *str = [[NSMutableString alloc] initWithString:[temp stringByExpandingTildeInPath]];
	[str appendFormat:BACKUP_DIR];
		
	/*if ([tview siteRemotePath] != nil) {
		if (NO == [[tview siteRemotePath] hasPrefix:@"/"])
			[str appendString:@"/"];
		
		[str appendString:[tview siteRemotePath]];
		
		if (NO == [str hasSuffix:@"/"])
			[str appendString:@"/"];
		
		[str appendString:name];
	}
	else if ([tview siteLocalPath] != nil) {
		if (NO == [[tview siteLocalPath] hasPrefix:@"/"])
			[str appendString:@"/"];
		
		[str appendString:[tview siteLocalPath]];
		
		if (NO == [str hasSuffix:@"/"])
			[str appendString:@"/"];
		
		[str appendString:name];
	}*/
	
	NSArray *documents = [[NSDocumentController sharedDocumentController] documents];
	
	CodaWindowController *windowCtrlr = (CodaWindowController *)[objc_getClass("CodaWindowController") frontmostController];
	if ([windowCtrlr respondsToSelector:@selector(documentsController)]) {
		TextDocumentViewController *docCtrlr = [[windowCtrlr documentsController] selectedViewController];
		
		if ([docCtrlr respondsToSelector:@selector(plainTextEditor)]) {
			TextDocument *document = [[docCtrlr plainTextEditor] document];
			PCNode *remoteNode = [document remoteNode];
			
			if (remoteNode) {
				isRemote = [remoteNode isRemote];
				[str appendString:[self getSite:isRemote]];
				
				NSString *lastRemotePath = [remoteNode displayPath];
				
				if (lastRemotePath) {
					if (NO == [lastRemotePath hasPrefix:@"/"])
						[str appendString:@"/"];
					
					[str appendString:lastRemotePath];
				}
			} else
				isRemote = NO;
		}
	}
	
	if (!isRemote && [tview path] != nil) {
		[str appendString:[self getSite:isRemote]];
		
		if (NO == [[tview path] hasPrefix:@"/"])
			[str appendString:@"/"];
		
		[str appendString:[tview path]];
	}
	else if (!isRemote || documents.count == 0) {
		// do nothing.. just save..
		[tview save];
		
		[str release];
		
		return;
	}
	
	if (NO == [str hasSuffix:@"/"])
		[str appendString:@"/"];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] initWithDateFormat:@"%Y%m%d/" allowNaturalLanguage:NO];
	NSString *theDate = [dateFormat stringFromDate:[NSDate date]];
	
	[str appendFormat:theDate];
	
	
	char *path = NULL;
	path = (char *)malloc([str length] * 4);
	sprintf(path, "mkdir -p \"%s\"", [str UTF8String]);
	system(path);
	free(path);
	
	
	NSDateFormatter *timeFormat = [[NSDateFormatter alloc] initWithDateFormat:@"%H%M%S" allowNaturalLanguage:NO];
	
	NSString *theTime = [timeFormat stringFromDate:[NSDate date]];
	
	NSString *fullpath = [NSString stringWithFormat:@"%@%@_%@", str, theTime, name];
	
	NSFileHandle *writeFile;
	NSData *data = [[tview string] dataUsingEncoding:NSUTF8StringEncoding];
	
	[[NSFileManager defaultManager] createFileAtPath:fullpath contents:nil attributes:nil];
	
	writeFile = [NSFileHandle fileHandleForWritingAtPath:fullpath];
	if (writeFile != nil) {
		[writeFile writeData:data];
		[writeFile closeFile];
	}
	
	[tview save];
	
	//[tview insertText:fullpath];
	
	[timeFormat release];
	[dateFormat release];
	[str release];
}

@end
