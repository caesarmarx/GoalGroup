package com.goalgroup.task;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetGameResultHttp;
import com.goalgroup.http.SetGameResultHttp;
import com.goalgroup.ui.GameResultActivity;
import com.goalgroup.utils.StringUtil;

public class SetGameResultTask extends AsyncTask<Void, Void, Void> {
	private GameResultActivity parent;	
	private String club_id;
	private String game_id;
	private String result_11;
	private String result_12;
	private String result_21;
	private String result_22;
	private String matchResult;
	
	private SetGameResultHttp post;
	
	public SetGameResultTask(GameResultActivity parent, String club_id, String game_id, 
			String result_11, String result_12, String result_21, String result_22, String matchResult) {
		this.parent = parent;
		this.club_id = club_id;
		this.game_id = game_id;
		
		this.result_11 = result_11;
		this.result_12 = result_12;
		this.result_21 = result_21;
		this.result_22 = result_22;
		
		this.matchResult = matchResult;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SetGameResultHttp();
		post.setParams(club_id, game_id, result_11, result_12, result_21, result_22, matchResult);
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
		
		parent.stopSetResult(Integer.valueOf(data_result));
	}
}
