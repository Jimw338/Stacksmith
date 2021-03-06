//
//  WILDHostFunctions.m
//  Stacksmith
//
//  Created by Uli Kusterer on 16.04.11.
//  Copyright 2011 Uli Kusterer. All rights reserved.
//

#include "WILDHostFunctions.h"
#include "CScriptableObjectValue.h"
#include "CDocument.h"
#include "CStack.h"
#include "CLayer.h"
#include "CCard.h"
#include "CPart.h"
#include "LEOScript.h"
#include "LEOContextGroup.h"
#include "CMessageBox.h"
#include "CMessageWatcher.h"
#include "CVariableWatcher.h"
#include "CScreen.h"


void	WILDStackInstruction( LEOContext* inContext );
void	WILDBackgroundInstruction( LEOContext* inContext );
void	WILDCardInstruction( LEOContext* inContext );
void	WILDCardFieldInstruction( LEOContext* inContext );
void	WILDCardButtonInstruction( LEOContext* inContext );
void	WILDCardMoviePlayerInstruction( LEOContext* inContext );
void	WILDCardBrowserInstruction( LEOContext* inContext );
void	WILDCardPartInstruction( LEOContext* inContext );
void	WILDBackgroundFieldInstruction( LEOContext* inContext );
void	WILDBackgroundButtonInstruction( LEOContext* inContext );
void	WILDBackgroundMoviePlayerInstruction( LEOContext* inContext );
void	WILDBackgroundBrowserInstruction( LEOContext* inContext );
void	WILDBackgroundPartInstruction( LEOContext* inContext );
void	WILDNextCardInstruction( LEOContext* inContext );
void	WILDPreviousCardInstruction( LEOContext* inContext );
void	WILDNextBackgroundInstruction( LEOContext* inContext );
void	WILDPreviousBackgroundInstruction( LEOContext* inContext );
void	WILDFirstCardInstruction( LEOContext* inContext );
void	WILDLastCardInstruction( LEOContext* inContext );
void	WILDPushOrdinalBackgroundInstruction( LEOContext* inContext );
void	WILDPushOrdinalPartInstruction( LEOContext* inContext );
void	WILDThisStackInstruction( LEOContext* inContext );
void	WILDThisBackgroundInstruction( LEOContext* inContext );
void	WILDThisCardInstruction( LEOContext* inContext );
void	WILDNumberOfCardButtonsInstruction( LEOContext* inContext );
void	WILDNumberOfCardFieldsInstruction( LEOContext* inContext );
void	WILDNumberOfCardMoviePlayersInstruction( LEOContext* inContext );
void	WILDNumberOfCardBrowsersInstruction( LEOContext* inContext );
void	WILDNumberOfCardPartsInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundButtonsInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundFieldsInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundMoviePlayersInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundBrowsersInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundPartsInstruction( LEOContext* inContext );
void	WILDNumberOfCardsInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundsInstruction( LEOContext* inContext );
void	WILDNumberOfStacksInstruction( LEOContext* inContext );
void	WILDCardTimerInstruction( LEOContext* inContext );
void	WILDBackgroundTimerInstruction( LEOContext* inContext );
void	WILDNumberOfCardTimersInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundTimersInstruction( LEOContext* inContext );
void	WILDCardGraphicInstruction( LEOContext* inContext );
void	WILDBackgroundGraphicInstruction( LEOContext* inContext );
void	WILDNumberOfCardGraphicsInstruction( LEOContext* inContext );
void	WILDNumberOfBackgroundGraphicsInstruction( LEOContext* inContext );
void	WILDMessageBoxInstruction( LEOContext* inContext );
void	WILDMessageWatcherInstruction( LEOContext* inContext );
void	WILDVariableWatcherInstruction( LEOContext* inContext );
void	WILDCardPartInstructionInternal( LEOContext* inContext, const char* inType );
void	WILDBackgroundPartInstructionInternal( LEOContext* inContext, const char* inType );
void	WILDNumberOfCardsInstruction( LEOContext* inContext, const char* inType );
void	WILDNumberOfBackgroundsInstruction( LEOContext* inContext, const char* inType );
void	WILDNumberOfStacksInstruction( LEOContext* inContext, const char* inType );
void	WILDNumberOfCardPartsInstructionInternal( LEOContext* inContext, const char* typeName );
void	WILDNumberOfBackgroundPartsInstructionInternal( LEOContext* inContext, const char* typeName );
void	WILDPushNumberOfScreensInstruction( LEOContext* inContext );
void	WILDPushScreenInstruction( LEOContext* inContext );
void	WILDPushThisProjectInstruction( LEOContext* inContext );
void	WILDPushProjectInstruction( LEOContext* inContext );
void	WILDPushMenuInstruction( LEOContext* inContext );
void	WILDPushMenuItemInstruction( LEOContext* inContext );


using namespace Carlson;


size_t	kFirstStacksmithHostFunctionInstruction = 0;


void	WILDStackInstruction( LEOContext* inContext )
{
//	LEODebugPrintContext(inContext);
	
	char						idStrBuf[256] = {0};
	const char*					idStr = LEOGetValueAsString( inContext->stackEndPtr -2, idStrBuf, sizeof(idStrBuf), inContext );
	bool						lookUpByID = idStr[0] != 0;
	char						stackNameBuf[1024] = { 0 };
	const char*					stackName = stackNameBuf;
	CStack	*					theStack = NULL;
	CScriptContextUserData	*	userData = (CScriptContextUserData*)inContext->userData;
	if( LEOCanGetAsNumber( inContext->stackEndPtr -1, inContext ) )
	{
		LEOInteger	theNumber = LEOGetValueAsInteger( inContext->stackEndPtr -1, NULL, inContext );
		if( lookUpByID )
		{
			theStack = userData->GetDocument()->GetStackWithID( theNumber );
			if( !theStack )
				snprintf(stackNameBuf, sizeof(stackNameBuf) -1, "id %lld", theNumber );
			
		}
		else if( theNumber > 0 && theNumber <= (LEOInteger)userData->GetDocument()->GetNumStacks() )
			theStack = userData->GetDocument()->GetStack( theNumber -1 );
	}
	
	if( !theStack && !lookUpByID )
	{
		stackName = LEOGetValueAsString( inContext->stackEndPtr -1, stackNameBuf, sizeof(stackNameBuf), inContext );
		theStack = userData->GetDocument()->GetStackByName( stackName );
	}
	
	if( theStack )
	{
		LEOValuePtr	valueToReplace = inContext->stackEndPtr -2;
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -1 );
		LEOCleanUpValue( valueToReplace, kLEOInvalidateReferences, inContext );
		theStack->InitValue( valueToReplace, kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Can't find stack \"%s\".", stackName );
	}
	
//	LEODebugPrintContext(inContext);
	
	inContext->currentInstruction++;
}


