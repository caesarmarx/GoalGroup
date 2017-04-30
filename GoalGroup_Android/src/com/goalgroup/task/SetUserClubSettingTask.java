package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SetUserClubSettingHttp;
import com.goalgroup.ui.ManagerSettingsActivity;

public class SetUserClubSettingTask extends AsyncTask<Void, Void, Void> {
	private ManagerSettingsActivity parent;	
	private String value;
	private String club_id;
	private String user_id;
	
	private SetUserClubSettingHttp post;
	
	public SetUserClubSettingTask(ManagerSettingsActivity parent, String club_id, String user_id, String status) {
		this.parent = parent;
		this.value = status;
		this.club_id = club_id;
		this.user_id = user_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SetUserClubSettingHttp();
		post.setParams(club_id, user_id, value);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		boolean success = false;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			success = true;
		}
		
		parent.stopSettingStatus(success);
	}
}
