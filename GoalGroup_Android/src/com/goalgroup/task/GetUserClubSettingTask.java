package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetUserClubSettingHttp;
import com.goalgroup.ui.ManagerSettingsActivity;

public class GetUserClubSettingTask extends AsyncTask<Void, Void, Void> {
	private ManagerSettingsActivity parent;	
	private String club_id;
	private String user_id;
	
	private GetUserClubSettingHttp post;
	
	public GetUserClubSettingTask(ManagerSettingsActivity parent, String club_id, String user_id) {
		this.parent = parent;
		this.club_id = club_id;
		this.user_id = user_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetUserClubSettingHttp();
		post.setParams(club_id, user_id);
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
		
		parent.stopGetStatus(data_result);
	}
}
