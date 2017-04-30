package com.goalgroup.ui.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.TextView;

import com.goalgroup.R;
import com.goalgroup.constants.ChatConsts;
import com.goalgroup.ui.chat.EmoteUtil;
import com.goalgroup.utils.FileUtil;

public class xTextView extends TextView {

	public xTextView(Context context) {
		super(context);
	}

	public xTextView(Context context, AttributeSet attrs) {
		super(context, attrs);
	}

	public void setMessage(String msg, int msg_type) {
		if (msg_type == ChatConsts.MSG_TEXT) {
			EmoteUtil.setEmoteText(this, msg);
		} else if (msg_type == ChatConsts.MSG_IMAGE) {

			this.setText("");

			final SpannableString ss = new SpannableString(msg);
			Bitmap bm;
			if(msg.startsWith("http"))
				bm = BitmapFactory.decodeFile(msg);
			else
				bm = BitmapFactory.decodeFile(FileUtil.getFullPath(msg));
			Log.v("JHG", FileUtil.getFullPath(msg));
			
			if (null != bm) {
				ImageSpan span = new ImageSpan(bm, ImageSpan.ALIGN_BOTTOM);
				
				int xm,ym, width, height;
				width = bm.getWidth();
				height = bm.getHeight();
				xm = 24;
				ym = width != 0 ? (int)((height * xm) / width) : 0;
				span.getDrawable().setBounds(0,0,xm,ym);
				
				ss.setSpan(span, 0, msg.length(),
						Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
			}

			this.append(ss);

		} else if (msg_type == ChatConsts.MSG_AUDIO) {

			this.setText("");

			final SpannableString ss = new SpannableString(msg);
			Drawable d = getResources().getDrawable(R.drawable.voice_mail_mark);
			d.setBounds(0, 0, 20, 20);
			ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BOTTOM);
			ss.setSpan(span, 0, msg.length(),
					Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
			this.append(ss);
		}

	}
}
