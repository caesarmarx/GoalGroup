package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.LeaveClubHttp;
import com.goalgroup.ui.ChatActivity;

public class LeaveClubTask extends AsyncTask<Void, Void, Void> {
	private ChatActivity parent;
	private String club_id;
	
	private LeaveClubHttp post;
	
	public LeaveClubTask(ChatActivity parent, String club_id) {
		this.parent = parent;
		this.club_id = club_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new LeaveClubHttp();
		post.setParams(club_id);
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
		
		parent.stopLeaveClub(data_result.equals("1"));
	}
}
