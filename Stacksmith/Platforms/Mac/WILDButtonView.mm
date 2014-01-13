//
//  WILDButtonView.mm
//  Stacksmith
//
//  Created by Uli Kusterer on 09.05.10.
//  Copyright 2010 Uli Kusterer. All rights reserved.
//

#import "WILDButtonView.h"
#import "UKHelperMacros.h"
#include "CDocument.h"
#include "CAlert.h"


using namespace Carlson;


@implementation WILDButtonView

@synthesize owningPart = owningPart;

-(void)	dealloc
{
	[self removeTrackingArea: mCursorTrackingArea];
	DESTROY_DEALLOC(mCursorTrackingArea);
	if( self->owningPart )
		self->owningPart->Release();

	[super dealloc];
}


-(void)	setOwningPart: (CButtonPart*)inPart
{
	if( self->owningPart != inPart )
	{
		if( self->owningPart )
			self->owningPart->Release();
		if( inPart )
			self->owningPart = (CButtonPart*) inPart->Retain();
		else
			self->owningPart = NULL;
	}
}


-(void)	mouseDown: (NSEvent*)event
{
	BOOL					keepLooping = YES;
	BOOL					autoHighlight = self->owningPart->GetAutoHighlight();
	BOOL					isInside = [[self cell] hitTestForEvent: event inRect: [self bounds] ofView: self] != NSCellHitNone;
	BOOL					newIsInside = isInside;
	
	if( !isInside || !self.isEnabled )
		return;
	
	if( autoHighlight && isInside )
		[[self cell] setHighlighted: YES];
	
	self->owningPart->SendMessage( NULL, [](const char* errMsg,size_t,size_t,CScriptableObject*) { if( errMsg ) CAlert::RunMessageAlert(errMsg); }, "mouseDown %ld", [event buttonNumber] +1 );
	
	NSAutoreleasePool	*	pool = [[NSAutoreleasePool alloc] init];
	
	while( keepLooping )
	{
		NSEvent	*	evt = [NSApp nextEventMatchingMask: NSLeftMouseUpMask | NSRightMouseUpMask | NSOtherMouseUpMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask | NSOtherMouseDraggedMask untilDate: [NSDate distantFuture] inMode: NSEventTrackingRunLoopMode dequeue: YES];
		if( evt )
		{
			switch( [evt type] )
			{
				 case NSLeftMouseUp:
				 case NSRightMouseUp:
				 case NSOtherMouseUp:
					keepLooping = NO;
					break;
				
				case NSLeftMouseDragged:
				case NSRightMouseDragged:
				case NSOtherMouseDragged:
					newIsInside = [[self cell] hitTestForEvent: evt inRect: [self bounds] ofView: self] != NSCellHitNone;
					if( isInside != newIsInside )
					{
						isInside = newIsInside;

						if( autoHighlight )
							[[self cell] setHighlighted: isInside];
					}
					self->owningPart->SendMessage( NULL, [](const char* errMsg,size_t,size_t,CScriptableObject*) { if( errMsg ) CAlert::RunMessageAlert(errMsg); }, "mouseDrag %ld", [event buttonNumber] +1 );
					break;
			}
		}
		
		[pool release];
		pool = [[NSAutoreleasePool alloc] init];
	}
	
	if( isInside )
	{
		if( autoHighlight )
		{
			[[self cell] setHighlighted: NO];
			[self setNeedsDisplay: YES];
			[self.window display];
		}
		[[self target] performSelector: [self action] withObject: self];
		self->owningPart->SendMessage( NULL, [](const char* errMsg,size_t,size_t,CScriptableObject*) { if( errMsg ) CAlert::RunMessageAlert(errMsg); }, "mouseUp %ld", [event buttonNumber] +1 );
	}
	else
		self->owningPart->SendMessage( NULL, [](const char* errMsg,size_t,size_t,CScriptableObject*) { if( errMsg ) CAlert::RunMessageAlert(errMsg); }, "mouseUpOutside %ld", [event buttonNumber] +1 );
	
	[pool release];
}


-(void)	resetCursorRects
{
	NSCursor	*	currentCursor = nil;
	if( !currentCursor )
	{
		std::string	cursorURL = self->owningPart->GetDocument()->GetMediaURLByIDOfType( 128, EMediaTypeCursor );
		if( cursorURL.length() > 0 )
		{
			NSImage	*			cursorImage = [[[NSImage alloc] initByReferencingURL: [NSURL URLWithString: [NSString stringWithUTF8String: cursorURL.c_str()]]] autorelease];
			NSCursor *			cursorInstance = [[NSCursor alloc] initWithImage: cursorImage hotSpot: NSMakePoint(8,8)];
			currentCursor = cursorInstance;
		}
	}
	if( !currentCursor )
		currentCursor = [NSCursor arrowCursor];
	[self addCursorRect: [self bounds] cursor: currentCursor];
}


-(void)	windowDidChangeKeyOrMain: (NSNotification*)inNotif
{
	[self setNeedsDisplay: YES];
}


-(void)	viewDidMoveToWindow
{
	[super viewDidMoveToWindow];
	
	if( self.window )
	{
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidChangeKeyOrMain:) name: NSWindowDidBecomeKeyNotification object: self.window];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidChangeKeyOrMain:) name: NSWindowDidResignKeyNotification object: self.window];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidChangeKeyOrMain:) name: NSWindowDidBecomeMainNotification object: self.window];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowDidChangeKeyOrMain:) name: NSWindowDidResignMainNotification object: self.window];
	}
}


-(void)	viewWillMoveToWindow: (NSWindow *)newWindow
{
	if( self.window )
	{
		[[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowDidBecomeKeyNotification object: self.window];
		[[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowDidResignKeyNotification object: self.window];
		[[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowDidBecomeMainNotification object: self.window];
		[[NSNotificationCenter defaultCenter] removeObserver: self name: NSWindowDidResignMainNotification object: self.window];
	}
	
	[super viewWillMoveToWindow: newWindow];
}

@end