package com.goalgroup.http;

import org.apache.http.message.BasicNameValuePair;

import com.goalgroup.common.GgHttpErrors;
import com.goalgroup.http.base.GoalGroupHttpPost;
import com.goalgroup.utils.JSONUtil;
import com.goalgroup.utils.StringUtil;

public class CancelGameHttp extends GoalGroupHttpPost {
	
	private int error;
	private String datas;
	
	public CancelGameHttp() {
		super();		
		error = GgHttpErrors.HTTP_POST_FAIL;
	}
	
	@Override
	public void setParams(Object... params) {
		post_params.add(new BasicNameValuePair("cmd", "game_resign"));
		post_params.add(new BasicNameValuePair("resign_club_id", (String)params[0]));
		post_params.add(new BasicNameValuePair("resign_game_id", (String)params[1]));
		post_params.add(new BasicNameValuePair("resign_cause", (String)params[2]));
		post_params.add(new BasicNameValuePair("resign_type", (String)params[3]));
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
		datas = JSONUtil.getValue(result, "data");
		if (!StringUtil.isEmpty(datas)) {
			error = GgHttpErrors.HTTP_POST_SUCCESS;
		}
		
		return;
	}
}
