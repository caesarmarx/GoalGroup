package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetUserIDHttp;
import com.goalgroup.ui.ChatActivity;

public class GetUserIDTask extends AsyncTask<Void, Void, Void> {
	private ChatActivity parent;
	private String user_name;
	
	private GetUserIDHttp post;
	
	public GetUserIDTask(ChatActivity parent, String user_name) {
		this.parent = parent;
		this.user_name = user_name;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetUserIDHttp();
		post.setParams(user_name);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopGetUserID(data_result);
	}
}
