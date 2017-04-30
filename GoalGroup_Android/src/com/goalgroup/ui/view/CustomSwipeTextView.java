package com.goalgroup.ui.view;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.widget.TextView;

/**
 * 
 * @author OYC
 * @date 2015-03-18
 * 
 */

public class CustomSwipeTextView extends TextView {

	public CustomSwipeTextView(Context context) {
		super(context);
	}

	public CustomSwipeTextView(Context context, AttributeSet attr) {
		super(context, attr);
	}

	public void insertDrawable(int id, int w, int h) {

		final SpannableString ss = new SpannableString("easy");
		Drawable d = getResources().getDrawable(id);
		d.setBounds(0, 0, w, h);
		ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BOTTOM);
		ss.setSpan(span, 0, "easy".length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
		append(ss);
	}
}
