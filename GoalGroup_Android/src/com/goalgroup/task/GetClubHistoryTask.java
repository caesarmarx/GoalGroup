package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetClubHistoryHttp;
import com.goalgroup.model.ClubHistoryItem;
import com.goalgroup.ui.ClubHistoryActivity;
import com.goalgroup.ui.adapter.ClubHistoryAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetClubHistoryTask extends AsyncTask<Void, Void, Void> {
	private ClubHistoryActivity parent;
	private ClubHistoryAdapter adapter;
	private String club_id;
	
	private GetClubHistoryHttp post;
	
	public GetClubHistoryTask(ClubHistoryActivity parent, ClubHistoryAdapter adapter, String club_id) {
		this.parent = parent;
		this.adapter = adapter;
		this.club_id = club_id;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetClubHistoryHttp();
		post.setParams(club_id);
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
			
			ArrayList<ClubHistoryItem> datas = new ArrayList<ClubHistoryItem>();
			for (int i = 0; i < model_values.length; i++) {
				ClubHistoryItem data = new ClubHistoryItem(
					JSONUtil.getValue(model_values[i], "year"), 
					JSONUtil.getValue(model_values[i], "all_game"),
					JSONUtil.getValue(model_values[i], "victor_game"), 
					JSONUtil.getValue(model_values[i], "draw_game"), 
					JSONUtil.getValue(model_values[i], "lose_game"),
					JSONUtil.getValue(model_values[i], "goal_point"), 
					JSONUtil.getValue(model_values[i], "miss_point"),
					JSONUtil.getValue(model_values[i], "ga_point"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachClubHistory();
	}
}
