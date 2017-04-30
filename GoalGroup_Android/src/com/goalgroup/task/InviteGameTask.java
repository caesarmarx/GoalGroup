package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.InviteGameHttp;
import com.goalgroup.ui.PlayerMarketActivity;

public class InviteGameTask extends AsyncTask<Void, Void, Void> {
	private PlayerMarketActivity parent;
	private int userId;
	private int clubId;
	private int gameId;
	
	private InviteGameHttp post;
	
	public InviteGameTask(PlayerMarketActivity parent, int userId, int clubId, int gameId) {
		this.parent = parent;
		this.userId = userId;
		this.clubId = clubId;
		this.gameId = gameId;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new InviteGameHttp();
		post.setParams(Integer.toString(userId), Integer.toString(clubId), Integer.toString(gameId));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = GgHttpErrors.INVITE_GAME_FAIL;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getRetCode();
		}
		
		parent.stopInviteGame(data_result);
	}
}
