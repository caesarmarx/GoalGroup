package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.RegisterUserToClubHttp;
import com.goalgroup.ui.ClubInfoActivity;
import com.goalgroup.ui.adapter.ClubFilterResultAdapter;

import android.os.AsyncTask;

public class RegisterUserToClubTask extends AsyncTask<Void, Void, Void> {
	private ClubInfoActivity parent;
	private ClubFilterResultAdapter adapter;
	private Object[] registerInfo;
	private RegisterUserToClubHttp post;
	
	public RegisterUserToClubTask(ClubFilterResultAdapter adapter, Object params[]) {
		this.adapter = adapter;
		this.registerInfo = params;
	}
	
	public RegisterUserToClubTask(ClubInfoActivity parent, Object params[]) {
		this.parent = parent;
		this.registerInfo = params;
	}

	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new RegisterUserToClubHttp();
		post.setParams(registerInfo);
		post.run();
		return null;
	}

	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		if (parent == null)
			adapter.stopRegisterUserToClub(data_result);
		else
			parent.stopRegisterUserToClub(data_result);
	}
}
