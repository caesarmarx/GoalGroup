package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.AcceptInvGameHttp;
import com.goalgroup.http.GetInvGameHttp;
import com.goalgroup.ui.InvGameActivity;

public class AcceptInvGameTask extends AsyncTask<Void, Void, Void> {
	private InvGameActivity parent;
	private int clubId;
	private int gameId;
	private int type;
	
	private AcceptInvGameHttp post;
	
	public AcceptInvGameTask(InvGameActivity parent, int clubId, int gameId, int type) {
		this.parent = parent;
		this.clubId = clubId;
		this.gameId = gameId;
		this.type = type;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new AcceptInvGameHttp();
		post.setParams(Integer.toString(clubId), Integer.toString(gameId), Integer.toString(type));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int success = 0;
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			success = post.isSuccess();
			data_result = post.getData();
		}
		
		parent.stopProcInvGame(success, data_result);
	}
}
