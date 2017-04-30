package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.CancelGameHttp;
import com.goalgroup.http.LeaveClubHttp;
import com.goalgroup.ui.ChatActivity;
import com.goalgroup.utils.JSONUtil;

public class CancelGameTask extends AsyncTask<Void, Void, Void> {
	private ChatActivity parent;
	private String club_id;
	private String game_id;
	private String exitCause;
	private String exitType;
	
	private CancelGameHttp post;
	
	public CancelGameTask(ChatActivity parent, String club_id, String game_id, String exitCause, String exitType) {
		this.parent = parent;
		this.club_id = club_id;
		this.game_id = game_id;
		this.exitCause = exitCause;
		this.exitType = exitType;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new CancelGameHttp();
		post.setParams(club_id, game_id, exitCause, exitType);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		int data_result = 0;
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = JSONUtil.getValueInt(post.getData(), "success");
		}
		
		parent.stopCancelGame(data_result);
	}
}
