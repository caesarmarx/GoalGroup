package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class NewGameHttp extends GoalGroupHttpPost {
	
	private int error;
	private int datas;
	
	public NewGameHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "game_create"));
		post_params.add(new BasicNameValuePair("club_id", String.valueOf(params[0])));
		post_params.add(new BasicNameValuePair("game_date", (String)params[1]));
		post_params.add(new BasicNameValuePair("game_time", (String)params[2]));
		post_params.add(new BasicNameValuePair("player_count", (String)params[3]));
		post_params.add(new BasicNameValuePair("stadium_area", (String)params[4]));
		post_params.add(new BasicNameValuePair("stadium_address", (String)params[5]));
		post_params.add(new BasicNameValuePair("money_split", (String)params[6]));
		post_params.add(new BasicNameValuePair("req_club_name", (String)params[7]));
	}

	@Override
	public boolean run() {
		try {
			postExecute();
			getResult();
			checkResult();
		} catch (Exception e) {
			e.printStackTrace();
			return false;
		}
		
		return true;
	}
	
	public int getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValueInt(result, "create_status");
		if (datas == 1) {
			error = GgHttpErrors.SEND_CHALL_SUCCESS;
		}
		
		return;
	}
}
