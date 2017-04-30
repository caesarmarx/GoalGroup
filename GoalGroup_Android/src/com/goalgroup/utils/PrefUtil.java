package com.goalgroup.utils;

import android.content.SharedPreferences;

import com.goalgroup.GgApplication;
import com.goalgroup.constants.PrefConst;

public class PrefUtil {
	private static final String CHAT_LAST_TIME = "GoalGroup Chat Last Received Time";
	
	private SharedPreferences pref;
	private String lastChatTime = "";
	
	public PrefUtil() {
		pref = GgApplication.getInstance().getSharedPreferences(PrefConst.PREF_NAME, 0); 
	}
	
	public void setLastChatTime(String value) {
		if (!StringUtil.isEmpty(lastChatTime)) {
			if (lastChatTime.compareTo(value) >= 0)
				return;
		}
		
		if (pref != null) {
			SharedPreferences.Editor editor = pref.edit();
			editor.putString(CHAT_LAST_TIME, value);
			editor.commit();
		}
		
		lastChatTime = value;
	}
	
	public String getLastChatTime() {
		if (StringUtil.isEmpty(lastChatTime)) {
			lastChatTime = pref.getString(CHAT_LAST_TIME, "");
		}
		return lastChatTime;
	}
}
