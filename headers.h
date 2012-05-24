//
//  headers.h
//  SaveWithBackup
//
//  Created by Harry deVbug on 12. 5. 24..
//  Copyright (c) 2012년 deVbug. All rights reserved.
//

#ifndef SaveWithBackup_headers_h
#define SaveWithBackup_headers_h

@interface PCNode : NSObject
- (BOOL)isRemote;
- (NSString *)displayPath;
@end

@interface CodaDocument : NSDocument
- (PCNode *)remoteNode;
@end

@interface PlainTextDocument : CodaDocument
@end

@interface TextDocument : PlainTextDocument
- (id)activePlainTextEditor;
@end

@interface PlainTextEditor : NSResponder
- (id)document;
- (id)textView;
- (id)editorView;
@end

@interface CodaPlainTextEditor : PlainTextEditor
- (id)textViewController;
- (id)document;
@end

@interface PlainTextWindowController : NSWindowController
- (id)documents;
- (id)activePlainTextEditor;
- (id)plainTextEditors;
@end

@interface CodaViewController : NSViewController
@end

@interface CodaDocumentViewController : NSViewController
@end

@interface TextDocumentViewController : CodaDocumentViewController
- (id)plainTextEditor;
@end

@interface DocumentsViewController : CodaViewController
- (id)viewControllers;
- (id)tabControllers;
- (id)selectedViewController;
- (id)selectedTabController;
- (id)selectedSplitController;
- (id)activeViewController;
- (id)documents;
@end

@interface CodaWindowController : NSWindowController
+ (id)frontmostController;
- (DocumentsViewController *)documentsController;
@end

#endif