void	WILDBackgroundInstruction( LEOContext* inContext )
{
//	LEODebugPrintContext(inContext);
	
	char			idStrBuf[256] = {0};
	const char*		idStr = LEOGetValueAsString( inContext->stackEndPtr -3, idStrBuf, sizeof(idStrBuf), inContext );
	bool			lookUpByID = idStr[0] != 0;
	CBackground	*	theBackground = NULL;
	char			backgroundName[1024] = { 0 };
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	CScriptContextUserData*	userData = (CScriptContextUserData*)inContext->userData;
	CStack*			ownerObject = userData->GetStack();
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
		ownerObject = dynamic_cast<CStack*>((CScriptableObject*)theOwner->object.object);
	if( !ownerObject )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Only stacks contain backgrounds." );
		return;
	}
	
	if( LEOCanGetAsNumber( inContext->stackEndPtr -2, inContext ) )
	{
		LEOInteger	theNumber = LEOGetValueAsInteger( inContext->stackEndPtr -2, NULL, inContext );
		if( lookUpByID )
		{
			theBackground = ownerObject->GetBackgroundByID( theNumber );
			if( !theBackground )
				snprintf(backgroundName, sizeof(backgroundName) -1, "id %lld", theNumber );
			
		}
		else if( theNumber > 0 && theNumber <= (LEOInteger)ownerObject->GetNumBackgrounds() )
			theBackground = ownerObject->GetBackground( theNumber -1 );
		else
			snprintf( backgroundName, sizeof(backgroundName) -1, "%lld", theNumber );
	}
	
	if( !theBackground && !lookUpByID )
	{
		LEOGetValueAsString( inContext->stackEndPtr -2, backgroundName, sizeof(backgroundName), inContext );
		
		theBackground = ownerObject->GetBackgroundByName( backgroundName );
	}
	
	if( theBackground )
	{
		LEOValuePtr	valueToReplace = inContext->stackEndPtr -3;
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2 );
		LEOCleanUpValue( valueToReplace, kLEOInvalidateReferences, inContext );
		theBackground->InitValue( valueToReplace, kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Can't find background \"%s\".", backgroundName );
	}
	
	inContext->currentInstruction++;
}


void	WILDCardInstruction( LEOContext* inContext )
{
//	LEODebugPrintContext(inContext);

	char			idStrBuf[256] = {0};
	const char*		idStr = LEOGetValueAsString( inContext->stackEndPtr -3, idStrBuf, sizeof(idStrBuf), inContext );
	bool			lookUpByID = idStr[0] != 0;
	CCard		*	theCard = NULL;
	char			cardName[1024] = { 0 };
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	CScriptContextUserData*	userData = (CScriptContextUserData*)inContext->userData;
	CStack*			frontStack = userData->GetStack();
	CBackground*	owningBg = NULL;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		owningBg = dynamic_cast<CBackground*>((CScriptableObject*)theOwner->object.object);
		if( owningBg )
			frontStack = owningBg->GetStack();
		CStack*		ownerObject = dynamic_cast<CStack*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			frontStack = ownerObject;
	}
	
	if( LEOCanGetAsNumber( inContext->stackEndPtr -2, inContext ) )
	{
		LEOInteger	theNumber = LEOGetValueAsInteger( inContext->stackEndPtr -2, NULL, inContext );
		if( lookUpByID )
		{
			theCard = frontStack->GetCardByID( theNumber );
			if( !theCard )
				snprintf(cardName, sizeof(cardName) -1, "id %lld", theNumber );
			
		}
		else if( theNumber > 0 && theNumber <= (LEOInteger)frontStack->GetNumBackgrounds() )
		{
			if( owningBg )
				theCard = frontStack->GetCardAtIndexWithBackground( theNumber -1, owningBg );
			else
				theCard = frontStack->GetCard( theNumber -1 );
		}
		else
			snprintf( cardName, sizeof(cardName) -1, "%lld", theNumber );
	}
	
	if( !theCard && !lookUpByID )
	{
		LEOGetValueAsString( inContext->stackEndPtr -2, cardName, sizeof(cardName), inContext );
		
		theCard = frontStack->GetCardByName( cardName );
	}
	
	if( theCard )
	{
		LEOValuePtr	valueToReplace = inContext->stackEndPtr -3;
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2 );
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		theCard->InitValue( valueToReplace, kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Can't find card \"%s\".", cardName );
	}
	
	inContext->currentInstruction++;
}


void	WILDCardPartInstructionInternal( LEOContext* inContext, const char* inType )
{
	CPart	*	thePart = NULL;
	CStack	*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	char		partName[1024] = { 0 };
	CCard	*	theCard = frontStack->GetCurrentCard();
	LEOValuePtr	theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CCard	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CCard*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			theCard = ownerObject;
	}
	
	if( !theCard->IsLoaded() )
	{
		LEOContextRetain( inContext );
		LEOPauseContext( inContext );
		
		theCard->Load( [inContext,theCard]( CLayer* inLoadedCard )
		{
			if( inLoadedCard == NULL || !inLoadedCard->IsLoaded() )
			{
				size_t		lineNo = 0;
				uint16_t	fileID = 0;
				LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
				LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Couldn't load %s.", theCard->GetDisplayName().c_str() );
			}
			LEOResumeContext( inContext );
			LEOContextRelease( inContext );
		});
		return;
	}
	
	char			idStrBuf[256] = {};
	const char*		idStr = LEOGetValueAsString( inContext->stackEndPtr -3, idStrBuf, sizeof(idStrBuf), inContext );
	bool			lookUpByID = idStr[0] != 0;
	if( LEOCanGetAsNumber( inContext->stackEndPtr -2, inContext ) )
	{
		LEOInteger	theNumber = LEOGetValueAsInteger( inContext->stackEndPtr -2, NULL, inContext );
		if( lookUpByID )
			thePart = theCard->GetPartWithID( theNumber );
		else
			thePart = theCard->GetPartOfType( theNumber -1, CPart::GetPartCreatorForType(inType) );
		
		if( !thePart )
			snprintf( partName, sizeof(partName) -1, "%lld", theNumber );
	}
	else if( !lookUpByID )
	{
		LEOGetValueAsString( inContext->stackEndPtr -2, partName, sizeof(partName), inContext );
		
		thePart = theCard->GetPartWithNameOfType( partName, CPart::GetPartCreatorForType(inType) );
	}
	
	if( thePart )
	{
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2 );
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		thePart->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Can't find card %s \"%s\".", (inType ? inType : "part"), partName );
	}
	
	inContext->currentInstruction++;
}


