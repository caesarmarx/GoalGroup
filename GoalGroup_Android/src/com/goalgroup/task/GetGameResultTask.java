package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetGameResultHttp;
import com.goalgroup.ui.GameResultActivity;
import com.goalgroup.utils.StringUtil;

public class GetGameResultTask extends AsyncTask<Void, Void, Void> {
	private GameResultActivity parent;	
	private String club_id;
	private String game_id;
	
	private GetGameResultHttp post;
	
	public GetGameResultTask(GameResultActivity parent, String club_id, String game_id) {
		this.parent = parent;
		this.club_id = club_id;
		this.game_id = game_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetGameResultHttp();
		post.setParams(club_id, game_id);
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
		
		parent.stopGetResult(!StringUtil.isEmpty(data_result), data_result);
	}
}
