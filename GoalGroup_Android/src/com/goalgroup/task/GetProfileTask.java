package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetProfileHttp;
import com.goalgroup.ui.ProfileActivity;

import android.os.AsyncTask;

public class GetProfileTask extends AsyncTask<Void, Void, Void> {
	private ProfileActivity parent;
	private GetProfileHttp post;
	
	private int user_id;
	
	public GetProfileTask(ProfileActivity parent, int user_id) {
		this.parent = parent;
		this.user_id = user_id;
	}
	
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetProfileHttp();
		post.setParams(user_id);
		post.run();
		return null;
	}
	
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopAttachProfile(data_result);
	}

}