void	WILDBackgroundPartInstructionInternal( LEOContext* inContext, const char* inType )
{
	CPart	*		thePart = NULL;
	CStack	*		frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	char			partName[1024] = { 0 };
	CBackground	*	theBackground = frontStack->GetCurrentCard()->GetBackground();
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CCard* ownerCard = dynamic_cast<CCard*>((CScriptableObject*)theOwner->object.object);
		if( ownerCard )
			theBackground = ownerCard->GetBackground();
		CBackground	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CBackground*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			theBackground = ownerObject;
	}
	
	char			idStrBuf[256] = {};
	const char*		idStr = LEOGetValueAsString( inContext->stackEndPtr -3, idStrBuf, sizeof(idStrBuf), inContext );
	bool			lookUpByID = idStr[0] != 0;
	
	if( LEOCanGetAsNumber( inContext->stackEndPtr -2, inContext ) )
	{
		LEOInteger	theNumber = LEOGetValueAsInteger( inContext->stackEndPtr -2, NULL, inContext );
		if( lookUpByID )
			thePart = theBackground->GetPartWithID( theNumber );
		else
			thePart = theBackground->GetPartOfType( theNumber -1, CPart::GetPartCreatorForType(inType) );
		
		if( !thePart )
			snprintf( partName, sizeof(partName) -1, "%lld", theNumber );
	}
	else if( !lookUpByID )
	{
		LEOGetValueAsString( inContext->stackEndPtr -2, partName, sizeof(partName), inContext );
		
		thePart = theBackground->GetPartWithNameOfType( partName, CPart::GetPartCreatorForType(inType) );
	}
	
	if( thePart )
	{
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2 );
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		thePart->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Can't find background %s \"%s\".", (inType ? inType : "part"), partName );
	}
	
	inContext->currentInstruction++;
}


void	WILDCardFieldInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, "field" );
}


void	WILDCardButtonInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, "button" );
}


void	WILDCardMoviePlayerInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, "moviePlayer" );
}


void	WILDCardTimerInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, "timer" );
}


void	WILDCardGraphicInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, "graphic" );
}


void	WILDCardBrowserInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, "browser" );
}


void	WILDCardPartInstruction( LEOContext* inContext )
{
	WILDCardPartInstructionInternal( inContext, NULL );
}


void	WILDBackgroundFieldInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, "field" );
}


void	WILDBackgroundButtonInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, "button" );
}


void	WILDBackgroundMoviePlayerInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, "moviePlayer" );
}


void	WILDBackgroundTimerInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, "timer" );
}


void	WILDBackgroundGraphicInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, "graphic" );
}


void	WILDBackgroundBrowserInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, "browser" );
}


void	WILDBackgroundPartInstruction( LEOContext* inContext )
{
	WILDBackgroundPartInstructionInternal( inContext, NULL );
}


void	WILDNextCardInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CCard		*	theCard = theStack->GetNextCard();
	
	theCard->InitValue( inContext->stackEndPtr, kLEOInvalidateReferences, inContext );
	inContext->stackEndPtr ++;
	
	inContext->currentInstruction++;
}


void	WILDPreviousCardInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CCard		*	theCard = theStack->GetPreviousCard();
	
	theCard->InitValue( inContext->stackEndPtr, kLEOInvalidateReferences, inContext );
	inContext->stackEndPtr ++;
	
	inContext->currentInstruction++;
}


void	WILDNextBackgroundInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CBackground	*	theBackground = theStack->GetCurrentCard()->GetBackground();
	size_t			bkgdIndex = theStack->GetIndexOfBackground(theBackground);
	bkgdIndex++;
	if( bkgdIndex >= theStack->GetNumBackgrounds() )
		bkgdIndex = 0;
	theBackground = theStack->GetBackground( bkgdIndex );
	
	theBackground->InitValue( inContext->stackEndPtr, kLEOInvalidateReferences, inContext );
	inContext->stackEndPtr ++;
	
	inContext->currentInstruction++;
}


void	WILDPreviousBackgroundInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CBackground	*	theBackground = theStack->GetCurrentCard()->GetBackground();
	size_t			bkgdIndex = theStack->GetIndexOfBackground(theBackground);
	if( bkgdIndex == 0 )
		bkgdIndex = theStack->GetNumBackgrounds() -1;
	else
		bkgdIndex--;
	theBackground = theStack->GetBackground( bkgdIndex );
	
	theBackground->InitValue( inContext->stackEndPtr, kLEOInvalidateReferences, inContext );
	inContext->stackEndPtr ++;
	
	inContext->currentInstruction++;
}


void	WILDFirstCardInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CStack	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CStack*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			theStack = ownerObject;
	}
	
	if( theStack->GetNumCards() == 0 )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No such card." );
	}
	
	CCard	*	theCard = theStack->GetCard( 0 );
		
	if( inContext->flags & kLEOContextKeepRunning )	// No error?
	{
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		theCard->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	
	inContext->currentInstruction++;
}


void	WILDLastCardInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CStack	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CStack*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			theStack = ownerObject;
	}
	
	if( theStack->GetNumCards() == 0 )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No such card." );
	}
	
	CCard	*	theCard = theStack->GetCard( theStack->GetNumCards() -1 );
	
	if( inContext->flags & kLEOContextKeepRunning )	// No error?
	{
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		theCard->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	
	inContext->currentInstruction++;
}


