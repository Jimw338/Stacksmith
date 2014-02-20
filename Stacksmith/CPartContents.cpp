//
//  CPartContents.cpp
//  Stacksmith
//
//  Created by Uli Kusterer on 30.12.13.
//  Copyright (c) 2013 Uli Kusterer. All rights reserved.
//

#include "CPartContents.h"
#include "CTinyXMLUtils.h"
#include "CDocument.h"


using namespace Carlson;



CPartContents::CPartContents( CLayer* owningLayer, tinyxml2::XMLElement * inElement )
{
	mID = CTinyXMLUtils::GetLongLongNamed( inElement, "id" );
	mHighlight = CTinyXMLUtils::GetBoolNamed( inElement, "highlight", false );
	tinyxml2::XMLElement * textElement = inElement->FirstChildElement( "text" );
	if( textElement )
	{
		mAttributedString.LoadFromElementWithStyles( textElement, owningLayer->GetStyles() );
	}
	std::string	theLayerStr;
	CTinyXMLUtils::GetStringNamed( inElement, "layer", theLayerStr );
	mIsOnBackground = (theLayerStr.compare("background") == 0);
	mOwningLayer = owningLayer;
}


void	CPartContents::SaveToElementOfDocumentStyleSheet( tinyxml2::XMLElement * inElement, tinyxml2::XMLDocument* document, CStyleSheet *styleSheet )
{
	CTinyXMLUtils::AddStringNamed(inElement, (mIsOnBackground ? "background" : "card"), "layer" );
	CTinyXMLUtils::AddLongLongNamed( inElement, mID, "id" );
	tinyxml2::XMLElement	*	elem = NULL;
	
	if( mHighlight )
	{
		elem = document->NewElement("highlight");
		elem->SetBoolFirstChild(mHighlight);
		inElement->InsertEndChild(elem);
	}
	
	if( mAttributedString.GetLength() > 0 )
	{
		elem = document->NewElement("text");
		mAttributedString.SaveToXMLDocumentElementStyleSheet( document, elem, styleSheet );
		inElement->InsertEndChild(elem);
	}
}


void	CPartContents::IncrementChangeCount()
{
	mOwningLayer->IncrementChangeCount();
}


void	CPartContents::Dump( size_t inIndent )
{
	const char	*	indentStr = IndentString(inIndent);
	printf( "%sContents for %s part ID %lld\n%s{\n", indentStr, (mIsOnBackground?"bg":"cd"), mID, indentStr );
	printf( "%s\thighlight = %s\n", indentStr, (mHighlight?"true":"false") );
	printf( "%s\ttext =\n%s\t{\n", indentStr, indentStr );
	mAttributedString.Dump( inIndent +2 );
	printf( "%s\t}\n", indentStr );
	printf( "%s}\n", indentStr );
}
