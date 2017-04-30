package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetPlayerHistoryHttp;
import com.goalgroup.model.PlayerHistoryItem;
import com.goalgroup.ui.PlayerHistoryActivity;
import com.goalgroup.ui.adapter.PlayerHistoryAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetPlayerHistoryTask extends AsyncTask<Void, Void, Void> {
	private PlayerHistoryActivity parent;
	private PlayerHistoryAdapter adapter;
	private String player_id;
	private int club_id;
	
	private GetPlayerHistoryHttp post;
	
	public GetPlayerHistoryTask(PlayerHistoryActivity parent, PlayerHistoryAdapter adapter, String player_id, int club_id) {
		this.parent = parent;
		this.adapter = adapter;
		this.player_id = player_id;
		this.club_id = club_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetPlayerHistoryHttp();
		post.setParams(player_id, club_id);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		String data_result = "";
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<PlayerHistoryItem> datas = new ArrayList<PlayerHistoryItem>();
			for (int i = 0; i < model_values.length; i++) {
				PlayerHistoryItem data = new PlayerHistoryItem(
					JSONUtil.getValue(model_values[i], "year"), 
					JSONUtil.getValue(model_values[i], "game_count"),
					JSONUtil.getValue(model_values[i], "goal_point"), 
					JSONUtil.getValue(model_values[i], "assist"), 
					JSONUtil.getValue(model_values[i], "point"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachPlayerHistory();
	}
}
