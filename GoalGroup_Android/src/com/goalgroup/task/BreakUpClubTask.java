package com.goalgroup.task;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.BreakUpClubHttp;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.ui.CreateClubActivity;

import android.os.AsyncTask;

public class BreakUpClubTask extends AsyncTask<Void, Void, Void> {
	private ChatActivity parent;
	private Object[] param;
	private BreakUpClubHttp post;
	
	public BreakUpClubTask(ChatActivity parent, Object params[]) {
		this.parent = parent;
		this.param = params;
	}

	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... arg0) {
		post = new BreakUpClubHttp();
		post.setParams(param);
		post.run();
		return null;
	}

	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
		}
		
		parent.stopBreakUpClub(data_result);
	}
}
