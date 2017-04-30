package com.goalgroup.task;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.LogOutHttp;
import com.goalgroup.ui.SettingsActivity;

import android.os.AsyncTask;

public class LogOutTask extends AsyncTask<Void, Void, Void> {
	private SettingsActivity parent;
	private LogOutHttp post;
	
	private int user_id;
	private Object[] param;

	public LogOutTask(SettingsActivity parent){
		this.parent = parent;
		this.user_id = Integer.valueOf(GgApplication.getInstance().getUserId());
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new LogOutHttp();
		param = new Object[1];
		param[0] = user_id;
		post.setParams(param);
		post.run();
		return null;
	}

	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopLogOut();
	}
}
