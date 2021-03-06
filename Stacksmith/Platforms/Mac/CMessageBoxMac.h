//
//  CMessageBoxMac.h
//  Stacksmith
//
//  Created by Uli Kusterer on 2014-01-17.
//  Copyright (c) 2014 Uli Kusterer. All rights reserved.
//

#ifndef __Stacksmith__CMessageBoxMac__
#define __Stacksmith__CMessageBoxMac__

#include "CMessageBox.h"


#if __OBJC__
@class WILDMessageBoxWindowController;
typedef WILDMessageBoxWindowController*			WILDMessageBoxWindowControllerPtr;
#else
#include <objc/objc.h>
typedef struct WILDMessageBoxWindowController*	WILDMessageBoxWindowControllerPtr;
#endif


namespace Carlson
{


class CMessageBoxMac : public CMessageBox
{
public:
	CMessageBoxMac();
	~CMessageBoxMac();

	virtual bool	SetTextContents( const std::string& inString );
	virtual bool	GetTextContents( std::string &outString );
	virtual void	SetResultText( const std::string &inString );

	virtual bool	SetValueForPropertyNamed( LEOValuePtr inValue, LEOContext* inContext, const char* inPropertyName, size_t byteRangeStart, size_t byteRangeEnd );
	virtual bool	GetPropertyNamed( const char* inPropertyName, size_t byteRangeStart, size_t byteRangeEnd, LEOContext* inContext, LEOValuePtr outValue );

	void			UpdateVisible( bool inVis )	{ mVisible = inVis; };
	
	void			SetVisible( bool inVis );
	virtual bool	IsVisible()	{ return mVisible; };
	
	void			SetNeedsToSyncContentsFromUI( bool inSync )	{ mNeedsToSyncContentsFromUI = inSync; }
	
protected:
	WILDMessageBoxWindowControllerPtr	mMacWindowController;
	bool								mVisible;
	bool								mNeedsToSyncContentsFromUI;
};


}

#endif /* defined(__Stacksmith__CMessageBoxMac__) */
