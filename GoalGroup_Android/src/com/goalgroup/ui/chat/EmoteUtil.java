package com.goalgroup.ui.chat;

import com.goalgroup.GgApplication;
import com.goalgroup.R;

import android.graphics.drawable.Drawable;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ImageSpan;
import android.widget.TextView;

public class EmoteUtil {
	
	public static Integer[] emoImageIDs = {
		R.drawable.emoticon1,R.drawable.emoticon2,R.drawable.emoticon3,R.drawable.emoticon4,
		R.drawable.emoticon5,R.drawable.emoticon6,R.drawable.emoticon7,R.drawable.emoticon8,
		R.drawable.emoticon9,R.drawable.emoticon10,R.drawable.emoticon11,R.drawable.emoticon12,
		R.drawable.emoticon13,R.drawable.emoticon14,R.drawable.emoticon15,R.drawable.emoticon16,
		R.drawable.emoticon17,R.drawable.emoticon18,R.drawable.emoticon19,R.drawable.emoticon20,
		R.drawable.emoticon21,R.drawable.emoticon22,R.drawable.emoticon23,R.drawable.emoticon24,
		R.drawable.del_emoticon
	};
	
	public static String[] emoArgs = {
		"`A`", "`B`", "`C`", "`D`", "`E`", "`F`", "`G`", "`H`", 
		"`I`", "`J`", "`K`", "`L`", "`M`", "`N`", "`O`", "`P`",
		"`Q`", "`R`", "`S`", "`T`", "`U`", "`V`", "`W`", "`X`"
	};

	
	public static void setEmoteText(TextView tv, String msg) {
		tv.setText("");
		int len = msg.length();
		for (int i = 0; i < len; i++) {
			if (msg.charAt(i) == '╬') {
				int next = msg.indexOf("╬", i + 1);
				String idstr = msg.substring(i + 1, next);
				int id = Integer.parseInt(idstr);
				final SpannableString ss = new SpannableString("easy");
				Drawable d = GgApplication.getInstance().getResources().getDrawable(id);
				d.setBounds(0, 0, 20, 20);
				ImageSpan span = new ImageSpan(d, ImageSpan.ALIGN_BASELINE);
				ss.setSpan(span, 0, "easy".length(),
						Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
				tv.append(ss);
				i = next;
			} else {
				tv.append(String.valueOf(msg.charAt(i)));
			}
		}
	}
}
