package com.goalgroup.common;

import android.content.Context;
import android.content.Intent;

public class GgBroadCast {
	
	public static final String GOAL_GROUP_BROADCAST = "BroadCast of GoalGroup";
	
	public static final int MSG_UNREAD_MESSAGE = 0x0001;
	public static final int MSG_LOGIN_RESULT = 0x0002;
	public static final int MSG_LOGOUT_RESULT = 0x0003;
	public static final int MSG_AUDIO_UP_FINISH = 0x0004;
	
	private Context ctx;
	private Intent intent;
	
	public GgBroadCast(Context ctx) {
		this.ctx = ctx;
		
		intent = new Intent();
		intent.setAction(GOAL_GROUP_BROADCAST);
	}
	
	public Intent getIntent() {
		return intent;
	}
	
	public void send(int msg) {
		try {
			intent.putExtra("Message", msg);
			ctx.sendBroadcast(intent);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
