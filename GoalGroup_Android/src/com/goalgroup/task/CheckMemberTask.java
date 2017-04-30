package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.CheckMemberHttp;
import com.goalgroup.ui.adapter.PlayFilterResultAdapter;

public class CheckMemberTask extends AsyncTask<Void, Void, Void> {
	private PlayFilterResultAdapter parent;
	private int userId;
	private int clubId;
	private int gameId;
	
	private CheckMemberHttp post;
	
	public CheckMemberTask(PlayFilterResultAdapter parent, int userId, int clubId) {
		this.parent = parent;
		this.userId = userId;
		this.clubId = clubId;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new CheckMemberHttp();
		post.setParams(Integer.toString(userId), Integer.toString(clubId));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = GgHttpErrors.INVITE_GAME_FAIL;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopTempInv(data_result);
	}
}
