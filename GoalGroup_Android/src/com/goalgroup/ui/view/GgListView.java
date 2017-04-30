package com.goalgroup.ui.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.GestureDetector;
import android.view.MotionEvent;
import android.view.View;

public class GgListView extends XListView {

    private GestureDetector mGestureDetector;
    View.OnTouchListener mGestureListener;
    public View bannerView;

    public GgListView(Context context, AttributeSet attrs) {
        super(context, attrs);
        setFadingEdgeLength(0);
    }

    @Override
    public boolean onInterceptTouchEvent(MotionEvent ev) {    	
    	mGestureDetector = new GestureDetector(new YScrollDetector());
        return super.onInterceptTouchEvent(ev) && mGestureDetector.onTouchEvent(ev);
    }

    class YScrollDetector extends GestureDetector.SimpleOnGestureListener {
        @Override
        public boolean onScroll(MotionEvent e1, MotionEvent e2, float distanceX, float distanceY) {

            if(distanceY != 0 && distanceX != 0) {
            }

//            if (null != bannerView) {
//                Rect rect = new Rect();
//                bannerView.getHitRect(rect);
//
//                if (null != e1) {
//                    if(rect.contains((int)e1.getX(),(int)e1.getY())) {
//                        return false;
//                    }
//                }
//
//                if (null != e2) {
//                    if(rect.contains((int)e2.getX(),(int)e2.getY())) {
//                        return false;
//                    }
//                }
//            }
            
            return true;
        }
    }

}