void	WILDPushOrdinalBackgroundInstruction( LEOContext* inContext )
{
	CStack		*	theStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CStack	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CStack*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			theStack = ownerObject;
	}
	
	size_t		numBackgrounds = theStack ? theStack->GetNumBackgrounds() : 0;
	if( numBackgrounds == 0 )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No such background." );
	}
	
	if( inContext->flags & kLEOContextKeepRunning )
	{
		CBackground	*	theBackground = (inContext->currentInstruction->param1 & 32) ? theStack->GetBackground( numBackgrounds -1 ) : theStack->GetBackground(0);
		
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		theBackground->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	
	inContext->currentInstruction++;
}


void	WILDPushOrdinalPartInstruction( LEOContext* inContext )
{
	CStack			*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CCard			*	theCard = frontStack ? frontStack->GetCurrentCard() : NULL;
	CPartCreatorBase*	partType = NULL;
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CCard	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CCard*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
		{
			theCard = ownerObject;
			frontStack = theCard->GetStack();
		}
	}
	CBackground		*	theBackground = theCard ? theCard->GetBackground() : NULL;
	CLayer			*	theLayer = theCard;
		
	if( (inContext->currentInstruction->param1 & 16) != 0 )
		theLayer = theBackground;
	
	uint16_t	partTypeNum = inContext->currentInstruction->param1 & ~(16 | 32);
	
	if( partTypeNum == 1 )
		partType = CPart::GetPartCreatorForType("button");
	else if( partTypeNum == 2 )
		partType = CPart::GetPartCreatorForType("field");
	else if( partTypeNum == 3 )
		partType = CPart::GetPartCreatorForType("moviePlayer");
	else if( partTypeNum == 4 )
		partType = CPart::GetPartCreatorForType("browser");
	else if( partTypeNum != 0 )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Can only list parts, buttons, fields, browsers and movie players on cards and backgrounds." );
	}
	
	if( inContext->flags & kLEOContextKeepRunning )	// No error?
	{
		size_t		numParts = theLayer->GetPartCountOfType(partType);
		if( numParts == 0 )
		{
			size_t		lineNo = SIZE_T_MAX;
			uint16_t	fileID = 0;
			LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
			LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No such %s %s.", ((theCard == theLayer)? "card" : "background"), partType->GetPartTypeName().c_str() );
		}
		size_t	desiredIndex = 0;
		if( inContext->currentInstruction->param1 & 32 )
			desiredIndex = numParts -1;
		
		if( inContext->flags & kLEOContextKeepRunning )	// Still no error? I.e. we have parts of this type?
		{
			CPart	*	thePart = theLayer->GetPartOfType(desiredIndex, partType);
			
			LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
			thePart->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
		}
	}
	
	inContext->currentInstruction++;
}


void	WILDThisStackInstruction( LEOContext* inContext )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
		
	if( frontStack )
	{
		inContext->stackEndPtr++;
		frontStack->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;
}


void	WILDThisBackgroundInstruction( LEOContext* inContext )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CBackground	*	theBackground = frontStack ? frontStack->GetCurrentCard()->GetBackground() : NULL;
	
	if( theBackground )
	{
		inContext->stackEndPtr++;
		theBackground->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;
}


void	WILDThisCardInstruction( LEOContext* inContext )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CCard		*	theCard = frontStack ? frontStack->GetCurrentCard() : NULL;
	
	if( theCard )
	{
		inContext->stackEndPtr++;
		theCard->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;
}


void	WILDNumberOfCardPartsInstructionInternal( LEOContext* inContext, const char* typeName )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CCard		*	theCard = frontStack ? frontStack->GetCurrentCard() : NULL;
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CCard	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CCard*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
		{
			theCard = ownerObject;
			frontStack = theCard->GetStack();
		}
	}
	
	if( theCard )
	{
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		LEOInitIntegerValue( inContext->stackEndPtr -1, theCard->GetPartCountOfType(CPart::GetPartCreatorForType(typeName)), kLEOUnitNone, kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;

}


void	WILDNumberOfBackgroundPartsInstructionInternal( LEOContext* inContext, const char* typeName )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CCard		*	theCard = frontStack ? frontStack->GetCurrentCard() : NULL;
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CCard	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CCard*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
		{
			theCard = ownerObject;
			frontStack = theCard->GetStack();
		}
	}
	CBackground	*	theBackground = theCard ? theCard->GetBackground() : NULL;
	
	if( theBackground )
	{
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		LEOInitIntegerValue( inContext->stackEndPtr -1, theBackground->GetPartCountOfType(CPart::GetPartCreatorForType(typeName)), kLEOUnitNone, kLEOInvalidateReferences, inContext );
	}
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;

}


void	WILDNumberOfCardButtonsInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, "button" );
}


void	WILDNumberOfCardFieldsInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, "field" );
}


void	WILDNumberOfCardMoviePlayersInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, "moviePlayer" );
}


void	WILDNumberOfCardBrowsersInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, "browser" );
}


void	WILDNumberOfCardTimersInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, "timer" );
}


void	WILDNumberOfCardGraphicsInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, "graphic" );
}


void	WILDNumberOfCardPartsInstruction( LEOContext* inContext )
{
	WILDNumberOfCardPartsInstructionInternal( inContext, NULL );
}


void	WILDNumberOfBackgroundButtonsInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, "button" );
}


void	WILDNumberOfBackgroundFieldsInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, "field" );
}


void	WILDNumberOfBackgroundMoviePlayersInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, "moviePlayer" );
}


void	WILDNumberOfBackgroundBrowsersInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, "browser" );
}


void	WILDNumberOfBackgroundTimersInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, "timer" );
}


void	WILDNumberOfBackgroundGraphicsInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, "graphic" );
}


void	WILDNumberOfBackgroundPartsInstruction( LEOContext* inContext )
{
	WILDNumberOfBackgroundPartsInstructionInternal( inContext, NULL );
}


void	WILDNumberOfCardsInstruction( LEOContext* inContext )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	if( frontStack )
		LEOPushIntegerOnStack( inContext, frontStack->GetNumCards(), kLEOUnitNone );
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;
}


void	WILDNumberOfBackgroundsInstruction( LEOContext* inContext )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	LEOValuePtr		theOwner = inContext->stackEndPtr -1;
	theOwner = LEOFollowReferencesAndReturnValueOfType( theOwner, &kLeoValueTypeScriptableObject, inContext );
	if( theOwner && theOwner->base.isa == &kLeoValueTypeScriptableObject )
	{
		CStack	*	ownerObject = NULL;
		ownerObject = dynamic_cast<CStack*>((CScriptableObject*)theOwner->object.object);
		if( ownerObject )
			frontStack = ownerObject;
	}
	if( frontStack )
		LEOPushIntegerOnStack( inContext, frontStack->GetNumBackgrounds(), kLEOUnitNone );
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No stack open at the moment." );
	}
	
	inContext->currentInstruction++;
}


