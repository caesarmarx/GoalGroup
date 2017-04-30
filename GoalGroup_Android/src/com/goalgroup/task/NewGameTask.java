package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.NewGameHttp;
import com.goalgroup.ui.NewChallengeActivity;

public class NewGameTask extends AsyncTask<Void, Void, Void> {
	private NewChallengeActivity parent;	
	
	private Object[] gameInfo;
	private NewGameHttp post;
	
	public NewGameTask(NewChallengeActivity parent, Object[] params) {
		this.parent = parent;
		this.gameInfo = params;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new NewGameHttp();
		post.setParams(gameInfo);
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
		
		parent.stopSendChallenge(data_result);
	}
}
