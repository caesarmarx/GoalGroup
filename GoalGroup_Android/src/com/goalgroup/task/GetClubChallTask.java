package com.goalgroup.task;

import java.util.ArrayList;

import android.os.AsyncTask;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.GetChallHttp;
import com.goalgroup.model.ClubChallengeItem;
import com.goalgroup.ui.ClubChallengesActivity;
import com.goalgroup.ui.adapter.ClubChallengeAdapter;
import com.goalgroup.utils.JSONUtil;

public class GetClubChallTask extends AsyncTask<Void, Void, Void> {
	
	private final int CHALL_UNIT_COUNT = 5;
	
	private ClubChallengesActivity parent;	
	private ClubChallengeAdapter adapter;
	private int type;
	private int startType;
	private int pagenum;
	private String clubIds;
	
	private GetChallHttp post;
	
	public GetClubChallTask(ClubChallengesActivity parent, ClubChallengeAdapter adapter, int type, int startType, String clubIds) {
		this.parent = parent;
		this.adapter = adapter;
		this.type = type;
		this.startType = startType;
		this.clubIds = clubIds;
	}
	
	@Override
	protected void onPreExecute() {
		super.onPreExecute();		
		pagenum = (adapter.getCount() / CHALL_UNIT_COUNT) + 1;
	}
	
	private String[] urls = {
		"GetRunningOrders", "GetPrestartOrders", "GetCompleteOrders", "GetDeletedOrders"
	};
	
	@Override
	protected Void doInBackground(Void... params) {
		post = new GetChallHttp();
		post.setParams(Integer.toString(pagenum), Integer.toString(type), clubIds, Integer.toString(startType));
		post.run();
		return null;
	}
	
	@Override
	protected void onPostExecute(Void result) {
		super.onPostExecute(result);
		
		if (post.getError() == GgHttpErrors.GET_CHALL_SUCCESS) {
			String data_result = post.getData();
			String[] model_values = JSONUtil.getArrays(data_result, "result");
			
			ArrayList<ClubChallengeItem> datas = new ArrayList<ClubChallengeItem>();
			for (int i = 0; i < model_values.length; i++) {
				ClubChallengeItem data = new ClubChallengeItem(
					JSONUtil.getValue(model_values[i], "challenge_id"),
					JSONUtil.getValue(model_values[i], "club_id_01"), 
					JSONUtil.getValue(model_values[i], "club_name_01"),
					JSONUtil.getValue(model_values[i], "mark_pic_url_01"), 
					JSONUtil.getValue(model_values[i], "club_id_02"), 
					JSONUtil.getValue(model_values[i], "club_name_02"),
					JSONUtil.getValue(model_values[i], "mark_pic_url_02"), 
					JSONUtil.getValue(model_values[i], "game_date"),
					JSONUtil.getValue(model_values[i], "game_weekday"), 
					JSONUtil.getValue(model_values[i], "game_time"), 
					JSONUtil.getValue(model_values[i], "stadium_area"), 
					JSONUtil.getValue(model_values[i], "stadium_address"),
					JSONUtil.getValue(model_values[i], "player_count"), 
					JSONUtil.getValue(model_values[i], "money_split"), 
					JSONUtil.getValue(model_values[i], "vs_status"),
					JSONUtil.getValue(model_values[i], "remain_time"));
				datas.add(data);
			}
			
			adapter.addData(datas);
		}
		
		parent.stopAttachChallenges(post.hasMore());
	}
}