void	WILDNumberOfStacksInstruction( LEOContext* inContext )
{
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CDocument	*	doc = frontStack ? frontStack->GetDocument() : NULL;
	if( doc )
		LEOPushIntegerOnStack( inContext, doc->GetNumStacks(), kLEOUnitNone );
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No document open at the moment." );
	}
	
	inContext->currentInstruction++;
}


void	WILDMessageBoxInstruction( LEOContext* inContext )
{
	CMessageBox*	msg = CMessageBox::GetSharedInstance();
		
	inContext->stackEndPtr++;
	msg->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	
	inContext->currentInstruction++;
}


void	WILDMessageWatcherInstruction( LEOContext* inContext )
{
	CMessageWatcher*	msg = CMessageWatcher::GetSharedInstance();
	
	inContext->stackEndPtr++;
	msg->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	
	inContext->currentInstruction++;
}


void	WILDVariableWatcherInstruction( LEOContext* inContext )
{
	CVariableWatcher*	msg = CVariableWatcher::GetSharedInstance();
	
	inContext->stackEndPtr++;
	msg->InitValue( (inContext->stackEndPtr -1), kLEOInvalidateReferences, inContext );
	
	inContext->currentInstruction++;
}


void	WILDPushNumberOfScreensInstruction( LEOContext* inContext )
{
	LEOPushIntegerOnStack( inContext, CScreen::GetNumScreens(), kLEOUnitNone );
	
	inContext->currentInstruction++;
}


void	WILDPushScreenInstruction( LEOContext* inContext )
{
	LEOUnit						outUnit = kLEOUnitNone;
	LEOValuePtr					screenIndexValue = (inContext->stackEndPtr -1);
	
	LEOInteger	screenIndex = LEOGetValueAsInteger( screenIndexValue, &outUnit, inContext );
	
	if( screenIndex < 1 || screenIndex > (long long)CScreen::GetNumScreens() )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Screen index %lld out of bounds.", screenIndex );
		return;
	}
	
	CScreen	currScreen = CScreen::GetScreen(screenIndex -1);
	struct LEOArrayEntry	*	currScreenArray = NULL;
	
	CRect screenFrame = currScreen.GetRectangle();
	LEOAddRectArrayEntryToRoot( &currScreenArray, "rectangle", screenFrame.GetH(), screenFrame.GetV(), screenFrame.GetMaxH(), screenFrame.GetMaxV(), inContext );
	CRect screenVisibleFrame = currScreen.GetWorkingRectangle();
	LEOAddRectArrayEntryToRoot( &currScreenArray, "working rectangle", screenVisibleFrame.GetH(), screenVisibleFrame.GetV(), screenVisibleFrame.GetMaxH(), screenVisibleFrame.GetMaxV(), inContext );
	LEOAddIntegerArrayEntryToRoot( &currScreenArray, "scaleFactor", currScreen.GetScale(), kLEOUnitNone, inContext );
	
	LEOCleanUpValue( screenIndexValue, kLEOInvalidateReferences, inContext );
	LEOInitArrayValue( &screenIndexValue->array, currScreenArray, kLEOInvalidateReferences, inContext );	// Takes over ownership of currScreenArray.
	
	inContext->currentInstruction++;
}


void	WILDPushThisProjectInstruction( LEOContext* inContext )
{
	CDocument	*	frontProject = nullptr;
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	if( frontStack )
		frontProject = frontStack->GetDocument();
	inContext->stackEndPtr++;
	if( frontProject )
		frontProject->InitValue( inContext->stackEndPtr -1, kLEOKeepReferences, inContext );
	else
		LEOInitUnsetValue( inContext->stackEndPtr -1, kLEOKeepReferences, inContext );
	inContext->currentInstruction++;
}


void	WILDPushProjectInstruction( LEOContext* inContext )
{
	LEOValuePtr		screenIndexValue = (inContext->stackEndPtr -1);
	CDocument	*	foundDoc = nullptr;
	
	if( LEOCanGetAsNumber( screenIndexValue, inContext ) )
	{
		LEOUnit		outUnit = kLEOUnitNone;

		LEOInteger	screenIndex = LEOGetValueAsInteger( screenIndexValue, &outUnit, inContext );
		LEOCleanUpValue( screenIndexValue, kLEOInvalidateReferences, inContext );
		
		foundDoc = CDocumentManager::GetSharedDocumentManager()->GetDocument( screenIndex -1 );
	}
	else
	{
		char		buf[512] = {};
		const char*	projectName = LEOGetValueAsString( screenIndexValue, buf, sizeof(buf), inContext );
		
		foundDoc = CDocumentManager::GetSharedDocumentManager()->GetDocumentWithName( projectName );
		LEOCleanUpValue( screenIndexValue, kLEOInvalidateReferences, inContext );
	}
	if( foundDoc && foundDoc->GetScriptContextGroupObject() == inContext->group )
		foundDoc->InitValue( screenIndexValue, kLEOInvalidateReferences, inContext );
	else
		LEOInitUnsetValue( screenIndexValue, kLEOInvalidateReferences, inContext );
	inContext->currentInstruction++;
}


