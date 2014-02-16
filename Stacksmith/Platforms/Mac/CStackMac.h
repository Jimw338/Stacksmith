//
//  CStackMac.h
//  Stacksmith
//
//  Created by Uli Kusterer on 2014-01-06.
//  Copyright (c) 2014 Uli Kusterer. All rights reserved.
//

#ifndef __Stacksmith__CStackMac__
#define __Stacksmith__CStackMac__

#include "CStack.h"
#include "CMacScriptableObjectBase.h"


#if __OBJC__
@class WILDStackWindowController;
typedef WILDStackWindowController*					WILDStackWindowControllerPtr;
@class NSWindow;
@class NSPopover;
@class WILDScriptEditorWindowController;
@class NSImage;
typedef NSWindow*									WILDNSWindowPtr;
typedef NSPopover*									WILDNSPopoverPtr;
typedef WILDScriptEditorWindowController*			WILDScriptEditorWindowControllerPtr;
typedef NSImage*									WILDNSImagePtr;
#else
typedef struct WILDStackWindowController*			WILDStackWindowControllerPtr;
typedef struct NSWindow*							WILDNSWindowPtr;
typedef struct NSPopover*							WILDNSPopoverPtr;
typedef struct WILDScriptEditorWindowController*	WILDScriptEditorWindowControllerPtr;
typedef struct NSImage*								WILDNSImagePtr;
#endif


namespace Carlson {

class CStackMac : public CStack, public CMacScriptableObjectBase
{
public:
	CStackMac( const std::string& inURL, ObjectID inID, const std::string& inName, const std::string& inFileName, CDocument * inDocument );
	virtual ~CStackMac();

	virtual bool				GoThereInNewWindow( TOpenInMode inOpenInMode, CStack* oldStack, CPart* overPart );
	virtual void				SetPeeking( bool inState );
	virtual void				SetStyle( TStackStyle inStyle );

	virtual void				SetCurrentCard( CCard* inCard );
	virtual void				SetEditingBackground( bool inState );
	virtual void				SetTool( TTool inTool );
	virtual void				SetName( const std::string& inName );

	virtual std::string			GetDisplayName();
	virtual WILDNSImagePtr		GetDisplayIcon();
	
	virtual WILDNSWindowPtr		GetMacWindow();
	
	virtual bool				ShowScriptEditorForObject( CConcreteObject* inObject );
	virtual bool				ShowPropertyEditorForObject( CConcreteObject* inObject );
	virtual void				OpenScriptEditorAndShowOffset( size_t byteOffset );
	virtual void				OpenScriptEditorAndShowLine( size_t lineIndex );
	
	virtual void				GetMousePosition( LEONumber *x, LEONumber *y );
	virtual void				RectChangedOfPart( CPart* inChangedPart );

	static void					RegisterPartCreators();

protected:
	WILDStackWindowControllerPtr		mMacWindowController;
	WILDNSPopoverPtr					mPopover;
	WILDScriptEditorWindowControllerPtr	mScriptEditor;
};

}

#endif /* defined(__Stacksmith__CStackMac__) */
