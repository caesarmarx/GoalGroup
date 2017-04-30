package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.GgApplication;
import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class SetGameResultHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	
	public SetGameResultHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "set_game_result"));
		post_params.add(new BasicNameValuePair("club_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("game_id", (String)params[1]));
		post_params.add(new BasicNameValuePair("Fhalf_Goal1", (String)params[2]));
		post_params.add(new BasicNameValuePair("Fhalf_Goal2", (String)params[3]));
		post_params.add(new BasicNameValuePair("Shalf_Goal1", (String)params[4]));
		post_params.add(new BasicNameValuePair("Shalf_Goal2", (String)params[5]));
		post_params.add(new BasicNameValuePair("Match_Result", (String)params[6]));
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
	
	public String getData() {
		return datas;
	}
	
	public int getError() {
		return error;
	}
	
	private void checkResult() {
		datas = JSONUtil.getValue(result, "set_status");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}
}
