//
//  CPaintEngineRoundRectTool.cpp
//  Stacksmith
//
//  Created by Uli Kusterer on 14.04.17.
//  Copyright © 2017 Uli Kusterer. All rights reserved.
//

#include "CPaintEngineRoundRectTool.h"


using namespace Carlson;


void	CPaintEngineRoundRectTool::MouseDownAtPoint( CPoint pos )
{
	mPaintEngine->GetTemporaryCanvas()->BeginDrawing();
	
		mStartPosition = pos;
		CRect	box( CRect::RectAroundPoints( mStartPosition, pos ) );
		if( mPaintEngine->GetGraphicsState().GetFillColor().GetAlpha() > 0 )
		{
			mPaintEngine->GetTemporaryCanvas()->FillRoundRect( box, mCornerRadius, mPaintEngine->GetGraphicsState() );
		}
		if( mPaintEngine->GetGraphicsState().GetLineThickness() > 0 )
		{
			mPaintEngine->GetTemporaryCanvas()->StrokeRoundRect( box, mCornerRadius, mPaintEngine->GetGraphicsState() );
		}
		mLastTrackingRectangle = box;
		mLastTrackingRectangle.Inset( -ceilf(mPaintEngine->GetGraphicsState().GetLineThickness() / 2.0) -1, -ceilf(mPaintEngine->GetGraphicsState().GetLineThickness() / 2.0) -1 );	// Line width, plus oval might draw anti-aliasing a tad outside the rectangle.
	
	mPaintEngine->GetTemporaryCanvas()->EndDrawing();
}


void	CPaintEngineRoundRectTool::MouseDraggedToPoint( CPoint pos )
{
	mPaintEngine->GetTemporaryCanvas()->BeginDrawing();
	
		mPaintEngine->GetTemporaryCanvas()->ClearRect( mLastTrackingRectangle );
		
		CRect	box( CRect::RectAroundPoints( mStartPosition, pos ) );
		if( mPaintEngine->GetGraphicsState().GetFillColor().GetAlpha() > 0 )
		{
			mPaintEngine->GetTemporaryCanvas()->FillRoundRect( box, mCornerRadius, mPaintEngine->GetGraphicsState() );
		}
		if( mPaintEngine->GetGraphicsState().GetLineThickness() > 0 )
		{
			mPaintEngine->GetTemporaryCanvas()->StrokeRoundRect( box, mCornerRadius, mPaintEngine->GetGraphicsState() );
		}
		mLastTrackingRectangle = box;
		mLastTrackingRectangle.Inset( -ceilf(mPaintEngine->GetGraphicsState().GetLineThickness() / 2.0) -1, -ceilf(mPaintEngine->GetGraphicsState().GetLineThickness() / 2.0) -1 );	// Line width, plus oval might draw anti-aliasing a tad outside the rectangle.

	mPaintEngine->GetTemporaryCanvas()->EndDrawing();
}


void	CPaintEngineRoundRectTool::MouseReleasedAtPoint( CPoint pos )
{
	mPaintEngine->GetTemporaryCanvas()->BeginDrawing();
	
		mPaintEngine->GetTemporaryCanvas()->ClearRect( mLastTrackingRectangle );

	mPaintEngine->GetTemporaryCanvas()->EndDrawing();

	mPaintEngine->GetCanvas()->BeginDrawing();
	
		CRect	box( CRect::RectAroundPoints( mStartPosition, pos ) );
	
		if( mPaintEngine->GetGraphicsState().GetFillColor().GetAlpha() > 0 )
		{
			mPaintEngine->GetCanvas()->FillRoundRect( box, mCornerRadius, mPaintEngine->GetGraphicsState() );
		}
		if( mPaintEngine->GetGraphicsState().GetLineThickness() > 0 )
		{
			mPaintEngine->GetCanvas()->StrokeRoundRect( box, mCornerRadius, mPaintEngine->GetGraphicsState() );
		}

	mPaintEngine->GetCanvas()->EndDrawing();
}