void	WILDPushMenuInstruction( LEOContext* inContext )
{
	char			idStrBuf[256] = {0};
	const char*		idStr = LEOGetValueAsString( inContext->stackEndPtr -2, idStrBuf, sizeof(idStrBuf), inContext );
	bool			lookUpByID = idStr[0] != 0;
	LEOValuePtr		screenIndexValue = (inContext->stackEndPtr -1);
	CStack		*	frontStack = ((CScriptContextUserData*)inContext->userData)->GetStack();
	CDocument	*	frontProject = frontStack ? frontStack->GetDocument() : nullptr;
	CMenu		*	foundMenu = nullptr;
	
	if( lookUpByID )
	{
		LEOUnit		outUnit = kLEOUnitNone;
		
		LEOInteger	screenIndex = LEOGetValueAsInteger( screenIndexValue, &outUnit, inContext );
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -1);
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		
		foundMenu = frontProject->GetMenuWithID( screenIndex );
	}
	else if( LEOCanGetAsNumber( screenIndexValue, inContext ) )
	{
		LEOUnit		outUnit = kLEOUnitNone;
		
		LEOInteger	screenIndex = LEOGetValueAsInteger( screenIndexValue, &outUnit, inContext );
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -1);
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		
		if( screenIndex > (long long)frontProject->GetNumMenus() )
		{
			size_t		lineNo = SIZE_T_MAX;
			uint16_t	fileID = 0;
			LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
			LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Menu index %lld out of bounds.", screenIndex );
		}
		else
			foundMenu = frontProject->GetMenu( screenIndex -1 );
	}
	else
	{
		char		buf[512] = {};
		const char*	projectName = LEOGetValueAsString( screenIndexValue, buf, sizeof(buf), inContext );
		if( (inContext->flags & kLEOContextKeepRunning) == 0 )
			return;
		
		foundMenu = frontProject->GetMenuWithName( projectName );
		if( foundMenu == nullptr )
		{
			size_t		lineNo = SIZE_T_MAX;
			uint16_t	fileID = 0;
			LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
			LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No menu named \"%s\".", projectName );
			return;
		}
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -1 );
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
	}
	if( foundMenu )
		foundMenu->InitValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
	else
		LEOInitUnsetValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
	inContext->currentInstruction++;
	
	//LEODebugPrintContext(inContext);
}


void	WILDPushMenuItemInstruction( LEOContext* inContext )
{
	char			idStrBuf[256] = {0};
	const char*		idStr = LEOGetValueAsString( inContext->stackEndPtr -3, idStrBuf, sizeof(idStrBuf), inContext );
	bool			lookUpByID = idStr[0] != 0;
	LEOValuePtr		screenIndexValue = (inContext->stackEndPtr -2);
	LEOValuePtr		menuObjectValue = (inContext->stackEndPtr -1);
	CMenu		*	ownerObject = nullptr;
	CMenuItem	*	foundMenuItem = nullptr;
	
	menuObjectValue = LEOFollowReferencesAndReturnValueOfType( menuObjectValue, &kLeoValueTypeScriptableObject, inContext );
	if( menuObjectValue && menuObjectValue->base.isa == &kLeoValueTypeScriptableObject )
		ownerObject = dynamic_cast<CMenu*>((CScriptableObject*)menuObjectValue->object.object);
	if( !ownerObject )
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Only menus contain menuItems." );
		return;
	}
	
	if( lookUpByID )
	{
		LEOUnit		outUnit = kLEOUnitNone;
		
		LEOInteger	screenIndex = LEOGetValueAsInteger( screenIndexValue, &outUnit, inContext );
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2);
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		
		foundMenuItem = ownerObject->GetItemWithID( screenIndex );
	}
	else if( LEOCanGetAsNumber( screenIndexValue, inContext ) )
	{
		LEOUnit		outUnit = kLEOUnitNone;
		
		LEOInteger	screenIndex = LEOGetValueAsInteger( screenIndexValue, &outUnit, inContext );
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2);
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
		
		if( screenIndex > (long long)ownerObject->GetNumItems() )
		{
			size_t		lineNo = SIZE_T_MAX;
			uint16_t	fileID = 0;
			LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
			LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "Menu index %lld out of bounds.", screenIndex );
		}
		else
			foundMenuItem = ownerObject->GetItem( screenIndex -1 );
	}
	else
	{
		char		buf[512] = {};
		const char*	projectName = LEOGetValueAsString( screenIndexValue, buf, sizeof(buf), inContext );
		
		foundMenuItem = ownerObject->GetItemWithName( projectName );
		LEOCleanUpStackToPtr( inContext, inContext->stackEndPtr -2);
		LEOCleanUpValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
	}
	if( foundMenuItem )
		foundMenuItem->InitValue( inContext->stackEndPtr -1, kLEOInvalidateReferences, inContext );
	else
	{
		size_t		lineNo = SIZE_T_MAX;
		uint16_t	fileID = 0;
		LEOInstructionsFindLineForInstruction( inContext->currentInstruction, &lineNo, &fileID );
		LEOContextStopWithError( inContext, lineNo, SIZE_T_MAX, fileID, "No such menu item." );
	}
	inContext->currentInstruction++;
	
	//LEODebugPrintContext(inContext);
}


#pragma mark Host Instruction array

LEOINSTR_START(StacksmithHostFunction,WILD_NUMBER_OF_HOST_FUNCTION_INSTRUCTIONS)
LEOINSTR(WILDStackInstruction)
LEOINSTR(WILDBackgroundInstruction)
LEOINSTR(WILDCardInstruction)
LEOINSTR(WILDCardFieldInstruction)
LEOINSTR(WILDCardButtonInstruction)
LEOINSTR(WILDCardMoviePlayerInstruction)
LEOINSTR(WILDCardPartInstruction)
LEOINSTR(WILDBackgroundFieldInstruction)
LEOINSTR(WILDBackgroundButtonInstruction)
LEOINSTR(WILDBackgroundMoviePlayerInstruction)
LEOINSTR(WILDBackgroundPartInstruction)
LEOINSTR(WILDNextCardInstruction)
LEOINSTR(WILDPreviousCardInstruction)
LEOINSTR(WILDFirstCardInstruction)
LEOINSTR(WILDLastCardInstruction)
LEOINSTR(WILDNextBackgroundInstruction)
LEOINSTR(WILDPreviousBackgroundInstruction)
LEOINSTR(WILDPushOrdinalBackgroundInstruction)
LEOINSTR(WILDPushOrdinalPartInstruction)
LEOINSTR(WILDThisStackInstruction)
LEOINSTR(WILDThisBackgroundInstruction)
LEOINSTR(WILDThisCardInstruction)
LEOINSTR(WILDNumberOfCardButtonsInstruction)
LEOINSTR(WILDNumberOfCardFieldsInstruction)
LEOINSTR(WILDNumberOfCardMoviePlayersInstruction)
LEOINSTR(WILDNumberOfCardPartsInstruction)
LEOINSTR(WILDNumberOfBackgroundButtonsInstruction)
LEOINSTR(WILDNumberOfBackgroundFieldsInstruction)
LEOINSTR(WILDNumberOfBackgroundMoviePlayersInstruction)
LEOINSTR(WILDNumberOfBackgroundPartsInstruction)
LEOINSTR(WILDCardTimerInstruction)
LEOINSTR(WILDBackgroundTimerInstruction)
LEOINSTR(WILDNumberOfCardTimersInstruction)
LEOINSTR(WILDNumberOfBackgroundTimersInstruction)
LEOINSTR(WILDCardGraphicInstruction)
LEOINSTR(WILDBackgroundGraphicInstruction)
LEOINSTR(WILDNumberOfCardGraphicsInstruction)
LEOINSTR(WILDNumberOfBackgroundGraphicsInstruction)
LEOINSTR(WILDMessageBoxInstruction)
LEOINSTR(WILDMessageWatcherInstruction)
LEOINSTR(WILDVariableWatcherInstruction)
LEOINSTR(WILDCardBrowserInstruction)
LEOINSTR(WILDBackgroundBrowserInstruction)
LEOINSTR(WILDNumberOfCardBrowsersInstruction)
LEOINSTR(WILDNumberOfBackgroundBrowsersInstruction)
LEOINSTR(WILDNumberOfCardsInstruction)
LEOINSTR(WILDNumberOfBackgroundsInstruction)
LEOINSTR(WILDNumberOfStacksInstruction)
LEOINSTR(WILDPushNumberOfScreensInstruction)
LEOINSTR(WILDPushScreenInstruction)
LEOINSTR(WILDPushThisProjectInstruction)
LEOINSTR(WILDPushProjectInstruction)
LEOINSTR(WILDPushMenuInstruction)
LEOINSTR_LAST(WILDPushMenuItemInstruction)


