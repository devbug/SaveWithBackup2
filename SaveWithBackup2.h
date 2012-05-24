//
//  SaveWithBackup.h
//  SaveWithBackup
//
//  Created by deVbug on 12. 5. 24..
//  Copyright 2012 deVbug All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "CodaPluginsController.h"

@class CodaPlugInsController;


@interface SaveWithBackup : NSObject <CodaPlugIn>
{
	CodaPlugInsController* controller;
}

- (id)initWithPlugInController:(CodaPlugInsController*)controller bundle:(NSBundle*)aBundle;

@end
