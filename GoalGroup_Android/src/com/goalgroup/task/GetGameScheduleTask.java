package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetGameScheduleHttp;
import com.goalgroup.model.ScheduleItem;
import com.goalgroup.ui.GameScheduleActivity;
import com.goalgroup.ui.adapter.GameScheduleAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetGameScheduleTask extends AsyncTask<Void, Void, Void> {
	
	private final int SCHEDULE_UNIT_COUNT = 5;
	
	private GameScheduleActivity parent;	
	private GameScheduleAdapter adapter;
	private int clubId;
	private int fromType;
	private int pagenum;
	
	private GetGameScheduleHttp post;
	
	public GetGameScheduleTask(GameScheduleActivity parent, GameScheduleAdapter adapter, int clubId, int fromType) {
		this.parent = parent;
		this.adapter = adapter;
		this.clubId = clubId;
		this.fromType = fromType;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / SCHEDULE_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetGameScheduleHttp();
		post.setParams(Integer.toString(clubId), Integer.toString(fromType), Integer.toString(pagenum));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<ScheduleItem> datas = new ArrayList<ScheduleItem>();
			for (int i = 0; i < model_values.length; i++) {
				ScheduleItem data = new ScheduleItem(
					JSONUtil.getValueInt(model_values[i], "game_list_id"),
					JSONUtil.getValue(model_values[i], "game_date"),
					JSONUtil.getValue(model_values[i], "game_time"),
					JSONUtil.getValue(model_values[i], "game_wday"),
					JSONUtil.getValue(model_values[i], "home_pic"),
					JSONUtil.getValue(model_values[i], "home_name"), 
					JSONUtil.getValue(model_values[i], "home_id"), 
					JSONUtil.getValueInt(model_values[i], "home_playercount"),
					JSONUtil.getValue(model_values[i], "away_pic"),
					JSONUtil.getValue(model_values[i], "away_name"), 
					JSONUtil.getValue(model_values[i], "away_id"), 
					JSONUtil.getValueInt(model_values[i], "away_playercount"), 
					JSONUtil.getValueInt(model_values[i], "player_num_mode"),
					JSONUtil.getValue(model_values[i], "stadium_area"),
					JSONUtil.getValue(model_values[i], "stadium_address"),
					JSONUtil.getValue(model_values[i], "game_result"), 				
					true, 
					JSONUtil.getValue(model_values[i], "remain_time"),
					JSONUtil.getValueInt(model_values[i], "game_type"),
					JSONUtil.getValueInt(model_values[i], "vs_status"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachSchedule(post.hasMore());
	}
}