#pragma mark Host function syntax table

struct THostCommandEntry	gStacksmithHostFunctions[] =
{
	{
		EStackIdentifier, WILD_STACK_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' }
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_PART_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EPartIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_BUTTON_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EButtonIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_FIELD_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EFieldIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_BROWSER_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EBrowserIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_TIMER_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, ETimerIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_GRAPHIC_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EGraphicIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_MOVIEPLAYER_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamInvisibleIdentifier, EPlayerIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBackgroundIdentifier, WILD_BACKGROUND_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_BROWSER_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EBrowserIdentifier, EHostParameterRequired, WILD_CARD_BROWSER_INSTRUCTION, 0, 0, '\0', 'A' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'A' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_MOVIEPLAYER_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EMovieIdentifier, EHostParameterRequired, WILD_CARD_MOVIEPLAYER_INSTRUCTION, 0, 0, '\0', 'B' },
			{ EHostParamIdentifier, EPlayerIdentifier, EHostParameterOptional, WILD_CARD_MOVIEPLAYER_INSTRUCTION, 0, 0, 'B', 'A' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'A' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_PART_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EPartIdentifier, EHostParameterRequired, WILD_CARD_PART_INSTRUCTION, 0, 0, '\0', 'A' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'A' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_FIELD_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EFieldIdentifier, EHostParameterRequired, WILD_CARD_FIELD_INSTRUCTION, 0, 0, '\0', 'A' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'A' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_BUTTON_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EButtonIdentifier, EHostParameterRequired, WILD_CARD_BUTTON_INSTRUCTION, 0, 0, '\0', 'A' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'A' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_GRAPHIC_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EGraphicIdentifier, EHostParameterRequired, WILD_CARD_GRAPHIC_INSTRUCTION, 0, 0, '\0', 'A' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'A' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EFieldIdentifier, WILD_CARD_FIELD_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EButtonIdentifier, WILD_CARD_BUTTON_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EMovieIdentifier, WILD_CARD_MOVIEPLAYER_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EPlayerIdentifier, EHostParameterRequired, WILD_CARD_MOVIEPLAYER_INSTRUCTION, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EBrowserIdentifier, WILD_CARD_BROWSER_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EPartIdentifier, WILD_CARD_PART_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ETimerIdentifier, WILD_CARD_TIMER_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EGraphicIdentifier, WILD_CARD_GRAPHIC_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ECardIdentifier, WILD_CARD_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'A' },
			{ EHostParamInvisibleIdentifier, EScreensIdentifier, EHostParameterRequired, WILD_PUSH_NUMBER_OF_SCREENS_INSTRUCTION, 0, 0, 'A', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'A' },
			{ EHostParamInvisibleIdentifier, ECardsIdentifier, EHostParameterRequired, WILD_NUMBER_OF_CARDS_INSTRUCTION, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'A' },
			{ EHostParamInvisibleIdentifier, EBackgroundsIdentifier, EHostParameterRequired, WILD_NUMBER_OF_BACKGROUNDS_INSTRUCTION, 0, 0, 'A', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'A' },
			{ EHostParamInvisibleIdentifier, EStacksIdentifier, EHostParameterRequired, WILD_NUMBER_OF_STACKS_INSTRUCTION, 0, 0, 'A', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'A' },
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'A', 'B' },
			{ EHostParamInvisibleIdentifier, EButtonsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_BACKGROUND_BUTTONS_INSTRUCTION, 0, 0, 'B', 'X' },
			{ EHostParamInvisibleIdentifier, EFieldsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_BACKGROUND_FIELDS_INSTRUCTION, 0, 0, 'B', 'X' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'B', 'M' },
			{ EHostParamInvisibleIdentifier, EPlayersIdentifier, EHostParameterOptional, WILD_NUMBER_OF_BACKGROUND_MOVIEPLAYERS_INSTRUCTION, 0, 0, 'M', 'X' },
			{ EHostParamInvisibleIdentifier, EPartsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_BACKGROUND_PARTS_INSTRUCTION, 0, 0, 'B', 'X' },
			{ EHostParamInvisibleIdentifier, ETimersIdentifier, EHostParameterOptional, WILD_NUMBER_OF_BACKGROUND_TIMERS_INSTRUCTION, 0, 0, 'B', 'X' },
			{ EHostParamInvisibleIdentifier, EGraphicsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_BACKGROUND_GRAPHICS_INSTRUCTION, 0, 0, 'B', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'A' },
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'A', 'C' },
			{ EHostParamInvisibleIdentifier, EButtonsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_BUTTONS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, EFieldsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_FIELDS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'C', 'm' },
			{ EHostParamInvisibleIdentifier, EPlayersIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_MOVIEPLAYERS_INSTRUCTION, 0, 0, 'm', 'X' },
			{ EHostParamInvisibleIdentifier, EPartsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_PARTS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, ETimersIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_TIMERS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, EGraphicsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_GRAPHICS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENumberIdentifier, INVALID_INSTR2, 0, 0, 'N', 'X',
		{
			{ EHostParamInvisibleIdentifier, EOfIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, 'N', 'C' },
			{ EHostParamInvisibleIdentifier, EButtonsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_BUTTONS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, EFieldsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_FIELDS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'C', 'm' },
			{ EHostParamInvisibleIdentifier, EPlayersIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_MOVIEPLAYERS_INSTRUCTION, 0, 0, 'm', 'X' },
			{ EHostParamInvisibleIdentifier, EPartsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_PARTS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, ETimersIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_TIMERS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamInvisibleIdentifier, EGraphicsIdentifier, EHostParameterOptional, WILD_NUMBER_OF_CARD_GRAPHICS_INSTRUCTION, 0, 0, 'C', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ENextIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterOptional, WILD_NEXT_CARD_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterOptional, WILD_NEXT_BACKGROUND_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EPreviousIdentifier, WILD_PREVIOUS_CARD_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterOptional, WILD_PREVIOUS_CARD_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterOptional, WILD_PREVIOUS_BACKGROUND_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EFirstIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_BACKGROUND_INSTRUCTION, 32, 0, '\0', 'B' },
			{ EHostParamInvisibleIdentifier, EButtonIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 16+1, 0, 'B', 'x' },
			{ EHostParamInvisibleIdentifier, EFieldIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 16+2, 0, 'B', 'x' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 16+3, 0, 'B', 'z' },
			{ EHostParamInvisibleIdentifier, EPlayerIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 16+3, 0, 'z', 'x' },
			{ EHostParamInvisibleIdentifier, EPartIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 16+0, 0, 'B', 'x' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'x', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EFirstIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterOptional, WILD_FIRST_CARD_INSTRUCTION, 0, 0, '\0', 'C' },
			{ EHostParamInvisibleIdentifier, EButtonIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 1, 0, 'C', 'x' },
			{ EHostParamInvisibleIdentifier, EFieldIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 2, 0, 'C', 'x' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 3, 0, 'C', 'y' },
			{ EHostParamInvisibleIdentifier, EPlayerIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 3, 0, 'y', 'x' },
			{ EHostParamInvisibleIdentifier, EPartIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 0, 0, 'C', 'x' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'x', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EFirstIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_BACKGROUND_INSTRUCTION, 32, 0, '\0', 'B' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'B', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EFirstIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterRequired, WILD_FIRST_CARD_INSTRUCTION, 0, 0, '\0', 'C' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'C', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ELastIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_BACKGROUND_INSTRUCTION, 0, 0, '\0', 'B' },
			{ EHostParamInvisibleIdentifier, EButtonIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+16+1, 0, 'B', 'x' },
			{ EHostParamInvisibleIdentifier, EFieldIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+16+2, 0, 'B', 'x' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+16+3, 0, 'B', 'z' },
			{ EHostParamInvisibleIdentifier, EPlayerIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+16+3, 0, 'z', 'x' },
			{ EHostParamInvisibleIdentifier, EPartIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+16+0, 0, 'B', 'x' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'x', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ELastIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterRequired, WILD_LAST_CARD_INSTRUCTION, 0, 0, '\0', 'C' },
			{ EHostParamInvisibleIdentifier, EButtonIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+1, 0, 'C', 'x' },
			{ EHostParamInvisibleIdentifier, EFieldIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+2, 0, 'C', 'x' },
			{ EHostParamInvisibleIdentifier, EMovieIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+3, 0, 'C', 'y' },
			{ EHostParamInvisibleIdentifier, EPlayerIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+3, 0, 'y', 'x' },
			{ EHostParamInvisibleIdentifier, EPartIdentifier, EHostParameterOptional, WILD_PUSH_ORDINAL_PART_INSTRUCTION, 32+0, 0, 'C', 'x' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'x', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ELastIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterRequired, WILD_PUSH_ORDINAL_BACKGROUND_INSTRUCTION, 0, 0, '\0', 'B' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'B', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		ELastIdentifier, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterRequired, WILD_LAST_CARD_INSTRUCTION, 0, 0, '\0', 'C' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'C', 'x' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EThisIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EStackIdentifier, EHostParameterOptional, WILD_THIS_STACK_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParamInvisibleIdentifier, EBackgroundIdentifier, EHostParameterOptional, WILD_THIS_BACKGROUND_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParamInvisibleIdentifier, ECardIdentifier, EHostParameterOptional, WILD_THIS_CARD_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParamInvisibleIdentifier, EProjectIdentifier, EHostParameterOptional, WILD_PUSH_THIS_PROJECT_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EMessageIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EBoxIdentifier, EHostParameterOptional, WILD_MESSAGE_BOX_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParamInvisibleIdentifier, EWatcherIdentifier, EHostParameterOptional, WILD_MESSAGE_WATCHER_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EVariableIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EWatcherIdentifier, EHostParameterRequired, WILD_VARIABLE_WATCHER_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EScreenIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, WILD_PUSH_SCREEN_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EProjectIdentifier, INVALID_INSTR2, 0, 0, '\0', 'X',
		{
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, WILD_PUSH_PROJECT_INSTRUCTION, 0, 0, '\0', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	},
	{
		EMenuIdentifier, WILD_PUSH_MENUITEM_INSTRUCTION, 0, 0, '\0', 'X',
		{
			{ EHostParamInvisibleIdentifier, EItemIdentifier, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', 'X' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, 'X', 'X' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' }
		}
	},
	{
		EMenuIdentifier, WILD_PUSH_MENU_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' }
		}
	},
	{
		EMenuItemIdentifier, WILD_PUSH_MENUITEM_INSTRUCTION, 0, 0, '\0', '\0',
		{
			{ EHostParamIdentifier, EIdIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamImmediateValue, ELastIdentifier_Sentinel, EHostParameterRequired, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParamLabeledValue, EOfIdentifier, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' }
		}
	},
	{	// END INDICATOR MUST BE LAST!!!
		ELastIdentifier_Sentinel, INVALID_INSTR2, 0, 0, '\0', '\0',
		{
			{ EHostParam_Sentinel, ELastIdentifier_Sentinel, EHostParameterOptional, INVALID_INSTR2, 0, 0, '\0', '\0' },
		}
	}
};
