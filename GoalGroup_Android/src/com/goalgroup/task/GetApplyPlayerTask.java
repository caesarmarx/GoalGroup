package com.goalgroup.task;

import java.util.ArrayList;

import android.app.Activity;
import android.os.AsyncTask;
import android.widget.Adapter;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.constants.CommonConsts;
import com.goalgroup.http.GetApplyPlayerHttp;
import com.goalgroup.model.PlayerFilterResultItem;
import com.goalgroup.model.PlayerResultItem;
import com.goalgroup.ui.ApplyPlayerActivity;
import com.goalgroup.ui.GameDetailActivity;
import com.goalgroup.ui.adapter.ApplyPlayerAdapter;
import com.goalgroup.ui.adapter.PlayerResultAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetApplyPlayerTask extends AsyncTask<Void, Void, Void> {
	
	private final int PLAYER_UNIT_COUNT = 5;
	
	private GameDetailActivity parent;
	private PlayerResultAdapter adapter;
	
	private int pagenum;
	private int clubId;
	private int gameId;
	private int type;
	
	private GetApplyPlayerHttp post;
	
	public GetApplyPlayerTask(Activity parent, Adapter adapter, int clubId, int gameId, int type) {
		this.parent = (GameDetailActivity)parent;
		this.adapter = (PlayerResultAdapter)adapter;
			
		this.clubId = clubId;
		this.gameId = gameId;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();
		pagenum = (adapter.getCount() / PLAYER_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetApplyPlayerHttp();
		post.setParams(Integer.toString(clubId), Integer.toString(gameId), Integer.toString(pagenum));
		post.run();
		
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			ArrayList<PlayerResultItem> datas = new ArrayList<PlayerResultItem>();
			for (int i = 0; i < model_values.length; i++) {
				PlayerResultItem data = new PlayerResultItem(
						JSONUtil.getValueInt(model_values[i], "user_id"),
						JSONUtil.getValue(model_values[i], "photo_url"), 
						JSONUtil.getValue(model_values[i], "user_name"), 
						JSONUtil.getValueInt(model_values[i], "goal_point"), 
						JSONUtil.getValueInt(model_values[i], "assist"),
						JSONUtil.getValueInt(model_values[i], "point"));
				datas.add(data);
			}
			adapter.addData(datas);
		}
		parent.stopAttachPlayerList(post.hasMore());
	}
}
