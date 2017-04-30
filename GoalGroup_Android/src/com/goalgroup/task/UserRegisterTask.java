package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.http.UserRegisterHttp;
import com.goalgroup.ui.UserRegistActivity;

public class UserRegisterTask extends AsyncTask<Void, Void, Void> {
	private UserRegistActivity parent;	
	
	private Object[] registerInfo;
	private UserRegisterHttp post;
	
	public UserRegisterTask(UserRegistActivity parent, Object[] params) {
		this.parent = parent;
		this.registerInfo = params;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new UserRegisterHttp();
		post.setParams(registerInfo);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		data_result = post.getData();
		
		if (data_result == null)
			data_result = "";
		parent.stopUserRegister(data_result);
	}
}
