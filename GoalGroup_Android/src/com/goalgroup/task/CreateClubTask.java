package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.CreateClubHttp;
import com.goalgroup.ui.CreateClubActivity;

public class CreateClubTask extends AsyncTask<Void, Void, Void> {
	private CreateClubActivity parent;	
	
	private Object[] clubInfo;
	private CreateClubHttp post;
	
	public CreateClubTask(CreateClubActivity parent, Object[] params) {
		this.parent = parent;
		this.clubInfo = params;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new CreateClubHttp();
		post.setParams(clubInfo);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopCreateClub(data_result);
	}
}
