//
//  CFieldPart.cpp
//  Stacksmith
//
//  Created by Uli Kusterer on 2014-01-02.
//  Copyright (c) 2014 Uli Kusterer. All rights reserved.
//

#include "CFieldPart.h"
#include "CTinyXMLUtils.h"


using namespace Carlson;


static const char*	sFieldStyleStrings[EFieldStyle_Last +1] =
{
	"transparent",
	"opaque",
	"rectangle",
	"shadow",
	"scrolling",
	"standard",
	"popup",
	"*UNKNOWN*"
};


TFieldStyle	CFieldPart::GetFieldStyleFromString( const char* inStyleStr )
{
	for( size_t x = 0; x < EFieldStyle_Last; x++ )
	{
		if( strcmp(sFieldStyleStrings[x],inStyleStr) == 0 )
			return (TFieldStyle)x;
	}
	return EFieldStyle_Last;
}


void	CFieldPart::LoadPropertiesFromElement( tinyxml2::XMLElement * inElement )
{
	CVisiblePart::LoadPropertiesFromElement( inElement );
	
	mDontWrap = CTinyXMLUtils::GetBoolNamed( inElement, "dontWrap", false );
	mDontSearch = CTinyXMLUtils::GetBoolNamed( inElement, "dontSearch", false );
	mSharedText = CTinyXMLUtils::GetBoolNamed( inElement, "sharedText", false );
	mFixedLineHeight = CTinyXMLUtils::GetBoolNamed( inElement, "fixedLineHeight", false );
	mAutoTab = CTinyXMLUtils::GetBoolNamed( inElement, "autoTab", false );
	mLockText = CTinyXMLUtils::GetBoolNamed( inElement, "lockText", false );
	mAutoSelect = CTinyXMLUtils::GetBoolNamed( inElement, "autoSelect", false );
	mMultipleLines = CTinyXMLUtils::GetBoolNamed( inElement, "multipleLines", false );
	mShowLines = CTinyXMLUtils::GetBoolNamed( inElement, "showLines", false );
	mWideMargins = CTinyXMLUtils::GetBoolNamed( inElement, "wideMargins", false );
	std::string	textAlignStr;
	CTinyXMLUtils::GetStringNamed( inElement, "textAlign", textAlignStr );
	mTextAlign = CVisiblePart::GetTextAlignFromString( textAlignStr.c_str() );
	mFont.erase();
	CTinyXMLUtils::GetStringNamed( inElement, "font", mFont );
	mTextSize = CTinyXMLUtils::GetIntNamed( inElement, "textSize", 12 );
	tinyxml2::XMLElement * currStyle = inElement->FirstChildElement("textStyle");
	mTextStyle = EPartTextStylePlain;
	while( currStyle )
	{
		mTextStyle |= GetStyleFromString( currStyle->GetText() );
		currStyle = currStyle->NextSiblingElement( "textStyle" );
	}
	mHasHorizontalScroller = CTinyXMLUtils::GetBoolNamed( inElement, "hasHorizontalScroller", false );
	mHasVerticalScroller = CTinyXMLUtils::GetBoolNamed( inElement, "hasVerticalScroller", false );
	std::string	styleStr;
	CTinyXMLUtils::GetStringNamed( inElement, "style", styleStr );
	mFieldStyle = GetFieldStyleFromString( styleStr.c_str() );
}


void	CFieldPart::DumpProperties( size_t inIndentLevel )
{
	const char*	indentStr = IndentString(inIndentLevel);
	
	CVisiblePart::DumpProperties( inIndentLevel );
	
	printf( "%sstyle = %s\n", indentStr, sFieldStyleStrings[mFieldStyle] );
	printf( "%sdontWrap = %s\n", indentStr, (mDontWrap ? "true" : "false") );
	printf( "%sdontSearch = %s\n", indentStr, (mDontSearch ? "true" : "false") );
	printf( "%ssharedText = %s\n", indentStr, (mSharedText ? "true" : "false") );
	printf( "%sfixedLineHeight = %s\n", indentStr, (mFixedLineHeight ? "true" : "false") );
	printf( "%sautoTab = %s\n", indentStr, (mAutoTab ? "true" : "false") );
	printf( "%slockText = %s\n", indentStr, (mLockText ? "true" : "false") );
	printf( "%sautoSelect = %s\n", indentStr, (mAutoSelect ? "true" : "false") );
	printf( "%smultipleLines = %s\n", indentStr, (mMultipleLines ? "true" : "false") );
	printf( "%sshowLines = %s\n", indentStr, (mShowLines ? "true" : "false") );
	printf( "%swideMargins = %s\n", indentStr, (mWideMargins ? "true" : "false") );
	printf( "%stextAlign = %d\n", indentStr, mTextAlign );
	printf( "%sfont = %s\n", indentStr, mFont.c_str() );
	printf( "%stextSize = %d\n", indentStr, mTextSize );
	printf( "%shasHorizontalScroller = %s\n", indentStr, (mHasHorizontalScroller ? "true" : "false") );
	printf( "%shasVerticalScroller = %s\n", indentStr, (mHasVerticalScroller ? "true" : "false") );
}