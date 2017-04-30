package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SearchClubHttp;
import com.goalgroup.http.SearchClubListHttp;
import com.goalgroup.model.ClubFilterResultItem;
import com.goalgroup.ui.ClubMarketActivity;
import com.goalgroup.ui.adapter.ClubFilterResultAdapter;
import com.goalgroup.ui.adapter.ClubListAdapter;
import com.goalgroup.utils.JSONUtil;

public class SearchClubListTask extends AsyncTask<Void, Void, Void> {
	
	private final int CLUB_SEARCH_UNIT_COUNT = 5;
	
	private ClubMarketActivity parent;	
	private ClubFilterResultAdapter adapter;
	private SearchClubListHttp post;
	private int pagenum;
	
	private Object[] param = new Object[5];
	
	public SearchClubListTask(ClubMarketActivity parent, ClubFilterResultAdapter adapter, Object[] param) {
		this.parent = parent;
		this.adapter = adapter;
		for (int i = 0; i < 4; i++)
			this.param[i] = param[i];
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / CLUB_SEARCH_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SearchClubListHttp();
		param[4] = pagenum;
		post.setParams(param);
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.HTTP_POST_SUCCESS) {
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<ClubFilterResultItem> datas = new ArrayList<ClubFilterResultItem>();
			for (int i = 0; i < model_values.length; i++) {
				String edit_playArea = JSONUtil.getValue(model_values[i], "act_area");
				String[] selArea = edit_playArea.split(",");
				
				String[] districtNames = GgApplication.getInstance().getDistrictName(); 
				String[] districtIds = GgApplication.getInstance().getDistrictID();
				
				String areaValue = "";
				for (int k = 0, cnt = 0; k < districtNames.length; k++) {
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
				ClubFilterResultItem data = new ClubFilterResultItem(
					JSONUtil.getValueInt(model_values[i], "club_id"),
					JSONUtil.getValue(model_values[i], "mark_pic_url"), 
					JSONUtil.getValue(model_values[i], "club_name"), 
					JSONUtil.getValueInt(model_values[i], "player_count"), 
					JSONUtil.getValueInt(model_values[i], "point"), 
					JSONUtil.getValueInt(model_values[i], "average_age"), 
					JSONUtil.getValueInt(model_values[i], "act_time"), 
					areaValue);
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopSearchClubList(post.hasMore());
	}
}