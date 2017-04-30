package com.goalgroup.chat.component;


import org.json.JSONException;
import org.json.JSONObject;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;


public class ChatService extends Service implements ActivityMessageCallback {
	
	static final String TAG = ChatService.class.getSimpleName();


	@Override
	public void onCreate() {
		// TODO Auto-generated method stub
		super.onCreate();
	}

	@Override
	public void onDestroy() {
		// TODO Auto-generated method stub
		super.onDestroy();
	}

	@SuppressWarnings("deprecation")
	@Override
	public void onStart(Intent intent, int startId) {
		// TODO Auto-generated method stub
		ChatEngine.chatService = this;
		super.onStart(intent, startId);
	}

	@Override
	public void setUpdate(JSONObject json) {
		// TODO Auto-generated method stub
		try {
			if (json.getString("event").equals( ChatEngine.UPDATE_CHAT)) {
				if (json.getInt("success") == 1) {
				}
			}
		} catch (JSONException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
		}		
	}

	@Override
	public IBinder onBind(Intent intent) {
		// TODO Auto-generated method stub
		return null;
	}
	
}
