package com.goalgroup.ui.view;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.widget.EditText;

public class xEditText extends EditText {

	public xEditText(Context context) {
		super(context);
	}

	public xEditText(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public void insertDrawable(int id, int w, int h) {
		String str = "╬" + id + "╬";
		final SpannableString ss = new SpannableString(str);
		Drawable d = getResources().getDrawable(id);
		d.setBounds(0, 0, w, h);
		ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BOTTOM);
		ss.setSpan(span, 0, str.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
		Editable e = this.getText();
		e.insert(this.getSelectionStart(), ss);
	}
	
//	public void insertBitmap(String file_name){
//
//		final SpannableString ss = new SpannableString("easy");
//		Bitmap bm = BitmapFactory.decodeFile(ChatGlobal.PHOTO_BASE_URL + file_name);
//		
//		@SuppressWarnings("deprecation")
//		ImageSpan span1 = new ImageSpan(bm);
//		ss.setSpan(span1, 0, "easy".length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
//
//		Editable e = this.getText();
//		e.insert(0, ss);
//		
//	}
	
	public void clearContents() {
		this.setText("");
	}

	public void removeLastCharacter() {
		if (!this.getText().toString().equals("")) {
			Editable e = this.getText();
			int index;
			int len = this.length();
			if (e.charAt(len - 1) == '╬') {
				for (index = len - 2; e.charAt(index) != '╬'; index--)
					;
				e.delete(index, len);
			} else {
				e.delete(this.getText().length() - 1, this.getText().length());
			}
			// Toast.makeText(getContext(), this.getText().toString(),
			// Toast.LENGTH_LONG).show();
		}
	}
}
