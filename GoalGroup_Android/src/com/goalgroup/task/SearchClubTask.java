package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.SearchClubHttp;
import com.goalgroup.model.ClubFilterResultItem;
import com.goalgroup.ui.ClubMarketActivity;
import com.goalgroup.ui.adapter.ClubFilterResultAdapter;
import com.goalgroup.utils.JSONUtil;

public class SearchClubTask extends AsyncTask<Void, Void, Void> {
	
	private final int CLUB_SEARCH_UNIT_COUNT = 5;
	
	private ClubMarketActivity parent;	
	private ClubFilterResultAdapter adapter;
	private int pagenum;
	
	private SearchClubHttp post;
	
	public SearchClubTask(ClubMarketActivity parent, ClubFilterResultAdapter adapter) {
		this.parent = parent;
		this.adapter = adapter;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / CLUB_SEARCH_UNIT_COUNT) + 1;
	}
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new SearchClubHttp();
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
		
		parent.stopAttachClubs(post.hasMore());
	}
}