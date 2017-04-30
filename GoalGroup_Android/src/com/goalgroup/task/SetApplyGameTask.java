package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.ApplyGameHttp;
import com.goalgroup.ui.GameScheduleActivity;

public class SetApplyGameTask extends AsyncTask<Void, Void, Void> {
	private GameScheduleActivity parent;
	private int clubId;
	private int gameId;
	private int userId;
	
	private ApplyGameHttp post;
	
	public SetApplyGameTask(GameScheduleActivity parent, int clubId, int gameId, int userId) {
		this.parent = parent;
		this.clubId = clubId;
		this.gameId = gameId;
		this.userId = userId;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new ApplyGameHttp();
		post.setParams(Integer.toString(userId), Integer.toString(clubId), Integer.toString(gameId));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int success = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			success = post.isSuccess();
		}
		
		parent.stopApplyGame(success);
	}
}
