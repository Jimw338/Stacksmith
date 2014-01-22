//
//  WILDStackWindowController.mm
//  Stacksmith
//
//  Created by Uli Kusterer on 2014-01-13.
//  Copyright (c) 2014 Uli Kusterer. All rights reserved.
//

#include "WILDStackWindowController.h"
#include "CStackMac.h"
#include "CCard.h"
#include "CBackground.h"
#include "CDocument.h"
#include "CMacPartBase.h"


using namespace Carlson;


@implementation WILDFlippedContentView

-(BOOL)	isFlipped
{
	return YES;
}


-(NSView *)	hitTest: (NSPoint)aPoint
{
	NSView	*	hitView = [super hitTest: aPoint];
	if( hitView != nil )
		return self;
	return nil;
}


-(void)	mouseDown: (NSEvent*)theEvt
{
	NSPoint		hitPos = [self convertPoint: [theEvt locationInWindow] fromView: nil];
	CStack	*	theStack = [(WILDStackWindowController*)[[self window] windowController] cppStack];
	CCard	*	theCard = theStack->GetCurrentCard();
	bool		foundOne = false;
	
	size_t		numParts = theCard->GetNumParts();
	for( size_t x = numParts; x > 0; x-- )
	{
		CPart	*	thePart = theCard->GetPart( x-1 );
		if( !foundOne && hitPos.x > thePart->GetLeft() && hitPos.x < thePart->GetRight()
			&& hitPos.y > thePart->GetTop() && hitPos.y < thePart->GetBottom() )
		{
			thePart->SetSelected(true);
			foundOne = true;
		}
		else
			thePart->SetSelected(false);
	}
	numParts = theCard->GetBackground()->GetNumParts();
	for( size_t x = numParts; x > 0; x-- )
	{
		CPart	*	thePart = theCard->GetBackground()->GetPart( x-1 );
		if( !foundOne && hitPos.x > thePart->GetLeft() && hitPos.x < thePart->GetRight()
			&& hitPos.y > thePart->GetTop() && hitPos.y < thePart->GetBottom() )
		{
			thePart->SetSelected(true);
			foundOne = true;
		}
		else
			thePart->SetSelected(false);
	}
	[(WILDStackWindowController*)[[self window] windowController] drawBoundingBoxes];
}

@end


@implementation WILDStackWindowController

-(id)	initWithCppStack: (CStackMac*)inStack
{
	NSRect			wdBox = NSMakeRect(0,0,inStack->GetCardWidth(),inStack->GetCardHeight());
	NSWindow	*	theWindow = [[[NSWindow alloc] initWithContentRect: wdBox styleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask backing: NSBackingStoreBuffered defer: NO] autorelease];
	NSView*	cv = [[[WILDFlippedContentView alloc] initWithFrame: wdBox] autorelease];
	cv.wantsLayer = YES;
	[cv setLayerUsesCoreImageFilters: YES];
	theWindow.contentView = cv;
	[theWindow setCollectionBehavior: NSWindowCollectionBehaviorFullScreenPrimary];
	[theWindow setTitle: [NSString stringWithUTF8String: inStack->GetName().c_str()]];
	[theWindow setRepresentedURL: [NSURL URLWithString: [NSString stringWithUTF8String: inStack->GetURL().c_str()]]];
	[theWindow center];
	[theWindow setDelegate: self];

	self = [super initWithWindow: theWindow];
	if( self )
	{
		mStack = inStack;
	}
	
	return self;
}


-(void)	dealloc
{
	[mSelectionOverlay release];
	mSelectionOverlay = nil;
	
	[super dealloc];
}


-(void)	removeAllViews
{
	CCard	*	theCard = mStack->GetCurrentCard();
	if( !theCard )
		return;
	
	size_t	numParts = theCard->GetNumParts();
	for( size_t x = 0; x < numParts; x++ )
	{
		CMacPartBase*	currPart = dynamic_cast<CMacPartBase*>(theCard->GetPart(x));
		if( !currPart )
			continue;
		currPart->DestroyView();
	}
	
	[mSelectionOverlay removeFromSuperlayer];
	[mSelectionOverlay release];
	mSelectionOverlay = nil;
}


-(void)	createAllViews
{
	[mBackgroundImageView removeFromSuperview];
	[mBackgroundImageView release];
	mBackgroundImageView = nil;
	[mCardImageView removeFromSuperview];
	[mCardImageView release];
	mCardImageView = nil;
	
	CCard	*	theCard = mStack->GetCurrentCard();
	if( !theCard )
		return;
	
	CBackground	*	theBackground = theCard->GetBackground();
	std::string		bgPictureURL( theBackground->GetPictureURL() );
	if( theBackground->GetShowPicture() && bgPictureURL.length() > 0 )
	{
		mBackgroundImageView = [[NSImageView alloc] initWithFrame: NSMakeRect(0,0,mStack->GetCardWidth(), mStack->GetCardHeight())];
		[mBackgroundImageView setWantsLayer: YES];
		mBackgroundImageView.image = [[[NSImage alloc] initByReferencingURL: [NSURL URLWithString: [NSString stringWithUTF8String: bgPictureURL.c_str()]]] autorelease];
		[self.window.contentView addSubview: mBackgroundImageView];
	}
	
	size_t	numParts = theBackground->GetNumParts();
	for( size_t x = 0; x < numParts; x++ )
	{
		CMacPartBase*	currPart = dynamic_cast<CMacPartBase*>(theBackground->GetPart(x));
		if( !currPart )
			continue;
		currPart->CreateViewIn( self.window.contentView );
	}

	numParts = theCard->GetNumParts();
	std::string		cdPictureURL( theCard->GetPictureURL() );
	if( theCard->GetShowPicture() && cdPictureURL.length() > 0 )
	{
		mCardImageView = [[NSImageView alloc] initWithFrame: NSMakeRect(0,0,mStack->GetCardWidth(), mStack->GetCardHeight())];
		[mCardImageView setWantsLayer: YES];
		mCardImageView.image = [[[NSImage alloc] initByReferencingURL: [NSURL URLWithString: [NSString stringWithUTF8String: cdPictureURL.c_str()]]] autorelease];
		[self.window.contentView addSubview: mCardImageView];
	}
	for( size_t x = 0; x < numParts; x++ )
	{
		CMacPartBase*	currPart = dynamic_cast<CMacPartBase*>(theCard->GetPart(x));
		if( !currPart )
			continue;
		currPart->CreateViewIn( self.window.contentView );
	}
	
	[self drawBoundingBoxes];
}


