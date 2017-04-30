package com.goalgroup.chat.component;


import org.json.JSONObject;

import android.app.NotificationManager;
import android.app.ProgressDialog;
import android.support.v4.app.FragmentActivity;

import com.goalgroup.GgApplication;


public class ChatBaseActivity extends FragmentActivity implements ActivityMessageCallback {

	public ProgressDialog progressDialog = null;
	public String err_msg;

	@Override
	protected void onStart() {
		// TODO Auto-generated method stub
		ChatEngine.setRunningActivity(this);
		
		NotificationManager manager = GgApplication.getInstance().getChatEngine().getNotificationManager();
		manager.cancel(0);
		
		
		super.onStart();
	}

	@Override
	public void setUpdate(JSONObject json) {
		// TODO Auto-generated method stub
	}
	
	public void prsDlgDismiss(){
		if (progressDialog != null)
			if (progressDialog.isShowing()) {
				progressDialog.dismiss();			
			}
	}
	
	@Override
	public void onUserLeaveHint() {
		super.onUserLeaveHint();
	}
	
	public void showCount() {		
	}

}