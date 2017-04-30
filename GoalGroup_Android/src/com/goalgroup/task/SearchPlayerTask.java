package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SearchPlayerHttp;
import com.goalgroup.model.PlayerFilterResultItem;
import com.goalgroup.ui.PlayerMarketActivity;
import com.goalgroup.ui.adapter.PlayFilterResultAdapter;
import com.goalgroup.utils.JSONUtil;

public class SearchPlayerTask extends AsyncTask<Void, Void, Void> {
	
	private final int PLAYER_SEARCH_UNIT_COUNT = 5;
	
	private PlayerMarketActivity parent;	
	private PlayFilterResultAdapter adapter;
	private int pagenum;
	
	private SearchPlayerHttp post;
	
	public SearchPlayerTask(PlayerMarketActivity parent, PlayFilterResultAdapter adapter) {
		this.parent = parent;
		this.adapter = adapter;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / PLAYER_SEARCH_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SearchPlayerHttp();
		post.setParams(Integer.toString(pagenum));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<PlayerFilterResultItem> datas = new ArrayList<PlayerFilterResultItem>();
			for (int i = 0; i < model_values.length; i++) {
				String edit_playArea = JSONUtil.getValue(model_values[i], "act_area");
				String[] selArea = edit_playArea.split(",");
				
				String[] districtNames = GgApplication.getInstance().getDistrictName(); 
				String[] districtIds = GgApplication.getInstance().getDistrictID();
				
				String areaValue = "";
				for (int k = 0, cnt = 0; k < ((districtNames == null ) ? 0 : districtNames.length); k++) {
					for (int j = 0; j < selArea.length; j++) {
						if (districtIds[k].equals(selArea[j])){
							if (cnt != 0)
								areaValue = areaValue.concat(", ");
							areaValue = areaValue.concat(districtNames[k]);
							cnt++;
							continue;
						}
					}
				}
				PlayerFilterResultItem data = new PlayerFilterResultItem(
					JSONUtil.getValueInt(model_values[i], "user_id"),
					JSONUtil.getValue(model_values[i], "user_icon"), 
					JSONUtil.getValue(model_values[i], "user_name"), 
					JSONUtil.getValue(model_values[i], "age"), 
					JSONUtil.getValue(model_values[i], "term"), 
					JSONUtil.getValue(model_values[i], "height"), 
					JSONUtil.getValue(model_values[i], "weight"), 
					JSONUtil.getValueInt(model_values[i], "position"), 
					JSONUtil.getValueInt(model_values[i], "act_time"), 
					areaValue);
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachPlayers(post.hasMore());
	}
}