-(void)	drawBoundingBoxes
{
	[mSelectionOverlay removeFromSuperlayer];
	[mSelectionOverlay release];
	mSelectionOverlay = nil;
	
	CCard	*	theCard = mStack->GetCurrentCard();
	if( !theCard )
		return;
	
	CGColorSpaceRef	colorSpace = CGColorSpaceCreateWithName( kCGColorSpaceGenericRGB );
	CGContextRef	bmContext = CGBitmapContextCreate( NULL, mStack->GetCardWidth(), mStack->GetCardHeight(), 8, mStack->GetCardWidth() * 8 * 4, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little );
	CGColorSpaceRelease(colorSpace);
	NSGraphicsContext	*	cocoaContext = [NSGraphicsContext graphicsContextWithGraphicsPort: bmContext flipped: NO];
	[NSGraphicsContext saveGraphicsState];
	[NSGraphicsContext setCurrentContext: cocoaContext];
	
	NSColor	*	peekColor = [NSColor colorWithPatternImage: [NSImage imageNamed: @"PAT_22"]];
	[NSBezierPath setDefaultLineWidth: 1];
	const CGFloat		theDashes[] = { 4, 4 };
	NSTimeInterval		currTime = [NSDate timeIntervalSinceReferenceDate];
	
	size_t		cardHeight = mStack->GetCardHeight();
	
	CBackground	*	theBackground = theCard->GetBackground();
	size_t	numParts = theBackground->GetNumParts();
	for( size_t x = 0; x < numParts; x++ )
	{
		CPart*	currPart = theBackground->GetPart(x);
		if( currPart->IsSelected() )
		{
			NSBezierPath		*		rectPath = [NSBezierPath bezierPathWithRect: NSMakeRect(currPart->GetLeft() +0.5, cardHeight -currPart->GetBottom() +0.5, currPart->GetRight() -currPart->GetLeft() -1.0, currPart->GetBottom() -currPart->GetTop() -1.0 )];
			[[NSColor whiteColor] set];
			[rectPath stroke];
			[rectPath setLineDash: theDashes count: sizeof(theDashes) / sizeof(CGFloat) phase: currTime];
			[[NSColor darkGrayColor] set];
			[rectPath stroke];
		}
		else if( mStack->GetPeeking() )
		{
			[peekColor set];
			[NSBezierPath strokeRect: NSMakeRect(currPart->GetLeft() +0.5, cardHeight -currPart->GetBottom() +0.5, currPart->GetRight() -currPart->GetLeft() -1.0, currPart->GetBottom() -currPart->GetTop() -1.0 )];
		}
	}

	numParts = theCard->GetNumParts();
	for( size_t x = 0; x < numParts; x++ )
	{
		CPart*	currPart = theCard->GetPart(x);
		if( currPart->IsSelected() )
		{
			NSBezierPath		*		rectPath = [NSBezierPath bezierPathWithRect: NSMakeRect(currPart->GetLeft() +0.5, cardHeight -currPart->GetBottom() +0.5, currPart->GetRight() -currPart->GetLeft() -1.0, currPart->GetBottom() -currPart->GetTop() -1.0 )];
			[[NSColor whiteColor] set];
			[rectPath stroke];
			[rectPath setLineDash: theDashes count: sizeof(theDashes) / sizeof(CGFloat) phase: currTime];
			[[NSColor darkGrayColor] set];
			[rectPath stroke];
		}
		else if( mStack->GetPeeking() )
		{
			[peekColor set];
			[NSBezierPath strokeRect: NSMakeRect(currPart->GetLeft() +0.5, cardHeight -currPart->GetBottom() +0.5, currPart->GetRight() -currPart->GetLeft() -1.0, currPart->GetBottom() -currPart->GetTop() -1.0 )];
		}
	}

	mSelectionOverlay = [[CALayer alloc] init];
	[[self.window.contentView layer] addSublayer: mSelectionOverlay];
	[mSelectionOverlay setFrame: [self.window.contentView layer].frame];
	
	[NSGraphicsContext restoreGraphicsState];
	CGImageRef	bmImage = CGBitmapContextCreateImage( bmContext );
	mSelectionOverlay.contents = [(id)bmImage autorelease];
	
	CFRelease(bmContext);
}


-(Carlson::CStackMac*)	cppStack
{
	return mStack;
}


-(void)	windowDidBecomeKey: (NSNotification *)notification
{
	CStack::SetFrontStack( mStack );
}


-(void)	windowDidBecomeMain: (NSNotification *)notification
{
	CStack::SetFrontStack( mStack );
}

@end